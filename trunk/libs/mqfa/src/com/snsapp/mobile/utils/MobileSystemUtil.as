package com.snsapp.mobile.utils
{
	import flash.system.Capabilities;

	/**
	 * 手机系统工具类
	 * @author Demon.S
	 *
	 */
	public final class MobileSystemUtil
	{
		public static const ANDROID:String = "AND";
		public static const IOS:String = "IOS";
		public static const PLAYBOOK:String = "QNX";
		public static const WINDOWS:String = "WIN";
		public static const UNIX:String = "QNX";
		public static const MAC:String = "OSX";

		public static const IP4:String = "IP4";
		public static const IPAD:String = "IPAD";

		private static const IOS_DPI_DEVICE_MAP:Object = {"132": IPAD, "326": IP4};

		private static var mobileDeviceIDs:Array = [ANDROID, IOS, PLAYBOOK];
		
		/**
		 * Returns the current os the application is running on. This is a 3 character value:
		 * OSX, WIN, AND, IOS, QNX
		 */
		public static function get os():String
		{
			return Capabilities.version.substr(0, 3);
		}

		/**
		 * 是否是android
		 * @return
		 *
		 */
		public static function isAndroid():Boolean
		{
			trace(os);
			return os == ANDROID;
		}


		public static function isIOS():Boolean
		{
			return os == IOS;
		}

		public static function isMobile():Boolean
		{
			return os == IOS || os == ANDROID;
		}



		public static function get device():String
		{
			if (os == IOS)
				return IOS_DPI_DEVICE_MAP[Capabilities.screenDPI.toString()] as String;
			return "";
		}

	}
}
