package com.snsapp.mobile.view.interactive.scroll.blitmask.itemlist
{
	import com.snsapp.mobile.view.interactive.scroll.ScrollCore;
	import com.snsapp.mobile.view.interactive.scroll.ScrollHelperEvent;
	import com.snsapp.mobile.view.interactive.scroll.ScrollPolicy;
	import com.snsapp.mobile.view.interactive.scroll.blitmask.BmdBlockPool;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;

	/**
	 * ItemRender的BlitMask
	 * @author hufan
	 * 使用于List的BlitMask类。
	 * 好友列表，页签都应该使用这个类。
	 */
	public class VItemListBlitMask extends ScrollCore
	{
		private var _delegate:IItemListDelegate;

		/**
		 * BlitMask 渲染相关
		 * **/
		protected var _maxCacheBlock:int = 0;
		protected var _canvas:Sprite; //画布
		protected var _canvasWidth:Number; //画布的宽
		protected var _canvasHeight:Number; //画布的高
		protected var _canvasBitmapdata:BitmapData; //画布的渲染数据,通过每一帧更新它的内容,达到了渲染的效果
		protected var _bitmapBlocks:Vector.<BitmapData>; //画布渲染的数据源,它是target显示信息的一份热贝
		protected var _firstDrawableIndex:int //当前第一个有绘制的块
		protected var _dirtyBlocks:Vector.<int>; //脏的块

		public function VItemListBlitMask(itemDelegate:IItemListDelegate, range:Point, flexable:Number = 0):void
		{
			_delegate = itemDelegate;
			_canvas = new Sprite();
			_dirtyBlocks = new Vector.<int>();
			super({x: 0, y: 0, width: _delegate.listWidth, height: _delegate.listHeight}, //
				null, range, 0, flexable, 0, 1);
			this._scrollPolicy = ScrollPolicy.VerticalOnly;
			initiatize();
		}

		override public function set scrollPolicy(policy:int):void
		{
			//不让人改滚动策略	
		}

		/**
		 * 一些初始化工作,包括：
		 * 1 清除原来的画布数据,如果存在的话
		 * 2 重置位置信息
		 * 3 初始化画布数据数组,（只是把数组构造出来,里面并没有数据）
		 * 4 如果target在舞台上,则用画布替换它
		 * @throws Error
		 */
		protected function initiatize():void
		{
			/**释放掉原来的内存**/
			if (_canvasBitmapdata)
				BmdBlockPool.recycle(_canvasBitmapdata);
			_canvas.removeChildren();
			_canvasBitmapdata = null;
			if (_bitmapBlocks)
				for (var i:int = 0; i < _bitmapBlocks.length; i++)
					BmdBlockPool.recycle(_bitmapBlocks[i]);
			_bitmapBlocks = null;
			_firstDrawableIndex = -1;
			_dirtyBlocks = new Vector.<int>();
			/**重设位置信息**/
			_canvas.y = this._verticalRange.x;
			_canvas.x = this.target.x;
			_canvasHeight = Math.round(this._verticalRange.y - this._verticalRange.x);
			_canvasWidth = Math.round(this.target.width);
			_maxCacheBlock = Math.min(Math.ceil(target.height / blockSize), (Math.ceil(_canvasHeight / blockSize) + 1) * 3);
			if (_canvasWidth > 0 && _canvasHeight > 0)
			{
				_bitmapBlocks = new Vector.<BitmapData>(Math.ceil(this.target.height / blockSize));
				_canvasBitmapdata = BmdBlockPool.apply(_canvasWidth, _canvasHeight);
				_canvasBitmapdata.lock();
			}
		}

		private var lastFrameY:Number

		/**
		 * 渲染循环
		 * 做两件事：
		 * 当目标滚动时,优先drawCanvas
		 * 当目标不滚动时,优先createRedrawData
		 */
		private function rendingLoop(e:Event = null):void
		{
//			trace('rendingLoop...............................');
			if (_canvasBitmapdata == null || _canvas.stage == null)
				return;
			if (lastFrameY == this.target.y)
			{
				if (!_moving)
					createRedrawData();
			}
			else
			{
				lastFrameY = this.target.y;
				drawCanvas(); //绘画
			}
		}

		/**
		 * 构造画布数据
		 */
		private var time:uint;

		protected function createRedrawData():void
		{
			if (_firstDrawableIndex == -1)
				time = getTimer();
			//找到现在的DataIndex
			const len:int = bitmapBlocks.length;
			//算出现在最合适的DataIndex
			var start:Number = this._verticalRange.x - this.targetTop;
			if (start < 0)
				start = 0;
			var intendDataIndex:int = Math.floor(start / blockSize) - Math.floor((_maxCacheBlock - maxVisualCount()) / 2);
			if (intendDataIndex < 0)
				intendDataIndex = 0
			else if (intendDataIndex > len - _maxCacheBlock)
				intendDataIndex = len - _maxCacheBlock;

			var tempIntend:int;
			var tempRealty:int;
			var msg:String = "";
			if (intendDataIndex != _firstDrawableIndex)
			{
				for (var i:int = 0; i < _maxCacheBlock; i++)
				{
					tempIntend = intendDataIndex + i;
					if (_firstDrawableIndex == -1) //_firstDrawableIndex == -1表示还没有构造过数据
						this._dirtyBlocks.push(tempIntend);
					else
					{
						if (bitmapBlocks[tempIntend] == null)
						{ //是空的
							tempRealty = _firstDrawableIndex + _maxCacheBlock - i - 1;
							bitmapBlocks[tempIntend] = bitmapBlocks[tempRealty];
							bitmapBlocks[tempRealty] = null;
							this._dirtyBlocks.push(tempIntend);
							var temp:int = _dirtyBlocks.indexOf(tempRealty);
							if (temp >= 0)
								this._dirtyBlocks.splice(temp, 1);
						}
					}
				}

				/**
				 * 这个排序算法会根据当前用户滚动的方向,排列重绘的优先级
				 * 优先满足 可视区域
				 * 其次满足 顺着滑动方向的不可见区域
				 * 最后满足 逆着滑动方向的不可见区域
				 * **/
				_dirtyBlocks.sort(function(block1:Number, block2:Number):int
				{
					var start:int = firstVisual;
					var end:int = lastVisual + 1;
					if (intendDataIndex > _firstDrawableIndex)
					{ //向上滑动
						if (block1 < start && block2 < start)
							return (block1 - block2) * -1;
						else if (block1 >= start && block2 >= start)
							return block1 - block2;
						if (block1 < start)
							block1 = 1;
						else if (block1 <= end)
							block1 = 0;
						else
							block1 = 2;
						if (block2 < start)
							block2 = 1;
						else if (block1 <= end)
							block2 = 0;
						else
							block2 = 2;
						return block1 - block2;
					}
					else
					{ //向下滑动
						if (block1 >= start && block2 >= start)
							return block1 - block2;
						else
							return (block1 - block2) * -1;
					}
				})
				_firstDrawableIndex = intendDataIndex;
			}
			if (_dirtyBlocks.length > 0)
				drawBlock(_dirtyBlocks.shift());
		}

		private function drawBlock(blockIndex:int):void
		{
			if (bitmapBlocks[blockIndex] == null)
			{
				bitmapBlocks[blockIndex] = BmdBlockPool.apply(_canvasWidth, blockSize);
				bitmapBlocks[blockIndex].lock();
			}
			else
				bitmapBlocks[blockIndex].fillRect(new Rectangle(0, 0, bitmapBlocks[blockIndex].width, //
					bitmapBlocks[blockIndex].height), 0x0);
			bitmapBlocks[blockIndex] = _delegate.getRealItemRender(blockIndex);
			if (isBlockVisble(blockIndex))
				drawCanvas();
		}

		private function isBlockVisble(blockIndex:int):Boolean
		{
			var start:Number = this._verticalRange.x - this.targetTop;
			if (start < 0)
				start = 0;
			var visualBlock:int = Math.floor(start / blockSize);
			return blockIndex >= visualBlock && blockIndex <= visualBlock + Math.ceil(_canvasHeight / blockSize);
		}

		/**
		 * 根据当前target的位置,绘制画布数据
		 */
		private var draw_sourceRect:Rectangle = new Rectangle();
		private var draw_destPoint:Point = new Point();
		private var draw_index:int = 0;
		private var draw_blitSize:int;
		private var draw_undraw:int;
		private var draw_candraw:int;
		private var draw_start:int;
		private var draw_fillSize:int;

		private function drawCanvas():void
		{
			_canvasBitmapdata.fillRect(new Rectangle(0, 0, _canvasWidth, _canvasHeight), 0x0);
			draw_start = Math.round(this._verticalRange.x - this.targetTop);
			draw_fillSize = 0;
			if (draw_start < 0)
			{ //左边有一些空白
				draw_fillSize += -draw_start;
				draw_start = 0;
			}
			draw_sourceRect.y = draw_start % blockSize; //需要这个块的数据是从哪开始的
			draw_sourceRect.width = _canvasWidth;

			draw_index = Math.floor(draw_start / blockSize); //现在需要第几块的数据
			draw_blitSize = getRealtyBlockSizeOf(draw_index); //这个块应该是多大
			draw_undraw = _canvasHeight - draw_fillSize; // 还差多少画完
			draw_candraw = draw_blitSize - draw_sourceRect.y; //当前位图块可以draw的地方
			while (true)
			{
				draw_destPoint.y = draw_fillSize;
				if (draw_candraw <= draw_undraw)
				{ //当前块不够大,一次draw不完
					draw_sourceRect.height = draw_candraw;
					copyPixelsFrom(draw_index, draw_sourceRect, draw_destPoint)
					draw_fillSize += draw_candraw;
					draw_undraw -= draw_candraw;
					draw_sourceRect.y = 0;
					if (draw_undraw < 0)
						break;
					else
					{
						draw_candraw = getRealtyBlockSizeOf(++draw_index);
						if (draw_candraw == 0)
							break;
					}
				}
				else if (draw_candraw > draw_undraw)
				{ //当前块足够大,一次可以draw完
					draw_sourceRect.height = draw_undraw;
					copyPixelsFrom(draw_index, draw_sourceRect, draw_destPoint)
					draw_sourceRect.y = 0;
					break;
				}
			}
			this._canvas.graphics.clear();
			this._canvas.graphics.beginBitmapFill(_canvasBitmapdata, null, false);
			this._canvas.graphics.drawRect(0, 0, _canvasWidth, _canvasHeight);
			this._canvas.graphics.endFill();
		}

		private function copyPixelsFrom(sourceIndex:int, sourceRect:Rectangle, destPoint:Point):void
		{
			var skin:BitmapData;
			if (sourceIndex >= bitmapBlocks.length || //
				bitmapBlocks[sourceIndex] == null || //
				_dirtyBlocks.indexOf(sourceIndex) != -1)
				skin = _delegate.getMockItemRender(sourceIndex);
			else
				skin = bitmapBlocks[sourceIndex]; //这个块是干净的
			_canvasBitmapdata.copyPixels(skin, sourceRect, destPoint);
		}

		/**
		 * 销毁方法
		 */
		override public function dispose():void
		{
			_canvas.removeEventListener(Event.ENTER_FRAME, rendingLoop);
			_canvas.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_canvas.graphics.clear();
			if (_canvasBitmapdata != null)
			{
				BmdBlockPool.recycle(_canvasBitmapdata);
				_canvasBitmapdata = null;
			}
			if (_bitmapBlocks != null)
			{
				for (var i:int = 0; i < _bitmapBlocks.length; i++)
					if (_bitmapBlocks[i])
					{
						BmdBlockPool.recycle(_bitmapBlocks[i]);
						_bitmapBlocks[i] = null;
					}
			}
			_bitmapBlocks = null;
			super.dispose();
		}

		/**
		 * 抛出有效点击事件
		 * 重载父类的方法,因为此时target已经被移除显示列表,所以globalToLocal的方法会有所不准
		 */
		override protected function effctiveClick(e:MouseEvent):void
		{
			this.dispatchEvent(new ScrollHelperEvent(ScrollHelperEvent.EffectiveClick, new Point(e.stageX, e.stageY)));
		}

		override public function set scrollEnable(bool:Boolean):void
		{
			super.scrollEnable = bool;
			if (this.scrollEnable)
			{
				_canvas.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				_canvas.addEventListener(Event.ENTER_FRAME, rendingLoop);
			}
			else
			{
				_canvas.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				_canvas.removeEventListener(Event.ENTER_FRAME, rendingLoop);
			}
		}

		//		/**
		//		 * 更新某块矩形的视图.
		//		 * rect 是滚动目标坐标系的一个矩形区域.表示这部分区域需要马上更新的
		//		 */
		public function vailteRectangle(rect:Rectangle):void
		{
			if (rect == null)
				return;
			if (rect.right < 0 || rect.left > target.width || rect.bottom < 0 || rect.top > target.height)
				return;
			if (rect.x < 0)
				rect.x = 0;

			if (rect.right > target.width)
				rect.width = target.width - rect.x;

			if (rect.y < 0)
				rect.y = 0;

			if (rect.bottom > target.height)
				rect.height = target.height - rect.y;

			var start:int = Math.floor(rect.y / blockSize);
			var startX:Number = rect.x;
			var startY:Number = rect.y;
			var change:Boolean = false;
			while (startY < rect.bottom)
			{
				var dirtyRect:Rectangle = new Rectangle(startX, startY, rect.width, 0);
				if (rect.height - (startY - rect.y) < _canvasHeight) //剩余的脏数据比一块小
					dirtyRect.height = rect.height - startY + rect.y;
				else
					dirtyRect.height = _canvasHeight;
				startY = dirtyRect.bottom;

				if (_dirtyBlocks.indexOf(start) == -1)
				{
					dirtyRect.y -= start * blockSize; //取偏移量
					_dirtyBlocks.push(start);
				}
				start++;
			}
		}

		public function vailteItem(index:int):void
		{
			if (_dirtyBlocks.indexOf(index) == -1)
				_dirtyBlocks.push(index);
		}

		private function getRealtyBlockSizeOf(index:int):Number
		{
			if (bitmapBlocks == null || bitmapBlocks.length == 0)
				return 0;

			if (index >= 0 && index < bitmapBlocks.length - 1)
				return blockSize;
			else if (index == bitmapBlocks.length - 1)
				return this.target.height - blockSize * (bitmapBlocks.length - 1);
			else
				return 0;
		}

		private function onMouseDown(e:MouseEvent):void
		{
			this.beginDrag();
		}

		public function get bitmapBlocks():Vector.<BitmapData>
		{
			return this._bitmapBlocks;
		}


		public function get firstVisual():int
		{
			var start:Number = this._verticalRange.x - this.targetTop;
			if (start < 0)
				start = 0;
			return Math.floor(start / blockSize);
		}

		public function get lastVisual():int
		{
			var start:int = firstVisual;
			var max:int = maxVisualCount();
			return Math.min(bitmapBlocks.length - 1, max + start);
		}

		private function maxVisualCount():int
		{
			return Math.ceil(this._canvasHeight / blockSize)
		}

		protected function get blockSize():Number
		{
			return this._delegate.itemHeight;
		}

		public function get visible():Boolean
		{
			return this._canvas.visible
		}

		public function set visible(value:Boolean):void
		{
			this._canvas.visible = value;
		}

		public function get view():DisplayObject
		{
			return _canvas;
		}

		protected function get target():Object
		{
			return _target;
		}

		public function get sizePer():Number
		{
			if (_canvas.height >= _target.height)
				return 1;
			var flex:Number = 0;
			if (target.y > 0)
				flex = target.y;
			else if (target.y < _canvasHeight - _target.height)
				flex = _canvasHeight - _target.height - target.y;
			return _canvasHeight / (_target.height + flex);
		}

		public function get posPer():Number
		{
			if (_canvasHeight >= _target.height)
				return 0;
			else if (_target.y >= 0)
				return 0;
			else if (_target.y <= _canvasHeight - _target.height)
				return 1;
			else
				return _target.y / (_canvasHeight - _target.height);
		}

		/**
		 * 全部重绘一次。
		 */
		public function redraw(px:Number = 0, py:Number = 0):void
		{
			_target.width = _delegate.listWidth;
			_target.height = _delegate.listHeight;
			_target.x = px, _target.y = py;
			for (var i:int = 0; i < _bitmapBlocks.length; i++)
			{
				if (_bitmapBlocks[i])
					BmdBlockPool.recycle(_bitmapBlocks[i]);
				_bitmapBlocks[i] = null;
			}
			_bitmapBlocks.length = Math.ceil(this.target.height / blockSize);
			_maxCacheBlock = Math.min(Math.ceil(target.height / blockSize), //
				(Math.ceil(_canvasHeight / blockSize) + 1) * 3);
			updateScrollParams();

			_firstDrawableIndex = -1;
			_dirtyBlocks = new Vector.<int>();
		}
	}
}
