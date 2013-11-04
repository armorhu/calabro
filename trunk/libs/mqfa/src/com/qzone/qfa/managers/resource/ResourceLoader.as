package com.qzone.qfa.managers.resource
{
	import com.qzone.qfa.managers.LoadManager;
	import com.qzone.qfa.managers.events.LoaderEvent;
	import com.qzone.utils.DisplayUtil;
	import com.snsapp.mobile.ffc.Event.FFCCloseEvent;
	import com.snsapp.mobile.ffc.Event.FFCStartupEvent;
	import com.snsapp.mobile.ffc.FlashFastCache;
	import com.snsapp.mobile.mananger.workflow.IWork;
	import com.snsapp.mobile.view.bitmapclip.BitmapFrame;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	/**
	 * 移动端的素材管理器
	 * 将底层的素材存取接口类与上层客户类的中间层
	 * @author armorhu
	 */
	[Event(name = "close", type = "flash.events.Event")]
	[Event(name = "complete", type = "flash.events.Event")]
	[Event(name = "error", type = "flash.events.ErrorEvent")]
	public class ResourceLoader extends EventDispatcher implements IWork
	{
		public static const APP:String = "app:/";
		public static const APP_STORAGE:String = "app-storage:/";
		public static const VERSION_DICT:String = "app-storage:/version/"
		/**
		 * 更新的素材vfs
		 * **/
		protected var _updatesAssetsVFS:FlashFastCache;

		/**
		 * app 素材
		 * **/
		protected var _oriAssetsVFS:FlashFastCache;


		/**
		 * localVersionResource map;
		 * 本地的版本控制文件的表
		 * **/
		protected var _versionResourceMap:Object;



		/**
		 * 是否启动成功
		 * **/
		private var _complete:Boolean;

		/**
		 * 资源解析器
		 * **/
		protected var _resourceParser:ResourceParser;

		public function ResourceLoader(version:int, resourceParser:ResourceParser = null)
		{
			super();
			_oriAssetsVFS = new FlashFastCache(APP + "orignal.vfs");
			_updatesAssetsVFS = new FlashFastCache(VERSION_DICT + "update_" + version + ".vfs");
			_versionResourceMap = new Object();
			if (resourceParser == null)
				_resourceParser = new ResourceParser();
			else
				_resourceParser = resourceParser;
		}


		/**
		 * 纯虚函数，由子类告诉父类.
		 * @return
		 */
		protected function get vfsList():Vector.<FlashFastCache>
		{
			// please implements by sub class
			var vfss:Vector.<FlashFastCache> = new Vector.<FlashFastCache>();
			vfss.push(_oriAssetsVFS, _updatesAssetsVFS);
			return vfss;
		}

		/**
		 * 启动vfs
		 * 有任何一个vfs启动失败都会导致程序不可用
		 */
		public function start():void
		{
			var vfss:Vector.<FlashFastCache> = vfsList;
			if (vfss.length == 0)
				throw new Error("至少要有一个VFS，才能启动AssetsManager");

			//检查版本文件夹。
			var versionFold:File = new File(VERSION_DICT);
			if (versionFold.exists)
			{
				var fileList:Array = versionFold.getDirectoryListing();
				const len:int = fileList.length;
				var file:File;
				for (var i:int = 0; i < len; i++)
				{
					file = fileList[i] as File;
					_versionResourceMap[realName(file.name)] = versionOf(file.name);
				}
			}

			//对updates.vfs的版本控制。
			deleteOld(_updatesAssetsVFS.url);

			//启动vfs
			addEventListeners(vfss[0], vfsStartupEventHandler);
			vfss.shift().start();


			function vfsStartupEventHandler(e:FFCStartupEvent):void
			{
				var vfs:FlashFastCache = e.target as FlashFastCache;
				if (vfs == null)
					return;
				removeEventListeners(vfs, vfsStartupEventHandler);
				if (e.type == FFCStartupEvent.STARTUP_COMPLETE)
				{
					if (vfss.length > 0)
					{
						addEventListeners(vfss[0], vfsStartupEventHandler);
						vfss.shift().start();
					}
					else
					{
						_complete = true;
						trace("VFS启动成功。");
//						setTimeout(dispatchEvent,1000,new Event(Event.COMPLETE)); //test method
						dispatchEvent(new Event(Event.COMPLETE));
					}
				}
				else if (e.type == FFCStartupEvent.STARTUP_FAILED)
				{
					dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
				}
			}
		}

		/**
		 * 通过url加载外部资源
		 * @param url
		 * @param onComplete onComplete(resoure:Reource);
		 * 如果vfs启动了，会走vfs。
		 * 反之，将绕过vfs。
		 */
		public function loadResource(url:String, onComplete:Function):void
		{
			var net:Boolean;
			if (_complete)
			{
				if (_oriAssetsVFS.hasFile(url))
				{
					_oriAssetsVFS.read(url, onGetByteArray);
					return;
				}
				else if (_updatesAssetsVFS.hasFile(url))
				{
					_updatesAssetsVFS.read(url, onGetByteArray);
					return;
				}
			}
			net = true;
			loadAssets(url, onGetByteArray);

			function onGetByteArray(bytes:ByteArray):void
			{
				if (bytes)
				{
					_resourceParser.bytesToResource(bytes, url, onComplete);
//					if (net && _complete)
//						_updatesAssetsVFS.appendByteArray(url, bytes);
				}
				else
				{
					var res:Resource = new Resource();
					res.url = url;
					onComplete(res);
				}

				FlashFastCache.recycle(bytes);
				bytes = null;
			}
		}

		public function loadResouceWithOutCache(url:String, onComplete:Function):void
		{
			loadAssets(url, onGetByteArray);
			function onGetByteArray(bytes:ByteArray):void
			{
				if (bytes)
					_resourceParser.bytesToResource(bytes, url, onComplete);
				else
				{
					var res:Resource = new Resource();
					res.url = url;
					onComplete(res);
				}
				FlashFastCache.recycle(bytes);
				bytes = null;
			}
		}

		/**
		 * 请求一张位图
		 * @param swf 必须为swf。
		 * @param onComplete 请求的回调函数。回调函数的参数为Bitmap类型。
		 * 					 请求失败的话，回调函数传null：onComplete(null);
		 * @param width 位图的宽 默认原始宽
		 * @param height 位图的高 默认原始高
		 */
		public function requestBitmap(swf:String, onComplete:Function, width:int = 0, height:int = 0):void
		{
			if (swf.indexOf('.swf') == -1)
				throw new Error('requestBitmap方法的第一个参数必须为swf类型的url');
			var cacheURL:String = swf.substring(0, swf.lastIndexOf('.')) + '_' + width + 'x' + height + '.bmf'; //缓存的url
			if (hasFile(cacheURL))
				this.loadResource(cacheURL, onLoadResouceComplete);
			else
				this.loadResource(swf, onLoadResouceComplete);

			function onLoadResouceComplete(res:Resource):void
			{
				if (res.data is DisplayObject)
				{ //矢量素材。
					DisplayUtil.stopAll(res.data as DisplayObjectContainer);
					if (width > 0)
						DisplayObject(res.data).width = width;
					if (height > 0)
						DisplayObject(res.data).height = height;
					var bmf:BitmapFrame = DisplayUtil.cacheAsBitmap(res.data as DisplayObject, 1, 1);
					appendBytesToVFS(cacheURL, bmf.serialize()); //缓存到vfs中。
				}
				else if (res.data is ByteArray)
				{
					//读取缓存。
					bmf = BitmapFrame.fromByteArray(res.data as ByteArray);
				}
				res.destroy();
				if (bmf)
					onComplete(new Bitmap(bmf.bmd));
				else
					onComplete(null);
			}
		}

		/**
		 * 加载纳入版本控制的外部资源
		 */
		public function loadVersionResource(url:String, onComplete:Function):void
		{
			var fileName:String = fileNameOf(url);
			var realName:String = realName(fileName);
			var version:String = versionOf(fileName);
			var loadURL:String;
			var del:Boolean, save:Boolean;

			if (_versionResourceMap[realName] == undefined || _versionResourceMap[realName] != version)
			{ //本地没有，或者过期。。。下载！
				save = true;
				del = _versionResourceMap[realName] != undefined;
				loadAssets(url, onGetBytes);
			}
			else
				loadAssets(VERSION_DICT + fileName, onGetBytes);

			function onGetBytes(bytesArray:ByteArray):void
			{
				if (bytesArray == null)
				{
					var res:Resource = new Resource();
					res.url = url;
					onComplete(res);
				}
				else
				{
					if (del)
					{
						var file:File = File.applicationStorageDirectory.resolvePath("version/" + //
							fileName.replace(version, _versionResourceMap[realName]));
						file.deleteFileAsync();
						file = null;
					}
					if (save)
					{
						var fs:FileStream = new FileStream();
						fs.open(new File(APP_STORAGE + "version/" + fileName), FileMode.WRITE);
						fs.writeBytes(bytesArray);
						fs.close();
						fs = null;
						_versionResourceMap[realName] = version;
					}
					_resourceParser.bytesToResource(bytesArray, url, onComplete);
				}

				FlashFastCache.recycle(bytesArray);
				bytesArray = null;
			}
		}

		/**
		 * 保存版本控制的文件。
		 * 保存新版本的同时，会删除旧版本的。
		 */
		public function saveVersionResource(name:String, bytes:ByteArray):void
		{
			deleteOld(name);
			var file:File = new File(VERSION_DICT + name);
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.WRITE);
			fs.writeBytes(bytes);
			fs.close();
			fs = null;
		}

		protected function deleteOld(fileName:String):void
		{
			fileName = fileNameOf(fileName);
			var realName:String = realName(fileName);
			var version:String = versionOf(fileName);
			if (_versionResourceMap[realName] != undefined && _versionResourceMap[realName] != version)
			{
				var file:File = new File(VERSION_DICT + fileName.replace(version, _versionResourceMap[realName]));
				if (file.exists)
				{
					file.deleteFileAsync();
					file = null;
				}
			}
			_versionResourceMap[realName] = version;
		}

		private var _ld:LoadManager; // 加载器
		private var _ldCallBackMap:Object; //以url为索引的回调函数biao

		protected function loadAssets(url:String, callBack:Function):void
		{
			if (_ldCallBackMap == null)
				_ldCallBackMap = new Object();
			if (_ldCallBackMap[url] == undefined)
			{
				_ldCallBackMap[url] = new Array();
				_ldCallBackMap[url].push(callBack);
			}
			else
			{
				_ldCallBackMap[url].push(callBack);
				return;
			}

			if (_ld == null)
			{
				_ld = new LoadManager();
				_ld.addEventListeners(handleLoadEvent);
				_ld.maxThreadCount = 4;
			}

			_ld.add(url, {type: ResourceType.TYPE_BINARY});
			if (_ld.status == LoadManager.STATUS_STOPPED)
				_ld.start();
		}


		protected function handleLoadEvent(e:LoaderEvent):void
		{
			switch (e.type)
			{
				case LoaderEvent.START:
					break;
				case LoaderEvent.COMPLETE:
					trace('handleLoadEvent',e.item.url);
					if (e.item.loaderInfo && e.item.loaderInfo.loader)
						e.item.loaderInfo.loader.unloadAndStop();

					if (e.item.data is ByteArray)
						_resourceParser.netToLocal(e.item.data as ByteArray, e.item.url, onParseComplete);
					else
						onParseComplete(null);
					break;
				case LoaderEvent.ERROR: //LoadManager在下载失败是会跳过错误,继续往下走
					/*var callBacks:Array = _ldCallBackMap[e.item.url] as Array;
					for each (var callBack:Function in callBacks)
						callBack(null);
					delete _ldCallBackMap[e.item.url];*/
					onParseComplete(null);
					break;
				default:
					break;
			}
			function onParseComplete(bytes:ByteArray):void
			{
				var callBacks:Array = _ldCallBackMap[e.item.url] as Array;
				for each (var callBack:Function in callBacks)
					callBack(bytes ? cloneByteArray(bytes) : null);
				if (bytes)
					bytes.clear(), bytes = null;
				delete _ldCallBackMap[e.item.url];
			}
		}

		private function cloneByteArray(bytes:ByteArray):ByteArray
		{
			var newBytes:ByteArray = new ByteArray();
			newBytes.writeBytes(bytes);
			newBytes.position = 0;
			return newBytes;
		}

		public function appendBytesToVFS(name:String, bytes:ByteArray):Boolean
		{
			return _updatesAssetsVFS.appendByteArray(name, bytes);
		}

		public function hasFile(name:String):Boolean
		{
			return _oriAssetsVFS.hasFile(name) || _updatesAssetsVFS.hasFile(name);
		}

		public function get complete():Boolean
		{
			return _complete;
		}

		protected function addEventListeners(vfs:FlashFastCache, vfsEventHandler:Function):void
		{
			vfs.addEventListener(FFCStartupEvent.STARTUP_COMPLETE, vfsEventHandler);
			vfs.addEventListener(FFCStartupEvent.STARTUP_FAILED, vfsEventHandler);
		}

		protected function removeEventListeners(vfs:FlashFastCache, vfsEventHandler:Function):void
		{
			vfs.removeEventListener(FFCStartupEvent.STARTUP_COMPLETE, vfsEventHandler);
			vfs.removeEventListener(FFCStartupEvent.STARTUP_FAILED, vfsEventHandler);
		}

		/**
		 * 关闭文件流
		 * 关闭成功后会抛出Close事件
		 */
		public function close():void
		{
			var vfss:Vector.<FlashFastCache> = this.vfsList;
			const MAX:int = vfss.length;
			if (MAX == 0)
			{
				dispatchEvent(new Event(Event.CLOSE));
				return;
			}
			var count:int = 0;
			for (var i:int = 0; i < vfss.length; i++)
			{
				vfss[i].addEventListener(FFCCloseEvent.CLOSE_COMPLETE, onCloseComplete);
				vfss[i].addEventListener(FFCCloseEvent.CLOSE_FAILED, onCloseComplete);
				vfss[i].close();
			}

			function onCloseComplete(e:FFCCloseEvent):void
			{
				e.target.removeEventListener(FFCCloseEvent.CLOSE_COMPLETE, onCloseComplete);
				e.target.removeEventListener(FFCCloseEvent.CLOSE_FAILED, onCloseComplete);
				count++;
				if (count == MAX)
					dispatchEvent(new Event(Event.CLOSE));
			}
		}

		/**
		 * a_123.swf
		 * @param fileName
		 * @return 123
		 */
		protected function versionOf(fileName:String):String
		{
			var temp:int = fileName.lastIndexOf("_");
			if (temp == -1)
				return "";
			var version:String = fileName.substr(temp + 1);
			temp = version.lastIndexOf(".");
			if (temp == -1)
				return version;
			else
				return version.substring(0, temp);
		}

		/**
		 * a_123.swf
		 * @param fileName
		 * @return a
		 */
		protected function realName(fileName:String):String
		{
			var temp:int = fileName.lastIndexOf("_");
			var start:int = fileName.lastIndexOf("/");
			if (temp == -1)
				temp = int.MAX_VALUE;
			return fileName.substring(start + 1, temp);
		}


		protected function fileNameOf(url:String):String
		{
			var temp:int = url.lastIndexOf("/");
			if (temp == -1)
				return url;
			else
				return url.substr(temp + 1);
		}
	}
}
