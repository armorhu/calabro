package com.snsapp.mobile.view.interactive.align.area
{
	import flash.geom.Point;

	public class Area implements IArea
	{
		protected var _col:int;
		protected var _row:int;
		private var _placedId:Vector.<int>;

		public function Area(col:int, row:int)
		{
			_col = col;
			_row = row;
			_placedId = new Vector.<int>();
			for (var i:int = 0; i < (_row * _col); i++)
				_placedId.push(0);
		}

		public function checkHitTest(x:Number, y:Number):Point
		{
			return null;
		}

		public function getPostionsAt(index:int):Point
		{
			return null;
		}

		public function allocPlaceId(row:int = -1):int
		{
			const len:int = _placedId.length;
			var start:int, end:int;
			if (row == -1)
			{
				start = 1;
				end = len;
			}
			else
			{
				start = row * _col + 1;
				end = (row + 1) * _col;
			}
			var min:int = _placedId[start - 1];
			for (var i:int = start; i < end; i++)
			{
				if (_placedId[i] < min)
					min = _placedId[i];
			}

			var index:int = _placedId.indexOf(min, start - 1);
			_placedId[index]++;
			return index;
		}

		public function disposePlaceId(placeId:int):void
		{
			_placedId[placeId]--;
		}
	}
}
