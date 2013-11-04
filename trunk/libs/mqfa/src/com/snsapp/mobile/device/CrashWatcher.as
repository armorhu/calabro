package com.snsapp.mobile.device
{
	import com.qzone.qfa.debug.Debugger;
	import com.snsapp.mobile.utils.Cookies;
	import com.snsapp.mobile.utils.MobileSystemUtil;
	import com.snsapp.mobile.utils.OZRecorder;
	
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.system.Capabilities;

	/**
	 * 监控App的Crash情况
	 * @author hufan
	 */
	public class CrashWatcher
	{
		private static var _and:int;
		private static var _ios:int;

		public static function initlize(andFlag:int, iosFlag:int):void
		{
			_and = andFlag;
			_ios = iosFlag;
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, invokeApp);
		}

		private static function invokeApp(e:InvokeEvent):void
		{
			//启动应用
			NativeApplication.nativeApplication.removeEventListener(InvokeEvent.INVOKE, invokeApp);
			//查看so里的应用状态描述字符串
			var appstate:String = Cookies.getObject('appstate') as String;
			var appstate_id:int = 0;
			var p:int = 10;
			if (appstate == null) //so里没有值
				appstate_id = 1;
			else if (appstate == Event.ACTIVATE)
			{
				appstate_id = 2;
				p = 1;
			}
			else if (appstate == Event.DEACTIVATE)
				appstate_id = 3;
			else if (appstate == Event.EXITING)
				appstate_id = 4;
			else if (appstate == InvokeEvent.INVOKE)
			{
				p = 1;
				appstate_id = 5;
			}
			Cookies.setObject('appstate', e.type, 0, true);
			if (MobileSystemUtil.isAndroid())
			{
				Debugger.log('[AND]CrashWatcher:上一次的应用关闭状态为:' + appstate_id,"os:",Capabilities.os);
				OZRecorder.recordOZ(_and, 1, p, 0, appstate_id);
			}
			else if (MobileSystemUtil.isIOS())
			{
				Debugger.log('[iOS]CrashWatcher:上一次的应用关闭状态为:' + appstate_id,'os:',Capabilities.os);
				OZRecorder.recordOZ(_ios, 1, p, 0, appstate_id);
			}

			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, appActiveChange);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, appActiveChange);
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, appActiveChange);
		}

		private static function appActiveChange(e:Event):void
		{
			//把状态字符串写进so
			Cookies.setObject('appstate', e.type, 0, true);
		}
	}
}
