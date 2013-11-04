package com.qzone.qfa.interfaces
{
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLVariables;

	/**
	 * 服务器接口
	 * MQFA 定义接口，下层的业务逻辑实现这些接口。
	 * @author hufan
	 */
	public interface IServerServices
	{
		/**根据requestId获取url**/
		function getRequestURL(requestId:int):String;

		/**
		 * 发送http请求
		 * @param requestId  后台请求id
		 * @param getParams  get参数
		 * @param postParams post参数
		 * @param onComplete 返回成功
		 * @param onNetError 请求失败
		 */
		function request( //
		requestId:int, //
			getParams:Object = null, //
			postParams:Object = null, //
			onComplete:Function = null, //
			onNetError:Function = null, //
			packager:IPackage = null, //request
			parser:IParser = null):void
	}
}
