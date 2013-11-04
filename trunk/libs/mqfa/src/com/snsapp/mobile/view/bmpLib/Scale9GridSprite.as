package com.snsapp.mobile.view.bmpLib
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	/**################################
	 * 九宫格缩放
	 * @author sevencchen
	 * @2012-9-22
	 * ###################################
	 */
	
	public class Scale9GridSprite extends Sprite
	{
		private var _graphics:BitmapData;
		private var _cWidth:Number;
		private var _cHeight:Number;
		private var _width:Number;
		private var _height:Number;
		
		public function Scale9GridSprite(target:DisplayObject,cWidth:Number=0,cHeight:Number=0)
		{
			_cWidth = cWidth;
			_cHeight = cHeight;
			var rect:Rectangle = target.getBounds(target);
			var matx:Matrix = new Matrix;
			matx.translate(-rect.x,-rect.y);
			_graphics = new BitmapData(target.width,target.height,true,0);
			_graphics.drawWithQuality(target,matx,null,null,null,true,StageQuality.HIGH);
		}
		override public function set height(h:Number):void
		{
			_height = h - _cHeight*2;
		}
		override public function set width(w:Number):void
		{
			_width = w - _cWidth*2;
		}
		
		public function createSprite():void
		{
			getBmd(new Rectangle(0,0,_cWidth,_cHeight),new Rectangle(0,0,_cWidth,_cHeight));//LT
			getBmd(new Rectangle(_cWidth,0,_cWidth,_cHeight),new Rectangle(_cWidth,0,_width,_cHeight));//TT
			getBmd(new Rectangle(_graphics.width - _cWidth,0,_cWidth,_cHeight),new Rectangle(_width + _cWidth,0,_cWidth,_cHeight));//RT
			getBmd(new Rectangle(0,_cHeight,_cWidth,_cHeight),new Rectangle(0,_cHeight,_cWidth,_height));//LC
			getBmd(new Rectangle(_cWidth,_cHeight,_cWidth,_cHeight),new Rectangle(_cWidth,_cHeight,_width,_height));//CC
			getBmd(new Rectangle(_graphics.width - _cWidth,_cHeight,_cWidth,_cHeight),new Rectangle(_width +_cWidth,_cHeight,_cWidth,_height));//RC
			getBmd(new Rectangle(0,_graphics.height - _cHeight,_cWidth,_cHeight),new Rectangle(0,_height+_cHeight,_cWidth,_cHeight));//LB
			getBmd(new Rectangle(_cWidth,_graphics.height - _cHeight,_cWidth,_cHeight),new Rectangle(_cWidth,_height+_cHeight,_width,_cHeight));//CB
			getBmd(new Rectangle(_graphics.width - _cWidth,_graphics.height - _cHeight,_cWidth,_cHeight),new Rectangle(_width + _cWidth,_height + _cHeight,_cWidth,_cHeight));//RB
			this.graphics.endFill();
		}
		private function getBmd(bmdRect:Rectangle,drawRect:Rectangle,repeat:Boolean=false):void
		{
			var bmd:BitmapData = new BitmapData(_cWidth,_cHeight,true,0);
			bmd.copyPixels(_graphics,bmdRect,new Point(0,0));
			var matx:Matrix = new Matrix;
			matx.translate(drawRect.x,drawRect.y);
			this.graphics.beginBitmapFill(bmd,matx,repeat);
			this.graphics.drawRect(drawRect.x,drawRect.y,drawRect.width,drawRect.height);
		}
	}
}