package com.qzone.qfa.interfaces
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	/**
	 * qfa请求逻辑的包装器。
	 * 用户可以实现自己的包装器，来满足一些定制化的需求
	 * @author hufan
	 */
	public interface IPackage
	{
		/**包装**/
		function pack(urlReq:URLRequest, urlLoader:URLLoader):void
	}
}
