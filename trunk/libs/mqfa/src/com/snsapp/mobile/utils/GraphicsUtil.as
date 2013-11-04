package com.snsapp.mobile.utils
{
	import flash.display.Shape;
	import flash.display.Sprite;
	
	/**################################
	 * 
	 * @author sevencchen
	 * @2012-9-9
	 * ###################################
	 */
	
	public class GraphicsUtil
	{
		public static function createMask(x:Number,y:Number,w:Number,h:Number,rw:Number=0,rh:Number=0):Shape
		{
			var maskMC:Shape =  new Shape;
			maskMC.graphics.beginFill(0,0.5);
			if(rw!=0&&rh!=0)
				maskMC.graphics.drawRoundRect(x,y,w,h,rw,rh);
			else
				maskMC.graphics.drawRect(x,y,w,h);
			maskMC.graphics.endFill();
			return maskMC;
		}
		public static function createMaskSprite(x:Number,y:Number,w:Number,h:Number):Sprite
		{
			var maskMC:Sprite =  new Sprite;
			maskMC.graphics.beginFill(0,0.2);
			maskMC.graphics.drawRect(x,y,w,h);
			maskMC.graphics.endFill();
			return maskMC;
		}
	}
}