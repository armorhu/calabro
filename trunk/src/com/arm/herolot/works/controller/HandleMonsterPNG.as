package com.arm.herolot.works.controller
{
	import com.qzone.qfa.interfaces.IApplication;
	import com.qzone.qfa.managers.resource.Resource;
	import com.qzone.qfa.managers.resource.ResourceLoader;
	import com.snsapp.mobile.mananger.workflow.SimpleWork;

	import flash.display.BitmapData;
	import flash.display.PNGEncoderOptions;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class HandleMonsterPNG extends SimpleWork
	{
		public function HandleMonsterPNG()
		{
			super(null);
		}

		override public function start():void
		{
			var bigPNG:BitmapData = new BIG();
			const HIGHT:int = 32;
			const len:int = Math.floor(2048 / HIGHT);
			const bmd:BitmapData = new BitmapData(128, HIGHT, true, 0x0);
			const folder:File = new File(ResourceLoader.VERSION_DICT + 'monsters/');
			const fs:FileStream = new FileStream();
			for (var i:int = 0; i < len; i++)
			{
				bmd.fillRect(bmd.rect, 0x0);
				bmd.copyPixels(bigPNG, new Rectangle(0, i * HIGHT, 128, HIGHT), new Point);
				fs.open(folder.resolvePath((31000 + i) + '.png'), FileMode.WRITE);
				fs.writeBytes(bmd.encode(bmd.rect, new PNGEncoderOptions));
				fs.close();
			}
		}
	}
}
