package com.snsapp.starling.texture.implement
{
	import com.qzone.qfa.utils.CommonUtil;
	import com.qzone.utils.BitmapDataUtil;
	import com.qzone.utils.DisplayUtil;
	import com.snsapp.mobile.utils.MaxRectsBinPack;
	import com.snsapp.mobile.utils.minimumLegalSizeOf;
	import com.snsapp.mobile.view.bitmapclip.BitmapClipData;
	import com.snsapp.mobile.view.bitmapclip.BitmapFrame;
	import com.snsapp.mobile.view.spritesheet.SpriteSheet;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	/**
	 * 批量材质管理类。
	 * 能够动态的分布插入的贴图。接入了TextureAtlas，MaxRectsBinPack两个类。
	 * @author hufan
	 */
	public class BatchTexture extends TextureBase
	{
		private static const GAP:int=1;
		/**摆放矩形的算法**/
		protected var _placeRect:MaxRectsBinPack;
		protected var _xml:XML;
		protected var _atlas:TextureAtlas;
		protected var _textureSettings:Object;
		protected var _expand:Boolean;

		/**
		 * @param w 材质的初始长
		 * @param h	材质的初始宽度
		 * @param expand 当材质insert失败时，是否自动扩张
		 */
		public function BatchTexture(w:int, h:int, expand:Boolean)
		{
			if (w > 0 && h > 0)
			{
				_placeRect=new MaxRectsBinPack(w, h, false);
				_canvas=new BitmapData(w, h, true, 0x0);
				_xml=new XML(<TextureAtlas></TextureAtlas>);
			}
			_uploaded=false;
			_expand=expand;
			_textureSettings=new Object();
		}

		public override function upload():void
		{
			super.upload();
			_atlas=new TextureAtlas(_texture, _xml);
		}

		public function getAtlas():TextureAtlas
		{
			return _atlas;
		}

		public function insert(name:String, frame:BitmapFrame):void
		{
			if (_uploaded)
				throw new Error("BatchTexture is uploaded!!");
			var rect:Rectangle
			while (true)
			{
				rect=_placeRect.insert(frame.bmd.width + GAP * 2, frame.bmd.height + GAP * 2, 0);
				if (rect.width == 0)
					expandTexture();
				else
					break;
			}
			var subXML:XML
			rect.x+=GAP;
			rect.y+=GAP;
			subXML=new XML(<SubTexture />);
			subXML.@name=name;
			subXML.@x=rect.x;
			subXML.@y=rect.y;
			subXML.@width=frame.bmd.width;
			subXML.@height=frame.bmd.height;
			_textureSettings[name]={x: frame.x, y: frame.y, scaleX: frame.scaleX, scaleY: frame.scaleY};
			if (frame.scale9Grid)
			{
				_textureSettings[name]['scale9Grid']=new Object();
				_textureSettings[name]['scale9Grid'].x=frame.scale9Grid.x;
				_textureSettings[name]['scale9Grid'].y=frame.scale9Grid.y;
				_textureSettings[name]['scale9Grid'].w=frame.scale9Grid.width;
				_textureSettings[name]['scale9Grid'].h=frame.scale9Grid.height;
			}
			_canvas.copyPixels(frame.bmd, new Rectangle(0, 0, frame.bmd.width, frame.bmd.height), rect.topLeft);
			_xml.appendChild(subXML);
		}


		public function insertBmd(name:String, bmd:BitmapData, scaleX:Number=1, scaleY:Number=1, qualityX:Number=1, qualityY:Number=1):void
		{
			bmd=BitmapDataUtil.scaleBitmapData2(bmd, scaleX * qualityX, scaleY * qualityY, true);
			insert(name, new BitmapFrame(bmd, 0, 0, 1 / qualityX, 1 / qualityY));
			bmd.dispose();
		}

		public function insertDisplayObject(name:String, displayObj:DisplayObject, scaleX:Number=1, scaleY:Number=1, qualityX:Number=1, qualityY:Number=1):void
		{
			displayObj.scaleX=scaleX * qualityX;
			displayObj.scaleY=scaleY * qualityY;
			var frame:BitmapFrame=DisplayUtil.cacheAsBitmap(displayObj, 1, 1);
			frame.scaleX=1 / qualityX;
			frame.scaleY=1 / qualityY;
			insert(name, frame);
			frame.dispose(), frame=null;
		}

		public function insertBitmapClip(prefix:String, bitmapclip:BitmapClipData):void
		{
			const len:int=bitmapclip.totalFrames;
			for (var i:int=0; i < len; i++)
				insert(prefix + "_" + i, bitmapclip.getFrame(i));
		}

		public function insertSpriteSheet(spriteSheet:SpriteSheet, scale:Number):void
		{
			var subTextures:XMLList=spriteSheet.xml.SubTexture;
			var subTexture:XML, clip:BitmapData;
			const len:int=subTextures.length();
			for (var i:int=0; i < len; i++)
			{
				subTexture=subTextures[i];
				clip=new BitmapData(subTexture.@width, subTexture.@height, true, 0x0);
				clip.copyPixels(spriteSheet.bmd, new Rectangle(subTexture.@x, subTexture.@y, clip.width, clip.height), new Point());
				if (scale != 1) //需要缩放。
					clip=BitmapDataUtil.scaleBitmapData(clip, scale);
				insert(subTexture.@name, new BitmapFrame(clip));
				clip.dispose();
			}
		}

		public function getTextures(prefix:String):Vector.<SingleTexture>
		{
			var names:Array=new Array();
			for (var name:String in _textureSettings)
				if (name.indexOf(prefix) == 0)
					names.push(name.replace(prefix, ""));
			names.sort(CommonUtil.sort_names);
			var v:Vector.<SingleTexture>=new Vector.<SingleTexture>();
			v.length=names.length;
			v.fixed=true;
			for (var i:int=0; i < v.length; i++)
				v[i]=getTexture(prefix + names[i]);

			return v;
		}

		public function getTexture(textureName:String):SingleTexture
		{
			var texture:Texture=_atlas.getTexture(textureName);
			var setting:Object=_textureSettings[textureName];
			var scaleRect:Rectangle;
			trace(textureName);
			if (setting['scale9Grid'] != undefined)
			{
				scaleRect=new Rectangle();
				scaleRect.x=setting['scale9Grid'].x;
				scaleRect.y=setting['scale9Grid'].y;
				scaleRect.width=setting['scale9Grid'].w;
				scaleRect.height=setting['scale9Grid'].h;
			}
			return SingleTexture.fromTexture(texture, textureName, setting.x, setting.y, setting.scaleX, setting.scaleY, scaleRect);
		}

		private function expandTexture():void
		{
			if (_expand == false)
				throw new Error("Batch Texture is OverSize!!");
			var newSize:Point=getUpLevelSize(_canvas.width, _canvas.height);
			if (newSize.x > 2048 || newSize.y > 2048)
				throw new Error("Batch Texture is OverSize!!");

			trace("expand batch texutre to", newSize);
			var newCanvas:BitmapData=new BitmapData(newSize.x, newSize.y, true, 0x0);
			var newPlaceRect:MaxRectsBinPack=new MaxRectsBinPack(newSize.x, newSize.y, false);
			var w:int, h:int, x:Number, y:Number;
			var rect:Rectangle;
			for each (var subXML:XML in _xml)
			{
				w=subXML.@width;
				h=subXML.@height;
				x=subXML.@x;
				y=subXML.@y;
				rect=newPlaceRect.insert(w + GAP * 2, h + GAP * 2, 0);
				rect.x+=GAP;
				rect.y+=GAP;
				newCanvas.copyPixels(_canvas, new Rectangle(x, y, w, h), rect.topLeft);
				subXML.@x=rect.x;
				subXML.@y=rect.y;
			}
			_canvas.dispose();
			_canvas=newCanvas;
			_placeRect.dispose();
			_placeRect=newPlaceRect;
		}

		private function getUpLevelSize(w:int, h:int):Point
		{
			if (w <= h)
				return new Point(w * 2, h);
			else
				return new Point(w, h * 2);
		}

		public override function dispose():void
		{
			super.dispose();
			if (_placeRect)
				_placeRect.dispose();
			_placeRect=null;
			if (_atlas)
				_atlas.dispose();
			_atlas=null;
			_xml=null;
		}

		public function get expand():Boolean
		{
			return _expand;
		}

		public override function toByteArray():ByteArray
		{
			if (_canvas == null || _xml == null || _placeRect == null)
				throw new Error("can not convert to byteArray");
			var ba:ByteArray=new ByteArray();
			ba.writeShort(BATCH);
			//写expand 标记
			ba.writeBoolean(_expand);

			//写xml
			var xmlStr:String=_xml.toString();
			var size:int=xmlStr.length;
			ba.writeInt(size);
			ba.writeUTFBytes(xmlStr);
			xmlStr=null;

			//写framePostions
			var frameJsonStr:String=JSON.stringify(_textureSettings);
			size=frameJsonStr.length;
			ba.writeInt(size);
			ba.writeUTFBytes(frameJsonStr);
			frameJsonStr=null;

			//写placeRect
			var temp:ByteArray=_placeRect.toByteArray();
			var ut:uint=temp.length;
			ba.writeUnsignedInt(ut);
			ba.writeBytes(temp, 0, ut);
			temp.clear(), temp=null;
			_placeRect.dispose(), _placeRect=null;

			//写位图
			var w:int=_canvas.width;
			var h:int=_canvas.height;
			ba.writeInt(w);
			ba.writeInt(h);
			var bytes:ByteArray=_canvas.getPixels(new Rectangle(0, 0, w, h));
			bytes.position=0;
			ba.writeUnsignedInt(bytes.bytesAvailable);
			ba.writeBytes(bytes, 0, bytes.bytesAvailable);
			bytes.clear(), bytes=null;
			if (COMPRESS)
				ba.compress();
			ba.position=0;
			return ba;
		}

		public static function fromByteArray(bytes:ByteArray, name:String, compress:Boolean=false):BatchTexture
		{
			if (COMPRESS && compress == false)
				bytes.uncompress();
			bytes.position=0;

			if (bytes.bytesAvailable >= 2)
				var flag:int=bytes.readShort();
			else
				throw new Error("decode from byteArray error!!");
			if (flag != BATCH)
				throw new Error(name + "的材质格式不是BatchTexture!");

			//读expand标记
			if (bytes.bytesAvailable >= 1)
				var expand:Boolean=bytes.readBoolean();
			else
				throw new Error("decode from byteArray error!!");
			//读xml
			if (bytes.bytesAvailable >= 4)
				var size:int=bytes.readInt();
			else
				throw new Error("decode from byteArray error!!");
			if (bytes.bytesAvailable >= size)
				var xmlStr:String=bytes.readUTFBytes(size);
			else
				throw new Error("decode from byteArray error!!");

			//读framePostion
			if (bytes.bytesAvailable >= 4)
				size=bytes.readInt();
			else
				throw new Error("decode from byteArray error!!");
			if (bytes.bytesAvailable >= size)
				var frameJsonStr:String=bytes.readUTFBytes(size);
			else
				throw new Error("decode from byteArray error!!");

			//读placeRect
			if (bytes.bytesAvailable >= 4)
				var ut:uint=bytes.readUnsignedInt();
			else
				throw new Error("decode from byteArray error!!");
			var temp:ByteArray=new ByteArray();
			if (bytes.bytesAvailable >= ut)
				bytes.readBytes(temp, 0, ut);
			else
				throw new Error("decode from byteArray error!!");
			//读位图
			if (bytes.bytesAvailable >= 4)
				var w:int=bytes.readInt();
			else
				throw new Error("decode from byteArray error!!");
			if (bytes.bytesAvailable >= 4)
				var h:int=bytes.readInt();
			else
				throw new Error("decode from byteArray error!!");
			if (bytes.bytesAvailable >= 4)
				size=bytes.readUnsignedInt();
			else
				throw new Error("decode from byteArray error!!");
			var ba:ByteArray=new ByteArray();
			if (bytes.bytesAvailable >= size)
				bytes.readBytes(ba, 0, size);
			else
				throw new Error("decode from byteArray error!!");
			var textureRes:BatchTexture=new BatchTexture(0, 0, expand);
			textureRes.name=name;
			textureRes._canvas=new BitmapData(w, h, true, 0x0);
			textureRes._canvas.setPixels(new Rectangle(0, 0, w, h), ba);
			ba.clear(), ba=null;
			textureRes._xml=new XML(xmlStr);
			textureRes._textureSettings=JSON.parse(frameJsonStr);
			textureRes._placeRect=MaxRectsBinPack.fromByteArray(temp);
			xmlStr=null, frameJsonStr=null;
			temp.clear(), temp=null;
			return textureRes;
		}


		public static const LEVEL:Array=[64, 128, 256, 512, 1024, 2048];

		public static function fromBitmapclipDatas(bmpcd:Vector.<BitmapClipData>, linkage:String):BatchTexture
		{
			var rects:Vector.<Point>=new Vector.<Point>();
			var area:int;
			const len1:int=bmpcd.length;
			for (var i:int=0; i < len1; i++)
			{
				const len2:int=bmpcd[i].totalFrames;
				for (var j:int=0; j < len2; j++)
				{
					rects.push(new Point(bmpcd[i].getFrameData(j).width, bmpcd[i].getFrameData(j).height));
					area+=rects[rects.length - 1].x * rects[rects.length - 1].y;
				}
			}

			var size:Point=minimumLegalSizeOf(area);
			var placedRect:Vector.<Rectangle>;
			if (size)
			{
				while (true)
				{
					placedRect=MaxRectsBinPack.batchInsert(size.x, size.y, rects, GAP);
					if (placedRect)
						break;
					if (size.x > size.y)
						size.y*=2;
					else
						size.x*=2;

					if (size.x > 2048 || size.y > 2048)
						break;
				}
			}

			if (placedRect == null)
				throw new Error(linkage + " is to big to build a texture!!");
			//没有满，则成功插入！
			var name:String="";
			var textureAnimalRes:BatchTexture=new BatchTexture(0, 0, false);
			textureAnimalRes._canvas=new BitmapData(size.x, size.y, true, 0x0);
			textureAnimalRes._xml=new XML(<TextureAtlas></TextureAtlas>);
			textureAnimalRes._placeRect=new MaxRectsBinPack(size.x, size.y, false);
			textureAnimalRes._name=linkage;
			var frame:BitmapFrame
			var subXML:XML;
			var temp:int;
			for (i=0; i < len1; i++)
			{
				const len3:int=bmpcd[i].totalFrames;
				for (j=0; j < len3; j++)
				{
					name=linkage + "_" + i + "_" + j;
					frame=bmpcd[i].getFrame(j);
					subXML=new XML(<SubTexture />);
					subXML.@name=name;
					subXML.@x=placedRect[temp].x + GAP;
					subXML.@y=placedRect[temp].y + GAP;
					subXML.@width=frame.bmd.width;
					subXML.@height=frame.bmd.height;
					textureAnimalRes._xml.appendChild(subXML);
					textureAnimalRes._textureSettings[name]={x: frame.x, y: frame.y, scaleX: frame.scaleX, scaleY: frame.scaleY};
					textureAnimalRes._canvas.copyPixels(frame.bmd, new Rectangle(0, 0, frame.bmd.width, frame.bmd.height), placedRect[temp].topLeft);
					temp++;
				}
			}
			return textureAnimalRes;
		}
	}
}
