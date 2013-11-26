package com.arm.herolot.services.notice
{
	import com.tencent.morefun.qqnb.modules.battle.view.BattleNoticeTypeAnnouncementUI;
	import com.tencent.morefun.qqnb.modules.battle.view.BattleNoticeTypeNoticeUI;
	import com.tencent.morefun.qqnb.modules.battle.view.BattleNoticeTypeWarningUI;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	
	import starling.animation.IAnimatable;
	
	/**
	 * 游戏消息类 
	 * @author wesleysong
	 * 
	 */	
	public class GameNotice extends Sprite implements IAnimatable
	{
		/**
		 * 结束播放 
		 */		
		public static const PLAY_FINISH:String = "GameNotice_PlayFinish";
		
		/**
		 * 消息的ID 
		 */		
		public var id:uint;
		
		/**
		 * 消息类型 
		 */		
		private var _type:int;
		
		/**
		 * 消息所用UI 
		 */		
		private var _ui:MovieClip;
		
		/**
		 * 横向滚动文本控制器 
		 */		
//		private var _hScrollTextFieldController:HScrollTextFieldController;
		
		/**
		 * 消息文本 
		 */		
		private var _text:String;

		/**
		 * 消息文本 
		 */		
		private var _htmlText:String;
		
		/**
		 * 当前状态剩余ticks
		 */		
		private var _currentStatusTicksLeft:int;
		
		private const ShowingTicks:int = 10;
		private const ShowingYOffset:Number = 20;
		private const ShowingAlphaMultiplier:Number = 1 / ShowingTicks;
		private const ShowingYMultiplier:Number = ShowingYOffset / ShowingTicks;
		
		private const HidingTicks:int = 10;
		private const HidingYOffset:Number = -20;
		private const HidingAlplaMultiplier:Number = 1 / HidingTicks;
		private const HidingYMultiplier:Number = HidingYOffset / HidingTicks;
		
		private var _tickIndex:int;
		private var _tickInterval:Number;
		private var _accServerTime:Number;
		private const TickThreshold:int = 10;
		
		private const DefaultTextMargin:int = 20;
		
		/**
		 * 当前的状态 
		 */		
		public var status:int;
		
		/**
		 * 消息的停留时间 
		 */		
		public var staySeconds:Number;
		
		public function GameNotice(frameRate:Number)
		{
			super();
			
			_type = -1;
			
			status = GameNoticeStatus.SHOWING;
			_currentStatusTicksLeft = ShowingTicks;
			
			_accServerTime = 0;
			
			_tickInterval = 1 / frameRate;
		}
		
		/**
		 * 获取消息类型 
		 * @return 
		 * 
		 */		
		public function get type():int
		{
			return _type;
		}
		
		/**
		 *  设置消息类型 
		 * 
		 */		
		public function set type(value:int):void
		{
			if(_type == value) return;
			
			if(_ui && this.contains(_ui)) this.removeChild(_ui);
			
			_type = value;
			
			switch(_type)
			{
				case GameNoticeType.WARNING :
				{
					_ui = new BattleNoticeTypeWarningUI();
					break;
				}
//				case GameNoticeType.ANNOUNCEMENT:
//				{
//					_ui = new BattleNoticeTypeAnnouncementUI();
//					break;
//				}
				default : 
				{
					_ui = new BattleNoticeTypeNoticeUI();
					break;
				}
			}
			
			if(_ui)
			{
				_ui.alpha = 0;
				_ui.y = ShowingYOffset;
				
				_ui.mouseChildren = false;
				_ui.mouseEnabled = false;
				
				_ui.addEventListener(Event.ADDED_TO_STAGE, onNoticeUIAddedToStage);
				
				this.addChild(_ui);
			}
		}
		
		private function onNoticeUIAddedToStage(e:Event):void
		{
			_ui.removeEventListener(Event.ADDED_TO_STAGE, onNoticeUIAddedToStage);
			
			//调整文本框大小
			if(!_text && !_htmlText)
			{
				_ui.txtNotice.text = "";
				_ui.txtNotice.visible = false;
				return;
			}
			
//			trace("Width after first adjustment :" + _ui.txtNotice.width);
			_text && _text != "" && (_ui.txtNotice.text = _text);
			_htmlText && _htmlText != "" && ((_ui.txtNotice as TextField).htmlText = _htmlText);
			
//			trace("TextField x :" + _ui.txtNotice.x);
			_ui.txtNotice.visible = true;
			
//			if (_type == GameNoticeType.ANNOUNCEMENT)
//			{
//				_hScrollTextFieldController = new HScrollTextFieldController(_ui.txtNotice as TextField);
//				_hScrollTextFieldController.addEventListener(HScrollTextFieldController.SCROLL_TEXTFIELD_PLAY_FINISHED, handleHScrollTextFieldPlayFinished);
//				_ui.x = 485;
//				_ui.y = 22;
//			}
//			else
//			{
				_ui.txtNotice.width = _ui.txtNotice.textWidth + 2 * DefaultTextMargin;
				//			trace("Width after second adjustment :" + _ui.txtNotice.width);
				_ui.txtNotice.x = (_ui.stage.stageWidth - _ui.txtNotice.width) >> 1;
//			}
		}
		
//		private function handleHScrollTextFieldPlayFinished(event:Event):void
//		{
//			_hScrollTextFieldController.removeEventListener(HScrollTextFieldController.SCROLL_TEXTFIELD_PLAY_FINISHED, handleHScrollTextFieldPlayFinished);
//			status = GameNoticeStatus.HIDING;
//			_currentStatusTicksLeft = HidingTicks;
//		}
		
		/**
		 * 获取消息文本 
		 * @return 
		 * 
		 */		
		public function get text():String
		{
			return _text;
		}
		
		/**
		 * 设置消息文本 
		 * @param value
		 * 
		 */		
		public function set text(value:String):void
		{
			_htmlText = null;
			_text = value;
		}

		/**
		 * 设置消息HTML文本 
		 * @param value
		 * 
		 */		
		public function set htmlText(value:String):void
		{
			_text = null;
			_htmlText = value;
		}
		
		/**
		 * 立即隐藏 
		 * 
		 */		
		public function hide(instantHide:Boolean = false):void
		{
			if(instantHide)
			{
				this.dispatchEvent(new Event(PLAY_FINISH));
			}
			else
			{
				if(status == GameNoticeStatus.HIDING) return;
				
				status = GameNoticeStatus.HIDING;
				_currentStatusTicksLeft = HidingTicks;
			}
		}
		
		/**
		 * 前进时间 
		 * @param time
		 * 
		 */		
		public function advanceTime(time:Number):void
		{
			var elapsed:Number = time;
			
			_accServerTime += elapsed;
			
			var maxTickIndexForThisHeartBeat:int = TickThreshold + _tickIndex;
			
			while(_accServerTime >= _tickInterval && _tickIndex < maxTickIndexForThisHeartBeat)
			{
				_accServerTime -= _tickInterval;
				
				_tickIndex++;
				
				tick(_tickIndex);
				
//				if (_hScrollTextFieldController)
//				{
//					_hScrollTextFieldController.tick(_tickIndex);
//				}
			}
		}
		
		/**
		 * 时钟循环 
		 * @param tickIndex
		 * 
		 */		
		private function tick(tickIndex:int):void
		{
			//这里可鞥有点耗，但是没必要为了这点功能再动用statusmanager之类的东西。。。
			switch(status)
			{
				case GameNoticeStatus.SHOWING:
				{
					_currentStatusTicksLeft--;
					
					_ui.alpha = (ShowingTicks - _currentStatusTicksLeft) * ShowingAlphaMultiplier;
					
//					if (_type != GameNoticeType.ANNOUNCEMENT)
//					{
						_ui.y = _currentStatusTicksLeft * ShowingYMultiplier;
//					}
//					
					if(_currentStatusTicksLeft <= 0)
					{
						status = GameNoticeStatus.STAYING;
						if(staySeconds > 0)
						{
							_currentStatusTicksLeft = Math.ceil(60 * staySeconds);
						}
						else
						{
							_currentStatusTicksLeft = -1;
						}
					}
					
					break;
				}
				case GameNoticeStatus.STAYING:
				{
					if(_currentStatusTicksLeft < 0) return;
					
					_currentStatusTicksLeft--;
					
					if(_currentStatusTicksLeft == 0)
					{
						status = GameNoticeStatus.HIDING;
						_currentStatusTicksLeft = HidingTicks;
					}
					
					break;
				}
				case GameNoticeStatus.HIDING:
				{
					_currentStatusTicksLeft--;
					
					_ui.alpha = _currentStatusTicksLeft * HidingAlplaMultiplier;
					
//					if (_type != GameNoticeType.ANNOUNCEMENT)
//					{
						_ui.y = (HidingTicks - _currentStatusTicksLeft) * HidingYMultiplier;
//					}
					
					if(_currentStatusTicksLeft <= 0)
					{
						this.dispatchEvent(new Event(PLAY_FINISH));
					}
					break;
				}
				default:
				{
					this.dispatchEvent(new Event(PLAY_FINISH));
					break;
				}
			}
		}
	}
}