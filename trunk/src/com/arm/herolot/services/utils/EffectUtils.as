package com.arm.herolot.services.utils
{
	import com.arm.herolot.Consts;
	import com.greensock.TweenLite;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.EaseLookup;
	import com.greensock.easing.Strong;

	public class EffectUtils
	{
		public function EffectUtils()
		{
		}

		/**
		 * 弹出，然后fadeOut
		 */
		public static function popup():void
		{
		}

		public static function die(object:Object):void
		{
			TweenLite.to(object, 0.5, {alpha: 0, y: object.y - Consts.TILE_SIZE});
		}

		public static function attack(object:Object):void
		{
		}

		public static function injured(object:Object):void
		{
		}
	}
}
