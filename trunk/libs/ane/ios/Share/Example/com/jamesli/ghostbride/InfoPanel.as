package com.jamesli.ghostbride
{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class InfoPanel extends MovieClip
	{
		private var clsBtn:SimpleButton;
		private var field:TextField;
		private var thmb:MovieClip;
		
		private var msk:MovieClip;
		
		private var oldMouseY:Number;
		private var oldFieldY:Number;
		private var oldThumbY:Number;
		
		private var initialY:Number;
		
		private var thumbClicked:Boolean;
		
		public function InfoPanel()
		{
			super();
		}
		public function init():void{
			clsBtn = getChildByName("closeButton") as SimpleButton;
			clsBtn.addEventListener(MouseEvent.CLICK,clickHandler);
			close();
			
			thmb = getChildByName("thumb") as MovieClip;
			thmb.mouseEnabled = false;
			field = getChildByName("infoField") as TextField;
			field.mouseEnabled = false;
			field.cacheAsBitmap=true;
			
			
			msk = getChildByName("maskClip") as MovieClip;
			field.mask = msk;
			initialY = field.y;
			
			updateView();
		}
		private function clickHandler(pEvent:MouseEvent):void{
			close();
		}
		private function close():void{
			visible = false;
			removeEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			removeEventListener(MouseEvent.MOUSE_MOVE,moveHandler);
			removeEventListener(MouseEvent.MOUSE_UP,upHandler);
		}
		
		public function open():void{
			visible = true;
			updateView(true);
			
			addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
		}
		private function downHandler(pEvent:MouseEvent):void{
			if(Math.abs(mouseX - thmb.x)<20){
				thumbClicked = true;
				oldThumbY = thmb.y;
			}else{
				thumbClicked = false;
				oldFieldY = field.y;
			}
			oldMouseY = mouseY;
			addEventListener(MouseEvent.MOUSE_MOVE,moveHandler);
			addEventListener(MouseEvent.MOUSE_UP,upHandler);
		}
		private function moveHandler(pEvent:MouseEvent):void{
			if(thumbClicked){
				thmb.y = oldThumbY + (mouseY - oldMouseY);
			}else{
				field.y = oldFieldY + (mouseY - oldMouseY);
			}
			updateView();
		}
		private function upHandler(pEvent:MouseEvent):void{
			thumbClicked = false;
			removeEventListener(MouseEvent.MOUSE_MOVE,moveHandler);
			removeEventListener(MouseEvent.MOUSE_UP,upHandler);
		}
		
		
		public function update(pMsg:String):void{
			field.htmlText = pMsg;
			field.width = field.textWidth + 5;
			field.height = field.textHeight + 10;
			if(visible) updateView(true);
		}
		private function updateView(pBottom:Boolean=false):void{
			thmb.visible = field.height > msk.height;	
			if(thumbClicked){
				thmb.y = Math.max(Math.min(thmb.y, -350 + (700 - thmb.height)),-350);
				field.y = initialY + (thmb.y-(-350))/(700-thmb.height) * (msk.height - field.height)
			}else{
				if(pBottom){
					field.y = Math.min(initialY,initialY + msk.height - field.height);
				}else{
					field.y = Math.min(Math.max(field.y, initialY + msk.height - field.height),initialY);
				}
				if(thmb.visible){	
					thmb.y = -350 + (700 - thmb.height) * (initialY - field.y)/(field.height - msk.height);
				}
			}
		}
	}
}