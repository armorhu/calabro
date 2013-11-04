package com.arm.herolot.modules.battle.view.render
{
	import com.arm.herolot.Consts;
	import com.arm.herolot.modules.battle.battle.monster.Monster;
	import com.arm.herolot.services.utils.EmbedFont;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	public class MonsterRender extends Sprite
	{
		public var ANIMATE_TYPE_FIGHT:int = 1;
		public var ANIMATE_TYPE_SUFFER:int = 2;

		private var _mc:MovieClip;
		private const MONSTER_XML:XML = <TextureAtlas imagePath="atlas.png">
				<SubTexture name="a_0" x="0" y="0" width="32" height="32"/>
				<SubTexture name="a_1" x="32" y="0" width="32" height="32"/>
				<SubTexture name="a_2" x="64" y="0" width="32" height="32"/>
				<SubTexture name="a_3" x="96" y="0" width="32" height="32"/>
			</TextureAtlas>;

		private var _tfHp:TextField;
		private var _tfAck:TextField;
		private var _status:Sprite;
			
		public function MonsterRender(monster:Monster)
		{
			initialize(monster);
		}

		private function initialize(m:Monster):void
		{
			initializeTextField();
			setStatus(m.hp, m.ack);
			
			var assterURL:String = m.getAssetesURL();
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, onLoadComplete);
			loader.load(new URLRequest(assterURL));
		}
		
		private function initializeTextField():void
		{
			_status = new Sprite();
			
			_tfHp = new TextField(64, 32, "", EmbedFont.fontName, 16, 0xFF0000, true);
			_tfHp.vAlign = VAlign.CENTER;
			_tfHp.hAlign = HAlign.CENTER;
			_status.addChild(_tfHp);
			
			_tfAck = new TextField(64, 32, "", EmbedFont.fontName, 16, 0xFF0000, true);
			_tfAck.vAlign = VAlign.CENTER;
			_tfAck.hAlign = HAlign.CENTER;
			_status.addChild(_tfAck);
			
			_tfAck.y = _tfHp.height;
			
			_tfHp.touchable = false;
			_tfAck.touchable = false;
			_status.touchable = false;
			
			addChild(_status);
		}

		private function onLoadComplete(e:flash.events.Event):void
		{
			var loaderInfo:LoaderInfo = e.target as LoaderInfo;
			var bitmap:Bitmap = loaderInfo.content as Bitmap;
			var atlas:TextureAtlas = new TextureAtlas(Texture.fromBitmap(bitmap, false, false), MONSTER_XML);
			_mc = new MovieClip(atlas.getTextures('a'));
			_mc.width = Consts.TILE_SIZE;
			_mc.height = Consts.TILE_SIZE;
			addChildAt(_mc, 0);
			Starling.juggler.add(_mc);
			loaderInfo.removeEventListener(flash.events.Event.COMPLETE, onLoadComplete);
			loaderInfo.loader.unloadAndStop(true);
			bitmap.bitmapData.dispose();
			
			_status.x = (this.width - _status.width) * 0.5;
			_status.y = (this.height - _status.height);
		}
		
		public function update(m:Monster):void
		{
			setStatus(m.hp, m.ack);
		}
		
		private function setStatus(hp:int, ack:int):void
		{
			_tfHp.text = "hp:" + hp;
			_tfAck.text = "ack:" + ack;
		}

//		public function animate(type:int, function onAnimateComplete):void
//		{
//			switch(type)
//			{
//			case ANIMATE_TYPE_FIGHT:
//				//onAnimateComplete
//				break;
//			case ANIMATE_TYPE_SUFFER:
//				//onAnimateComplete
//				break;
//			}
//			//切回_normalAni
//		}

//		public function reset(monster:Monster)
//		{
//			if(_normalAni)
//			{
//				removeChild(_normalAni);
//				Starling.juggler.remove(_normalAni);
//			}
//			
//			if(_fightAni)
//			{
//				removeChild(_fightAni);
//				Starling.juggler.remove(_fightAni);
//			}
//			
//			if(_sufferAni)
//			{
//				removeChild(_sufferAni);
//				Starling.juggler.remove(_sufferAni);
//			}
//			//初始化MovieClip
//			
//		}
	}
}
