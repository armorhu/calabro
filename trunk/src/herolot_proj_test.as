package
{
	import com.arm.herolot.services.utils.Csv2asCommand;
	import com.qzone.qfa.managers.LoadManager;
	import com.qzone.qfa.managers.events.LoaderEvent;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.PNGEncoderOptions;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class herolot_proj_test extends Sprite
	{
		public function herolot_proj_test()
		{
			super();
			stage.scaleMode = "noScale";
			stage.align = "topLeft";

//			trace('o.ack = t.ack*3 + 1-5'.replace(/\-/g, '+-'));
//			var o:BattleEntity = new BattleEntity();
//			o.ack = 10, o.armor = 2, o.hp = 100, o.critFator = 1.5, o.speed = 10, o.dodge = 10, o.crit = 20;
//			var t:BattleEntity = new BattleEntity();
//			t.ack = 10, t.armor = 2, t.hp = 100, t.critFator = 1.5, t.speed = 10, t.dodge = 10, t.crit = 30;
//
//			EnhanceCapacityBuffer.excuteMathCmd('o.ack = o.ack + 1', o, t, null);
//			return;
//			var testRunner:TestRunner = new TestRunner();
//			this.addChild(testRunner);
//			testRunner.start(HerolotTestSuite);

//			new Csv2asCommand().start();

//			var ld:LoadManager = new LoadManager();
//			ld.maxThreadCount = 8;
//			ld.addEventListeners(loaderEventHandler);
//			var items:File = new File(File.applicationDirectory.resolvePath('res/pic/monsters').nativePath);
//			var itemFiles:Array = items.getDirectoryListing();
//			for (var i:int = 0; i < itemFiles.length; i++)
//			{
//				if ((itemFiles[i] as File).extension.toLocaleLowerCase() == 'png')
//					ld.add(itemFiles[i].url);
//			}
//			ld.start();
		}

		private function loaderEventHandler(evt:LoaderEvent):void
		{
			if (evt.type == LoaderEvent.COMPLETE)
			{
				var url:String = evt.item.url.replace('monsters', 'monsters2');
				var toFile:File = new File(url);
				var bitmap:Bitmap = evt.item.data as Bitmap;
				bitmap.scaleX = 4, bitmap.scaleY = 4;
				var bmd:BitmapData = new BitmapData(bitmap.width, bitmap.height);
				bmd.drawWithQuality(bitmap, bitmap.transform.matrix, null, null, null, true, StageQuality.BEST);
				evt.item.destroy();
				evt.item = null;
				var fs:FileStream = new FileStream();
				fs.open(toFile, FileMode.WRITE);
				fs.writeBytes(bmd.encode(bmd.rect, new PNGEncoderOptions()));
				fs.close();
			}
		}

	}
}
