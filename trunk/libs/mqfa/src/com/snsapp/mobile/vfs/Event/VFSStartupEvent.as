package com.snsapp.mobile.vfs.Event
{
	import flash.events.Event;

	public class VFSStartupEvent extends Event
	{
		public static const STARTUP_COMPLETE:String = "startup_complete";

		public static const STARTUP_FAILED:String = "startup_failed";

		public function VFSStartupEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
