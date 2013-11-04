package com.snsapp.mobile.ffc.Event
{
	import flash.events.Event;

	public class FFCStartupEvent extends Event
	{
		public static const STARTUP_COMPLETE:String = "startup_complete";

		public static const STARTUP_FAILED:String = "startup_failed";

		public function FFCStartupEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
