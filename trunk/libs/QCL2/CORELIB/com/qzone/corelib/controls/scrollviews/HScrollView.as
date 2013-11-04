package com.qzone.corelib.controls.scrollviews
{
	import flash.display.DisplayObjectContainer;
	
	/**
	 * 水平方向滚动控制器
	 * @author Larry H.
	 */
	public class HScrollView extends BasicScrollView
	{		
		/**
		 * 构造函数
		 * create a [HScrollView] object
		 * @param	listContainer	列表容器
		 * @param	rowCount		每页显示的行数
		 * @param	columnCount		每页显示的列数
		 * @param	horizontalGap	水平方向间隔
		 * @param	verticalGap		垂直方向间隔
		 */
		public function HScrollView(listContainer:DisplayObjectContainer, rowCount:int, columnCount:int = 1,
										horizontalGap:Number = 5,verticalGap:Number = 5)
		{			
			super(listContainer, rowCount, columnCount, horizontalGap, verticalGap);
			
			_itemCount = (_columnCount + 1) * _rowCount;
		}
		
		/**
		 * 滚动渲染
		 */
		override protected function startScrollRenderer():void
		{		
			// 开始渲染
			_container.x = _offsetX - _scroller.value * (_lineCount - _columnCount) * (_itemWidth + _horizontalGap) / 100;
			
			var columnIndex:Number = - (_container.x - _offsetX) / (_itemWidth + _horizontalGap);
			
			var scrollingRight:Boolean = true;
			if (columnIndex >= _currentLineIndex)
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
		 * 刷新显示
		 */
		override protected function refreshDisplay():void
		{
			var viewIndex:int = 0;
			var dataIndex:int = 0;
			var item:RendererWrapper = null;
			for (var i:int = _currentLineIndex; i < _currentLineIndex + _columnCount + 1; i++)
			{
				for (var j:int = 0; j < _rowCount; j++)
				{
					item = _itemList[viewIndex];
					dataIndex = i * _rowCount + j;
					
					item.index = viewIndex;
					item.dataIndex = dataIndex;
					item.data = _dataProvider[dataIndex];
					
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
					
					item.y = j * item.height + j * _verticalGap;
					item.x = i * item.width + i * _horizontalGap;
					viewIndex ++;
				}
			}
		}
		
		/**
		 * 调整试图顺序
		 */
		override protected function adjustItemViewOrder(scrollingRight:Boolean):void
		{
			var index:int = 0;
			
			var firstItem:RendererWrapper = null;
			var lastItem:RendererWrapper = null;
			
			if (scrollingRight)
			{
				for (index = 0; index < _rowCount; index++)
				{
					firstItem = _itemList[0];
					lastItem = _itemList.pop() as RendererWrapper;
					lastItem.x = firstItem.x - _itemWidth - _horizontalGap;
					lastItem.data = _dataProvider[firstItem.dataIndex - 1];
					_itemList.unshift(lastItem);
				}
			}
			else
			{
				for (index = 0; index < _rowCount; index++)
				{
					firstItem = _itemList.shift() as RendererWrapper;
					lastItem = _itemList[_itemList.length - 1];
					firstItem.x = lastItem.x + _itemWidth + _horizontalGap;
					firstItem.data = _dataProvider[lastItem.dataIndex + 1 ];
					_itemList.push(firstItem);
				}
			}
		}
		
		/**
		 * 计算行数
		 */
		override protected function caculateLineCount():void 
		{
			_lineCount = Math.ceil(_dataProvider.length / _rowCount);
		}
		
		/**
		 * 滚动到水平方向指定数据位置
		 * @param	dataIndex
		 */
		override public function scrollTo(dataIndex:int):void 
		{
			if (dataIndex < 0) dataIndex = 0;
			var lineIndex:int = Math.floor(dataIndex / _rowCount);
			if (lineIndex > (_lineCount - _columnCount) && _lineCount > _columnCount)
			{
				lineIndex = _lineCount - _columnCount;
			}
			
			_currentLineIndex = lineIndex;
			_scroller.value = 100 * _currentLineIndex / (_lineCount - _columnCount);
		}
	}

}