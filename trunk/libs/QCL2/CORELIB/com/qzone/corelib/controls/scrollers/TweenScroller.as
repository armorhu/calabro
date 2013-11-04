package com.qzone.corelib.controls.scrollers
{
	import com.greensock.TweenLite;
	import com.qzone.corelib.controls.events.ScrollEvent;
	import flash.display.InteractiveObject;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	/**
	 * 滑块数值发生变化时派发
	 */
	[Event(name = "change", type = "flash.events.Event")]
	
	/**
	 * 滑块停止滚动时派发
	 */
	[Event(name = "stopScrolling",type = "com.qzone.corelib.controls.events.ScrollEvent")]
	
	/**
	 * 滑块开始滚动时派发
	 */
	[Event(name = "startScrolling",type = "com.qzone.corelib.controls.events.ScrollEvent")]
	
	/**
	 * 包含两个按钮，滚动时整行、整列滚动
	 * @author Larry H.
	 */
	public class TweenScroller extends SimpleScroller
	{	
		private var _deltaLines:int = 0;
		
		private var _deltaValue:Number = 0;
		
		private var _pageCount:int = 0;
		
		private var _duration:Number = 0.3;
		
		private var _scrolling:Boolean = false;
		
		private var _tween:TweenLite = null;
		
		private var _lineIndex:int = 0;
		private var _ease:Function = null;
		
		/**
		 * 构造函数
		 * create a [TweenScroller] object
		 * @param	preBtn		向上翻的按钮
		 * @param	nextBtn		向下翻的按钮
		 * @param	pageCount	滑块控制的列表需要显示的行数（竖直滚动）或者列数（水平滚动）
		 */
		public function TweenScroller(preBtn:InteractiveObject, nextBtn:InteractiveObject, pageCount:int) 
		{
			super(preBtn, nextBtn);
			
			_pageCount = pageCount;
			
			this.deltaLines = 1;
		}
		
		/**
		 * 鼠标按下处理
		 * @param	e
		 */
		override protected function downHandler(e:MouseEvent):void 
		{
			e.stopPropagation();
			
			if (_scrolling || _pageCount >= _currentLineCount) return;
			
			var target:DisplayObject = e.currentTarget as DisplayObject;
			
			if (_buttonMap[target])
			{
				_directon = -1;
			}
			else
			{
				_directon = 1;
			}
			
			var index:int = _lineIndex + _deltaLines * _directon;
			if (index > _currentLineCount - _pageCount)
			{
				index = _currentLineCount - _pageCount;
			}
			else
			if(index < 0)
			{
				index = 0;
			}
			
			if (_tween)
			{
				TweenLite.killTweensOf(this);
			}
			
			_tween = TweenLite.to(this, _duration, { value: index * _deltaValue, ease:_ease, onComplete:stopRenderer } );
			
			_scrolling = true;
			
			dispatchEvent(new ScrollEvent(ScrollEvent.START_SCROLLING));
		}
		
		/**
		 * 停止渲染
		 */
		private function stopRenderer():void
		{
			dispatchEvent(new ScrollEvent(ScrollEvent.STOP_SCROLLING));
			
			_scrolling = false;
		}
		
		//-----------------------------------------------------------
		//	Getters & Setters
		//-----------------------------------------------------------
		/**
		 * 单次滚动的行数
		 * @default 1
		 */
		public function get deltaLines():int { return _deltaLines; }
		public function set deltaLines(value:int):void 
		{
			_deltaLines = value;
		}
		
		/**
		 * 设置行数
		 */
		override public function setCurrentLineCount(value:int):void 
		{
			super.setCurrentLineCount(value);
			
			_deltaValue = 100 / (_currentLineCount - _pageCount);
		}
		
		/**
		 * 每次滚动所需要的时间
		 * @default 0.3
		 */
		public function get duration():Number { return _duration; }
		public function set duration(value:Number):void 
		{
			_duration = value;
		}
		
		/**
		 * 缓动函数
		 * @default null
		 */
		public function get ease():Function { return _ease; }
		public function set ease(value:Function):void 
		{
			_ease = value;
		}
		
		/**
		 * 数值
		 * @default 0
		 */
		override public function set value(value:Number):void
		{
			super.value = value;
			
			_lineIndex = Math.ceil(_value / _deltaValue);
			
			dispatchEvent(new Event(Event.CHANGE));
		}
	}

}