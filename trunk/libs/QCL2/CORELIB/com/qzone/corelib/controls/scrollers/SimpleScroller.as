package com.qzone.corelib.controls.scrollers
{
	import com.qzone.corelib.controls.events.ScrollEvent;
	import com.qzone.corelib.controls.interfaces.IScroller;
	import flash.display.InteractiveObject;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import flash.events.EventDispatcher;
	
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
	 * 简单化快，只包含上下两个按钮的滑块
	 * @author Larry H.
	 */
	public class SimpleScroller extends EventDispatcher implements IScroller
	{
		private var _enabled:Boolean = false;
		
		protected var _value:Number = 0;
		protected var _currentLineCount:int = 0;
		
		protected var _speed:Number = 1;
		
		protected var _preBtn:InteractiveObject = null;
		protected var _nextBtn:InteractiveObject = null;
		
		protected var _buttonMap:Dictionary = null;
		
		protected var _directon:int = -1;
		
		/**
		 * 构造函数
		 * create a [SimpleScroller] object
		 * @param	preBtn		向上翻的按钮
		 * @param	nextBtn		向下翻的按钮
		 */
		public function SimpleScroller(preBtn:InteractiveObject,nextBtn:InteractiveObject)
		{
			if (preBtn == null || nextBtn == null)
			{
				throw new ArgumentError("构造" + this + "对象时必须传入有效地参数！");
			}
			
			_preBtn = preBtn;
			_nextBtn = nextBtn;
			
			// 厨师按钮映射
			_buttonMap = new Dictionary();
			_buttonMap[_preBtn] = true;
		}
		
		/**
		 * 添加事件侦听
		 */
		private function addListener():void
		{
			_preBtn.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			_nextBtn.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
		}
		
		/**
		 * 移除事件侦听
		 */
		private function removeListener():void
		{
			_preBtn.removeEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			_nextBtn.removeEventListener(MouseEvent.MOUSE_DOWN, downHandler);
		}
		
		/**
		 * 鼠标按下
		 * @param	e
		 */
		protected function downHandler(e:MouseEvent):void 
		{
			var target:DisplayObject = e.currentTarget as DisplayObject;
			
			if (_buttonMap[target])
			{
				_directon = -1;
			}
			else
			{
				_directon = 1;
			}
			
			_preBtn.stage.addEventListener(MouseEvent.MOUSE_UP, upHandler);
			_preBtn.addEventListener(Event.ENTER_FRAME, startRenderer);
			
			dispatchEvent(new ScrollEvent(ScrollEvent.START_SCROLLING));
		}
		
		/**
		 * 鼠标弹起处理
		 * @param	e
		 */
		protected function upHandler(e:MouseEvent):void
		{
			e.currentTarget.removeEventListener(e.type,arguments.callee);
			
			_preBtn.removeEventListener(Event.ENTER_FRAME, startRenderer);
			
			dispatchEvent(new ScrollEvent(ScrollEvent.STOP_SCROLLING));
		}
		
		/**
		 * 开始渲染
		 * @param	e
		 */
		protected function startRenderer(e:Event = null):void 
		{
			_value += _speed * _directon;
			
			if (_value > 100)
			{
				_value = 100;
			}
			else
			if(_value < 0)
			{
				_value = 0;
			}
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * 数值
		 */
		public function get value():Number { return _value; }
		public function set value(value:Number):void 
		{
			_value = value;
		}
		
		/**
		 * 是否激活鼠标事件
		 */
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void 
		{
			_enabled = value;
			
			_enabled? addListener() : removeListener();
		}
		
		/**
		 * 当前行数量
		 */
		public function setCurrentLineCount(value:int):void
		{
			_currentLineCount = value;
		}
		
		/**
		 * 滚动速度
		 */
		public function get speed():Number { return _speed; }
		public function set speed(value:Number):void 
		{
			_speed = value;
		}
	}

}