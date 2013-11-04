package com.snsapp.mobile.view.bmpLib
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.StageQuality;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	
	/**################################
	 * 
	 * @author sevencchen
	 * @2012-9-8
	 * ###################################
	 */
	
	public class BitmapIMG extends Bitmap
	{
		private var _mc:DisplayObject;
		private var _scale:Number;
		private var _bmd:BitmapData;
		public function BitmapIMG(mc:DisplayObject,scale:Number=1,show:Boolean=true)
		{
			_mc = mc;
			_scale = scale;
			
			var rect:Rectangle = _mc.getBounds(_mc.parent);
			this.name =  mc.name;
			this.x = rect.x*_scale;
			this.y = rect.y*_scale;
			if(show)
				update();
		}
		public function update():void
		{
			if(this.bitmapData)
				this.bitmapData.dispose();
			var rect:Rectangle = _mc.getBounds(_mc);
			var matx:Matrix = new Matrix;
			matx.scale(_scale,_scale);
			matx.translate(-rect.x*_scale,-rect.y*_scale);
			_bmd= new BitmapData(rect.width*_scale,rect.height*_scale,true,0);
			_bmd.drawWithQuality(_mc,matx,null,null,null,true,StageQuality.HIGH);
			this.bitmapData = _bmd;
		}
		public function destory():void
		{
			if(this.bitmapData)
				this.bitmapData.dispose();
			if(this.parent)
				this.parent.removeChild(this);
		}
	}
}