package com.snsapp.starling.display
{
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	/**
	 * 封装最基础的点击事件的组件
	 * @author hufan
	 */
	public class EffectiveClickRender extends Sprite
	{
		private var pasuse:int;
		private var touchTime:Number=0;
		private var sx:Number;
		private var sy:Number;
		
		public function EffectiveClickRender()
		{
			super();
			addEventListener(TouchEvent.TOUCH, touchEvent);
		}

		private function touchEvent(e:TouchEvent):void
		{
			
			var touch:Touch = e.getTouch(this);
			if (touch)
			{
				if (touch.phase == TouchPhase.BEGAN)
				{
					sx = touch.globalX;
					sy = touch.globalY;
					touchTime = getTimer();
					pasuse = 1;
				}
				else if (touch.phase == TouchPhase.MOVED){
					pasuse = 2;
				}
				else if (touch.phase == TouchPhase.ENDED)
				{
					touchTime = getTimer() - touchTime;
					sx = touch.globalX - sx;
					sy = touch.globalY - sy;
//					if (pasuse == 1)
					if(touchTime<500&&Math.abs(sx)<20&&Math.abs(sy)<20)
						touchMeBaby(touch);
				}
			}
		}

		/**
		 * 子类可以直接重载这个方法来方便的做出响应
		 * @param touch
		 */
		protected function touchMeBaby(touch:Touch):void
		{
			trace("EffectiveClickEvent");
			pasuse = 0;
			dispatchEvent(new EffectiveClickEvent(EffectiveClickEvent.CLICK));
		}
	}
}
