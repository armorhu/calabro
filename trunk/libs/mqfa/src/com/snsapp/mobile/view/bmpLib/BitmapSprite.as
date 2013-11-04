package com.snsapp.mobile.view.bmpLib
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	
	/**################################
	 *
	 * @author sevencchen
	 * @2012-9-8
	 * ###################################
	 */
	
	public class BitmapSprite extends Sprite
	{
		private var _bmp:Bitmap;
		private var _bmd:BitmapData;
		private var _mc:DisplayObject;
		private var _scale:Number;
		public function BitmapSprite(mc:DisplayObject,scale:Number=1,show:Boolean=true)
		{
			_mc = mc;
			_scale = scale;
			var rect:Rectangle = _mc.getBounds(_mc.parent);
			this.name =  mc.name;
			this.x = rect.x*_scale;
			this.y = rect.y*_scale;
			
			_bmp = new Bitmap();
			addChild(_bmp);
			if(show)
				update();
		}
		public function update():void
		{
			if(_bmp.bitmapData)
				_bmp.bitmapData.dispose();
			var rect:Rectangle = _mc.getBounds(_mc);
			var matx:Matrix = new Matrix;
			matx.scale(_scale,_scale);
			matx.translate(-rect.x*_scale,-rect.y*_scale);
			_bmd= new BitmapData(rect.width*_scale,rect.height*_scale,true,0);
			_bmd.drawWithQuality(_mc,matx,null,null,null,true,StageQuality.HIGH);
			_bmp.bitmapData = _bmd;
		}
		public function destory():void
		{
			if(_bmp.bitmapData)
				_bmp.bitmapData.dispose();
			if(this.parent)
				this.parent.removeChild(this);
		}
	}
}