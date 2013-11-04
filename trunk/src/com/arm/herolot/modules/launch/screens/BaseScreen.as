package com.arm.herolot.modules.launch.screens
{
	import com.arm.herolot.modules.launch.LaunchView;
	import com.arm.herolot.services.utils.EmbedFont;
	import com.snsapp.starling.StarlingFactory;
	import com.snsapp.starling.display.Button;
	import com.snsapp.starling.texture.implement.BatchTexture;

	import feathers.controls.Screen;

	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	public class BaseScreen extends Screen
	{
		public function BaseScreen()
		{
			super();
		}

		protected override function initialize():void
		{
			_batch = LaunchView(this.owner).texture.mainTexture;
			_scale = LaunchView(this.owner).scale;
		}

		protected function addChildImage(textureName:String, px:Number = 0, py:Number = 0, p:Sprite = null):Image
		{
			var image:Image = StarlingFactory.newImage(_batch.getTexture(textureName));
			image.name = textureName;
			return addChildAtPos(image, px, py, p) as Image;
		}


		protected function addTextField(text:String, w:Number, h:Number, px:Number = 0, py:Number = 0, size:uint = 28, color:uint = 0x0, p:Sprite = null):TextField
		{
			var tf:TextField = new TextField(w * _scale, h * _scale, text, EmbedFont.fontName, size * _scale, color);
			tf.vAlign = VAlign.TOP;
			tf.hAlign = HAlign.LEFT;
			return addChildAtPos(tf, px, py, p) as TextField;
		}

		protected function addChildAtPos(displayObj:DisplayObject, px:Number = 0, py:Number = 0, p:Sprite = null):DisplayObject
		{
			if (p == null)
				p = this;
			displayObj.x = px * _scale;
			displayObj.y = py * _scale;
			p.addChild(displayObj);
			return displayObj;
		}

		protected function addChildBtn(textureName:String, tirggerHandler:Function, px:Number = 0, py:Number = 0, p:Sprite = null):Button
		{
			var btn:Button = new Button(_batch.getTexture(textureName));
			btn.addEventListener(Event.TRIGGERED, tirggerHandler);
			return addChildAtPos(btn, px, py, p) as Button;
		}

		protected function requestData(type:String):void
		{
			dispatchEventWith(LaunchView.REQUEST_DATA, false, type);
		}

		public function setData(type:String, data:*):void
		{
			throw new Error('pls implements by sub class!!!!');
		}

		protected var _batch:BatchTexture;
		protected var _scale:Number;
	}
}
