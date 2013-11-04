package com.qzone.corelib.controls.scrollers 
{	
	import com.qzone.corelib.controls.events.ScrollEvent;
	import com.qzone.corelib.controls.interfaces.IScroller;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
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
	 * 滚动滑块
	 * <p>滚动滑块的素材(scrollView)构成如下：</p>
	 * <ol>
	 * 	<li>upScrollBtn，这是scrollView上方的那个按钮，它是一个按钮(SimpleButton)</li>
	 * 	<li>downScrollBtn，这是scrollView下方的那个按钮，它是一个按钮(SimpleButton)</li>
	 * 	<li>dragBar，这是scrollView中间可以拖动的滑块，它可以是下面任意一种格式</li>
	 * 	<ul>
	 * 		<li>简单的显示对象，圆角的可以使用九宫格切割，方角的可以直接使用，顶对齐</li>
	 * 		<li>复杂的显示对象，里面包含三部分：</li>
	 * 		<ul>
	 * 			<li>top，顶对齐的MovieClip</li>
	 * 			<li>middle，顶对齐个MovieClip，在dragBar缩放的时候，只对这一部分进行缩放</li>
	 * 			<li>bottom，顶对齐的MovieClip</li>
	 * 		</ul>
	 *		<p>			这时dragBar的最小高度为top和bottom的高度和</p>
	 * 	</ul>
	 * 	<li>track，这时dragBar拖动时所在轨道</li>
	 * </ol>
	 * @author Larry H.
	 */
	public class EasyScrollBar extends EventDispatcher implements IScroller
	{
		//////////////////////////////////////////////////////////////////////////
		// private static const
		private static const DEFAULT_MAX_LINE_COUNT:int = 100;
		
		//////////////////////////////////////////////////////////////////////////
		// 
		private var _max:Number = 0;
		private var _min:Number = 0;
		
		private var _maxLineCount:int = DEFAULT_MAX_LINE_COUNT;
		private var _pageCount:int = 10;
		
		private var _scrollView:MovieClip = null;
		private var _dragBar:DragBar = null;
		private var _upScrollBtn:SimpleButton = null;
		private var _downScrollBtn:SimpleButton = null;
		
		private var _scrollTrack:MovieClip = null;
		
		private var _enabled:Boolean = false;
		
		private var _scrollArea:DisplayObjectContainer = null;
		
		private var _scrollSpeed:Number = 3;
		private var _wheelSpeed:Number = 3;
		private var _direction:int = 1;		// 1 为向上滚动，-1为向下滚动
		
		private var _isOnTrack:Boolean = false;
		
		private var _stage:Stage = null;
		
		/**
		 * 构造函数
		 * create a [EasyScrollBar] object
		 * @param	scrollView	滚动滑块素材资源
		 * @param	pageCount	滑块控制的列表需要显示的行数（竖直滚动）或者列数（水平滚动）
		 * @param	simpleBarMode	简单滑块模式，简单滑块是指没有分成top、midlle和bottom三部分的滑块
		 */
		public function EasyScrollBar(scrollView:MovieClip, pageCount:int,simpleBarMode:Boolean = false)
		{
			_scrollView = scrollView;
			_pageCount = pageCount;
			
			if (_scrollView == null)
			{
				throw new ArgumentError("构造" + this + "的时候必须传入一个有效的素材！");
			}
			
			_scrollView.mouseEnabled = false;
			_dragBar = new DragBar(_scrollView["dragBar"], simpleBarMode);
			_dragBar.visible = false;
			
			_downScrollBtn = _scrollView["downScrollBtn"];
			_upScrollBtn = _scrollView["upScrollBtn"];
			
			_scrollTrack = _scrollView["track"];
			
			this.height = _scrollView.height;
			
			_dragBar.y = _min;
		}
		
		/**
		 * 移动到目标点
		 * @param	targetX
		 * @param	targetY
		 */
		public function moveTo(targetX:Number,targetY:Number):void
		{
			_scrollView.x = targetX;
			_scrollView.y = targetY;
		}
		
		/**
		 * 添加事件侦听
		 */
		private function addListener():void
		{
			_upScrollBtn.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			_downScrollBtn.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			
			_dragBar.addEventListener(MouseEvent.MOUSE_DOWN, barDownHandler);
			_dragBar.addEventListener(MouseEvent.MOUSE_UP, barUpHandler);
			
			_scrollTrack.addEventListener(MouseEvent.MOUSE_DOWN, trackDownHandler);
			
			if (_scrollView.stage)
			{
				addToStageHandler(null);
				return;
			}
			
			_scrollView.addEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
		}
		
		/**
		 * 添加到舞台
		 * @param	e
		 */
		private function addToStageHandler(e:Event):void 
		{
			if (e)
			{
				e.currentTarget.removeEventListener(e.type,arguments.callee);
			}
			
			_stage = _scrollView.stage;
			
			_stage.addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
		}
		
		/**
		 * 移除事件侦听
		 */
		private function removeListener():void
		{
			_upScrollBtn.removeEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			_downScrollBtn.removeEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			
			_dragBar.removeEventListener(MouseEvent.MOUSE_DOWN, barDownHandler);
			_dragBar.removeEventListener(MouseEvent.MOUSE_UP, barUpHandler);
			
			_scrollTrack.removeEventListener(MouseEvent.MOUSE_DOWN, trackDownHandler);
			
			if (_stage)
			{
				_stage.removeEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
			}
		}
		
		/**
		 * 鼠标滚动
		 * @param	e
		 */
		private function wheelHandler(e:MouseEvent):void 
		{
			var target:DisplayObject = e.target as DisplayObject;
			
			if (_scrollView.contains(target) || (_scrollArea && _scrollArea.contains(target)))
			{
				_direction = e.delta / Math.abs(e.delta);
				
				renderHandler(null, _wheelSpeed);
			}
		}
		
		/**
		 * 鼠标按下滑轨
		 * @param	e
		 */
		private function trackDownHandler(e:MouseEvent):void 
		{
			var target:DisplayObject = e.target as DisplayObject;
			if (_scrollTrack.contains(target))
			{
				_isOnTrack = true;
				
				var targetY:Number = _scrollView.mouseY;
				if (targetY > _dragBar.y)
				{
					_direction = 1;
				}
				else
				{
					_direction = -1;
				}
				
				startRender();
				
				dispatchEvent(new ScrollEvent(ScrollEvent.START_SCROLLING));
			}
		}
		
		/**
		 * 启动渲染
		 */
		private function startRender():void
		{
			_stage.addEventListener(MouseEvent.MOUSE_UP, upHandler);
			_scrollView.addEventListener(Event.ENTER_FRAME, renderHandler);	
		}		
		
		/**
		 * 鼠标在滑块上弹起
		 * @param	e
		 */
		private function barUpHandler(e:MouseEvent):void 
		{
			_dragBar.stopDrag();
			
			_scrollView.removeEventListener(Event.ENTER_FRAME, dragHandler);
			
			dispatchEvent(new ScrollEvent(ScrollEvent.STOP_SCROLLING));
		}
		
		/**
		 * 鼠标在滑块上按下
		 * @param	e
		 */
		private function barDownHandler(e:MouseEvent):void
		{			
			var bounds:Rectangle = new Rectangle(_dragBar.x, _min, 0, _max - _min);
			
			_dragBar.startDrag(bounds);		
			_scrollView.addEventListener(Event.ENTER_FRAME, dragHandler);
			
			dispatchEvent(new ScrollEvent(ScrollEvent.START_SCROLLING));
		}
		
		/**
		 * 鼠标拖动
		 * @param	e
		 */
		private function dragHandler(e:Event):void 
		{
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * 鼠标按下处理
		 * @param	e
		 */
		private function downHandler(e:MouseEvent):void 
		{
			var button:SimpleButton = e.currentTarget as SimpleButton;
			if (button.name.indexOf("up") != -1)
			{
				_direction = -1;
			}
			else
			{
				_direction = 1;
			}
			
			startRender();
			
			dispatchEvent(new ScrollEvent(ScrollEvent.START_SCROLLING));
		}
		
		/**
		 * 根据帧频来渲染
		 * @param	e
		 */
		private function renderHandler(e:Event, speed:Number = 0):void		
		{
			if (speed == 0) speed = _scrollSpeed;
			
			var targetY:Number = _dragBar.y;
			targetY += speed * _direction;
			
			if (_isOnTrack)
			{
				if (_direction == -1)
				{
					var minY:int = Math.max(_scrollView.mouseY, _min);
					
					if (targetY < minY)
					{
						targetY = minY;
					}
				}
				else
				if(_direction == 1)
				{
					var maxY:Number = Math.min(_scrollView.mouseY, _max);
					if (targetY > maxY)
					{
						targetY = maxY;
					}
				}
			}
			
			if (targetY < _min)
			{
				targetY = _min;
			}
			else
			if (targetY > _max)
			{
				targetY = _max;
			}
			
			_dragBar.y = targetY;
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * 鼠标弹起处理
		 * @param	e
		 */
		private function upHandler(e:MouseEvent):void 
		{
			e.currentTarget.removeEventListener(e.type,arguments.callee);
			_scrollView.removeEventListener(Event.ENTER_FRAME, renderHandler);
			
			_isOnTrack = false;
			
			dispatchEvent(new ScrollEvent(ScrollEvent.STOP_SCROLLING));
		}
		
		/**
		 * 更新数据
		 */
		private function initData():void
		{
			_min = _upScrollBtn.y + _upScrollBtn.height / 2;
			_max = _downScrollBtn.y - _downScrollBtn.height / 2 - _dragBar.height;
			
			_max = Math.round(_max);
			_min = Math.round(_min);
		}
		
		//-----------------------------------------------------------
		//	Getters & Setters
		//-----------------------------------------------------------
		/**
		 * slider横坐标
		 */
		public function get x():Number { return _scrollView.x; }
		public function set x(value:Number):void 
		{
			_scrollView.x = value;
		}
		
		/**
		 * slider竖坐标
		 */
		public function get y():Number { return _scrollView.y; }
		public function set y(value:Number):void 
		{
			_scrollView.y = value;
		}
		
		/**
		 * slider高度
		 */
		public function get height():Number { return _scrollView.height; }
		public function set height(value:Number):void 
		{
			_scrollTrack.height = value;
			
			_upScrollBtn.y = _scrollTrack.y + _upScrollBtn.height / 2;
			_downScrollBtn.y = _scrollTrack.y + _scrollTrack.height - _downScrollBtn.height / 2;
			
			initData();
		}
		
		/**
		 * slider宽度
		 */
		public function get width():Number { return _scrollView.width; }
		
		/**
		 * 该属性表示，当_currentLineCount达到maxLineCount时，滑块会缩短到最小值
		 */
		public function get maxLineCount():int { return _maxLineCount; }
		public function set maxLineCount(value:int):void 
		{
			_maxLineCount = value;
		}
		
		/**
		 * 页面显示行数
		 */
		public function get pageCount():int { return _pageCount; }
		public function set pageCount(value:int):void 
		{
			_pageCount = value;
		}
		
		/**
		 * 设置当前行数量
		 */
		public function setCurrentLineCount(value:int):void
		{
			if (value <= _pageCount)
			{
				this.enabled = false;				
				_dragBar.visible = false;
				return;
			}
			
			this.enabled = true;
			_dragBar.visible = true;
			
			_dragBar.y = _scrollTrack.y + _upScrollBtn.height;
			
			//
			var base:Number = Math.pow(_dragBar.minHeight / (_max - _min), 1 / (_maxLineCount - _pageCount));
			var barHeight:Number = (_max - _min) * Math.pow(base, value - _pageCount);
			_dragBar.height = barHeight;
			
			initData();
		}
		
		/**
		 * 是否感应鼠标事件
		 */
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void 
		{
			_enabled = value;
			_dragBar.mouseEnabled = _enabled;
			
			if (_enabled)
			{
				addListener();
				
				_scrollView.mouseChildren = _scrollView.mouseEnabled = true;
			}
			else
			{
				removeListener();
				
				_scrollView.mouseChildren = _scrollView.mouseEnabled = false;
			}
		}
		
		/**
		 * 滚动反应的速度
		 */
		public function get scrollSpeed():Number { return _scrollSpeed; }
		public function set scrollSpeed(value:Number):void 
		{
			_scrollSpeed = value;
		}
		
		/**
		 * 滚轮感应区域
		 * @notice 鼠标滚轮有效地区域
		 * @default scrollView
		 */
		public function get scrollArea():DisplayObjectContainer { return _scrollArea; }
		public function set scrollArea(value:DisplayObjectContainer):void 
		{
			_scrollArea = value;
		}
		
		/**
		 * 滚轮速度
		 */
		public function get wheelSpeed():Number { return _wheelSpeed; }
		public function set wheelSpeed(value:Number):void 
		{
			_wheelSpeed = value;
		}
		
		/**
		 * 数值
		 * @notice 写入属性时，会派发事件
		 */
		public function get value():Number { return 100 * (_dragBar.y - _min) / (_max - _min); }
		public function set value(inputValue:Number):void
		{			
			if (inputValue >= 100) inputValue = 99.9;
			if (inputValue < 0) inputValue = 0;	
			
			_dragBar.y = inputValue * (_max - _min) / 100 + _min;
			
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
}