package com.snsapp.starling.texture.implement
{
	import com.snsapp.mobile.view.bitmapclip.BitmapFrame;

	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	import starling.textures.Texture;
	import starling.utils.RectangleUtil;
	import starling.utils.getNextPowerOfTwo;

	/**
	 * 最简单的Texture。
	 * 封装了Texture的名字，引用计数等基础功能
	 * @author hufan
	 */
	public class SingleTexture extends TextureBase
	{
		private var _scaleX:Number;
		private var _scaleY:Number;
		private var _frameX:Number;
		private var _frameY:Number;
		private var _scale9Gird:Rectangle;

		public function SingleTexture()
		{
			super();
			_frameX = 0;
			_frameY = 0;
			_scaleX = 1;
			_scaleY = 1;
			_scale9Gird = null;
		}

		public override function toByteArray():ByteArray
		{
			if (_canvas == null)
				throw new Error("can not convert to byteArray");
			var ba:ByteArray = new ByteArray();
			ba.writeShort(SINGLE);
			ba.writeFloat(_frameX);
			ba.writeFloat(_frameY);
			ba.writeFloat(_scaleX);
			ba.writeFloat(_scaleY);

			var w:int = _canvas.width;
			var h:int = _canvas.height;
			ba.writeInt(w);
			ba.writeInt(h);
			var bytes:ByteArray = _canvas.getPixels(new Rectangle(0, 0, w, h));
			bytes.position = 0;
			ba.writeUnsignedInt(bytes.bytesAvailable);
			ba.writeBytes(bytes, 0, bytes.bytesAvailable);

			if (_scale9Gird)
			{
				ba.writeFloat(_scale9Gird.x);
				ba.writeFloat(_scale9Gird.y);
				ba.writeFloat(_scale9Gird.width);
				ba.writeFloat(_scale9Gird.height);
			}

			if (COMPRESS)
				ba.compress();
			ba.position = 0;
			return ba;
		}

		public function get pivotX():Number
		{
			return _frameX;
		}

		public function get pivotY():Number
		{
			return _frameY;
		}

		public function get scaleX():Number
		{
			return _scaleX;
		}

		public function get scaleY():Number
		{
			return _scaleY;
		}

		public function get width():Number
		{
			return _texture.width * _scaleX;
		}

		public function get height():Number
		{
			return _texture.height * _scaleY;
		}

		public function get scale9Grid():Rectangle
		{
			return _scale9Gird
		}

		public static function fromByteArray(bytes:ByteArray, name:String, compress:Boolean = false):SingleTexture
		{
			if (COMPRESS && compress == false)
				bytes.uncompress();
			bytes.position = 0;
			if (bytes.bytesAvailable >= 2)
				var flag:int = bytes.readShort();
			else
				throw new Error("decode from byteArray error!!");
			if (flag != SINGLE)
				throw new Error(name + "的材质格式不是SingleTexture!");

			if (bytes.bytesAvailable >= 4)
				var x:Number = bytes.readFloat();
			else
				throw new Error("decode from byteArray error!!");
			if (bytes.bytesAvailable >= 4)
				var y:Number = bytes.readFloat();
			else
				throw new Error("decode from byteArray error!!");

			if (bytes.bytesAvailable >= 4)
				var scaleX:Number = bytes.readFloat();
			else
				throw new Error("decode from byteArray error!!");
			if (bytes.bytesAvailable >= 4)
				var scaleY:Number = bytes.readFloat();
			else
				throw new Error("decode from byteArray error!!");

			//读位图
			if (bytes.bytesAvailable >= 4)
				var w:int = bytes.readInt();
			else
				throw new Error("decode from byteArray error!!");
			if (bytes.bytesAvailable >= 4)
				var h:int = bytes.readInt();
			else
				throw new Error("decode from byteArray error!!");
			if (bytes.bytesAvailable >= 4)
				var size:uint = bytes.readUnsignedInt();
			else
				throw new Error("decode from byteArray error!!");

			var ba:ByteArray = new ByteArray();
			if (bytes.bytesAvailable >= size)
				bytes.readBytes(ba, 0, size);
			else
				throw new Error("decode from byteArray error!!");

			if (bytes.bytesAvailable == 4 * 4)
			{
				var scale9Grid:Rectangle = new Rectangle();
				scale9Grid.x = bytes.readFloat();
				scale9Grid.y = bytes.readFloat();
				scale9Grid.width = bytes.readFloat();
				scale9Grid.height = bytes.readFloat();
			}

			var textureRes:SingleTexture = new SingleTexture;
			textureRes._canvas = new BitmapData(w, h, true, 0x0);
			textureRes._canvas.setPixels(new Rectangle(0, 0, w, h), ba);
			textureRes._frameX = x, textureRes._frameY = y;
			textureRes._scaleX = scaleX, textureRes._scaleY = scaleY;
			textureRes._scale9Gird = scale9Grid;
			ba.clear(), ba = null;
			textureRes.name = name;
			return textureRes;
		}

		public static function fromBitmapdata(bitmapFrame:BitmapFrame, name:String):SingleTexture
		{
			var t:SingleTexture = new SingleTexture();
			t._name = name;
			t._canvas = bitmapFrame.bmd;
			t._frameX = bitmapFrame.x;
			t._frameY = bitmapFrame.y;
			t._scaleX = bitmapFrame.scaleX;
			t._scaleY = bitmapFrame.scaleY;
			t._scale9Gird = bitmapFrame.scale9Grid;
			return t;
		}

		public static function fromTexture(texture:Texture, name:String, frameX:Number, frameY:Number, scaleX:Number, scaleY:Number, scale9Gird:Rectangle):SingleTexture
		{
			var t:SingleTexture = new SingleTexture();
			t._texture = texture;
			t._name = name;
			t._frameX = frameX;
			t._frameY = frameY;
			t._scaleX = scaleX;
			t._scaleY = scaleY;
			t._scale9Gird = scale9Gird;
			t._uploaded = true;
			return t;
		}
	}
}
