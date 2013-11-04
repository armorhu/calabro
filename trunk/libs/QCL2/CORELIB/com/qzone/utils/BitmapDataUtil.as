package com.qzone.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;

	public class BitmapDataUtil
	{
		public static function scaleBitmapData(bmpd:BitmapData, scale:Number, smoothing:Boolean = false):BitmapData
		{
			var w:int = bmpd.width;
			var h:int = bmpd.height;
			var bmp:Bitmap = new Bitmap(bmpd, "auto", smoothing);
			bmp.scaleX = scale, bmp.scaleY = scale;
			var temp:BitmapData = new BitmapData(bmp.width, bmp.height, true, 0x0);
			temp.draw(bmp, bmp.transform.matrix, null, null, null, smoothing);
			bmpd.dispose();
			return temp;
		}

		public static function scaleBitmapData2(bmpd:BitmapData, scaleX:Number, scaleY:Number, smoothing:Boolean = false):BitmapData
		{
			var w:int = bmpd.width;
			var h:int = bmpd.height;
			var bmp:Bitmap = new Bitmap(bmpd, "auto", smoothing);
			bmp.scaleX = scaleX, bmp.scaleY = scaleY;
			var temp:BitmapData = new BitmapData(bmp.width, bmp.height, true, 0x0);
			temp.draw(bmp, bmp.transform.matrix, null, null, null, smoothing);
			bmpd.dispose();
			return temp;
		}
	}
}
