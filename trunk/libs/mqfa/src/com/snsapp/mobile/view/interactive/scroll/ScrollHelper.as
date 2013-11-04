package com.snsapp.mobile.view.interactive.scroll
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class ScrollHelper extends ScrollCore
	{
		public function ScrollHelper(target:InteractiveObject, $horizontalRange:Point = null, $verticalRange:Point = null, $horizontalFlexble:Number = 0, $verticalFlexble:Number = 0, $horizontalSupport:int = 0, $verticalSupport:int = 0, $trigClick_Offset:Number = 20, $trigSwipe_Time:int = 300, $trigSwipe_Offset:Number = 50, $minSwipeSpeed:Number = 5, $inertanceEasing:Number = 0.8)
		{
			super(target, $horizontalRange, $verticalRange, $horizontalFlexble, $verticalFlexble, $horizontalSupport, $verticalSupport, $trigClick_Offset, $trigSwipe_Time, $trigSwipe_Offset, $minSwipeSpeed, $inertanceEasing);
		}

		override protected function init(e:Event = null):void
		{
			super.init(e);
			_target.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownTarget, false, 0, true);
		}

		override public function dispose():void
		{
			super.dispose();
			this._target.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownTarget);
			this._target = null;
		}

		protected function mouseDownTarget(e:MouseEvent):void
		{
			this.beginDrag();
		}
	}
}
