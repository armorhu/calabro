package com.snsapp.starling
{
	import com.snsapp.starling.display.TextureClip;
	import com.snsapp.starling.texture.implement.BatchTexture;
	import com.snsapp.starling.texture.implement.SingleTexture;
	
	import feathers.display.Scale9Image;
	import feathers.textures.Scale9Textures;
	
	import starling.display.DisplayObject;
	import starling.display.Image;

	public class StarlingFactory
	{
		public static function newImage(texture:SingleTexture):Image
		{
			var image:Image=new Image(texture.texture);
			image.pivotX=texture.pivotX;
			image.pivotY=texture.pivotY;
			image.scaleX=texture.scaleX;
			image.scaleY=texture.scaleY;
			return image;
		}

		public static function newScale9Image(texture:SingleTexture):Scale9Image
		{
			var s9Texture:Scale9Textures=new Scale9Textures(texture.texture, texture.scale9Grid);
			var scale9Image:Scale9Image=new Scale9Image(s9Texture, texture.scaleX);
//			scale9Image.pivotX=texture.pivotX;
//			scale9Image.pivotY=texture.pivotY;
//			scale9Image.scaleX=texture.scaleX;
//			scale9Image.scaleY=texture.scaleY;
			return scale9Image;
		}

		public static function newDisplayObj(texture:SingleTexture):DisplayObject
		{
			if (texture.scale9Grid)
				return newScale9Image(texture);
			else
				return newImage(texture);
		}

		public static function setTexture(image:Image, texture:SingleTexture):Image
		{
			image.texture=texture.texture;
			image.width=texture.texture.width;
			image.height=texture.texture.height;
			image.pivotX=texture.pivotX / image.scaleX;
			image.pivotY=texture.pivotY / image.scaleY;
			image.scaleX*=texture.scaleX;
			image.scaleY*=texture.scaleY;
			return image;
		}

		public static function newTexureClip(texture:BatchTexture, fps:int=12):TextureClip
		{
			var clip:TextureClip=new TextureClip(texture.getTextures(texture.name), fps);
			return clip;
		}
	}
}
