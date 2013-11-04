package com.qzone.corelib.controls.scrollviews 
{	
	import com.qzone.corelib.controls.events.ScrollEvent;
	import com.qzone.corelib.controls.interfaces.IScroller;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	
	/**
	 * 滚动列表基类
	 * @author Larry H.
	 */
	public class BasicScrollView extends EventDispatcher
	{
		private var _listContainer:DisplayObjectContainer = null;
		
		protected var _container:DisplayObjectContainer = null;
		protected var _scroller:IScroller = null;
		
		protected var _rowCount:int = 5;
		protected var _columnCount:int = 1;
		
		protected var _enabled:Boolean = false;
		
		protected var _dataProvider:Array = null;
		
		protected var _itemRenderClass:Class = null;
		
		protected var _itemList:Array = null;
		
		protected var _currentLineIndex:int = 0;
		protected var _lineCount:int = 0;
		
		protected var _horizontalGap:Number = 0;
		protected var _verticalGap:Number = 1;
		
		protected var _itemHeight:Number = 0;
		protected var _itemWidth:Number = 0;
		
		private var _lastValue:Number = 0;
		
		protected var _itemCount:int = 0;
		
		protected var _offsetX:Number = 0;
		protected var _offsetY:Number = 0;
		
		protected var _dataIndex:int = 0;
		
		/**
		 * 构造函数
		 * create a [BasicScrollView] object
		 * @param	listContainer	列表容器
		 * @param	rowCount		每页显示的行数
		 * @param	columnCount		每页显示的列数
		 * @param	horizontalGap	水平方向间隔
		 * @param	verticalGap		垂直方向间隔
		 */
		public function BasicScrollView(listContainer:DisplayObjectContainer, rowCount:int, columnCount:int = 1,
										horizontalGap:Number = 5,verticalGap:Number = 5)
		{			
			_rowCount = rowCount;
			_columnCount = columnCount;
			
			_horizontalGap = horizontalGap;
			_verticalGap = verticalGap;
			
			_listContainer = listContainer;
			
			_container = new Sprite();
			_listContainer.addChild(_container);
		}
		
		/**
		 * 初始化列表
		 */
		protected function initView():void
		{
			_itemList = [];
			
			var itemRender:RendererWrapper = null;
			for (var i:int = 0; i < _itemCount; i++)
			{
				itemRender = new RendererWrapper(_itemRenderClass);
				itemRender.index = i;
				_itemList.push(itemRender);
			}
			
			_itemHeight = itemRender.height;
			_itemWidth = itemRender.width;
			
			// add mask
			var maskWidth:Number = _columnCount * (_itemWidth + _horizontalGap) - _horizontalGap;
			var maskHeight:Number = _rowCount * (_itemHeight + _verticalGap) - _verticalGap;
			
			var mask:Shape = new Shape();
			var g:Graphics = mask.graphics;
			g.beginFill(0x000000, 0);
			g.drawRect(0, 0, maskWidth, maskHeight);
			g.endFill();
			
			mask.x = _offsetX;
			mask.y = _offsetY;
			if (_container.parent)
			{
				_container.parent.addChild(mask);
			}
			
			_container.mask = mask;
		}	
		
		//-----------------------------------------------------------
		//	private APIs
		//-----------------------------------------------------------
		/**
		 * 添加事件侦听
		 */
		protected function addListener():void
		{
			if (_scroller == null) return;
			_scroller.addEventListener(Event.CHANGE, scrollHandler);
			_scroller.addEventListener(ScrollEvent.START_SCROLLING, scrollingHandler);
			_scroller.addEventListener(ScrollEvent.STOP_SCROLLING, scrollingHandler);
		}
		
		/**
		 * 移除事件侦听
		 */
		protected function removeListener():void
		{
			if (_scroller == null) return;
			_scroller.removeEventListener(Event.CHANGE, scrollHandler);
			_scroller.removeEventListener(ScrollEvent.START_SCROLLING, scrollingHandler);
			_scroller.removeEventListener(ScrollEvent.STOP_SCROLLING, scrollingHandler);
		}
		
		/**
		 * 滑块停止滚动
		 * @param	e
		 */
		protected function scrollingHandler(e:Event):void 
		{			
			switch(e.type)
			{
				case ScrollEvent.START_SCROLLING:
				{
					RendererWrapper.scrolling = true;
					break;
				}
				
				case ScrollEvent.STOP_SCROLLING:
				{
					RendererWrapper.scrolling = false;
					break;
				}
			}
			
			if(e is ScrollEvent)
			{
				_container.dispatchEvent(e as ScrollEvent);
			}
		}
		
		/**
		 * 滑块滚动处理
		 * @param	e
		 */
		private function scrollHandler(e:Event):void 
		{
			if (_scroller == null) return;
			
			// 效率优化
			if (_scroller.value == _lastValue) return;
			_lastValue = _scroller.value;
			
			// 开始渲染
			startScrollRenderer();
		}
		
		//-----------------------------------------------------------
		//	protected APIs
		//-----------------------------------------------------------
		/**
		 * 滚动渲染
		 * @notice 需要基类复写实现
		 */
		protected function startScrollRenderer():void
		{
			
		}
		
		/**
		 * 刷新显示
		 * @notice 需要基类复写实现
		 */
		protected function refreshDisplay():void
		{
			
		}
		
		/**
		 * 调整试图顺序
		 * @notice 需要基类复写实现
		 */
		protected function adjustItemViewOrder(scrolling:Boolean):void
		{
			
		}
		
		/**
		 * 滚动到指定数据位置
		 * @param	dataIndex
		 */
		public function scrollTo(dataIndex:int):void
		{
			
		}
		
		/**
		 * 计算行数量
		 * @notice 需要基类复写实现
		 */
		protected function caculateLineCount():void
		{
			//_lineCount = Math.ceil(_dataProvider.length / _columnCount);
		}
		
		//-----------------------------------------------------------
		//	Getters & Setters
		//-----------------------------------------------------------
		/**
		 * 是否激活鼠标交互
		 * @default false
		 * @important 如需正常使用，需要把该属性设为true
		 */
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void 
		{
			_enabled = value;
			
			if (_scroller)
			{
				_scroller.enabled = _enabled;
			}
			
			if (_enabled)
			{
				addListener();
			}
			else
			{
				removeListener();
			}
		}
		
		/**
		 * 滚动滑块
		 * @important 该参数必须赋值，不然会报错
		 */
		public function get scroller():IScroller { return _scroller; }
		public function set scroller(value:IScroller):void 
		{
			_scroller = value;
		}
		
		/**
		 * 数据
		 */
		public function get dataProvider():Array { return _dataProvider; }
		public function set dataProvider(value:Array):void 
		{
			_dataProvider = value;
			if (_dataProvider == null)_dataProvider = [];
			
			_currentLineIndex = 0;
			caculateLineCount();
			
			if (_itemList == null)
			{
				initView();
			}
			
			if (_scroller)
			{
				_scroller.setCurrentLineCount(_lineCount);
				_scroller.value = 0;
			}
			
			refreshDisplay();
		}
		
		/**
		 * ListItem渲染类，该类为BasicItem的子类
		 */
		public function get itemRenderClass():Class { return _itemRenderClass; }
		public function set itemRenderClass(value:Class):void 
		{
			_itemRenderClass = value;
		}				
		
		/**
		 * 滚动列表宽度
		 * @notice 只读属性
		 */
		public function get width():Number { return _container.width; }
		
		/**
		 * 滚动列表高度
		 * @notice 只读属性
		 */
		public function get height():Number { return _container.height; }
		
		/**
		 * 滚动列表横坐标
		 * @default 0
		 */
		public function get x():Number { return _offsetX; }
		public function set x(value:Number):void 
		{
			_offsetX = value;
			
			if (_container.x == 0)			
			{
				_container.x = value;
			}
			
			if(_container.mask)
			{
				_container.mask.x = _offsetX;
			}
		}
		
		/**
		 * 滚动列表竖坐标
		 * @default 0
		 */
		public function get y():Number { return _offsetY; }
		public function set y(value:Number):void 
		{
			_offsetY = value;
			
			if(_container.y == 0)
			{
				_container.y = value;
			}
			
			if(_container.mask)
			{
				_container.mask.y = _offsetY;
			}
		}
		
		/**
		 * 是否可见
		 */
		public function get visible():Boolean { return _container.visible; }
		public function set visible(value:Boolean):void 
		{
			_container.visible = value;
		}		
	}

}