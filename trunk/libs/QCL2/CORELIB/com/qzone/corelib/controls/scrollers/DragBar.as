package com.qzone.corelib.controls.scrollers
{
	import flash.display.DisplayObject;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.display.Scene;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	/**
	 * 鼠标弹起时派发事件
	 */
	[Event(name = "mouseUp", type = "flash.events.MouseEvent")]
	
	/**
	 * 鼠标按下事件
	 */
	[Event(name = "mouseDown",type = "flash.events.MouseEvent")]
	
	/**
	 * 滑块
	 * 如果simpleMode为false，则滑块一定要包含这三部分
	 * 并且命名为top、middle、bottom，barLine可有可无
	 * @author Larry H.
	 */
	internal class DragBar extends EventDispatcher
	{
		//////////////////////////////////////////////////////////////////////////
		// const vars
		private const ROLL_OVER:String 	= "over";
		private const ROLL_OUT:String 	= "out";
		private const MOUSE_DOWN:String = "down";
		private const DISABLED:String 	= "disabled";
		
		//////////////////////////////////////////////////////////////////////////
		//
		private var _barView:MovieClip = null;
		
		private var _top:MovieClip = null;
		private var _middle:MovieClip = null;
		private var _bottom:MovieClip = null;
		
		// 滑块正中央的横条
		private var _line:MovieClip = null;
		
		// 是否为简单模式
		private var _simpleMode:Boolean = false;
		
		// 是否激活鼠标事件
		private var _mouseEnabled:Boolean = false;
		
		// 鼠标是否按下
		private var _isMouseDown:Boolean = false;
		
		// 滑块最小值
		private var _minBarHeight:Number = 10;
		
		/**
		 * 构造函数
		 * create a [DragBar] object
		 * @param	barView		滑块视图资源类
		 * @param	simpleMode	是否使用简单模式
		 * 
		 * <ol>
		 * <li>如果为true，则滑块缩放的时候直接对barView整体放缩；</li>
		 * <li>如果为false，则把barView分成上中心三部分，只对中间部分缩放</li>
		 * </ol>
		 */
		public function DragBar(barView:MovieClip, simpleMode:Boolean = false)
		{
			_barView = barView;
			_barView.mouseChildren = false;
			//_barView.buttonMode = true;	
			
			_simpleMode = simpleMode;
			
			init();
		}
		
		/**
		 * 初始化
		 */
		private function init():void
		{
			if (_simpleMode)
			{
				storeFrameList(_barView);
				return;
			}
			
			var list:Array = ["top", "middle", "bottom","line"];
			
			var item:MovieClip = null;
			for each(var key:String in list)
			{
				item = _barView[key];
				if (item == null) continue;
				
				item.stop();
				storeFrameList(item);
				this["_" + key] = item;
			}
		}
		
		/**
		 * 存储帧列表
		 * @param	clip
		 */
		private function storeFrameList(clip:MovieClip):void
		{
			var list:Array = [];
			var scene:Scene = clip.scenes[0];
			for each(var frameLabel:FrameLabel in scene.labels)
			{
				list.push(frameLabel.name);
			}
			
			clip["list"] = list;
		}
		
		/**
		 * 开始拖动
		 * @param	bounds
		 * @return
		 */
		public function startDrag(bounds:Rectangle = null):void
		{
			_barView.startDrag(false, bounds);
		}
		
		/**
		 * 停止拖动
		 */
		public function stopDrag():void
		{
			_barView.stopDrag();
		}
		
		/**
		 * 添加时间侦听
		 */
		private function addListener():void
		{
			_barView.addEventListener(MouseEvent.ROLL_OVER, overHandler);
			_barView.addEventListener(MouseEvent.ROLL_OUT, outHandler);
			
			_barView.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
		}
		
		/**
		 * 移除事件侦听
		 */
		private function removeListener():void
		{
			_barView.removeEventListener(MouseEvent.ROLL_OVER, overHandler);
			_barView.removeEventListener(MouseEvent.ROLL_OUT, outHandler);
			
			_barView.removeEventListener(MouseEvent.MOUSE_DOWN, downHandler);
		}
		
		/**
		 * 鼠标弹起事件
		 * @param	e
		 */
		private function downHandler(e:MouseEvent):void
		{
			dispatchEvent(e);
			
			_isMouseDown = true;
			this.status = this.MOUSE_DOWN;
			
			_barView.stage.addEventListener(MouseEvent.MOUSE_UP, upHandler);
		}
		
		/**
		 * 鼠标按下事件
		 * @param	e
		 */
		private function upHandler(e:MouseEvent):void 
		{
			e.currentTarget.removeEventListener(e.type,arguments.callee);
			
			dispatchEvent(e);
			
			_isMouseDown = false;
			var target:DisplayObject = e.target as DisplayObject;
			if (_barView.contains(target))
			{
				this.status = this.ROLL_OVER;
			}
			else
			{
				this.status = this.ROLL_OUT;
			}
		}
		
		/**
		 * 鼠标移开
		 * @param	e
		 */
		private function outHandler(e:MouseEvent):void 
		{
			this.status = this.ROLL_OUT;
		}
		
		/**
		 * 鼠标滑过
		 * @param	e
		 */
		private function overHandler(e:MouseEvent):void 
		{
			if (_isMouseDown)
			{
				this.status = this.MOUSE_DOWN;
				return;
			}
			
			this.status = this.ROLL_OVER;
		}
		
		/**
		 * 设置状态
		 */
		private function set status(label:String):void
		{
			if (_simpleMode)
			{
				setClipStopAt(_barView, label);
				return;
			}
			
			setClipStopAt(_top, label);
			setClipStopAt(_middle, label);
			setClipStopAt(_bottom, label);
		}
		
		/**
		 * 跳到指定帧
		 * @param	clip
		 * @param	label
		 */
		private function setClipStopAt(clip:MovieClip,label:String):void
		{
			if (clip["list"].indexOf(label) == -1) return;
			
			clip.gotoAndStop(label);
		}
		
		/**
		 * 是否激活鼠标感应
		 */
		public function get mouseEnabled():Boolean { return _mouseEnabled; }	
		public function set mouseEnabled(value:Boolean):void 
		{
			_mouseEnabled = value;
			
			if (!_mouseEnabled)
			{
				this.status = this.DISABLED;
				
				removeListener();
			}
			else
			{
				this.status = this.ROLL_OUT;
				
				addListener();
			}
		}
		
		/**
		 * 滑块高度，这个高度不会小于minBarHeight
		 */
		public function get height():Number { return (_top.height + _middle.height + _bottom.height); }		
		public function set height(value:Number):void 
		{
			if (value < _minBarHeight) value = _minBarHeight;
			
			if (_simpleMode)
			{
				_barView.height = value;
				return;
			}
			
			var middleHeight:Number = value - _top.height - _bottom.height;
			if (middleHeight < 0)
			{
				middleHeight = 0;
			}
			
			_top.y = 0;
			_middle.height = middleHeight;
			_middle.y = _top.y + _top.height;
			_bottom.y = _middle.y + _middle.height;
			
			if (_line)
			{
				_line.y = _middle.y + (_middle.height - _line.height) / 2;
			}
		}
		
		/**
		 * 滑块宽度
		 */
		public function get width():Number { return _barView.width; }
		
		/**
		 * 滑块横坐标
		 */
		public function get x():Number { return _barView.x; }
		public function set x(value:Number):void
		{
			_barView.x = value;
		}
		
		/**
		 * 滑块竖坐标
		 */
		public function get y():Number { return _barView.y; }
		public function set y(value:Number):void 
		{
			_barView.y = value;
		}
		
		/**
		 * 最小高度
		 * 如果simpleMode为true，则minHeight就是上下两部分的高度和，不包含中间那部分高度
		 * 如果simpleMode为false，则mingHeight就是滑块的原始高度
		 */
		public function get minHeight():Number 
		{
			if (_simpleMode) return _minBarHeight;
			
			var value:Number = _top.height + _bottom.height;
			if (_minBarHeight < value) return value;
			
			return _minBarHeight;
		}
		
		/**
		 * 是否可见
		 * @default true
		 */
		public function get visible():Boolean { return _barView.visible; }
		public function set visible(value:Boolean):void
		{
			_barView.visible = value;
		}
		
		/**
		 * 滑块最小高度
		 * @default 10
		 */
		public function get minBarHeight():Number { return _minBarHeight; }
		public function set minBarHeight(value:Number):void 
		{
			_minBarHeight = value;
		}
	}

}