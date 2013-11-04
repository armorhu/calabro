package com.snsapp.starling.display.tab
{
	import com.snsapp.starling.display.Button;
	
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;

	public class Tab extends Sprite
	{
		private var _upBtn:Button;
		private var _downBtn:Button;

		public function Tab(upBtn:Button, downBtn:Button)
		{
			super();
			_upBtn=upBtn;
//			_upBtn.x = -_upBtn.width/2;
			_downBtn=downBtn;
//			_downBtn.x = -_downBtn.width/2;

			addChild(_upBtn);
			addChild(_downBtn);
			_upBtn.visible=true;
			_downBtn.visible=false;

			_upBtn.addEventListener(Event.TRIGGERED, tigerEventHandler);
			_downBtn.addEventListener(Event.TRIGGERED, tigerEventHandler);
		}

		private function tigerEventHandler(e:Event):void
		{
			selected=!selected;
			dispatchEventWith(Event.TRIGGERED);
		}

		public function get selected():Boolean
		{
			return _downBtn.visible;
		}

		public function set selected(value:Boolean):void
		{
			if (selected == value)
				return;
			_upBtn.visible=!_upBtn.visible;
			_downBtn.visible=!_downBtn.visible;
		}
	}
}
