package com.snsapp.charon.wtlogin
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	public class HttpLoader extends URLLoader
	{
		private var type:Object = {IP_SIG: "http://wlogin.qq.com/cgi-bin/wlogin_ip_sig", LOGIN: "http://wlogin.qq.com/cgi-bin/wlogin_http"};

		public function HttpLoader()
		{
			super();
		}

		public function post(_data:String, _type:String = "IP_SIG"):void
		{
			var req:URLRequest = new URLRequest();
			req.url = type[_type];
			req.method = URLRequestMethod.POST;
			var headers:Array = [];
			headers.push(new URLRequestHeader("Accept", "*/*"));
			headers.push(new URLRequestHeader("Accept-Language", "zh-cn"));
			headers.push(new URLRequestHeader("Cache-Control", "no-cache"));
			req.requestHeaders = headers;
			var vars:URLVariables = new URLVariables();
			req.data = _data;
			this.load(req);
		}
	}
}
