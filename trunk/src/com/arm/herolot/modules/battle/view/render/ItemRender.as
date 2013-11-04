package com.arm.herolot.modules.battle.view.render
{
	import com.arm.herolot.Consts;
	import com.arm.herolot.HerolotApplication;
	import com.arm.herolot.modules.battle.battle.item.Item;
	import com.snsapp.starling.texture.TextureLoadEvent;
	import com.snsapp.starling.texture.implement.TextureBase;
	
	import flash.events.Event;
	
	import starling.display.Image;
	import starling.display.Sprite;

	public class ItemRender extends Sprite
	{
		private var _itemImage:Image;
		private var _itemTextureName:String;
		private var _itemTexture:TextureBase;
		
		public function ItemRender(item:Item)
		{
			super();
			setItem(item);
		}
		
		public function setItem(item:Item):void
		{
			_itemTextureName = HerolotApplication.instance.textureLoader.getCacheURL(item.getAssetesURL());
			HerolotApplication.instance.textureLoader.addEventListener(TextureLoadEvent.COMPLETE, onloadTexture);
			HerolotApplication.instance.textureLoader.requestTexture(item.getAssetesURL(), false);
		}
		
		protected function onloadTexture(event:TextureLoadEvent):void
		{
			if (event.texture.name == _itemTextureName)
			{
				if (_itemTexture)
					_itemTexture.useCount--;
				if (_itemImage == null)
				{
					_itemImage = new Image(event.texture.texture);
					_itemImage.width = Consts.TILE_SIZE;
					_itemImage.height = Consts.TILE_SIZE;
					addChild(_itemImage);
				}
				else
				{
					_itemImage.texture = event.texture.texture;
				}
				_itemTexture = event.texture;
				event.texture.useCount++;
				_itemImage.visible = true;
			}
		}
	}
}