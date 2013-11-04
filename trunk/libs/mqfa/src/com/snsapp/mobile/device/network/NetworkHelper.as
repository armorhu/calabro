package com.snsapp.mobile.device.network
{
	import com.snsapp.mobile.utils.MobileSystemUtil;

	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;

	/**
	 * 网络状态接口
	 * **/
	public class NetworkHelper
	{
		public static const MOBILE:Array = ["pdp_ip0", "pdp_ip1", "pdp_ip2"];

		public static const WIFI:Array = ["en0", "en1"];

		public function NetworkHelper()
		{

		}

		public static function checkNetwork():Boolean
		{
			if (MobileSystemUtil.isIOS())
				return NetworkHelper_IOS.checkNetwork();
			else
				return getActiveNetWorkNames().length > 0;
		}

		public static function is3G():Boolean
		{
			if (MobileSystemUtil.isIOS())
				return NetworkHelper_IOS.is3G()

			var activeNames:Vector.<String> = getActiveNetWorkNames();
			const len:int = activeNames.length;
			for (var i:int = 0; i < len; i++)
			{
				if (MOBILE.indexOf(activeNames[i]) != -1 ||
                    activeNames[i].indexOf("mobile") > -1)
					return true;
			}
			return false;
		}

		protected static function getActiveNetWorkNames():Vector.<String>
		{
			var ntf:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
			var activeNames:Vector.<String> = new Vector.<String>();
			for each (var interfaceObj:NetworkInterface in ntf)
				if (interfaceObj.active)
					activeNames.push(interfaceObj.name.toLowerCase());
			return activeNames;
		}
	}
}
