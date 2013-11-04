package com.snsapp.starling.display.textfield
{
	import com.snsapp.mobile.StageInstance;
	import com.snsapp.mobile.view.spritesheet.SpriteSheet;

	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;

	import starling.utils.HAlign;

	public class StarlingTextFieldTexture
	{
		public static const sNativeTextField:TextField = new TextField();

		public static function create(name:String, width:Number, height:Number, charset:String, tf:TextFormat, scale:Number):SpriteSheet
		{
			sNativeTextField.width = width;
			sNativeTextField.height = height;
			sNativeTextField.defaultTextFormat = tf;
			sNativeTextField.antiAliasType = AntiAliasType.ADVANCED;
			sNativeTextField.selectable = false;
			sNativeTextField.multiline = true;
			sNativeTextField.wordWrap = true;
			sNativeTextField.embedFonts = true;
			sNativeTextField.text = charset;
			var textWidth:Number = sNativeTextField.textWidth;
			var textHeight:Number = sNativeTextField.textHeight;
//			var xOffset:Number = 0.0;
			var mHAlign:String = tf.align;
//			if (mHAlign == HAlign.LEFT)
//				xOffset = 2; // flash adds a 2 pixel offset
//			else if (mHAlign == HAlign.CENTER)
//				xOffset = (width - textWidth) / 2.0;
//			else if (mHAlign == HAlign.RIGHT)
//				xOffset = width - textWidth - 2;
			var yOffset:Number = (height - textHeight) / 2.0;
			var bitmapData:BitmapData = new BitmapData(width, height, true, 0x0);
			var xmls:XML = new XML(<TextureAtlas></TextureAtlas>);
//			xOffset*= scale;
//			yOffset*= scale;
			var matrix:Matrix = new Matrix(1, 0, 0, 1, 0, int(yOffset) - 2);
			matrix.scale(scale, scale);
			sNativeTextField.scaleX = sNativeTextField.scaleY;
			bitmapData.draw(sNativeTextField, matrix);
			var subXML:XML, rect:Rectangle;
			StageInstance.stage.addChild(sNativeTextField);
			for (var i:int = 0; i < charset.length; i++)
			{
				subXML = new XML(<SubTexture />);
				rect = sNativeTextField.getCharBoundaries(i);
				subXML.@name = name + "_" + charset.charAt(i);
				subXML.@x = rect.x * scale;
				subXML.@y = rect.y * scale;
				subXML.@width = rect.width * scale;
				subXML.@height = rect.height * scale;
				xmls.appendChild(subXML);
			}
			sNativeTextField.text = "";

			return new SpriteSheet(bitmapData, xmls);
		}
	}
}
