package com.qzone.qfa.managers.events
{
	import flash.events.Event;

	public class RequestEvent extends Event
	{
		/**
		 * 请求的get参数
		 * **/
		public var getParam:Object;
		/**
		 * 请求的post参数
		 * **/
		public var postParam:Object;
		/**
		 * 请求的id
		 * **/
		public var requestId:int;
		/**加载了多少**/
		public var bytesLoaded:Number;
		/**回包的大小**/
		public var bytesTotal:Number;
		/**响应时间**/
		public var responseTime:Number;

		public function RequestEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
