package com.snsapp.mobile.view.bitmapclip
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	/**
	 * 包含一个BitmapClip需要的显示数据
	 * BitmapClip-->BitmapClipData类似于Bitmap--->Bitmapdata
	 * @author hufan
	 */
	public class BitmapClipData
	{
		protected var _frames:Vector.<BitmapFrame>;

		/**
		 *
		 * @param bitmapdatas
		 * @param _postions
		 */
		public function BitmapClipData(frames:Vector.<BitmapFrame> = null)
		{
			_frames = frames;
			if (_frames == null)
				_frames = new Vector.<BitmapFrame>();
		}

		public function getFrameData(index:int):BitmapData
		{
			if (index < 0 || index >= totalFrames)
				throw new ArgumentError("index越界!");

			return _frames[index].bmd;
		}

		public function getFramePostion(index:int):Point
		{
			if (index < 0 || index >= totalFrames)
				throw new ArgumentError("index越界!");
			return new Point(_frames[index].x, _frames[index].y);
		}

		public function getFrame(index:int):BitmapFrame
		{
			if (index < 0 || index >= totalFrames)
				throw new ArgumentError("index越界!");

			return _frames[index];
		}

		public function get totalFrames():int
		{
			return this._frames.length;
		}

		public function dispose():void
		{
			const len:int = totalFrames;
			for (var i:int = 0; i < len; i++)
				_frames[i].dispose();
		}

		public function push(frame:BitmapFrame):void
		{
			_frames.push(frame);
		}

		public function get rects():Vector.<Point>
		{
			var rets:Vector.<Point> = new Vector.<Point>();
			rets.length = _frames.length, rets.fixed = true;
			for (var i:int = 0; i < rets.length; i++)
				rets[i] = new Point(_frames[i].bmd.width, _frames[i].bmd.height);
			return rets;
		}

		/**
		 * 序列化
		 * @return
		 *
		 */
		public function serialize():ByteArray
		{
			var ba:ByteArray = new ByteArray();
			const len:int = totalFrames;
			var bpdBytes:ByteArray;
			for (var i:int = 0; i < len; i++)
			{
				bpdBytes = _frames[i].serialize();
				ba.writeBytes(bpdBytes, 0, bpdBytes.bytesAvailable); //位图内容。
				bpdBytes.clear();
				bpdBytes = null;
			}
			ba.position = 0;
			return ba;
		}

		/**
		 * 反序列化
		 * @param value
		 * @return
		 */
		public static function deserialize(value:ByteArray):BitmapClipData
		{
			var bcpd:BitmapClipData = new BitmapClipData();
			var frame:BitmapFrame;
			while (value.bytesAvailable)
			{
				frame = BitmapFrame.fromByteArray(value);
				bcpd.push(frame);
			}
			return bcpd;
		}
	}
}
