package com.snsapp.mobile.utils
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLVariables;

	/**
	 * SocialAPI
	 * @author demons
	 * 
	 */	
	public class SocialHelper
	{
	
		public static var cookies:String;
		public static var g_token:String;
		
		/**
		 * 一键分享到空间和微博</br>
         * 注意: msg, title, linkUrl都是必须的字段, 且不能为"".
         * 
         * 
		 * @param uin
		 * @param msg
		 * @param title
		 * @param picUrl
		 * @param linkUrl
		 * @param callback
		 * 
		 * example:
		 *  SocialHelper.g_token=GhostBridge.g_tk;
		 *	SocialHelper.cookies=GhostBridge.cookies;
		 *	SocialHelper.share("1373211","hello world la","lalalala","http://www.google.com/xxx.jpg","http://www.google.com",function():void{trace("share done")})
		 *	
		 * 
		 */		
		public static function share(uin:String,
							  msg:String="",
							  title:String="",
							  picUrl:String="",
							  linkUrl:String="",
							  callback:Function=null,errorCallback:Function=null,requestURL:String="http://sns.qzone.qq.com/cgi-bin/qzshare/cgi_qzshareadd_url"):void
		{
			
				var urlVars:URLVariables=new URLVariables("spaceuin="+uin+"&entryuin="+uin+"&token="+g_token+"&description="+msg+"&where=0&share2weibo=1&url="+linkUrl+"++++&site=&title="+title+"&pics="+picUrl+"&type=4&fupdate=1&notice=1");
				var shareCgiUrl:String=requestURL+"?g_tk="+g_token;
				var req:URLRequest=new URLRequest(shareCgiUrl);
				req.data=urlVars;
				req.method="post";
				var urlLoader:URLLoader=new URLLoader(req);
				req.requestHeaders.push(new URLRequestHeader("Referer","http://sns.qzone.qq.com/cgi-bin/qzshare/cgi_qzshare_onekey"))
				req.requestHeaders.push(new URLRequestHeader("User-Agent","Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)"));
				req.requestHeaders.push(new URLRequestHeader("Cookie",cookies))
				
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR,function(e:Event):void{trace(e.target.data);if(errorCallback!=null) errorCallback()});
				urlLoader.addEventListener(Event.COMPLETE,function(e:Event):void{trace(e.target.data);if(callback!=null) callback()});
				urlLoader.load(req);
		}
	}
}