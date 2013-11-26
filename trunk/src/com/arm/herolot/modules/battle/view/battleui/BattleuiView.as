package com.arm.herolot.modules.battle.view.battleui
{
	import com.arm.herolot.HerolotApplication;
	import com.arm.herolot.Vars;
	import com.arm.herolot.modules.battle.battle.hero.HeroModel;
	import com.arm.herolot.modules.battle.battle.item.Item;
	import com.arm.herolot.modules.battle.model.battleui.BattleuiModel;
	import com.arm.herolot.modules.battle.texture.BattleTexture;
	import com.arm.herolot.services.utils.EmbedFont;
	import com.snsapp.starling.StarlingFactory;
	import com.snsapp.starling.texture.TextureLoadEvent;
	import com.snsapp.starling.texture.implement.BatchTexture;
	import com.snsapp.starling.texture.implement.SingleTexture;
	import com.snsapp.starling.texture.implement.TextureBase;

	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	/**
	 * 英雄信息&道具栏视图。。。
	 * PS：HeroLayer不妥，有没有更好的命名？
	 */
	public class BattleuiView extends Sprite
	{
		private var _heroIcon:Image;
		private var _heroTexture:TextureBase;
		private var _heroTextureName:String;
		private var _heroHP:TextField;
		private var _heroACK:TextField;
		private var _level:TextField;
		private var _itemContainer:Sprite;
		private var _batch:BatchTexture;
		private var _scale:Number;

		private const R:int = 2;
		private const C:int = 4;
		private var H_GAP:Number = 10;
		private var V_GAP:Number = 10;

		public function BattleuiView(batch:BatchTexture)
		{
			super();
			_scale = Vars.starlingScreenScale;
			_batch = batch;

			_level = addTextWithBg(140, 15); //level
			_heroHP = addTextWithBg(140, 65); //hp
			_heroACK = addTextWithBg(140, 115); //ack
			_level.hAlign = HAlign.CENTER;

			//物品栏
			_itemContainer = new Sprite();
			_itemContainer.x = 300 * _scale;
			_itemContainer.y = 15 * _scale;
			addChild(_itemContainer);
			var item:BagItemRender;
			const texture:SingleTexture = _batch.getTexture(BattleTexture.EQUIP_BOX);
			const cell:Number = texture.width;
			for (var i:int = 0; i < R; i++)
			{
				for (var j:int = 0; j < C; j++)
				{
					item = new BagItemRender(texture);
					item.x = j * (cell + H_GAP);
					item.y = i * (cell + V_GAP);
					item.addEventListener(Event.TRIGGERED, tiggerItemBox);
					_itemContainer.addChild(item);
				}
			}
		}

		/**
		 * 设置英雄数据
		 */
		private function setHeroData(hero:HeroModel):void
		{
			//加载英雄头像
			HerolotApplication.instance.textureLoader.addEventListener(TextureLoadEvent.COMPLETE, onLoadTextureComplete);
			_heroTextureName = HerolotApplication.instance.textureLoader.getCacheURL(hero.config.SmallPicURL);
			HerolotApplication.instance.textureLoader.requestTexture(hero.config.SmallPicURL, false);
			_heroHP.text = '生命:' + hero.hp;
			_heroACK.text = '攻击:' + hero.ack;
		}

		public function setBattleuiModel(data:Object):void
		{
			var model:BattleuiModel = data as BattleuiModel;
			model.addEventListener(Event.CHANGE, modelChangeHandler);
			validate(model);
		}

		private function modelChangeHandler(evt:Event):void
		{
			validate(evt.target as BattleuiModel);
		}

		protected function validate(model:BattleuiModel):void
		{
			setHeroData(model.hero);
		}


		/**
		 * 设置关卡数据
		 */
		public function setLevel(level:int):void
		{
			_level.text = '第' + level + '层';
		}

		/**
		 * 设置物品数据
		 */
		private function setItemData(items:Vector.<Item>):void
		{
			const len:int = _itemContainer.numChildren;
			var item:Item, render:BagItemRender;
			for (var i:int = 0; i < len; i++)
			{
				render = _itemContainer.getChildAt(i) as BagItemRender;
				if (items && items.length > i)
					render.setItem(items[i]);
				else
					render.setItem(null);
			}
		}

		private function tiggerItemBox(evt:Event):void
		{
		}


		private function onLoadTextureComplete(e:TextureLoadEvent):void
		{
			if (e.texture.name == _heroTextureName)
			{
				HerolotApplication.instance.textureLoader.removeEventListener(TextureLoadEvent.COMPLETE, onLoadTextureComplete);
				_heroIcon = StarlingFactory.newImage(e.texture as SingleTexture);
				_heroTexture = e.texture;
				_heroTexture.useCount++;
				_heroIcon.x = 10 * Vars.starlingScreenScale;
				_heroIcon.y = 10 * Vars.starlingScreenScale;
				addChild(_heroIcon);
			}
		}

		protected function addTextWithBg(px:Number, py:Number, p:Sprite = null):TextField
		{
			var bg:Image = addChildImage(BattleTexture.TF_BG, px, py, p);
			var tf:TextField = addTextField('', bg.width - 16, 27, px + 8, py + 3, 22, 0x0);
			return tf;
		}

		protected function addTextField(text:String, w:Number, h:Number, px:Number = 0, py:Number = 0, size:uint = 28, color:uint = 0x0, p:Sprite = null):TextField
		{
			var tf:TextField = new TextField(w * _scale, h * _scale, text, EmbedFont.fontName, size * _scale, color);
			tf.vAlign = VAlign.TOP;
			tf.hAlign = HAlign.LEFT;
			return addChildAtPos(tf, px, py, p) as TextField;
		}

		protected function addChildImage(textureName:String, px:Number = 0, py:Number = 0, p:Sprite = null):Image
		{
			var image:Image = StarlingFactory.newImage(_batch.getTexture(textureName));
			image.name = textureName;
			return addChildAtPos(image, px, py, p) as Image;
		}

		protected function addChildAtPos(displayObj:DisplayObject, px:Number = 0, py:Number = 0, p:Sprite = null):DisplayObject
		{
			if (p == null)
				p = this;
			displayObj.x = px * _scale;
			displayObj.y = py * _scale;
			p.addChild(displayObj);
			return displayObj;
		}

		public function get heroView():DisplayObject
		{
			return _heroIcon;
		}
	}
}
