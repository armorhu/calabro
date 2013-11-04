package com.jamesli.ghostbride
{
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	
	public class BlueButton extends SimpleButton
	{
		public function BlueButton(upState:DisplayObject=null, overState:DisplayObject=null, downState:DisplayObject=null, hitTestState:DisplayObject=null)
		{
			super(upState, overState, downState, hitTestState);
		}
		
		public function enable():void{
			alpha = 1;
			mouseEnabled = true;
		}
		public function disable():void{
			alpha = .1;
			mouseEnabled = false;
		}
	}
}