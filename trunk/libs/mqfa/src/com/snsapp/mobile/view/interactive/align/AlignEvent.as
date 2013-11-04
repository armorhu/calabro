package com.snsapp.mobile.view.interactive.align
{
	import flash.events.Event;

	public class AlignEvent extends Event
	{
		public static const ClickChild:String = "AlignEvent_ClickChild";

		public var childIndex:int

		public function AlignEvent(type:String, $childIndex:int = -1, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			childIndex = $childIndex;
			super(type, bubbles, cancelable);
		}
	}
}
