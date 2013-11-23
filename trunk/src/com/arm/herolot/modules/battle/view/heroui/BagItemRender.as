package com.arm.herolot.modules.battle.view.heroui
{
	import com.arm.herolot.modules.battle.battle.item.Item;
	import com.snsapp.starling.display.Button;
	import com.snsapp.starling.texture.implement.SingleTexture;

	import starling.display.Image;
	import starling.text.TextField;

	public class BagItemRender extends Button
	{
		private var _itemIcon:Image;
		private var _itemAmount:TextField;

		public function BagItemRender(upState:SingleTexture)
		{
			super(upState, text, downState);
		}

		public function setItem(item:Item):void
		{
		}
	}
}
