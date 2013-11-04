package com.snsapp.mobile.ffc.Event
{
	import flash.events.Event;

	public class FFCCloseEvent extends Event
	{
		public static const CLOSE_COMPLETE:String = "close_complete";

		public static const CLOSE_FAILED:String = "close_failed";

		public function FFCCloseEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
