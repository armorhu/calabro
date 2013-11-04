package com.snsapp.mobile.device.network
{
//	import com.adobe.nativeExtensions.Networkinfo.NetworkInfo;
//	import com.adobe.nativeExtensions.Networkinfo.NetworkInterface;
	
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;

	/**
	 * 网络状态接口
	 * **/
	public class NetworkHelper_IOS
	{
		public static const MOBILE:Array = ["pdp_ip0", "pdp_ip1", "pdp_ip2"];

		public static const WIFI:Array = ["en0", "en1"];

		public function NetworkHelper_IOS()
		{

		}

		public static function checkNetwork():Boolean
		{
			return getActiveNetWorkNames().length > 0;
		}

		public static function is3G():Boolean
		{
			var activeNames:Vector.<String> = getActiveNetWorkNames();
			const len:int = activeNames.length;
			for (var i:int = 0; i < len; i++)
			{
				if (MOBILE.indexOf(activeNames[i]) != -1)
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
					activeNames.push(interfaceObj.name);
			return activeNames;
		}
	}
}
