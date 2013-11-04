package com.snsapp.mobile.utils
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.clearInterval;
	import flash.utils.setTimeout;

	/**
	 * 访问应用的辅助类
	 * @author hufan
	 */
	[Event(name = "status", type = "flash.events.StatusEvent")]
	public class NavigateAppHepler extends EventDispatcher
	{
		private const DELAY:uint = 500;
		private var _appURL:String;
		private var _appStroeURL:String;
		private var _timeOut:uint

		public function NavigateAppHepler()
		{
		}

		public function call(appURL:String, appStroeURL:String):void
		{
			_appURL = appURL;
			_appStroeURL = appStroeURL;
            if(appURL != null && appURL != "")
            {
                navigateToURL(new URLRequest(appURL));
                _timeOut = setTimeout(onApp, 500);
                NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDeactivete, false, 0, true);
            }
            else
                onApp();
		}

		private function onDeactivete(e:Event):void
		{
			//启动app成功
			var evt:StatusEvent = new StatusEvent(StatusEvent.STATUS);
			evt.code = '1';
			dispatchEvent(evt);
			NativeApplication.nativeApplication.removeEventListener(Event.DEACTIVATE, onDeactivete);
			clearInterval(_timeOut);
		}

		private function onApp():void
		{
			//启动失败，去appstroe
			var evt:StatusEvent = new StatusEvent(StatusEvent.STATUS);
			evt.code = '2';
			dispatchEvent(evt);
			navigateToURL(new URLRequest(_appStroeURL));
		}
	}
}
