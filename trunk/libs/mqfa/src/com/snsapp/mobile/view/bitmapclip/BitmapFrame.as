package com.snsapp.mobile.view.bitmapclip
{
	import com.qzone.utils.DisplayUtil;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	public class BitmapFrame
	{
		public var bmd:BitmapData;
		public var x:Number;
		public var y:Number;
		public var scaleX:Number;
		public var scaleY:Number;
		public var scale9Grid:Rectangle;

		public function BitmapFrame(bmd:BitmapData=null, x:Number=0, y:Number=0, scaleX:Number=1, scaleY:Number=1)
		{
			this.bmd=bmd;
			this.x=x;
			this.y=y;
			this.scaleX=scaleX;
			this.scaleY=scaleY;
		}

		public function dispose():void
		{
			if (bmd)
				bmd.dispose();
		}

		public function serialize():ByteArray
		{
			var ba:ByteArray=new ByteArray();
			var bpdBytes:ByteArray;
			bpdBytes=bmd.getPixels(new Rectangle(0, 0, bmd.width, bmd.height));
			bpdBytes.position=0;

			ba.writeUnsignedInt(bpdBytes.bytesAvailable); //位图大小
			ba.writeInt(bmd.width); //位图长
			ba.writeInt(bmd.height); //位图宽
			ba.writeFloat(x); //帧坐标，x
			ba.writeFloat(y); //帧坐标，y
			ba.writeFloat(scaleX); //帧坐标，x
			ba.writeFloat(scaleX); //帧坐标，y
			ba.writeBytes(bpdBytes, 0, bpdBytes.bytesAvailable); //位图内容。

			if (scale9Grid)
			{
				ba.writeFloat(scale9Grid.x);
				ba.writeFloat(scale9Grid.y);
				ba.writeFloat(scale9Grid.width);
				ba.writeFloat(scale9Grid.height);
			}

			bpdBytes.clear();
			bpdBytes=null;
			ba.position=0;
			return ba;
		}

		public static function fromByteArray(value:ByteArray):BitmapFrame
		{
			var bmpcd:BitmapFrame=new BitmapFrame();
			var bmd:BitmapData;
			var size:uint; //位图大小
			var w:int; //位图宽
			var h:int; //位图高
			var x:Number; //帧坐标x
			var y:Number; //帧坐标y
			var scaleX:Number;
			var scaleY:Number;
			var ba:ByteArray;

			if (value.bytesAvailable >= 4)
				size=value.readUnsignedInt();
			else
				throw new Error("BitmapFrame deserialize error!");
			if (value.bytesAvailable >= 4)
				w=value.readInt();
			else
				throw new Error("BitmapFrame deserialize error!");
			if (value.bytesAvailable >= 4)
				h=value.readInt();
			else
				throw new Error("BitmapFrame deserialize error!");
			if (value.bytesAvailable >= 4)
				x=value.readFloat();
			else
				throw new Error("BitmapFrame deserialize error!");
			if (value.bytesAvailable >= 4)
				y=value.readFloat();
			else
				throw new Error("BitmapFrame deserialize error!");
			if (value.bytesAvailable >= 4)
				scaleX=value.readFloat();
			else
				throw new Error("BitmapFrame deserialize error!");
			if (value.bytesAvailable >= 4)
				scaleY=value.readFloat();
			else
				throw new Error("BitmapFrame deserialize error!");

			ba=new ByteArray();
			if (value.bytesAvailable >= size)
				value.readBytes(ba, 0, size);
			else
				throw new Error("BitmapFrame deserialize error!");

			if (value.bytesAvailable == 4 * 4)
			{
				var scale9Grid:Rectangle=new Rectangle();
				scale9Grid.x=value.readFloat();
				scale9Grid.y=value.readFloat();
				scale9Grid.width=value.readFloat();
				scale9Grid.height=value.readFloat();
			}

			var frame:BitmapFrame=new BitmapFrame();
			frame.bmd=new BitmapData(w, h, true, 0x0);
			frame.bmd.setPixels(new Rectangle(0, 0, w, h), ba);
			frame.x=x, frame.y=y, frame.scaleX=scaleX, frame.scaleY=scaleY;
			frame.scale9Grid=scale9Grid;
			ba.clear();
			ba=null;

			return frame;
		}

		public static function fromDisplayObj(displayObj:DisplayObject, scale:Number=1, quality_x:Number=1, quality_y:Number=1):BitmapFrame
		{
			displayObj.scaleX*=quality_x * scale;
			displayObj.scaleY*=quality_y * scale;
			var frame:BitmapFrame=DisplayUtil.cacheAsBitmap(displayObj, 1, 1, true, 0);
			frame.scaleX=1 / quality_x;
			frame.scaleY=1 / quality_y;
			frame.scale9Grid=displayObj.scale9Grid;
			if (frame.scale9Grid)
			{
				frame.scale9Grid.x*=displayObj.scaleX;
				frame.scale9Grid.y*=displayObj.scaleY;
				frame.scale9Grid.width*=displayObj.scaleX;
				frame.scale9Grid.height*=displayObj.scaleY;
			}
			return frame;
		}
	}
}
