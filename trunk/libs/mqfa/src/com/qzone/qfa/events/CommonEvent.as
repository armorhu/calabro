package com.qzone.qfa.events
{
	import flash.events.Event;

	/**
	 * 带着任意类型数据的事件
	 * @author hf
	 */
	public class CommonEvent extends Event
	{
		private var _data : *;

		public function CommonEvent(type : String, data : *, bubbles : Boolean = false, cancelable : Boolean = false)
		{
			super(type, bubbles, cancelable);
			
			_data = data;
		}

		public function set data(value : *) : void
		{
			_data = value;
		}

		public function get data() : *
		{
			return _data;
		}

	}
}