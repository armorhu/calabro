package com.snsapp.effect.cpu
{
	import com.snsapp.mobile.StageInstance;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;

	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.textures.Texture;

	public class Cloud extends Bitmap implements IAnimatable
	{
		/*
		下面的变量对柏林噪音的参数起作用。
		*/
		private var periodX:Number;
		private var periodY:Number;
		private var seed:int;
		private var offsets:Array;
		private var numOctaves:int;
		private var cmf:ColorMatrixFilter;
		private var frameDelay:Number;

		public function Cloud(w:Number, h:Number, fps:int = 12, quality:Number = 1)
		{
			var bmd:BitmapData = new BitmapData(w * quality, h * quality, true, 0x0);
			this.scaleX = 1 / quality;
			this.scaleY = 1 / quality;
			frameDelay = 1 / fps;
			super(bmd);
			initialize();
		}

		private function initialize():void
		{
			//periodX, periodY, numOctaves ：determine properties of our Perlin noise and
			//决定了我们柏林噪音的属性以及云彩的呈现。
			//较小的周期值，导致高水平和垂直频度产生小而源源不断的云朵。
			//较小的音度值、音度数量会给云朵不仅好看的外表且CPU也表现的很配合，尤其对于大型的图像而言这样做很好。
			//柏林噪音是很消耗CPU的。在我们例子中，通过设置periodX = 150。
			//periodY = 60,numOctaves = 3,你会得到一个漂亮的天空
			//那就会运行更高的FPS
			periodX = 150;
			periodY = 60;
			numOctaves = 3;

//			periodX = 60;
//			periodY = 60;
//			numOctaves = 15;

			//为了得到我们的灰阶柏林噪声，我们要用到ColorMatrixFilter类，cmf，这是让perlinData中较暗的像素
			//变得更加透亮的滤镜，让蓝空展现出来。
			//应用了cmf之后，一些像素会比其他的像素透明但是它们会转变成白色。
			cmf = new ColorMatrixFilter([0, 0, 0, 0, 255, 0, 0, 0, 0, 255, 0, 0, 0, 0, 255, 1, 0, 0, 0, 0]);

			//在柏林噪声中我们选择随机的“种子”，然后创建offsets数组对象。
			seed = int(Math.random() * 10000);
			offsets = new Array();
			for (var i:int = 0; i <= numOctaves - 1; i++)
			{
				offsets.push(new Point());
			}
		}

		private var timePast:Number;

		public function advanceTime(time:Number):void
		{
			timePast += time;
			if (timePast > frameDelay)
			{
				var i:int;
				//白云运动就更新柏林噪声的offsets。
				for (i = 0; i <= numOctaves - 1; i++)
				{
					offsets[i].x += 3;
					offsets[i].y += .6;
				}
				//我们创建一个灰阶的柏林噪声，
				//并给它应用ColorMateixFilter类的cmf实例。

				bitmapData.perlinNoise(periodX, periodY, numOctaves, seed, false, true, 1, true, offsets);
				bitmapData.applyFilter(bitmapData, bitmapData.rect, new Point(), cmf);
				timePast = 0;
			}
		}

		public function play():void
		{
			timePast = 0;
			Starling.juggler.add(this);
		}

		public function stop():void
		{
			Starling.juggler.remove(this);
		}
	}
}
