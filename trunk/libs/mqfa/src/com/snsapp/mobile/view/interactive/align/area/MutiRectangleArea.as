package com.snsapp.mobile.view.interactive.align.area
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class MutiRectangleArea implements IArea
	{
		private var _rects:Vector.<Rectangle>;
		private var _posSetting:Vector.<int>; //位置点的分配
		private var _posCount:int;

		public function MutiRectangleArea(rects:Vector.<Rectangle>, posCount:int)
		{
			_posCount = posCount;
			var total:Number = 0;
			const len:int = _rects.length;
			for (var i:int = 0; i < len; i++)
				total += _rects[i].width * _rects[i].height;

			var rest:int = posCount;
			var length:int;
			for (i = 0; i < len; i++)
			{
				length = ((_rects[i].width * _rects[i].height) / total) * posCount;
				if (length > rest)
					length = rest;
				else if (length < 1)
					length = 1;
				_posSetting.push(length);
				rest -= length;
			}
		}

		public function checkHitTest(x:Number, y:Number):Point
		{
			const len:int = _rects.length;
			var start:Point = new Point(x, y);
			var bestPoint:Point = null;
			var hitResult:Point;
			for (var i:int = 0; i < len; i++)
			{
				hitResult = checkHitTestRect(_rects[i], x, y);
				if (hitResult)
				{
					if (bestPoint == null)
						bestPoint = hitResult;
					else
						bestPoint = getNearestPoint(start, bestPoint, hitResult);
				}
				else
					return null;
			}
			
			return bestPoint;
		}

		private function getNearestPoint(start:Point, end1:Point, end2:Point):Point
		{
			var dist1:Number = (start.x - end1.x) * (start.x - end1.x) + //
				(start.y - end1.y) * (start.y - end1.y);

			var dist2:Number = (start.x - end2.x) * (start.x - end2.x) + //
				(start.y - end2.y) * (start.y - end2.y);

			return dist1 < dist2 ? end1 : end2;
		}

		/**
		 * @param x
		 * @param y
		 */
		private function checkHitTestRect(rect:Rectangle, x:Number, y:Number):Point
		{
			var tpx:Number = x;
			var tpy:Number = y;
			if (x < rect.left)
				x = rect.left;
			else if (x > rect.right)
				x = rect.right;

			if (y < rect.top)
				y = rect.top;
			else if (y > rect.bottom)
				y = rect.bottom;

			if (x == tpx && y == tpy)
				return null;
			else
				return new Point(x, y);
		}

		public function getPostionsAt(index:int):Point
		{
			index = index % _posCount;

			for (var i:int = 0; i < _posSetting.length; i++)
			{
				if (index > _posSetting[i])
					index -= _posSetting[i];
				else
					return getPostions(_rects[i], index, _posSetting[i]);
			}
			return null;
		}

		private function getPostions(rect:Rectangle, offset:int, length:int):Point
		{
			var col:int;
			var row:int;
			var colPercent:Number = rect.width / (rect.width + rect.height);
			col = length * colPercent;
			if (col < 1)
				col = 1;
			row = Math.ceil(offset / col);
			if (row < 1)
				row = 1;
			var w:Number = rect.width / col;
			var h:Number = rect.height / row;
			var point:Point = rect.topLeft;
			var x:Number = offset % col * w + point.x + w / 2;
			var y:Number = int(offset / col) * h + point.y + h / 2;
			return new Point(x, y);
		}
	}
}
