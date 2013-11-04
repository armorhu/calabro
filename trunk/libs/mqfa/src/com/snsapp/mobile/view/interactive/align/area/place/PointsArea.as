package com.snsapp.mobile.view.interactive.align.area.place
{
	import flash.geom.Point;

	/**
	 * 动物生产区
	 * @author hufan
	 */
	public class PointsArea extends Area
	{
		private var _poss:Vector.<Vector.<Point>>;

		public function PointsArea(areaStart:Point, lastRowStart:Point, lastColStart:Point, row:int, col:int)
		{
			super(col, row);
			if (row < 2 || col < 2)
				throw new ArgumentError("PointsArea的行数和宽数都需都大于2");
			if (areaStart == null)
				areaStart = new Point();
			if (lastColStart == null)
				lastColStart = new Point();
			if (lastRowStart == null)
				lastRowStart = new Point();
			const colDistX:Number = (lastColStart.x - areaStart.x) / (col - 1); //列加一时的偏移量
			const colDistY:Number = (lastColStart.y - areaStart.y) / (col - 1); //列加一时的偏移量

			//换行时的偏移量
			const rowDistX:Number = (lastRowStart.x - areaStart.x) / (row - 1);
			const rowDistY:Number = (lastRowStart.y - areaStart.y) / (row - 1);

			_poss = new Vector.<Vector.<Point>>();
			_poss.length = _row;
			_poss.fixed = true;
			var pos:Vector.<Point>;
			for (var i:int = 0; i < _row; i++)
			{
				pos = new Vector.<Point>();
				pos.length = _col;
				pos.fixed = true;
				_poss[i] = pos;
				for (var j:int = 0; j < _col; j++)
				{
					pos[j] = new Point();
					pos[j].x = areaStart.x + j * colDistX;
					pos[j].y = areaStart.y + j * colDistY;
				}
				areaStart.x += rowDistX;
				areaStart.y += rowDistY;
			}
		}

		public override function checkHitTest(x:Number, y:Number):Point
		{
			return null;
		}

		public override function getPostionsAt(index:int):Point
		{
			if (index < 0)
				index += Math.ceil(Math.abs(index) / (_col * _row)) * (_col * _row);
			index = index % (_col * _row);
			var c:int = index % _col;
			var r:int = index / _col;
			return _poss[r][c];
		}
	}
}
