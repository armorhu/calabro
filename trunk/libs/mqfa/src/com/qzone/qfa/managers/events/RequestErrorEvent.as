package com.qzone.qfa.managers.events
{


	public class RequestErrorEvent extends RequestEvent
	{
		public static const ERROR:String = "RequestErrorEvent_Error";

		public var errorType:int;
		/**
		 * 当errorType == RequestError.HTTP_ERR_HTTPSTATUS时
		 *   errorContext为具体的StatusCode
		 * **/
		public var errorContext:String;

		/**
		 * 只有在errorType == RequestError.HTTP_ERR_SERVER_LOGIC时这个参数才有效。
		 * **/
		public var serverLogicErrorVO:ServerLogicErrorVO;

		public function RequestErrorEvent(type:String, errorType:int, errorContext:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			this.errorType = errorType;
			this.errorContext = errorContext;
			super(type, bubbles, cancelable);
		}
	}
}
