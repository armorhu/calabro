package com.snsapp.starling.texture.implement
{
	import com.qzone.utils.DisplayUtil;
	import com.snsapp.mobile.view.bitmapclip.BitmapFrame;

	import flash.geom.Point;
	import flash.text.AntiAliasType;
	import flash.text.TextField;

	/**
	 * @author hufan
	 */
	public class GPUTextFieldTexture
	{
		private var _charSet:String; //字符集
		private var _vector:TextField; //矢量TextField
		private var _texture:BatchTexture;
		private var _name:String;

		/**
		 * @param _charSet   位图文本的字符集
		 * @param textFormat 位图文本的显示设置
		 * @param texture    位图文本材质的Texture。支持传入外部的材质，位图动态生成的材质会
		 * 					 如果不传的话，他会自己生成一个新的。并在材质生成以后上传至显卡。
		 */
		public function GPUTextFieldTexture(name:String, texture:BatchTexture)
		{
			super();
			_texture = texture;
			_name = name;
			if (_texture == null)
				_texture = new BatchTexture(64, 64, true);
			_vector = new TextField();
			_vector.antiAliasType = AntiAliasType.ADVANCED;
			_vector.selectable = false;
			_vector.multiline = true;
			_vector.wordWrap = true;

//			_vector.defaultTextFormat = textFormat;
//			_vector.width = width;
//			_vector.height = height;
//			_vector.text = mText;
//			_vector.embedFonts = true;
//			_vector.filters = mNativeFilters;
		}

		public function createCharSetTexture(charSet:String):Vector.<Point>
		{
			_charSet = charSet;
			_vector.text = charSet;
			const len:int = _charSet.length;
			var sizes:Vector.<Point> = new Vector.<Point>();
			for (var i:int = 0; i < len; i++)
			{
				_vector.text = _charSet.charAt(i);
				_vector.width = _vector.textWidth;
				_vector.height = _vector.textHeight;
				var frame:BitmapFrame = DisplayUtil.cacheAsBitmap(_vector, 1, 1);
				texture.insert(name + "_" + _vector.text, frame);
				sizes.push(new Point(frame.bmd.width, frame.bmd.height));
				frame.dispose();
			}
			return sizes;
		}

		public function get vectorTF():TextField
		{
			return _vector;
		}

		public function get texture():BatchTexture
		{
			return _texture;
		}

		public function get name():String
		{
			return _name
		}
	}
}
