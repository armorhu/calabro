package com.arm.herolot.modules.battle.view.render
{
	import com.arm.herolot.Consts;
	import com.snsapp.starling.StarlingFactory;
	import com.snsapp.starling.texture.implement.BatchTexture;

	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;

	public class Tile extends Sprite
	{
		public static const TILE_TYPE_GROUND:int = 1;
		public static const TILE_TYPE_BLOCK:int = 2;

		private var _crashAni:MovieClip;
		private var _image:Image;
		private var _disableMark:Image;
		private var _ableMark:Image;
		private var _type:int;

		public function Tile(type:int, index:int, batch:BatchTexture)
		{
			_type = type;

			if (TILE_TYPE_GROUND == type)
				_image = StarlingFactory.newImage(batch.getTexture("ground_" + index));
			else if (TILE_TYPE_BLOCK == type)
			{
				_image = StarlingFactory.newImage(batch.getTexture("block_" + index));
				_image.alpha = 0.75;
				_disableMark = StarlingFactory.newImage(batch.getTexture("cross"));
				_ableMark = StarlingFactory.newImage(batch.getTexture("tick"));
					//_crashAni = new MovieClip(TempAssets.getAltas().getTextures(name + "_crash_0"), 10);
			}
			else
				throw new Error('bad value');

			_image.width = Consts.TILE_SIZE;
			_image.height = Consts.TILE_SIZE;
			addChild(_image);

			if (_disableMark)
			{
				_disableMark.width = Consts.TILE_SIZE;
				_disableMark.height = Consts.TILE_SIZE;
				_disableMark.visible = false;
				addChild(_disableMark);
			}

			if (_ableMark)
			{
				_ableMark.width = Consts.TILE_SIZE;
				_ableMark.height = Consts.TILE_SIZE;
				_ableMark.visible = false;
				addChild(_ableMark);
			}
		}

		public function showDisableMark(b:Boolean):void
		{
			_disableMark.visible = b;
			if (b)
				_ableMark.visible = false;
		}

		public function showAbleMark(b:Boolean):void
		{
			_ableMark.visible = b;
			if (b)
				_disableMark.visible = false;
		}
		
		public function reset():void
		{
			_disableMark.visible = _ableMark.visible = false;
		}

		override public function set visible(value:Boolean):void
		{
			if (!_crashAni)
			{
				super.visible = value;
				return;
			}

			if (super.visible == true && value == false)
			{
				_image.visible = false;
				_ableMark.visible = false;
				_disableMark.visible = false;
				addChild(_crashAni);
				Starling.juggler.add(_crashAni);
				_crashAni.addEventListener(Event.COMPLETE, onCrashComplete);
			}
			else if (super.visible == false && value == true)
			{
				super.visible = true;
				_image.visible = true;
			}
		}

		private function onCrashComplete(event:Event):void
		{
			_crashAni.removeEventListener(Event.COMPLETE, onCrashComplete);
			Starling.juggler.remove(_crashAni);
			removeChild(_crashAni);
			super.visible = false;
		}

		public function get type():int
		{
			return _type;
		}
	}
}
