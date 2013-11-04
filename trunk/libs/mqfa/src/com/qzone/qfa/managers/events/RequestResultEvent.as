package com.qzone.qfa.managers.events
{
	

	/**
	 * 请求事件
	 * @author Demon.S
	 */
	public class RequestResultEvent extends RequestEvent
	{
		//成功
		public static const RESULT:String = "RequestResultEvent_Result";

		public function RequestResultEvent(type:String, data:* = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			_data = data;
			super(type, bubbles, cancelable);
		}

		/**
		 * 获得的数据
		 */
		protected var _data:*;
		public function get data():*
		{
			return _data;
		}

		public function set data(value:*):void
		{
			_data = value;
		}


	}

}
