package com.arm.herolot.services.utils
{

	public class GameMath
	{
		public static function random(probability:Number):Boolean
		{
			return Math.random() < probability;
		}

	}
}
