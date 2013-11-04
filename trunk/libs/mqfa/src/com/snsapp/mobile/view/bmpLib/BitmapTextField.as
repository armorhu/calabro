package com.snsapp.mobile.view.bmpLib
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.StageQuality;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	
	/**################################
	 * 
	 * @author sevencchen
	 * @2012-9-26
	 * ###################################
	 */
	
	public class BitmapTextField extends Bitmap
	{
		private var _tf:EmbedTextField;
		private var _scale:Number;
		private var _bmd:BitmapData;
		public function BitmapTextField(fontName:String,scale:Number=1,size:uint=18,color:uint=0,alin:String="none",sx:Number=0,sy:Number=0)
		{
			_tf = new EmbedTextField(fontName,scale,size,color,alin,sx,sy);
			_scale = scale;
			var rect:Rectangle = _tf.getBounds(_tf.parent);
			this.name =  _tf.name;
		}
		public function set text(str:String):void
		{
			_tf.text = str;
			update();
		}
		public function set htmlText(str:String):void
		{
			_tf.htmlText = str;
			update();
		}
		private function update():void
		{
			if(this.bitmapData)
				this.bitmapData.dispose();
			var rect:Rectangle = _tf.getBounds(_tf);
			var matx:Matrix = new Matrix;
			matx.scale(_scale,_scale);
			matx.translate(-rect.x*_scale,-rect.y*_scale);
			_bmd= new BitmapData(rect.width*_scale,rect.height*_scale,true,0);
			_bmd.drawWithQuality(_tf,matx,null,null,null,true,StageQuality.HIGH);
			this.bitmapData = _bmd;
		}
		public function setGlow(color:uint,blur:Number,stg:int,qy:uint):void{
			this.filters = [new GlowFilter(color,1,blur,blur,stg,qy)]
		}
		public function destory():void
		{
			if(_tf!=null){
				_tf = null;
			}
			if(this.bitmapData)
				this.bitmapData.dispose();
			if(this.parent)
				this.parent.removeChild(this);
		}
	}
}

import flash.display.BitmapData;
import flash.events.Event;
import flash.filters.GlowFilter;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

class EmbedTextField extends TextField
{
	private var _scale:Number;
	private var _bmd:BitmapData;
	private var _align:String;
	private var _sx:Number;
	private var _sy:Number;
	private var _parentW:Number=0;
	private var _parentH:Number=0;
	
	public function EmbedTextField(fontName:String,scale:Number=1,size:uint=18,color:uint=0,alin:String="none",sx:Number=0,sy:Number=0)
	{
		_scale = scale;
		_align = alin;
		_sx = sx;
		_sy = sy;
		this.scaleX = this.scaleY = _scale;
		this.mouseEnabled = this.selectable = false;
		this.defaultTextFormat = new TextFormat(fontName, size, color,null,null,null,null,null,TextFormatAlign.CENTER);
		this.antiAliasType = AntiAliasType.ADVANCED;
		this.embedFonts = true;
		this.cacheAsBitmap = true;
		this.autoSize = TextFieldAutoSize.CENTER;
		this.multiline = false;
	}
	override public function set text(value:String):void
	{
		super.text = value;
		update();
	}
	override public function set htmlText(value:String):void
	{
		super.htmlText = value;
		update();
	}
	private function update():void
	{
		if(this.parent&&_parentW==0){
			_parentW = this.parent.width;
		}
		if(this.parent&&_parentH==0){
			_parentH = this.parent.height;
		}
		if(_align=="LT"){
			this.x = 0 + _sx;
		}else if (_align=="LC"){
			this.x = 0 + _sx;
			this.y = (_parentH - this.height+ _sy*2)>>1;
		}else if(_align=="LB"){
			this.x = 0 + _sx;
			this.y = _parentH - this.height + _sy;
		}else if(_align=="CT"){
			this.x = (_parentW - this.width+_sx*2)>>1;
		}else if(_align=="CC"){
			this.x = (_parentW - this.width+_sx*2)>>1;
			this.y = (_parentH - this.height + _sy*2)>>1 ;;
		}else if(_align=="CB"){
			this.x = (_parentW - this.width + _sx*2)>>1;
			this.y = _parentH - this.height + _sy;
		}else if(_align =="RT"){
			this.x = _parentW - this.width + _sx;
		}else if(_align=="RC"){
			this.x = _parentW - this.width + _sx;
			this.y = (_parentH - this.height+ _sy*2)>>1;
		}else if(_align=="RB"){
			this.x = _parentW - this.width + _sx;
			this.y = _parentH - this.height+ _sy;
		}
	}
	public function setGlow(color:uint,blur:Number,stg:int,qy:uint):void{
		this.filters = [new GlowFilter(color,1,blur,blur,stg,qy)]
	}
}