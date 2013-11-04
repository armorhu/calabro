package com.snsapp.starling.display.scroll
{
	import com.greensock.TweenLite;
	import com.snsapp.mobile.view.interactive.scroll.ScrollCoreEx;
	import com.snsapp.mobile.view.interactive.scroll.ScrollHelperEvent;
	import com.snsapp.mobile.view.interactive.scroll.ScrollPolicy;
	import com.snsapp.starling.StarlingFactory;
	import com.snsapp.starling.texture.implement.SingleTexture;

	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;

	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	/**
	 * GPU的滚动列表。
	 * @author hufan
	 */
	public class StarlingScrollList extends ScrollCoreEx
	{
		private var _bigView:Sprite; //真正对外公佈的view
		private var _view:Sprite; //供ScrollCore做手势操作的Target。
		private var _itemContainer:Sprite; //item容器。
		private var _viewBackground:Quad; //大背景，用来填充_view。

		private var _delegate:IStarlingScrollListDelegate; //代理
		private var _vectical:Boolean; //水平，还是竖直的
		private var _width:Number;
		private var _height:Number;

		public function StarlingScrollList(delegate:IStarlingScrollListDelegate, //
			vertical:Boolean, //
			range:Point, flexble:Number)
		{
			_delegate = delegate;
			_vectical = vertical;
			_bigView = new Sprite();
			_view = new Sprite();
			_bigView.addChild(_view);
			_viewBackground = new Quad(1, 1);
			_viewBackground.alpha = 0;
			_view.addChild(_viewBackground);
			_itemContainer = new Sprite();
			_view.addChild(_itemContainer);
			var params:Array;
			if (vertical)
				params = [_view, null, range, 0, flexble, 0, 1];
			else
				params = [_view, range, null, flexble, 0, 1, 0];
			super(params[0], params[1], params[2], params[3], params[4], params[5], params[6]);

			redraw();
			if (vertical)
				this._scrollPolicy = ScrollPolicy.VerticalOnly;
			else
				this._scrollPolicy = ScrollPolicy.HorizontalOnly;
		}

		override public function set scrollPolicy(policy:int):void
		{
			//不让人改滚动策略	
		}

		override public function set scrollEnable(bool:Boolean):void
		{
			super.scrollEnable = bool;
			if (this.scrollEnable)
			{
				_view.addEventListener(TouchEvent.TOUCH, onMouseDown);
				_view.addEventListener(Event.ENTER_FRAME, rendingLoop);
			}
			else
			{
				_view.removeEventListener(TouchEvent.TOUCH, onMouseDown);
				_view.removeEventListener(Event.ENTER_FRAME, rendingLoop);
			}
		}

		private function onMouseDown(e:TouchEvent):void
		{
			var touch:Touch = e.getTouch(_view, TouchPhase.BEGAN);
			if (touch && touch.phase == TouchPhase.BEGAN)
				beginDrag();
		}

		private var _cleanMap:Object = {};
		private var _dirtyList:Vector.<DisplayObject> = new Vector.<DisplayObject>();

		private function rendingLoop(e:Event):void
		{
//			validateScrollBar();
			var start:int = firstVisual; //第一个被看见的
			var end:int = lastVisual; //最后一个被看见的
			var renderStart:int = 0, renderEnd:int;
			if (_itemContainer.numChildren > 0)
				renderStart = int(_itemContainer.getChildAt(0).name);
			renderEnd = renderStart + _itemContainer.numChildren;
			if (renderStart == start && renderEnd == end)
				return;
			var render:DisplayObject, index:int;

			for (var i:int = 0, len:int = _itemContainer.numChildren; i < len; i++)
			{
				render = _itemContainer.getChildAt(i);
				render.visible = false;
				index = int(render.name);
				if (index >= start && index < end) //可见的。
					_cleanMap[render.name] = render;
				else
					_dirtyList.push(render);
			}

			var pos:Point = new Point();
			for (i = start; i < end; i++)
			{
				render = _cleanMap[i];
				if (render == null)
				{
					if (_dirtyList.length > 0)
						render = _dirtyList.pop();
					render = _delegate.renderItemAt(i, render);
					if (render.parent == null)
						_itemContainer.addChild(render);
					render.name = i.toString();
				}
				else
					_cleanMap[i] = null;

				if (_vectical)
				{
					render.x = (i % _delegate.level) * _delegate.itemWidth;
					render.y = int(i / _delegate.level) * _delegate.itemHeight;
				}
				else
				{
					render.x = int(i / _delegate.level) * _delegate.itemWidth;
					render.y = (i % _delegate.level) * _delegate.itemHeight;
				}
				render.visible = true;
//				_itemContainer.addChild(render);
			}
		}

		public function redraw():void
		{
			if (_vectical)
			{
				_width = _delegate.itemWidth * _delegate.level;
				_height = _verticalRange.y - _verticalRange.x;
				_col = _delegate.level;
				_row = Math.ceil(_delegate.length / _delegate.level);
				_visbleCol = _col;
				_visbleRow = Math.ceil((_verticalRange.y - _verticalRange.x) / _delegate.itemHeight) + 1;
			}
			else
			{
				_width = _horizontalRange.y - _horizontalRange.x;
				_height = _delegate.itemHeight * _delegate.level;
				_col = Math.ceil(_delegate.length / _delegate.level);
				_row = _delegate.level;
				_visbleCol = Math.ceil((_horizontalRange.y - _horizontalRange.x) / _delegate.itemWidth) + 1;
				_visbleRow = _row;
			}
			_viewBackground.width = _col * _delegate.itemWidth;
			_viewBackground.height = _row * _delegate.itemHeight;
			while (_itemContainer.numChildren)
				_dirtyList.push(_itemContainer.removeChildAt(0));
			if (_target)
			{
				TweenLite.killTweensOf(_target);
				updateScrollParams();
			}
			setTo(0, 0);
			rendingLoop(null);
		}

		public function setTo(px:Number, py:Number):void
		{
			if (_target == null)
				return;
			if (_horizontalRange)
			{
				if (px >= _horizontalRange.x)
					px = _horizontalRange.x;
				else if (px + _view.width < _horizontalRange.y)
					px = _horizontalRange.y - _view.width;
			}
			targetLeft = px, targetTop = py;
		}

		public function get firstVisual():int
		{
			if (_horizontalRange)
			{
				var start:Number = this._horizontalRange.x - this.targetLeft;
				if (start < 0)
					start = 0;
				return Math.floor(start / _delegate.itemWidth) * _delegate.level;
			}
			else
			{
				start = this._verticalRange.x - this.targetTop;
				if (start < 0)
					start = 0;
				return Math.floor(start / _delegate.itemHeight) * _delegate.level;
			}
		}

		public function get lastVisual():int
		{
			var start:int = firstVisual;
			var max:int = _visbleCol * _visbleRow;
			return Math.min(_delegate.length, max + start);
		}

		private var _visbleCol:int;
		private var _visbleRow:int;
		private var _col:int;
		private var _row:int;


		public function get view():Sprite
		{
			return _bigView;
		}

		public function get itemContainer():Sprite
		{
			return _itemContainer;
		}

		protected override function effctiveClick(e:MouseEvent):void
		{
			if (_view.stage)
			{
				var localPoint:Point = _view.globalToLocal(new Point(mouseX, mouseY));
				var c:int = localPoint.x / _delegate.itemWidth;
				var r:int = localPoint.y / _delegate.itemHeight;
				var index:int;
				if (_vectical)
					index = r * _delegate.level + c;
				else
					index = c * _delegate.level + r;

				if (index >= 0 && index < _delegate.length)
					dispatchEvent(new ScrollHelperEvent(ScrollHelperEvent.EffectiveClick, new Point(index, 0)));
			}
		}

		public override function dispose():void
		{
			_bigView.removeChildren(0, -1, true);
			_bigView = null;
			_view = null; //供ScrollCore做手势操作的Target。
			_itemContainer = null; //item容器。
			_viewBackground = null; //大背景，用来填充_view。
			_delegate = null; //代理
		}

		/**
		 * 设置滚动条
		 * @param barTexture 滚动条
		 * @param bgTexture  滚动条的底板
		 */
		private var _scrollBar:DisplayObject;
		private var _scrollBarBg:DisplayObject;

		public function setScrollBarSkin(barTexture:SingleTexture, bgTexture:SingleTexture = null):void
		{
			if (_scrollBar)
				_scrollBar.removeFromParent(true);
			_scrollBar = null;
			if (_scrollBarBg)
				_scrollBarBg.removeFromParent(true);
			_scrollBarBg = null;

			if (bgTexture)
			{
				_scrollBarBg = StarlingFactory.newDisplayObj(bgTexture);
				_bigView.addChild(_scrollBarBg);
				if (_vectical)
				{
					_scrollBarBg.x = _width;
					_scrollBarBg.y = 0;
					_scrollBarBg.height = _height;
				}
				else
				{
					_scrollBarBg.x = 0;
					_scrollBarBg.y = _height;
					_scrollBarBg.width = _width;
				}
				_scrollBarBg.visible = false;
			}

			if (barTexture)
			{
				_scrollBar = StarlingFactory.newDisplayObj(barTexture);
				_bigView.addChild(_scrollBar);
				if (_vectical)
				{
					_scrollBar.x = _width;
					_scrollBar.y = 0;
				}
				else
				{
					_scrollBar.x = 0;
					_scrollBar.y = _height;
				}
				_scrollBar.visible = false;
				addEventListener(ScrollHelperEvent.BeginScroll, scrollingHandler);
				addEventListener(ScrollHelperEvent.EndScroll, scrollingHandler);
			}
			else
			{
				removeEventListener(ScrollHelperEvent.BeginScroll, scrollingHandler);
				removeEventListener(ScrollHelperEvent.EndScroll, scrollingHandler);
			}
		}

		private function scrollingHandler(e:ScrollHelperEvent):void
		{
			if (e.type == ScrollHelperEvent.BeginScroll)
			{
				if (_scrollBar)
					_scrollBar.visible = true;
				if (_scrollBarBg)
					_scrollBarBg.visible = true;
			}
			else
			{
				if (_scrollBar)
					_scrollBar.visible = false;
				if (_scrollBarBg)
					_scrollBarBg.visible = false;
			}
		}

		public function getSizePer():Number
		{
			if (_vectical)
			{
				if (_height >= _target.height)
					return 1;
				var flex:Number = 0;
				if (_target.y > 0)
					flex = _target.y;
				else if (_target.y < _height - _target.height)
					flex = _height - _target.height - _target.y;
				return _height / (_target.height + flex);
			}
			else
			{
				if (_width >= _targetWidth)
					return 1;
				flex = 0;
				if (_target.x > 0)
					flex = _target.x;
				else if (_target.x < _width - _targetWidth)
					flex = _width - _targetWidth - _target.x;
				return _width / (_targetWidth + flex);
			}
		}

		public function getPosPer():Number
		{
			if (_vectical)
			{
				if (_height >= _target.height)
					return 0;
				else if (_target.y >= 0)
					return 0;
				else if (_target.y <= _height - _targetHeight)
					return 1;
				else
					return _target.y / (_height - _targetHeight);
			}
			else
			{
				if (_width >= _targetWidth)
					return 0;
				else if (_target.x >= 0)
					return 0;
				else if (_target.x <= _width - _targetWidth)
					return 1;
				else
					return _target.x / (_width - _targetWidth);
			}
		}

		private function validateScrollBar():void
		{
//			return;
			if (_scrollBar && _scrollBar.visible)
			{
				var time:uint = getTimer();
				var size:Number = getSizePer();
				if (_vectical)
				{
					_scrollBar.height = _height * size;
					_scrollBar.y = (_height - _scrollBar.height) * getPosPer();
				}
				else
				{
					_scrollBar.width = _width * size;
					var pos:Number = getPosPer();
					_scrollBar.x = (_width - _scrollBar.width) * pos;
				}
			}
		}
	}
}
