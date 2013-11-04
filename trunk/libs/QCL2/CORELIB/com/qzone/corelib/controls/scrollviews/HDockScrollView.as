package com.qzone.corelib.controls.scrollviews 
{
	import com.greensock.TweenLite;
	import com.qzone.corelib.controls.events.ScrollEvent;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	/**
	 * 水平dock，该控件可以模拟类似苹果停靠图标的效果
	 * 该控件的渲染器<strong>强烈</strong>推荐继承BasicDockItemRenderer
	 * 该控件暂时只完美支持TweenScroller作为滚动控制，其他的也可以支持，但是效果稍微差一点
	 * @important <strong>该类的渲染器所使用的素材必须是上下左右居中对齐的，否则效果会有问题</strong>
	 * @author Larry H.
	 */
	public class HDockScrollView extends BasicScrollView
	{
		private var _dictionary:Dictionary = null;
		
		private var _lastItem:RendererWrapper = null;
		private var _firstItem:RendererWrapper = null;
		
		private var _mouseTarget:RendererWrapper = null;
		
		private var _lastOffset:Number = 0;
		private var _firstOffset:Number = 0;
		
		/**
		 * 构造函数
		 * create a [HDockScrollView] object
		 */
		public function HDockScrollView(listContainer:DisplayObjectContainer, columnCount:int, gap:Number = 5)
		{
			super(listContainer, 1, columnCount, gap, 0);
			
			_itemCount = _columnCount + 1;
			
			_dictionary = new Dictionary();
		}
		
		/**
		 * 初始化复写
		 */
		override protected function initView():void 
		{
			super.initView();
			
			var mask:DisplayObject = _container.mask;
			mask.scaleY = 3;
			mask.y -= mask.width / 3;
		}
		
		/**
		 * 寻找边界渲染器
		 */
		private function findLimitItems():void
		{
			var mask:DisplayObject = _container.mask;
			var point:Point = new Point(mask.x, mask.y);
			point = mask.parent.localToGlobal(point);
			point = _container.globalToLocal(point);
			
			var item:RendererWrapper = null;
			
			var scale:Number = 2 / 3;
			
			// 从开头查找第一个渲染器
			for (var i:int = 0; i < _itemList.length; i++)
			{
				item = _itemList[i];
				if (item.x + _itemWidth / 2 * scale >= point.x)				
				{
					_firstOffset = point.x - (item.x - _itemWidth / 2);
					_firstItem = item; break;
				}
			}
			
			// 从尾部查找最后一个渲染器
			for (var j:int = _itemList.length - 1; j >= 0; j--)
			{
				item = _itemList[j];
				if (item.x - _itemWidth / 2 * scale <= point.x + mask.width)
				{
					_lastOffset = (item.x + _itemWidth / 2) - (mask.width + point.x);
					_lastItem = item; break;
				}
			}
		}
		
		/**
		 * 记录位置
		 */
		private function recordPosition():void
		{
			if (_dictionary == null)
			{
				_dictionary = new Dictionary();
			}
			
			var item:RendererWrapper = null;
			for (var i:int = 0; i < _itemList.length; i++)
			{
				item = _itemList[i];
				_dictionary[item] = item.x;
			}
			
			findLimitItems();
		}
		
		/**
		 * 添加事件侦听
		 */
		override protected function addListener():void 
		{
			super.addListener();
			
			_container.addEventListener(Event.RESIZE, resizeHandler);
			_container.addEventListener(DataEvent.DATA, targetChangeHandler);
			_container.addEventListener(MouseEvent.ROLL_OUT, outHandler);
		}
		
		/**
		 * 移除事件侦听
		 */
		override protected function removeListener():void 
		{
			super.removeListener();
			
			_container.removeEventListener(Event.RESIZE, resizeHandler);
			_container.removeEventListener(Event.CHANGE, targetChangeHandler);
			_container.removeEventListener(MouseEvent.ROLL_OUT, outHandler);
		}
		
		/**
		 * 鼠标移开处理
		 * @param	e
		 */
		private function outHandler(e:MouseEvent):void 
		{
			var target:RendererWrapper = _itemList[0];
			
			_mouseTarget = target;
			TweenLite.to(target, 1, { x:_dictionary[target], onUpdate:adjustLayout } );
		}
		
		/**
		 * 目标发生变化
		 * @param	e
		 */
		private function targetChangeHandler(e:DataEvent):void 
		{
			var scale:Number = parseFloat(e.data);
			var target:RendererWrapper = e.target as RendererWrapper;
			
			var targetX:Number = _dictionary[target];
			
			if (target == _firstItem)
			{
				targetX += _itemHeight * (scale - 1) / 2 + _firstOffset;
			}
			else
			if (target == _lastItem)
			{
				targetX -= _itemHeight * (scale - 1) / 2 + _lastOffset;
			}
			
			_mouseTarget = target;
			TweenLite.to(target, 0.6, { x:targetX, onUpdate:adjustLayout } );
		}
		
		/**
		 * 处理滚动
		 * @param	e
		 */
		override protected function scrollingHandler(e:Event):void
		{
			super.scrollingHandler(e);
			
			switch(e.type)
			{
				case ScrollEvent.START_SCROLLING:
				{
					if (_mouseTarget) TweenLite.killTweensOf(_mouseTarget);	
					_container.mouseEnabled = _container.mouseChildren = false;	
					
					break;
				}
				
				case ScrollEvent.STOP_SCROLLING:
				{
					recordPosition();
					_container.mouseEnabled = _container.mouseChildren = true;
					
					break;
				}
			}
		}
		
		/**
		 * 列表项目缩放时处理
		 * @param	e
		 */
		private function resizeHandler(e:Event):void 
		{			
			var target:RendererWrapper = e.target as RendererWrapper;
			
			adjustLayout(target);
		}
		
		/**
		 * 调整布局
		 */
		private function adjustLayout(target:RendererWrapper = null):void
		{		
			if (target == null) target = _mouseTarget;
			
			var preItem:RendererWrapper = null;
			var nextItem:RendererWrapper = null;
			
			var index:int = _itemList.indexOf(target);
			
			// 下半部分
			for (var i:int = index + 1; i < _itemList.length; i++)
			{
				preItem = _itemList[i - 1];
				nextItem = _itemList[i];
				
				nextItem.x = preItem.x +(preItem.width + nextItem.width) / 2 + _horizontalGap;
			}
			
			// 上半部分
			for (var j:int = index - 1; j >= 0; j--)
			{
				preItem = _itemList[j];
				nextItem = _itemList[j + 1];
				
				preItem.x = nextItem.x  - (preItem.width + nextItem.width) / 2 - _horizontalGap;
			}
		}
		
		/**
		 * 开始滚动渲染
		 */
		override protected function startScrollRenderer():void 
		{
			// 开始渲染
			_container.x = _offsetX - _scroller.value * (_lineCount - _columnCount) * (_itemWidth + _horizontalGap) / 100;
			
			var columnIndex:Number = - (_container.x - _offsetX + _horizontalGap) / (_itemWidth + _horizontalGap);
			
			var scrollingRight:Boolean = true;
			if (columnIndex - 1 >= _currentLineIndex)
			{
				columnIndex >>= 0;
			}
			else
			if(columnIndex <= _currentLineIndex)
			{
				scrollingRight = false;
				columnIndex >>= 0;
			}
			else
			{
				return;
			}
			
			_currentLineIndex = columnIndex;
			
			adjustItemViewOrder(scrollingRight);
			
			refreshDisplay();
		}
		
		/**
		 * 刷新数据显示
		 */
		override protected function refreshDisplay():void 
		{
			var index:int = 0;
			var item:RendererWrapper = null;
			for (var i:int = _currentLineIndex; i < _currentLineIndex + _columnCount + 1; i++)
			{
				item = _itemList[index];
				
				item.index = index;
				item.dataIndex = i;
				item.data = _dataProvider[i];
				
				// check
				if (item.data)
				{
					if(item.parent != _container)
					{
						_container.addChild(item);
					}
				}
				else
				{
					item.parent && item.parent.removeChild(item);
				}
				
				item.y = _itemHeight / 2;
				item.x = i * (item.width + _horizontalGap) + _itemWidth / 2;
				
				index ++;
			}
		}
		
		/**
		 * 调整项目视图显示
		 * @param	scrollingDown
		 */
		override protected function adjustItemViewOrder(scrollingDown:Boolean):void 
		{			
			var firstItem:RendererWrapper = null;
			var lastItem:RendererWrapper = null;
			
			if (scrollingDown)
			{				
				firstItem = _itemList[0];
				lastItem = _itemList.pop() as RendererWrapper;
				lastItem.x = firstItem.x - _itemWidth - _horizontalGap;
				lastItem.data = _dataProvider[firstItem.dataIndex - 1];
				_itemList.unshift(lastItem);
			}
			else
			{
				firstItem = _itemList.shift() as RendererWrapper;
				lastItem = _itemList[_itemList.length - 1];
				firstItem.x = lastItem.x + _itemWidth + _horizontalGap;
				firstItem.data = _dataProvider[lastItem.dataIndex + 1 ];
				_itemList.push(firstItem);
			}
		}
		
		/**
		 * 滚动指定位置
		 * @param	dataIndex
		 */
		override public function scrollTo(dataIndex:int):void 
		{
			if (dataIndex < 0) dataIndex = 0;
			if (dataIndex > (_lineCount - _columnCount) && _lineCount > _columnCount)
			{
				dataIndex = _lineCount - _columnCount;
			}
			
			_currentLineIndex = dataIndex;
			_scroller.value = 100 * _currentLineIndex / (_lineCount - _columnCount);
			
			recordPosition();
		}
		
		/**
		 * 计算当前行所在位置
		 */
		override protected function caculateLineCount():void 
		{
			_lineCount = _dataProvider.length;
		}
		
		/**
		 * 初次渲染
		 */
		override public function set dataProvider(value:Array):void 
		{
			super.dataProvider = value;
			
			recordPosition();
		}
	}

}