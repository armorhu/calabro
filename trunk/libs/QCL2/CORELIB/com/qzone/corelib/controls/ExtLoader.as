package com.qzone.corelib.controls
{
	import com.qzone.qfa.debug.Debugger;
	import com.qzone.utils.ImageSizeUtil;
	import com.snsapp.mobile.utils.MobileSystemUtil;

	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.utils.ByteArray;

	/**
	 * 自动缩放大小的Loader
	 * @author elementli
	 *
	 */
	public class ExtLoader extends Sprite
	{
		protected var _loader:Loader;
		protected var _lc:LoaderContext;
		protected var _w:Number;
		protected var _h:Number;
		protected var _style:int;
		protected var _smoothing:Boolean;
		protected var _prevImage:Bitmap;
		protected var _cachePrevImage:Boolean;
		protected var _retryNum:int = 0;
		protected var _autoRetry:int;
		protected var _req:URLRequest;
		public var contentUrl:String;

		public var defaultWidth:Number;
		public var defaultHeight:Number;

		public static const ONLOAD_INIT:String = "onLoadInit";

		protected var _border:Sprite;

		/**
		 * 构造一个ExtLoader
		 * @param theWidth 最大宽度
		 * @param theHeight 最大高度
		 * @param style 缩放参数，参看ImageSize
		 * @param smoothing 平滑参数
		 * @param border 参考线，测试用，0或1;
		 * @see ImageSize
		 */
		public function ExtLoader(theWidth:Number = 150, theHeight:Number = 80, style:int = -1, smoothing:Boolean = false, border:int = 0, cachePrevImage:Boolean = false, autoRetry:int = 1)
		{
			_w = theWidth;
			_h = theHeight;
			_style = style;
			_autoRetry = autoRetry;
			_smoothing = smoothing;
			_cachePrevImage = cachePrevImage;
			_lc = new LoaderContext(true, ApplicationDomain.currentDomain, SecurityDomain.currentDomain)
			_loader = new Loader();
			addChild(_loader);

			_border = new Sprite();
			_border.graphics.lineStyle(0, 0, (border >= 1) ? 1 : 0);
			_border.graphics.drawRect(0, 0, _w, _h);
			_border.graphics.endFill();
			addChild(_border);

		}

		/**
		 * 加载图片
		 * @param url
		 *
		 */
		public function load(url:String):void
		{
			if (MobileSystemUtil.isMobile())
			{
				Debugger.log(url+ "的加载,手机端暂不支持！");
				return;
			}
			if (_cachePrevImage)
			{
				if (_loader.content is Bitmap)
				{
					unloadPrevImage();

					_prevImage = new Bitmap(Bitmap(_loader.content).bitmapData.clone(), "auto", true);
					_prevImage.x = _loader.x;
					_prevImage.y = _loader.y;
					_prevImage.width = _loader.width;
					_prevImage.height = _loader.height;
					addChild(_prevImage);
				}
			}
			unload();
			_req = new URLRequest(url);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, __onLoaderCompleteHandler);
			if (_autoRetry > 0)
			{
				_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, __onLoaderIOErrorHandler);
			}
			contentUrl = url;
			_loader.load(_req, _lc);
		}

		public function unloadPrevImage():void
		{
			if (_prevImage != null)
			{
				removeChild(_prevImage);
				_prevImage.bitmapData.dispose();
				_prevImage = null;
			}
		}

		public function unload():void
		{
			try
			{
				Bitmap(_loader.content).bitmapData.dispose();
				_loader.unload();
			}
			catch (err:Error)
			{
			}
		}

		public function loadBytes(bytes:ByteArray, contex:LoaderContext = null):void
		{
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, __onLoaderCompleteHandler);
			_loader.loadBytes(bytes, contex);
		}

		public function set style(v:int):void
		{
			if (_loader != null)
			{
				_style = v;
				ImageSizeUtil.setSize2(_loader, 0, 0, _w, _h, _style);
			}
		}

		public function get contentWidth():Number
		{
			return _loader.width || 0;
		}

		public function get contentHeight():Number
		{
			return _loader.height || 0;
		}

		public function get loader():Loader
		{
			return _loader;
		}

		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			if (type == Event.COMPLETE || type == ProgressEvent.PROGRESS || type == IOErrorEvent.DISK_ERROR || type == IOErrorEvent.NETWORK_ERROR || type == IOErrorEvent.VERIFY_ERROR)
			{
				_loader.contentLoaderInfo.addEventListener(type, listener, useCapture, priority, useWeakReference);
			}
			else
			{
				super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			}
		}

		protected function __onLoaderCompleteHandler(e:Event):void
		{
			_retryNum = 0;
			if (_cachePrevImage)
			{
				_loader.alpha = 0;
				setChildIndex(_loader, numChildren - 1);
			}
			defaultWidth = _loader.content.width || 0;
			defaultHeight = _loader.content.height || 0;
			ImageSizeUtil.setSize2(_loader, 0, 0, _w, _h, _style);
			if (_loader.content is Bitmap && _smoothing)
			{
				Bitmap(_loader.content).smoothing = true;
			}
			_loader.content.cacheAsBitmap = true;
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, __onLoaderCompleteHandler);
			dispatchEvent(new Event(ONLOAD_INIT));
		}

		protected function __onLoaderIOErrorHandler(e:IOErrorEvent):void
		{
			if (_retryNum < _autoRetry && _autoRetry)
			{
				_loader.load(_req, _lc);
				_retryNum++;
//				trace("Retry:"+_retryNum);
				return;
			}
			_retryNum = 0;
			dispatchEvent(e);
		}
	}
}
