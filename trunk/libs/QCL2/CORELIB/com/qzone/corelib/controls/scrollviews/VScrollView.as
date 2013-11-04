package com.qzone.corelib.controls.scrollviews 
{
	import flash.display.DisplayObjectContainer;
	
	/**
	 * 竖直方向滚动控制器
	 * @author Larry H.
	 */
	public class VScrollView extends BasicScrollView
	{		
		/**
		 * 构造函数
		 * create a [VScrollView] object
		 * @param	listContainer	列表容器
		 * @param	rowCount		每页显示的行数
		 * @param	columnCount		每页显示的列数
		 * @param	horizontalGap	水平方向间隔
		 * @param	verticalGap		垂直方向间隔
		 */
		public function VScrollView(listContainer:DisplayObjectContainer, rowCount:int, columnCount:int = 1,
										horizontalGap:Number = 5,verticalGap:Number = 5)
		{			
			super(listContainer, rowCount, columnCount, horizontalGap, verticalGap);
			
			_itemCount = (_rowCount + 1) * _columnCount;
		}		
		
		/**
		 * 滚动渲染
		 */
		override protected function startScrollRenderer():void
		{
			// 开始渲染
			_container.y = _offsetY - _scroller.value * (_lineCount - _rowCount) * (_itemHeight + _verticalGap) / 100;
			
			var rowIndex:Number = - (_container.y - _offsetY) / (_itemHeight + _verticalGap);
			
			var scrollingDown:Boolean = true;
			if (rowIndex - 1 >= _currentLineIndex)
			{				
				rowIndex >>= 0;
			}
			else
			if(rowIndex <= _currentLineIndex)
			{
				scrollingDown = false;
				rowIndex >>= 0;
			}
			else
			{
				return;
			}
			
			_currentLineIndex = rowIndex;
			
			adjustItemViewOrder(scrollingDown);
			
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
			for (var i:int = _currentLineIndex; i < _currentLineIndex + _rowCount + 1; i++)
			{
				for (var j:int = 0; j < _columnCount; j++)
				{
					item = _itemList[viewIndex];
					dataIndex = i * _columnCount + j;
					
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
					
					item.x = j * item.width + j * _horizontalGap;
					item.y = i * item.height + i * _verticalGap;
					viewIndex ++;
				}
			}
		}
		
		/**
		 * 调整试图顺序
		 */
		override protected function adjustItemViewOrder(scrollingDown:Boolean):void
		{
			var index:int = 0;
			
			var firstItem:RendererWrapper = null;
			var lastItem:RendererWrapper = null;
			if (scrollingDown)
			{
				for (index = 0; index < _columnCount; index++)
				{
					firstItem = _itemList[0];
					lastItem = _itemList.pop() as RendererWrapper;
					lastItem.y = firstItem.y - _itemHeight - _verticalGap;
					lastItem.data = _dataProvider[firstItem.dataIndex - 1];
					_itemList.unshift(lastItem);
				}
			}
			else
			{
				for (index = 0; index < _columnCount; index++)
				{
					firstItem = _itemList.shift() as RendererWrapper;
					lastItem = _itemList[_itemList.length - 1];
					firstItem.y = lastItem.y + _itemHeight + _verticalGap;
					firstItem.data = _dataProvider[lastItem.dataIndex + 1 ];
					_itemList.push(firstItem);
				}
			}
		}
		
		override protected function caculateLineCount():void 
		{
			_lineCount = Math.ceil(_dataProvider.length / _columnCount);
		}
		
		/**
		 * 滚动到水平方向指定数据位置
		 * @param	dataIndex
		 */
		override public function scrollTo(dataIndex:int):void 
		{
			if (dataIndex < 0) dataIndex = 0;
			var lineIndex:int = Math.floor(dataIndex / _columnCount);
			if (lineIndex > (_lineCount - _rowCount) && _lineCount > _rowCount)
			{
				lineIndex = _lineCount - _rowCount;
			}
			
			_currentLineIndex = lineIndex;
			_scroller.value = 100 * _currentLineIndex / (_lineCount - _rowCount);
		}
	}
}