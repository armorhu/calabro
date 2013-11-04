package com.snsapp.mobile.view
{
	import com.snsapp.mobile.utils.MobileScreenUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.InteractiveObject;
	import flash.display.SimpleButton;
	import flash.display.Stage;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.LocationChangeEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;

	/**
	 * 移动端应用内打开网页的工具类
	 * @author armorhu
	 */
	public class CustomWebView
	{
		private var _url:String;

		private var _stage:Stage;

		private var _webView:StageWebView;

		private var _btnClose:InteractiveObject;

		public function CustomWebView(url:String, stage:Stage, sb:InteractiveObject)
		{
			if (url == null || stage == null)
				throw new ArgumentError();
			_url = url;
			_btnClose = sb;
			_stage = stage;
		}

		public function show():void
		{
			if (_webView)
				return;
			var _shape:Bitmap = new Bitmap(new BitmapData(1, 1, true, 0x88000000));
			var rect:Rectangle = MobileScreenUtil.getScreenRectInLandScape(_stage);
			_shape.width = rect.width;
			_shape.height = rect.height;

			_btnClose.width = 50;
			_btnClose.height = 50;
			_btnClose.x = rect.width - _btnClose.width / 2;
			_btnClose.addEventListener(MouseEvent.CLICK, onCloseWebView);

			_webView = new StageWebView();
			rect.top += _btnClose.height + 10;
			_webView.viewPort = rect;
			_webView.addEventListener(Event.COMPLETE, handleWebViewEvent)
			_webView.addEventListener(ErrorEvent.ERROR, handleWebViewEvent);
			_webView.addEventListener(LocationChangeEvent.LOCATION_CHANGING, handleWebViewEvent);
			_webView.loadURL(_url);

			_stage.addChild(_shape);
			_stage.addChild(_btnClose);
			_webView.stage = _stage;

			function onCloseWebView(e:MouseEvent):void
			{
				_btnClose.removeEventListener(MouseEvent.CLICK, onCloseWebView);
				_webView.removeEventListener(Event.COMPLETE, handleWebViewEvent)
				_webView.removeEventListener(ErrorEvent.ERROR, handleWebViewEvent);
				_webView.removeEventListener(LocationChangeEvent.LOCATION_CHANGING, handleWebViewEvent);

				_webView.stage = null;
				_webView.dispose();
				if (_btnClose.parent)
					_btnClose.parent.removeChild(_btnClose);
				if (_shape.parent)
					_shape.parent.removeChild(_shape);
				_webView = null;
				_btnClose = null;
				_shape = null;
			}

			function handleWebViewEvent(event:Event):void
			{
				switch (event.type)
				{
					case Event.COMPLETE:
						break;
					case LocationChangeEvent.LOCATION_CHANGING:
						break;
					case ErrorEvent.ERROR:
						onCloseWebView(null);
						//alter("无法访问网页!");
						break;
				}
			}
		}

		public static function show(url:String, stage:Stage, sb:InteractiveObject):void
		{
			new CustomWebView(url, stage, sb).show();
		}
	}
}
