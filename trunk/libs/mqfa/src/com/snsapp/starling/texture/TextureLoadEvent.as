package com.snsapp.starling.texture
{

	import com.snsapp.starling.texture.implement.TextureBase;

	import flash.events.Event;

	/**
	 * 材质加载成功事件
	 * @author hufan
	 */
	public class TextureLoadEvent extends Event
	{
		/**加载材质成功，且已经被上传到显卡里中。**/
		public static const COMPLETE:String = "TextureLoadEvent_Complete";
		/**加载材质成功，但是改材质还没有被上传到显卡中。**/
		public static const PRE_COMPLETE:String = 'TextureLoadEvent_Pre_Complete';
		public var texture:TextureBase;

		public function TextureLoadEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}

		override public function preventDefault():void
		{
			if (type == PRE_COMPLETE)
			{
				texture.dispose();
				texture = null;
			}
		}
	}
}
