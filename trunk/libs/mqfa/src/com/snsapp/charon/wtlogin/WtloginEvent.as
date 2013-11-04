package com.snsapp.charon.wtlogin
{
	import flash.events.Event;
	
	public class WtloginEvent extends Event
	{
		public static const LOGIN_RESULT:String = "login_result";
		public var replayCode:int;   //返回码
		public var replayMsg:String; //返回信息
		
		public function WtloginEvent(replayCode:int,replayMsg:String,type:String = LOGIN_RESULT,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.replayCode = replayCode;
			this.replayMsg = replayMsg;
			super(type, bubbles, cancelable);
		}
	}
}