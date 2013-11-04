package com.snsapp.mobile.view.interactive.scroll
{
	import flash.events.Event;
	import flash.geom.Point;

	public class ScrollHelperEvent extends Event
	{
		public static const BeginScroll:String = "BeginScroll";

		public static const Scrolling:String = "Scrolling";

		public static const EndScroll:String = "EndScroll";

		public static const Swipe:String = "Swipe";

		public static const ParsueScroll:String = "ParsueScroll";

		public static const EffectiveClick:String = "EffectiveClick";

		public var localPoint:Point;
		public function ScrollHelperEvent(type:String, //
			$localPoint:Point = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			localPoint = $localPoint;
			super(type, bubbles, cancelable);
		}
	}
}
