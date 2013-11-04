package com.snsapp.mobile.view.spritesheet
{
	import flash.display.BitmapData;

	public class SpriteSheet
	{
		public var xml:XML;
		public var bmd:BitmapData;

		public function SpriteSheet(bmd:BitmapData, xml:XML)
		{
			this.xml = xml;
			this.bmd = bmd;
		}
	}
}
