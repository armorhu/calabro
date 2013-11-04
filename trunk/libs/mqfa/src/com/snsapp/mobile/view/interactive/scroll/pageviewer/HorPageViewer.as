package com.snsapp.mobile.view.interactive.scroll.pageviewer
{
	import com.greensock.TweenLite;
	import com.qzone.utils.DisplayUtil;
	import com.snsapp.mobile.StageInstance;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;

	/**
	 * 水平的分页查看图片的播放器
	 * @author armorhu
	 */
	public class HorPageViewer extends Sprite
	{
		/**
		 * 图片的源
		 * **/
		private var _sourceBmd:BitmapData;

		private var _source:DisplayObject;

		/**
		 * 图片的页数
		 * **/
		private var _pageSum:int;

		private var _canvasWidth:int;

		private var _canvasHeight:int;

		private var _canvasBmd:BitmapData;

//		/**结束按钮**/
//		private var _completeBtn:InteractiveObject;
//		private var _completePage:int;

		private var _completeArea:Rectangle;

		public function set completeArea(rect:Rectangle):void
		{
			_completeArea = rect;
		}

		/**正在拖动**/
		private var _draging:Boolean;

		/**拖动的参数**/
		protected var _buttonDownX:Number;
		protected var _buttonDownSourceX:Number;
		protected var _offsetX:Number;
		protected var _buttonDownTime:Number;
		protected var _lastDrawX:Number;

		public function HorPageViewer(source:Bitmap, pageSum:Number, transparent:Boolean = true)
		{
			super();
			_source = source;
			_sourceBmd = source.bitmapData;
			_pageSum = pageSum;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			_canvasHeight = Math.ceil(_sourceBmd.height);
			_canvasWidth = Math.ceil(_sourceBmd.width / pageSum);
			_canvasBmd = new BitmapData(_canvasWidth, _canvasHeight, transparent, StageInstance.stage.color);
//			_completePage = -1;
		}

		private function onAddedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			addEventListener(Event.EXIT_FRAME, eachFrame);
			_lastDrawX = _source.x - 1;
			draging = false;
		}


		private function eachFrame(e:Event):void
		{
			if (_source == null)
				return;

			if (_draging)
			{ //正在拖动
				var tempX:Number = (stage.mouseX - _source.x - _offsetX);
				_source.x += tempX;
				if (_source.x > _canvasWidth / 3)
					_source.x = _canvasWidth / 3;
				else if (_source.x + _source.width < _canvasWidth * 2 / 3)
					_source.x = _canvasWidth * 2 / 3 - _source.width;
				_offsetX = stage.mouseX - _source.x;
			}

			if (_source.x != _lastDrawX)
			{
				_canvasBmd.fillRect(new Rectangle(0, 0, _canvasWidth, _canvasHeight), stage.color);
				_canvasBmd.copyPixels(_sourceBmd, new Rectangle(-_source.x, 0, _canvasWidth, _canvasHeight), new Point(0, 0));

				this.graphics.clear();
				this.graphics.beginBitmapFill(_canvasBmd, null, false, true);
				this.graphics.drawRect(0, 0, _canvasWidth, _canvasHeight);
				this.graphics.endFill();
				_lastDrawX = _source.x;
			}
		}

		private function beginDrag(e:MouseEvent):void
		{
//			trace(e.localX - _source.x, e.localY);
			if (_completeArea && _completeArea.contains(e.localX - _source.x, e.localY))
			{
				dispatchEvent(new Event(Event.COMPLETE));
				return;
			}
//			if (_completeBtn && _completeBtn.parent)
//				removeChild(_completeBtn);
			draging = true;
			_buttonDownX = stage.mouseX;
			_offsetX = stage.mouseX - _source.x;
			_buttonDownSourceX = _source.x;
			_buttonDownTime = getTimer();
			TweenLite.killTweensOf(_source);
		}

		private function endDrag(e:MouseEvent):void
		{
			draging = false;
			var xOffset:Number = e.stageX - _buttonDownX; //这个拖动过程中鼠标移动了多少
			var timeCost:int = getTimer() - _buttonDownTime; //这个拖动过程耗时多少
			if (timeCost < 300 && Math.abs(xOffset) > 50) //swipe
			{
				var tempX:Number = _source.x * -1;
				if (tempX < 0)
					tempX = 0;
				else if (tempX > _canvasWidth * (_pageSum - 1))
					tempX = _canvasWidth * (_pageSum - 1);
				var index:Number = tempX / _canvasWidth;
				if (xOffset > 0) //往右滑 往前一页
				{
					if (Math.floor(index) == index)
						index--;
					else
						index = Math.floor(index);
				}
				else
				{
					if (Math.ceil(index) == index)
						index++;
					else
						index = Math.ceil(index);
				}

				if (index < 0)
				{
					tweenTo(_canvasWidth / 3, function brounceBack():void
					{
						tweenTo(0);
					})
					index = 0;
				}
				else if (index >= _pageSum)
				{
					tweenTo(-_canvasWidth / 3 - (_pageSum - 1) * _canvasWidth, function brounceBack():void
					{
						tweenTo(-(_pageSum - 1) * _canvasWidth)
					});
					index = _pageSum - 1;
				}
				else
					tweenTo(index * _canvasWidth * -1);
				return;
			}

			var targetPage:int = Math.round(_source.x * -1 / _canvasWidth);
			if (targetPage < 0)
				targetPage = 0;
			else if (targetPage >= _pageSum)
				targetPage = _pageSum - 1;
			tweenTo(targetPage * _canvasWidth * -1);
		}

		private function set draging(value:Boolean):void
		{
			if (value)
			{
				_draging = true;
				addEventListener(MouseEvent.MOUSE_UP, endDrag);
				addEventListener(MouseEvent.MOUSE_OUT, endDrag);
				removeEventListener(MouseEvent.MOUSE_DOWN, beginDrag);
			}
			else
			{
				_draging = false;
				removeEventListener(MouseEvent.MOUSE_DOWN, endDrag);
				removeEventListener(MouseEvent.MOUSE_OUT, endDrag);
				addEventListener(MouseEvent.MOUSE_DOWN, beginDrag);
			}
		}

		private function tweenTo(targetX:Number, onComplete:Function = null):void
		{
			var dist:Number = Math.abs(targetX - _source.x);
			var time:Number = dist / _canvasWidth > 0.5 ? 0.5 : dist / _canvasWidth;
			if (onComplete != null)
				TweenLite.to(_source, time, {x: targetX, onComplete: onComplete});
			else
				TweenLite.to(_source, time, {x: targetX});
		}


		override public function get width():Number
		{
			return this._canvasWidth * this.scaleX;
		}

		override public function get height():Number
		{
			return this._canvasHeight * this.scaleY;
		}


		public function dispose():void
		{
			removeEventListener(MouseEvent.MOUSE_DOWN, endDrag);
			removeEventListener(MouseEvent.MOUSE_OUT, endDrag);
			removeEventListener(MouseEvent.MOUSE_DOWN, beginDrag);
			removeEventListener(Event.ENTER_FRAME, eachFrame);
			_sourceBmd.dispose();
			TweenLite.killTweensOf(_source);
			_source = null;
			_canvasBmd.dispose();
			if (this.parent)
				this.parent.removeChild(this);
		}
	}
}
