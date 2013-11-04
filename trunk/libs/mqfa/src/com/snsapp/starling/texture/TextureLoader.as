package com.snsapp.starling.texture
{
	import com.qzone.qfa.interfaces.IApplication;
	import com.qzone.qfa.managers.resource.ResourceType;
	import com.snsapp.mobile.view.bitmapclip.vo.DrawSetting;
	import com.snsapp.starling.texture.implement.TextureBase;
	import com.snsapp.starling.texture.worker.WorkLoadCacheTexture;
	import com.snsapp.starling.texture.worker.WorkLoadRemoteTexture;
	import com.snsapp.starling.texture.worker.WorkLoadTexture;

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.ApplicationDomain;

	/**
	 * 管理WorkLoadTexture的类。
	 * @author hufan
	 */
	[Event(name = "TextureLoadEvent_Complete", type = "com.snsapp.starling.texture.TextureLoadEvent")]
	public class TextureLoader extends EventDispatcher
	{
		/**textures对象数组**/
		protected var _textures:Vector.<TextureBase>;
		/**加载Texture工作**/
		protected const SERIAL_MAX_THREAD:int = 1;
		protected var _waitingQueue:Vector.<WorkLoadTexture>; //等待队列
		protected var _serialQueue:Vector.<WorkLoadTexture>; //串行队列
		protected var _paiallelQueue:Vector.<WorkLoadTexture>; //并行队列
		/**是否正在处理**/
		protected var _loading:Boolean;
		protected var _app:IApplication;
		protected var _scale:Number;

		public function TextureLoader(app:IApplication, scale:Number)
		{
			super(null);
			_app = app;
			_scale = scale;
			initliaze();
		}

		private function initliaze():void
		{
			//4个工作队列的初始化
			_serialQueue = new Vector.<WorkLoadTexture>();
			_paiallelQueue = new Vector.<WorkLoadTexture>();
			_waitingQueue = new Vector.<WorkLoadTexture>();
			_textures = new Vector.<TextureBase>();
		}


		protected function dispatchBatch(texture:TextureBase):void
		{
			//上传之前抛个事件。--用户可以监听这个事件，在新材质上传之前，将旧材质dispose掉。
			//这样就可以避免因为旧材质占着显存，新材质上传不进去的情况
			var event:TextureLoadEvent = new TextureLoadEvent(TextureLoadEvent.PRE_COMPLETE);
			event.texture = texture;
			dispatchEvent(event);
			if (event.texture)
			{
				if (_textures.indexOf(texture) == -1)
					_textures.push(texture);
				if (texture.uploaded == false)
					texture.upload();
				//上传之后抛个事件。
				event = new TextureLoadEvent(TextureLoadEvent.COMPLETE);
				event.texture = texture;
				dispatchEvent(event);
				clearUnUsedTexture();
			}
		}

		public function clearUnUsedTexture():void
		{
			const len:int = _textures.length;
			for (var i:int = len - 1; i >= 0; i--)
			{
				if (_textures[i].useCount <= 0)
				{
					_textures[i].dispose();
					_textures.splice(i, 1);
				}
			}
		}

		/**
		 * 某动物完成处理
		 */
		protected function loadTextureComplete(e:Event):void
		{
			var worker:WorkLoadTexture = e.target as WorkLoadTexture;
			worker.removeEventListener(Event.COMPLETE, loadTextureComplete);
			worker.removeEventListener(ErrorEvent.ERROR, loadTextureComplete);
			if (e.type == Event.COMPLETE)
			{
				const len:int = worker.textures.length;
				for (var i:int = 0; i < len; i++)
					this.dispatchBatch(worker.textures[i]);
			}
			else if (e.type == ErrorEvent.ERROR)
			{
				//To do...
			}
			//从工作队列里删除。
			var index:int = _serialQueue.indexOf(worker);
			var temp:WorkLoadTexture;
			if (index == -1)
			{
				index = _paiallelQueue.indexOf(worker);
				_paiallelQueue.splice(index, 1);
			}
			else
				_serialQueue.splice(index, 1);

			worker.dispose();
			startWorking(true); //完成一项工作时调用
		}

		protected function startWorking(complete:Boolean = false):void
		{
			//只要在三个队列里，有一个showLoading=true的工作，就认为是要显示loading的！
			var showLoading:Boolean = false;
			while (_waitingQueue.length > 0 && _serialQueue.length < SERIAL_MAX_THREAD)
			{
				var worker:WorkLoadTexture = _waitingQueue.pop();
				_serialQueue.push(worker);
				if (worker.isStart == false)
					worker.start();
			}

			var len:int = _paiallelQueue.length;
			for (var i:int = 0; i < len; i++)
			{
				if (_paiallelQueue[i].showLoading)
					showLoading = true;
				if (_paiallelQueue[i].isStart == false)
					_paiallelQueue[i].start();
			}

			len = _serialQueue.length;
			for (i = 0; i < len; i++)
			{
				if (_serialQueue[i].showLoading)
					showLoading = true;
			}
			len = _waitingQueue.length;
			for (i = 0; i < len; i++)
			{
				if (_waitingQueue[i].showLoading)
					showLoading = true;
			}

			if (showLoading) //未完成的工作中有需要显示loading的。一律显示loading
				loading = true;
			else if (complete) //只有在某项工作完成时，且剩余工作不需要显示loading，才会停止显示loading
				loading = false;
		}

		protected function set loading(value:Boolean):void
		{
			if (_loading == value)
				return;
			_loading = value;
		}

		protected function get loading():Boolean
		{
			return this._loading
		}

		protected function getWorkByURL(url:String):WorkLoadTexture
		{
			var len:int = _serialQueue.length;
			for (var i:int = 0; i < len; i++)
			{
				if (_serialQueue[i].url == url)
					return _serialQueue[i];
			}

			len = _paiallelQueue.length;
			for (i = 0; i < len; i++)
			{
				if (_paiallelQueue[i].url == url)
					return _paiallelQueue[i];
			}

			len = _waitingQueue.length;
			for (i = 0; i < len; i++)
			{
				if (_waitingQueue[i].url == url)
					return _waitingQueue[i];
			}

			return null;
		}

		protected function getTextureByName(textureName:String):TextureBase
		{
			const len:int = _textures.length;
			for (var i:int = 0; i < len; i++)
				if (_textures[i].name == textureName)
					return _textures[i];

			return null;
		}

		public function clearWaitingQueue():void
		{
			var worker:WorkLoadTexture;
			while (_waitingQueue.length)
			{
				worker = _waitingQueue.pop();
				worker.removeEventListener(Event.COMPLETE, loadTextureComplete);
				worker.removeEventListener(ErrorEvent.ERROR, loadTextureComplete);
				worker.dispose();
			}
		}

		/**
		 *
		 * @param resourceURL 资源url，必须为swf或bitmap。
		 * @param loading 加载该资源时是否显示loading。
		 * @param drawSetting 位图化该资源时的参数。
		 * <p>（注意，因为屏幕自适应，drawSetting.scale参数会自动和屏幕scale相乘）</p>
		 * @throws Error resourceURL代表的资源格式如果不是swf或者bitmap，会引发异常。
		 * useage:
		 * <code>
			var tl:TextureLoader;
			tl.addEventListener(TextureLoadEvent.COMPLETE, onloadTexture);
			var targetView:Image;
			var targetTexture:TextureBase;
			var waitTextureName:String = tl.requestTexture('http://img.qq.com/resouce.swf');
			function onloadTexture(e:TextureLoadEvent):void
			{
				if (waitTextureName != e.texture.name)
					return;
				if (targetTexture) //将引用计数减一
					targetTexture.useCount--;
				if (targetView) //移除旧的视图
				{
					targetView.dispose();
					targetView = null;
				}

				targetTexture = e.texture;
				targetTexture.useCount++; //将引用计数+1；
				if (targetTexture is BatchTexture)
					targetView = StarlingFactory.newTexureClip(targetTexture as BatchTexture);
				else if (targetTexture is SingleTexture)
					targetView = StarlingFactory.newImage(targetTexture);
			}
		 * </code>
		 */
		public function requestTexture(resourceURL:String, loading:Boolean = true, drawSetting:DrawSetting = null):void
		{
			var cacheURL:String = getCacheURL(resourceURL);
			if (requestCheck(resourceURL, cacheURL, cacheURL) == false)
				return;
			var worker:WorkLoadTexture;
			if (_app.hasFile(cacheURL))
				worker = new WorkLoadCacheTexture(_app, cacheURL, loading);
			else
			{
				if (drawSetting)
					drawSetting.scale *= _scale;
				else
					drawSetting = new DrawSetting({scale: _scale});
				worker = new WorkLoadRemoteTexture(_app, resourceURL, cacheURL, //
					drawSetting, loading);
			}
			worker.addEventListener(ErrorEvent.ERROR, loadTextureComplete);
			worker.addEventListener(Event.COMPLETE, loadTextureComplete);
			_paiallelQueue.push(worker);
			startWorking();
		}

		public function requestCacheTexture(cacheURL:String, loading:Boolean = false):void
		{
			if (_app.hasFile(cacheURL))
			{
				var worker:WorkLoadTexture = new WorkLoadCacheTexture(_app, cacheURL, loading);
				worker.addEventListener(ErrorEvent.ERROR, loadTextureComplete);
				worker.addEventListener(Event.COMPLETE, loadTextureComplete);
				_paiallelQueue.push(worker);
				startWorking();
			}
		}

		public function getCacheURL(resourceURL:String):String
		{
			if (ApplicationDomain.currentDomain.hasDefinition(resourceURL))
			{ //是元件。。。
				return resourceURL + '.texture';
			}
			var type:String = ResourceType.getType(resourceURL);
			if (type == ResourceType.TYPE_SWF || type == ResourceType.TYPE_BITMAP)
				return resourceURL.substring(0, resourceURL.lastIndexOf('.')) + '.texture';
			else
				throw new Error('请求加载的资源[' + resourceURL + ']不是swf或者bitmap格式');
		}

		public function hasCache(resourceURL:String):Boolean
		{
			var cache:String = getCacheURL(resourceURL);
			if (_app.hasFile(cache))
				return true;
			else
				return false;
		}

		protected function requestCheck(url:String, cacheURL:String, textureName:String):Boolean
		{
			var texture:TextureBase = getTextureByName(textureName);
			if (texture) //对应的Texture已经在显卡里面了。
			{
				this.dispatchBatch(texture);
				return false;
			}

			var worker:WorkLoadTexture;
			if (_app.hasFile(cacheURL))
			{
				worker = getWorkByURL(cacheURL);
				if (worker)
				{
					worker.pushTextureName(textureName);
					return false;
				}
			}
			else
			{
				worker = getWorkByURL(url);
				if (worker)
				{
					worker.pushTextureName(textureName);
					return false;
				}
			}

			return true;
		}
	}
}
