//------------------------------------------------------------------------------
//
//   Copyright 2010, Qzone, Tencent. 
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package com.snsapp.mobile.utils 
{
	import com.qzone.qfa.debug.Debugger;
	import com.qzone.qfa.debug.LogType;
	
	import flash.events.NetStatusEvent;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;

	/**
	 * A simple wrapper class for local shared object.
	 */
	public class Cookies
	{
		private static var Cookie:SharedObject = null;

		public static function Get(name:String):String
		{
			if (Cookie == null)
				return null;
			if (name == null || name == "")
				return null;

			return Cookie.data[name];
		}

		public static function Set(name:String, val:String):Boolean
		{
			if (Cookie == null)
				return false;
			if (name == null || name == "")
				return false;
			if (val == null || val == "")
				return false;

			Cookie.data[name] = val;
			return flush();
		}

		public static function clear():void
		{
			if (Cookie == null)
				return;

			try
			{
				Cookie.clear();
			}
			catch (e:Error)
			{
				trace("Cookies exception: " + e);
			}
		}

		/**
		 * 获得一个值
		 */
		public static function getObject(name:String, time:Number = 0):Object
		{
			if (Cookie == null)
				return null;

			var returnValue:Object = null;
			try
			{
				if (time == 0)
					time = new Date().time;

				if (Cookie.data[name] != undefined)
				{
					if (Cookie.data[name].hasOwnProperty('time'))
					{ //兼容老数据
						var diff:Number = Cookie.data[name].time - time;
						if (diff >= 0)
						{
							returnValue = Cookie.data[name].value;
						}
					}
					else
					{
						returnValue = Cookie.data[name];
					}
				}
			}
			catch (e:Error)
			{
				trace("Cookies exception: " + e);
			}
			return returnValue;
		}

		public static function hasObject(name:String):Boolean
		{
			if (Cookie == null)
				return false;

			var flag:Boolean = false;
			var now:Number = new Date().time;
			if (Cookie.data[name] != undefined)
			{
				if (Cookie.data[name].hasOwnProperty('time'))
				{ //兼容老数据
					var diff:Number = Cookie.data[name].time - now;
					if (diff > 0)
					{
						flag = true;
					}
				}
			}

			return flag;
		}


		/**
		 * 静态类初始化，只需且只能调用一次
		 * @param game
		 *
		 */
		public static function initialize(game:String):void
		{
			if (Cookie != null)
				return;

			try
			{
				Cookie = SharedObject.getLocal(game);
				Cookie.addEventListener(NetStatusEvent.NET_STATUS, onNetStatusError, false, 0, true);
			}
			catch (e:Error)
			{
				trace("Cookies exception: " + e);
			}
		}

		/**
		 * 写入一个值
		 */
		public static function setObject(name:String, value:Object, time:Number = 0, flushNow:Boolean = false):Boolean
		{
			if (Cookie == null)
				return false;

			if (time == 0)
				time = new Date(2038, 12, 31).time;

			Cookie.data[name] = {'value': value, 'time': time};

			if (flushNow)
			{
				var flushResult:Boolean = flush();
				if (flushResult == false)
				{
					delete Cookie.data[name];
				}
				return flushResult;
			}
			return flushNow;
		}

		public static function flush():Boolean
		{
			if (Cookie == null)
				return false;

			try
			{
				var flushResult:String = Cookie.flush();
				if (flushResult == SharedObjectFlushStatus.PENDING)
				{
					Debugger.log("Cookies: PENDING -- 数据超出限制", LogType.ERROR);
					trace("Cookies: PENDING -- 数据超出限制");
				}
				else if (flushResult == SharedObjectFlushStatus.FLUSHED)
				{
//					trace("Cookies: FlUSHED -- 成功写入");
				}
			}
			catch (e:Error)
			{
				Debugger.log("Cookies exception: " + e, LogType.ERROR);
				trace("Cookies exception: " + e);
				return false;
			}
			return true;
		}

		private static function onNetStatusError(e:NetStatusEvent):void
		{
			Debugger.log("Cookies exception: " + e, LogType.ERROR);
//			trace("Cookies exception: " + e);
		}

	}
}