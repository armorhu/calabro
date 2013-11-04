package com.qzone.qfa.managers.errors
{


	/**
	 * 连接型错误
	 * @author Demon.S
	 */
	public class RequestError
	{
		public static const HTTP_ERR_HTTPSTATUS_4:int = 7; //状态码4xx
		public static const HTTP_ERR_HTTPSTATUS_5:int = 8; //状态码5xx
		public static const HTTP_ERR_TIMEOUT:int = 3; //超时
		public static const HTTP_ERR_SECURITY:int = 2; // 安全错误
		public static const HTTP_ERR_IOERROR:int = 4; //ioError
		public static const HTTP_ERR_UNKOWN_REQUESTID:int = 12; //未知的请求id
		public static const HTTP_ERR_LOGIC_ERROR:int = 13; //发送请求的代码逻辑错误
		public static const HTTP_ERR_DATA_PARSER:int = 14; //数据解析失败...
		public static const HTTP_ERR_SERVER_LOGIC:int = 15; //服务端逻辑错误。
	}

}
