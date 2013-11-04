package com.snsapp.mobile.utils
{
	import flash.display.Stage;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;

	/**
	 * 手机屏幕工具类
	 * @author Demon.S
	 *
	 */
	public final class MobileScreenUtil
	{
		/**
		 * for air project ,get screen size in landscape
		 * @param stage
		 * @return screen size
		 *
		 */
		public static function getScreenRectInLandScape(stage:Stage):Rectangle
		{
			var rect:Rectangle;
			if (stage && stage.fullScreenSourceRect)
				return stage.fullScreenSourceRect.clone();
            
			var h:int = stage.fullScreenHeight;
			var w:int = stage.fullScreenWidth;
			if (h > w)
				return new Rectangle(0, 0, h, w);
			return new Rectangle(0, 0, w, h);
		}
		
		
		/**
		 * for air project ,get screen size in landscape
		 * @param stage
		 * @return screen size
		 *
		 */
		public static function getScreenRectInPortrait(stage:Stage):Rectangle
		{
//			var rect:Rectangle;
//			if (stage && stage.fullScreenSourceRect)
//				return stage.fullScreenSourceRect.clone();
			
			var h:int = stage.fullScreenHeight;
			var w:int = stage.fullScreenWidth;
			if (h < w)
				return new Rectangle(0, 0, h, w);
			return new Rectangle(0, 0, w, h);
		}

		/**
		 * Convert inches to pixels.
		 */
		public static function inchesToPixels(inches:Number, dpi:uint = 0):uint
		{
			if (dpi == 0)
				dpi = Capabilities.screenDPI;

			return Math.round(dpi * inches);
		}

		/**
		 * Convert millimeters to pixels.
		 */
		public static function mmToPixels(mm:Number, dpi:uint = 0):uint
		{
			if (dpi == 0)
				dpi = Capabilities.screenDPI;
			return Math.round(dpi * (mm / 25.4));
		}

		/**
		 * get inch from pixel in dpi
		 * @param pixel
		 * @param dpi
		 * @return
		 *
		 */
		public static function getInchInPixel(pixel:uint, dpi:uint = 0):Number
		{
			if (dpi == 0)
				dpi = Capabilities.screenDPI;
			return pixel / dpi
		}
	}
}
