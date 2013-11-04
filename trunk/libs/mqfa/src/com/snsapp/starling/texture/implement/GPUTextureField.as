package com.snsapp.starling.texture.implement
{
	import flash.text.TextFormatAlign;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;

	public class GPUTextureField extends Sprite
	{
		private var _text:String;
		private var _algin:String;
		private var _perfix:String;
		private var _charSet:String;
		private var _texture:BatchTexture;

		public function GPUTextureField(texture:BatchTexture, perfix:String, charSet:String)
		{
			super();
			_texture = texture;
			_algin = TextFormatAlign.CENTER;
			_perfix = perfix;
			_charSet = charSet;
		}

		public function set align(value:String):void
		{
			_algin = value;
			alignAt(_algin);
		}

		public function set text(value:String):void
		{
			if (text == value)
				return;
			removeChildren(0, -1, true);
			_text = value;
			const len:int = value.length;
			var image:Image;
			for (var i:int = 0; i < len; i++)
			{
				image = new Image(getCharTexture(value.charAt(i)));
				image.x = this.width;
				addChildAt(image, 0);
			}

			alignAt(_algin);
		}

		private function getCharTexture(char:String):Texture
		{
			if (char.length > 1)
				throw new Error("请传入单个字符");
			return _texture.getTexture(_perfix + "_" + char).texture;
		}

		private function alignAt(prolicy:String):void
		{
			var start:Number = 0;
			if (prolicy == TextFormatAlign.CENTER)
				start = -width / 2;
			else if (prolicy == TextFormatAlign.LEFT)
				start = 0;
			else if (prolicy == TextFormatAlign.RIGHT)
				start = -width;
			const len:int = numChildren;
			for (var i:int = len - 1; i >= 0; i--)
			{
				getChildAt(i).x = start;
				start += getChildAt(i).width;
			}
		}

		public function get text():String
		{
			return _text;
		}
	}
}
