package com.snsapp.mobile.view.bmpLib
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextInteractionMode;
	
	
	/**################################
	 * 
	 * @author sevencchen
	 * @2012-9-8
	 * ###################################
	 */
	
	public class EmbedTextField extends TextField
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
			this.antiAliasType = AntiAliasType.ADVANCED;
			this.embedFonts = true;
			this.cacheAsBitmap = true;
			this.autoSize = TextFieldAutoSize.CENTER;
			this.multiline = false;
			
			this.defaultTextFormat = new TextFormat(fontName, size, color,null,null,null,null,null,TextFormatAlign.CENTER);
			this.addEventListener(Event.ADDED_TO_STAGE,addToStage);
		}
		private function addToStage(e:Event):void
		{
			if(e!=null)
				this.removeEventListener(Event.ADDED_TO_STAGE,addToStage);
			
		}
		override public function set text(value:String):void
		{
			if(this.parent&&_parentW==0){
				_parentW = this.parent.width;
			}
			if(this.parent&&_parentH==0){
				_parentH = this.parent.height;
			}
			super.text = value;
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
}