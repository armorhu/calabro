package com.snsapp.mobile.view.bitmapclip.vo
{
	import flash.geom.Point;

	/**
	 * 位图化参数
	 * @author hufan
	 */
	public class DrawSetting
	{
		/**改变这个值会改变输出Bitmapdata的大小，但不会在显示对象的scale体现出来**/
		public var scale:Number = 1;
		/**改变这个值会改变输出Bitmapdata的大小，而最终的显示对象的scaleX=1/quality_x**/
		public var quality_x:Number = 1;
		/**改变这个值会改变输出Bitmapdata的大小，而最终的显示对象的scaleY=1/quality_Y**/
		public var quality_y:Number = 1;
		/**可选项（仅在draw的对象为MovieClip时有效）：位图化MoviceClip时，draw的帧数的上限值。默认为MovieClip.totalFrames**/
		public var totalFrames:int = 0;
		/**可选项（仅在draw的对象为Sprite/Bitmap时有效）：如果位图超过了这个大小，则会改变quality_x&quality_y来保证最终的Bitmapdata小于这个Size**/
		public var maxSize:Point;
		/**可选项：扩展参数**/
		public var params:Object;

		public function DrawSetting(setting:Object)
		{
			if (setting)
			{
				scale = setting.hasOwnProperty('scale') ? setting.scale : 1;
				quality_x = setting.hasOwnProperty('quality_x') ? setting.quality_x : 1;
				quality_y = setting.hasOwnProperty('quality_y') ? setting.quality_y : 1;
				totalFrames = setting.hasOwnProperty('totalFrames') ? setting.totalFrames : 0;
				params = setting.params;
				maxSize = setting.maxSize;
			}
		}

		public function toString():String
		{
			return 'scaleX=' + (scale * quality_x).toFixed(1) + '&scaleY=' + (scale * quality_y).toFixed(1);
		}
	}
}
