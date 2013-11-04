package com.snsapp.mobile.utils
{
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.sendToURL;

	public class OZRecorder
	{
		/**
		 * OZ上报的URL
		 */
		public static const OZ_RECORD_URL:String = "http://isdspeed.qq.com/cgi-bin/v.cgi";
		private static const CLICK_PROBABILITY:int = 10; //点击量的采样率。
		public static const NAVIGATE_FARM:int = 161076; //访问农场。
		public static var uin:String = null;

		public function OZRecorder()
		{

		}

		/**
		 * 上报oz的最基础的接口。
		 * @param flag1 oz上申请的id
		 * @param flag2 oz上配置的flag2，1-成功，2-失败，3-逻辑失败。
		 * @param probability 采样率
		 * @param delay 延迟。
		 * @param flag3 返回码小范围分类
		 */
		public static function recordOZ(flag1:int, flag2:int, probability:int, delay:Number, flag3:int):void
		{
			if (int(Math.random() * probability) != 0)
				return;

			var vars:URLVariables = new URLVariables();
			vars.flag1 = flag1.toString();
			vars["flag2"] = flag2;
			vars["flag3"] = flag3;
			vars['flag4'] = uin;
			vars["1"] = probability; //取样率
			vars["2"] = delay.toString();

			var req:URLRequest = new URLRequest(OZ_RECORD_URL); //new URLRequest(_recordUrl+sign+"flag1="+pid+"&flag2="+code);
			req.data = vars;
			req.method = URLRequestMethod.GET;
			sendToURL(req);
		}
	}
}
