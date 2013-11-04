package com.snsapp.starling.texture
{
	import com.qzone.qfa.interfaces.IApplication;
	import com.qzone.qfa.managers.resource.ResourceLoader;
	import com.qzone.qfa.utils.CommonUtil;
	import com.qzone.utils.BitmapDataUtil;
	import com.snsapp.mobile.mananger.workflow.IWork;
	import com.snsapp.mobile.mananger.workflow.WorkFlowEvent;
	import com.snsapp.mobile.mananger.workflow.Workflow;
	import com.snsapp.mobile.view.bitmapclip.BitmapClipData;
	import com.snsapp.mobile.view.bitmapclip.BitmapClipDataWorker;
	import com.snsapp.mobile.view.bitmapclip.BitmapFrame;
	import com.snsapp.mobile.view.bitmapclip.vo.DrawSetting;
	import com.snsapp.mobile.view.spritesheet.SpriteSheet;
	import com.snsapp.mobile.view.spritesheet.SpriteSheetLoadWorker;
	import com.snsapp.starling.display.textfield.StarlingTextFieldTexture;
	import com.snsapp.starling.texture.implement.BatchTexture;
	import com.snsapp.starling.texture.implement.TextureBase;
	import com.snsapp.starling.texture.worker.ComputeTextureLevelScalesWorker;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.PNGEncoderOptions;
	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.System;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;

	public class CacheableTexture extends EventDispatcher implements IWork
	{
		/**
		 * 主场景材质。
		 * */
		protected var _mainTexture:BatchTexture;
		protected var _mainTextureName:String;
		protected var _quality:Number;
		private var _buildMainTextureWorkFlow:Workflow;

		/**
		 * 当前的材质等级
		 * **/
		protected var _texture_level:int;
		protected var _texture_level_scales:Vector.<Number>;
		protected var _texture_level_sizes:Vector.<Point>;
		protected var _computeTextureLevelScales:Boolean = false;
		protected var _subRects:Vector.<Point>;
		protected var _staticSubRects:Vector.<Point>; //不能缩放的矩形块
		protected var _exportPNG:Boolean = false;
		protected var _debugTextureLevel:int = -1;
		protected var _app:IApplication;
		protected var _clientParams:ClientTextureParams;
		protected var _name:String;
		protected var _resLoader:Loader;

		public function CacheableTexture(app:IApplication, name:String)
		{
			_app = app;
			_name = name;
			super(null);
		}

		public function setup(clientParams:ClientTextureParams, onComplete:Function):void
		{
			initliazeWithClientParams(clientParams);
			addEventListener(Event.COMPLETE, setupComplete);
			addEventListener(ErrorEvent.ERROR, setupComplete);
			start();

			function setupComplete(e:Event):void
			{
				trace(_mainTextureName + " setup", e.type);
				removeEventListener(Event.COMPLETE, setupComplete);
				removeEventListener(ErrorEvent.ERROR, setupComplete);
				if (e.type == Event.COMPLETE)
					onComplete(true);
				else if (e.type == ErrorEvent.ERROR)
					onComplete(false)
			}
		}

		public function start():void
		{
			if (_clientParams == null)
			{
				throw new Error('请先调用initliazeWithClientParams先！！');
				return;
			}

			var file:File = new File(ResourceLoader.VERSION_DICT + _mainTextureName);
			if (file.exists)
			{
				var fs:FileStream = new FileStream();
				fs.openAsync(file, FileMode.READ);
				fs.addEventListener(Event.COMPLETE, onReadComplete);
				fs.addEventListener(ProgressEvent.PROGRESS, onReadComplete);
				fs.addEventListener(IOErrorEvent.IO_ERROR, onReadError);
				var ba:ByteArray = new ByteArray();
				function onReadComplete(e:Event):void
				{
					if (e.type == Event.COMPLETE)
					{
						try
						{
							/**
							 * 这里瞬间会new 3个 16mb....
							 * 在内存吃紧的设备上，完全hold不住啊
							 * **/
							System.gc();
							_mainTexture = BatchTexture.fromByteArray(ba, _mainTextureName);
							ba.clear(), ba = null;
							System.gc();
							_mainTexture.upload();
						}
						catch (error:Error)
						{
							onReadError(null);
							return;
						}

						fs.removeEventListener(Event.COMPLETE, onReadComplete);
						fs.removeEventListener(ProgressEvent.PROGRESS, onReadComplete);
						fs.removeEventListener(IOErrorEvent.IO_ERROR, onReadError);
						fs.close();
						fs = null;
						System.gc();
						setupComplete();
					}
					else
						fs.readBytes(ba, fs.position, fs.bytesAvailable);
				}

				function onReadError(evt:Event):void
				{
					fs.removeEventListener(Event.COMPLETE, onReadComplete);
					fs.removeEventListener(ProgressEvent.PROGRESS, onReadComplete);
					fs.removeEventListener(IOErrorEvent.IO_ERROR, onReadError);
					fs.close();
					fs = null, ba.clear(), ba = null;
					dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
				}
			}
			else if (_clientParams.resouceSwf)
			{
				_resLoader = new Loader();
				_resLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
				_resLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadComplete);
				_resLoader.load(new URLRequest(_clientParams.resouceSwf), new LoaderContext(false, ApplicationDomain.currentDomain));
			}
			else
			{
				buildMainTexture();
				_buildMainTextureWorkFlow.start();
			}
		}

		private function onLoadComplete(evt:Event):void
		{
			var loaderInfo:LoaderInfo = evt.target as LoaderInfo;
			loaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadComplete);
			if (evt.type == IOErrorEvent.IO_ERROR)
			{
				throw new IOError(IOErrorEvent(evt).toString());
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
			}
			else
			{
				buildMainTexture();
				_buildMainTextureWorkFlow.start();
				_resLoader.unloadAndStop();
				_resLoader = null;
			}
		}

		protected function buildMainTexture():void
		{
			if (_computeTextureLevelScales == false)
				_mainTexture = new BatchTexture( //
					_texture_level_sizes[_texture_level].x, // 
					_texture_level_sizes[_texture_level].y, false);
			else
			{
				_subRects = new Vector.<Point>();
				_staticSubRects = new Vector.<Point>();
			}
			_buildMainTextureWorkFlow = new Workflow();
			_buildMainTextureWorkFlow.addEventListeners(onInitlizeWorkflow);
		}

		private function onInitlizeWorkflow(e:WorkFlowEvent):void
		{
			if (e.type == WorkFlowEvent.QUEUE_FAILED)
			{
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
			}
			else if (e.type == WorkFlowEvent.QUEUE_COMPLETE)
			{
				if (_computeTextureLevelScales)
				{
					new ComputeTextureLevelScalesWorker(_subRects, _texture_level_sizes).start();
					return;
				}

				System.gc();
				if (_exportPNG)
				{
					//导出PNG
					ba = _mainTexture.bitmapdata.encode(_mainTexture.bitmapdata.rect, new PNGEncoderOptions());
					_app.saveVersionResource(_mainTextureName + '.png', ba);
					ba.clear(), ba = null;
				}
				else
				{
					//缓存到本地。
					var ba:ByteArray;
					ba = _mainTexture.toByteArray();
					_app.saveVersionResource(_mainTextureName, ba);
					ba.clear(), ba = null;
				}
				System.gc();
				//上传显卡
				_mainTexture.name = _mainTextureName;
				_mainTexture.upload();
				System.gc();
				setupComplete();
			}
			else if (e.type == WorkFlowEvent.COMPLETE)
			{
				if (e.work is BitmapClipDataWorker)
				{
					var worker:BitmapClipDataWorker = e.work as BitmapClipDataWorker;
					if (worker)
					{
						if (worker.params && worker.params.vfs == true)
						{
							var bmcps:BitmapClipData = worker.result as BitmapClipData;
							var vector:Vector.<BitmapClipData> = new Vector.<BitmapClipData>();
							vector.push(bmcps);
							var texture:TextureBase = BatchTexture.fromBitmapclipDatas(vector, worker.name);
							ba = texture.toByteArray();
							_app.appendBytesToVFS(worker.name, ba);
							ba.clear();
							ba = null;
							vector = null;
							texture.dispose();
						}
						else
						{
							if (_computeTextureLevelScales)
							{
								trace(worker.name, BitmapClipData(worker.result).rects);
								_subRects = _subRects.concat(BitmapClipData(worker.result).rects);
							}
							else
								_mainTexture.insertBitmapClip(worker.name, worker.result as BitmapClipData);
						}
						worker.dispose();
						worker = null;
						System.gc();
					}
				}
				else if (e.work is SpriteSheetLoadWorker)
				{
					insertSpriteSheet(SpriteSheetLoadWorker(e.work).result as SpriteSheet, _clientParams.screenScale * _quality);
				}
			}
		}

		protected function setupComplete():void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}


		protected function insertTF(tfName:String, textWidth:Number, textHeight:Number, tfCharset:String, format:TextFormat, scale:Number):void
		{
			trace('insertTF(' + tfName, '[' + tfCharset + '])');
			var spriteSheet:SpriteSheet = StarlingTextFieldTexture.create(tfName, textWidth, textHeight, tfCharset, format, 1);
			insertSpriteSheet(spriteSheet, 1, true);
		}

		protected function loadSpriteSheet(png:String, xml:String):void
		{
			trace('loadSpriteSheet(' + png, xml + ')');
			_buildMainTextureWorkFlow.registeWork(new SpriteSheetLoadWorker(_app, png, xml));
		}

		protected function insertSpriteSheet(spriteSheet:SpriteSheet, scale:Number, static:Boolean = false):void
		{
			if (_computeTextureLevelScales)
			{
				var subTextures:XMLList = spriteSheet.xml.SubTexture;
				var subTexture:XML;
				var size:Point;
				const len:int = subTextures.length();
				for (var i:int = 0; i < len; i++)
				{
					subTexture = subTextures[i];
					size = new Point(Math.ceil(scale * subTexture.@width), //
						Math.ceil(scale * subTexture.@height));
					if (static)
					{
						size.x *= -1;
						size.y *= -1;
					}
					_subRects.push(size);
				}
			}
			else
				_mainTexture.insertSpriteSheet(spriteSheet, scale);
		}

		/**
		 * @param linkage 素材在fla里定义的linkage
		 * @param name    材质名字
		 * @param setting 设置。
		 * @throws Error
		 * @throws Error
		 */
		protected function insert(linkage:String, name:String, setting:Object):void
		{
			trace('insert(' + linkage, name + ')');
			var displayObj:Object = CommonUtil.getInstance(linkage);
			if (displayObj == null)
				throw new Error('找不到' + linkage + '的类定义!');
			if (displayObj is BitmapData)
			{ //位图
				var bmd:BitmapData = displayObj as BitmapData;
				var scale:Number = 1;
				if (setting is Number)
					scale = Number(setting);
				bmd = BitmapDataUtil.scaleBitmapData2(bmd, scale * _quality, scale * _quality, true);
				if (_computeTextureLevelScales) //收集小矩形
					_subRects.push(new Point(bmd.width, bmd.height));
				else
					_mainTexture.insert(name, new BitmapFrame(bmd, 0, 0, 1 / _quality, 1 / _quality));
				bmd.dispose();
				bmd = null;
			}
			else if (displayObj is MovieClip && MovieClip(displayObj).totalFrames > 1)
			{ //动画
				if (setting == null)
					setting = new Object;
				if (setting.quality_x == undefined)
					setting.quality_x = 1;
				if (setting.quality_y == undefined)
					setting.quality_y = 1;
				setting.quality_x *= _quality;
				setting.quality_y *= _quality;
				_buildMainTextureWorkFlow.registeWork(new BitmapClipDataWorker(name, displayObj as MovieClip, new DrawSetting(setting)));
			}
			else if (displayObj is DisplayObject)
			{ //矢量Sprite
				scale = 1;
				if (setting is Number)
					scale = Number(setting);
				var frame:BitmapFrame = BitmapFrame.fromDisplayObj(displayObj as DisplayObject, scale, _quality, _quality);
				if (_computeTextureLevelScales) //收集小矩形
					_subRects.push(new Point(frame.bmd.width, frame.bmd.height));
				else
					_mainTexture.insert(name, frame);
				frame.dispose(), frame = null;
			}
			else
				throw new Error(linkage + '不是合法的资源格式');
			displayObj = null;
		}

		/**
		 * 从配置里获取默认材质等级
		 */
		private function getDefaultTextureLevel():int
		{
			//根据屏幕缩放，确定合适的level
			var scaleLevel:int = 0;
			for (var j:int = 0; j < _texture_level_scales.length; j++)
			{
				if (_texture_level_scales[j] <= _clientParams.screenScale)
				{ //找到第一个比屏幕Scale小的
					scaleLevel = j - 1;
					break;
				}
			}

			if (scaleLevel >= _texture_level_scales.length)
				scaleLevel = _texture_level_scales.length - 1;
			else if (scaleLevel < 0)
				scaleLevel = 0;

			//根据配置文件，确定适合配置文件中要求的level。
			var configLevel:int = 0;
			if (_clientParams.deviceDefalutLevelConfig)
			{
				const len:int = _clientParams.deviceDefalutLevelConfig.setting.length();
				var setting:XML, deviceName:String, os:String;
				for (var i:int = 0; i < len; i++)
				{
					setting = _clientParams.deviceDefalutLevelConfig.setting[i];
					deviceName = setting.@deviceName;
					os = setting.@os;
					if (os == _clientParams.os)
					{
						configLevel = setting.@defaultLevel;
						break;
					}
					else if (deviceName != "" && _clientParams.deviceName.indexOf(deviceName) == 0)
					{
						configLevel = setting.@defaultLevel;
						break;
					}
				}
			}

			if (scaleLevel < configLevel)
				scaleLevel = configLevel;
			return scaleLevel;
		}

		protected function initliazeWithClientParams(clientParams:ClientTextureParams):void
		{
			_clientParams = clientParams;
			if (!_computeTextureLevelScales)
			{
				_texture_level = getDefaultTextureLevel();
				if (_debugTextureLevel >= 0 && _exportPNG)
					_texture_level = _debugTextureLevel;
				_quality = _texture_level_scales[_texture_level] / clientParams.screenScale;
				if (_quality > 1)
					_quality = 1;
				_mainTextureName = 'LV' + _texture_level + _name //
					+ clientParams.textureVersion;
				trace(_mainTextureName, _clientParams.screenScale, _quality);
			}
			else
				_quality = 1;
		}

		public function get mainTexture():BatchTexture
		{
			return _mainTexture;
		}

		public function dispose():void
		{
			if (_buildMainTextureWorkFlow)
			{
				_buildMainTextureWorkFlow.removeEventListeners(onInitlizeWorkflow);
				_buildMainTextureWorkFlow.destory();
			}
			_app = null;
			_resLoader = null;
			_clientParams = null;
			_mainTexture.dispose();
			_mainTexture = null;
		}
	}
}
