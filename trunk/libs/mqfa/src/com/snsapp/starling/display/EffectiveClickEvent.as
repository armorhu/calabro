package com.snsapp.starling.display
{
	import starling.events.Event;

	/**
	 * 有效点击事件
	 * 有效点击事件。
     * 即MouseDown和MouseUp之间没有MouseMove的出现。
	 * @author hufan
	 */
	public class EffectiveClickEvent extends Event
	{
		public static const CLICK:String = "EffectiveClickEvent_Click";

		public function EffectiveClickEvent(type:String, bubbles:Boolean = false, data:Object = null)
		{
			super(type, bubbles, data);
		}
	}
}
