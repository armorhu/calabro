package com.arm.herolot.services.notice
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	
	import starling.core.Starling;

	/**
	 * 消息显示管理 
	 * @author wesleysong
	 * 
	 */	
	public class GameNoticeManager
	{
		private var _noticeContainer:DisplayObjectContainer;
		
		private var _notices:Vector.<GameNotice>;
		
		private var _maxNoticeID:uint;
		
		private const NoticeX:Number = 0;
		private const NoticeY:Number = 65;
		
		public function GameNoticeManager(noticeContainer:DisplayObjectContainer)
		{
			_noticeContainer = noticeContainer;
			
			_notices = new Vector.<GameNotice>();
			
			_maxNoticeID = 0;
		}
		
		/**
		 * 显示消息 
		 * @param text
		 * @param type
		 * @param autoHideSeconds 几秒之后隐藏，为0则常驻
		 * @param isHTML 是否为HTML格式
		 * @return 返回公告实例ID
		 * 
		 */		
		public function showNotice(text:String, type:int = GameNoticeType.NORMAL, autoHideSeconds:Number = 3, offsetY:Number = 0, isHTML:Boolean = false):uint
		{
			_maxNoticeID++;
			
			var newNotice:GameNotice = new GameNotice(_noticeContainer.stage.frameRate);
			newNotice.id = _maxNoticeID;
			newNotice.type = type;
			if(isHTML)
			{
				newNotice.htmlText = text;
			}
			else
			{
				newNotice.text = text;
			}
			
			newNotice.staySeconds = autoHideSeconds;
			_notices.push(newNotice);
			
			newNotice.x = NoticeX;
			newNotice.y = NoticeY + offsetY;
			_noticeContainer.addChild(newNotice);
			
			Starling.juggler.add(newNotice);
			newNotice.addEventListener(GameNotice.PLAY_FINISH, onNoticePlayFinished);
			
			return _maxNoticeID;
		}
		
		private function onNoticePlayFinished(e:Event):void
		{
			var finishedNotice:GameNotice = e.target as GameNotice;
			
			if(!finishedNotice) return;
			
			if(_noticeContainer.contains(finishedNotice))
			{
				_noticeContainer.removeChild(finishedNotice);
			}
			
			Starling.juggler.remove(finishedNotice);
			
			var noticeIndex:int = _notices.indexOf(finishedNotice);
			if(noticeIndex != -1)
			{
				_notices.splice(noticeIndex, 1);
			}
		}
		
		/**
		 * 隐藏消息 
		 * @param noticeID
		 * 
		 */		
		public function hideNotice(noticeID:uint, instantHide:Boolean = false):void
		{
			var noticeToHide:GameNotice = getNoticeByID(noticeID);
			if(!noticeToHide) return;
			
			noticeToHide.hide(instantHide);
		}
		
		/**
		 * 隐藏所有消息 
		 * 
		 */		
		public function hideAllNotices():void
		{
			for each(var noticeToHide:GameNotice in _notices)
			{
				noticeToHide.hide();
			}
		}
		
		/**
		 * 根据ID获取消息实例 
		 * @param noticeID
		 * @return 
		 * 
		 */		
		private function getNoticeByID(noticeID:uint):GameNotice
		{
			for each(var noticeToCheck:GameNotice in _notices)
			{
				if(noticeToCheck.id == noticeID) return noticeToCheck;
			}
			
			return null;
		}
	}
}