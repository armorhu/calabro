package com.snsapp.starling.display
{
	import starling.display.Sprite;

	/**
	 * Starling层的PopupManager
	 * @author hufan
	 */
	public class StarlingPopUpManager
	{
		public static var layer:Sprite; //弹出层。

		public function StarlingPopUpManager()
		{
			
		}

		public static function show(view:Sprite):void
		{
			if (!layer.contains(view))
				layer.addChild(view);
		}

		public static function remove(view:Sprite):void
		{
			if (layer.contains(view))
				layer.removeChild(view);
		}
	}
}
