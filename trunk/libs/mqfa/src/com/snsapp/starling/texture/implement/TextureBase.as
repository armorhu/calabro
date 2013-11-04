package com.snsapp.starling.texture.implement
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import starling.textures.Texture;

	public class TextureBase
	{
		public static var SIZE:Number = 0;
		public static const COMPRESS:Boolean = true;
		public static const BATCH:int = 10001;
		public static const SINGLE:int = 10002;

		protected var _canvas:BitmapData;
		protected var _uploaded:Boolean;
		protected var _size:int;
		protected var _name:String;
		protected var _texture:Texture;
		private var _useCount:int;
		private var _maxUseCount:int;

		public function TextureBase()
		{
		}

		public function get uploaded():Boolean
		{
			return this._uploaded
		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}

		public function get useCount():int
		{
			return _useCount;
		}

		public function set useCount(value:int):void
		{
			if (_uploaded == false)
				throw new Error("Texture:" + _name + " not uploaded!!");
			_useCount = value;
			if (_useCount > _maxUseCount)
				_maxUseCount = _useCount;
		}

		public function get maxUseCount():int
		{
			return _maxUseCount;
		}

		public function upload():void
		{
			if (_uploaded)
				throw new Error("Texture:" + _name + " is uploaded!!");
			var time:int = getTimer();
			trace("upload:", _name);
			_texture = Texture.fromBitmapData(_canvas, false);
			_uploaded = true;
			_size = _texture.width * _texture.height * 4;
			SIZE += _size;
//			if (!Starling.handleLostContext)
//				_canvas.dispose();
			//			Debugger.log("upload:" + _name + ",耗时:" + (getTimer() - time) + "ms", LogType.ASSERT);
		}

//		public function unload():void
//		{
//			if (_uploaded)
//			{
//				trace('unload:', _name);
//				_texture.dispose();
//				_texture = null;
//				_uploaded = false;
//				SIZE -= _size;
//			}
//		}

		public function dispose():void
		{
			trace("dispose:", _name);
			if (_canvas)
				_canvas.dispose();
			_canvas = null;
			if (_uploaded)
			{
				if (_texture)
					_texture.dispose();
				_texture = null;
				SIZE -= _size;
				_uploaded = false;
			}
		}

		public function get bitmapdata():BitmapData
		{
			return _canvas;
		}

		public function get texture():Texture
		{
			return _texture;
		}

		public function toByteArray():ByteArray
		{
			throw new Error('pls implements by sub class!!!');
		}

		public static function fromByteArray(bytes:ByteArray, name:String):TextureBase
		{
			if (COMPRESS)
				bytes.uncompress();
			bytes.position = 0;
			if (bytes.bytesAvailable > 2)
				var flag:int = bytes.readShort();
			else
				throw new Error("decode from byteArray error!!");

			if (flag == BATCH)
				return BatchTexture.fromByteArray(bytes, name, true);
			else if (flag == SINGLE)
				return SingleTexture.fromByteArray(bytes, name, true);
			else
				throw new Error('unkonw texture format!');
		}
	}
}
