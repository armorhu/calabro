package com.snsapp.mobile.view.interactive.align.area
{
	import flash.geom.Point;

	/**
	 * 动物生产区
	 * @author hufan
	 */
	public class PointsArea extends Area
	{
		private var _poss:Vector.<Vector.<Point>>;

		public function PointsArea(p1:Point, p2:Point, p3:Point, row:int, col:int)
		{
			super(col, row);
//			p1.x *= scale;
//			p1.y *= scale;
//			p2.x *= scale;
//			p2.y *= scale;
//			p3.x *= scale;
//			p3.y *= scale;

			var k:Number;
			k = (p1.y - p2.y) / (p1.x - p2.x); //斜率
			const xDist:Number = (p2.x - p1.x) / _col; //x轴偏移量
			const yDist:Number = xDist * k; //y轴偏移量
			//换行时的偏移量
			const rowDistX:Number = p3.x - p1.x;
			const rowDistY:Number = p3.y - p1.y;

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
					pos[j].x = p1.x + j * xDist;
					pos[j].y = p1.y + j * yDist;
				}
				p1.x += rowDistX;
				p1.y += rowDistY;
			}
		}

		public override function checkHitTest(x:Number, y:Number):Point
		{
			return null;
		}

		public override function getPostionsAt(index:int):Point
		{
			index = index % (_col * _row);
			var c:int = index % _col;
			var r:int = index / _col;
			return _poss[r][c];
		}
	}
}
