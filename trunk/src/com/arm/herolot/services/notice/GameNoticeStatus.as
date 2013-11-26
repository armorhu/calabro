package com.arm.herolot.services.notice
{
	/**
	 * 消息状态 
	 * @author wesleysong
	 * 
	 */	
	public class GameNoticeStatus
	{
		/**
		 * 消息状态 - 正在进场 
		 */		
		public static const SHOWING:int = 0;
		
		/**
		 * 消息状态 - 停留在场景中展示 
		 */		
		public static const STAYING:int = 1;
		
		/**
		 * 消息状态 - 正在隐藏
		 */		
		public static const HIDING:int = 2;
		
		public function GameNoticeStatus()
		{
		}
	}
}