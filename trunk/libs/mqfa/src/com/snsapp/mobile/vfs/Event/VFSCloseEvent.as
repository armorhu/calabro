package com.snsapp.mobile.vfs.Event
{
	import flash.events.Event;

	public class VFSCloseEvent extends Event
	{
		public static const CLOSE_COMPLETE:String = "close_complete";

		public static const CLOSE_FAILED:String = "close_failed";

		public function VFSCloseEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
