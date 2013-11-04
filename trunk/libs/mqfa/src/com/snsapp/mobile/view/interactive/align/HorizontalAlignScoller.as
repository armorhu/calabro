package com.snsapp.mobile.view.interactive.align
{
	import com.snsapp.mobile.mananger.cachepool.SimpleCachePool;
	import com.snsapp.mobile.mananger.factory.IFactory;
	import com.snsapp.mobile.view.interactive.align.setting.AlignSetting;
	import com.snsapp.mobile.view.interactive.align.setting.HorizontalAlign;
	import com.snsapp.mobile.view.interactive.scroll.ScrollHelperEvent;
	import com.snsapp.mobile.view.interactive.scroll.blitmask.HorizontalScrollBlitmask;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	public class HorizontalAlignScoller extends AlignPanel
	{
		protected var _scoller:HorizontalScrollBlitmask;
		protected var _range:Point;
		protected var _flexable:Number;
		protected var _dynamicFunction:Function;
		protected var _dynamicContentContainer:Sprite;
		protected var _skin:BitmapData;

		/**
		 *
		 * @param itemFactory
		 * @param alignSetting
		 * @param range
		 * @param flexable
		 * @param dynamicFunction 允许用户设置动态的显示内容,当滚动停下时会调用你所传入的函数
		 * 						  参数统一为一个displayobject,是与你要显示的内容所对应的item
		 */
		[Event(name = "AlignEvent_ClickChild", type = "com.snsapp.mobile.view.interactive.align.AlignEvent")]
		public function HorizontalAlignScoller(itemFactory:IFactory, //
			row:int, //
			range:Point, //
			flexable:Number, //
			skin:BitmapData, //
			dynamicFunction:Function = null, //
			panelBgSkin:BitmapData = null)
		{
			var alignSetting:AlignSetting = new HorizontalAlign();
			alignSetting.cellWidth = skin.width;
			alignSetting.cellHeight = skin.height;
			_skin = skin;
			super(itemFactory, alignSetting, panelBgSkin);
			this._dynamicFunction = dynamicFunction;
			_range = range;
			_flexable = flexable;
		}

		override protected function buildComplete():void
		{
			buildBlitMaskData();
			super.buildComplete();
		}

		protected function buildBlitMaskData():void
		{
			if (_scoller)
			{
				registerListener(false);
				_scoller.dispose();
			}
			if (_dynamicContentContainer)
				clearDynamicContent();
			/**尽量保持原来的位置.仅在位置不够时换位**/
			if (_itemContainer.width < (_range.y - _range.x))
				_itemContainer.x = left;
			else if (_itemContainer.x >= left)
				_itemContainer.x = left;
			else if (_itemContainer.x + _itemContainer.width < right)
				_itemContainer.x = right - _itemContainer.width;

			if (_itemContainer.width > 0 && _itemContainer.height > 0)
			{
				if (_dynamicFunction != null)
				{
					/**构建动态展示内容**/
					_dynamicContentContainer = new Sprite();
					var index:int = this.getChildIndex(_itemContainer);
					this.addChildAt(_dynamicContentContainer, index + 1);
					var myMask:Shape = new Shape();
					myMask.graphics.beginFill(0);
					myMask.graphics.drawRect(left, _itemContainer.y, right - left, _itemContainer.height);
					myMask.graphics.endFill();
					this.addChild(myMask);
					_dynamicContentContainer.mask = myMask;
					this.addEventListener(Event.ENTER_FRAME, loop, false, -10, true);
					_scoller = new HorizontalScrollBlitmask(_itemContainer, _skin, new Point(left, right), _flexable);
					registerListener(true);
					if (_dynamicFunction != null)
						endScroll(null);
				}
				else
					_scoller = new HorizontalScrollBlitmask(_itemContainer, _skin, new Point(left, right), _flexable);

				this._scoller.addEventListener(ScrollHelperEvent.EffectiveClick, onClickChild);
			}
		}

		private function registerListener(bool:Boolean):void
		{
			if (_scoller == null)
				return;
			if (bool)
			{
				this._scoller.addEventListener(ScrollHelperEvent.BeginScroll, beginScroll);
				this._scoller.addEventListener(ScrollHelperEvent.EndScroll, endScroll);
				this._scoller.addEventListener(ScrollHelperEvent.ParsueScroll, endScroll);
			}
			else
			{
				this._scoller.removeEventListener(ScrollHelperEvent.BeginScroll, beginScroll);
				this._scoller.removeEventListener(ScrollHelperEvent.EndScroll, endScroll);
				this._scoller.removeEventListener(ScrollHelperEvent.ParsueScroll, endScroll);
			}
		}

		private function beginScroll(e:ScrollHelperEvent):void
		{
			while (_dynamicContentContainer.numChildren > 0)
			{
				if (_dynamicContentContainer.getChildAt(0) is Loader)
					Loader(_dynamicContentContainer.getChildAt(0)).unloadAndStop(true);
				else if (_dynamicContentContainer.getChildAt(0) is MovieClip)
					MovieClip(_dynamicContentContainer.getChildAt(0)).stop();
				_dynamicContentContainer.removeChildAt(0);
			}
		}

		private function endScroll(e:ScrollHelperEvent):void
		{
			var end:int = this.lastVisualIndex;
			this._dynamicContentContainer.x = this.x;
			trace("可见区域：", this.firstVisualIndex, end);
			for (var i:int = firstVisualIndex; i < end; i++)
				_dynamicFunction(this.getChildAt(i), this._dynamicContentContainer);
		}

		private function onClickChild(e:ScrollHelperEvent):void
		{
			var index:int = this._alignSetting.getIndexOf(e.localPoint);
			if (index >= 0 && index < this._itemCount)
				dispatchEvent(new AlignEvent(AlignEvent.ClickChild, index));
		}


		private function get firstVisualIndex():int
		{
			var num:int = Math.floor((left - _itemContainer.x) / (align.cellHeight + align.horCellGap));
			if (num < 0)
				num = 0;
			return num * (align as HorizontalAlign).rowSize;
		}

		private function get lastVisualIndex():int
		{
			if (_itemCount == 0)
				return 0;
			var first:int = firstVisualIndex;
			return (first + maxVisualCount) > this._itemCount ? //
				this._itemCount : (first + maxVisualCount);
		}

		private function get maxVisualCount():int
		{
			var num:Number = (right - left) / (align.cellWidth + align.horCellGap);
			if (num - Math.floor(num) < 0.1)
				num = Math.floor(num);
			else
				num = Math.floor(num) + 1;
			return num * (align as HorizontalAlign).rowSize;
		}

		public function dispose():void
		{
			clearDynamicContent();
			if (_scoller)
			{
				this.registerListener(false);
				this._scoller.removeEventListener(ScrollHelperEvent.EffectiveClick, onClickChild);
				_scoller.dispose();
			}
			if (this._itemFactory is SimpleCachePool)
				SimpleCachePool(this._itemFactory).clear();
		}


		private function clearDynamicContent():void
		{
			if (_dynamicContentContainer)
			{
				var child:DisplayObject
				while (_dynamicContentContainer.numChildren)
				{
					child = _dynamicContentContainer.getChildAt(0);
					if (child is MovieClip)
						MovieClip(child).stop();
					else if (child is Loader)
						Loader(child).unloadAndStop();
					_dynamicContentContainer.removeChild(child);
				}
				if (_dynamicContentContainer.parent)
					_dynamicContentContainer.parent.removeChild(_dynamicContentContainer);
				_dynamicContentContainer = null;
				this.removeEventListener(Event.ENTER_FRAME, loop);
			}
		}

		private function loop(e:Event):void
		{
			_dynamicContentContainer.x = this.x;
		}

		private function get left():Number
		{
			return this._range.x - this.x;
		}

		private function get right():Number
		{
			return this._range.y - this.x;
		}
	}
}
