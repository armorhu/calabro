package com.snsapp.mobile.view.interactive.align.area.place
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * 动物的放养驱
	 * @author hufan
	 */
	public class RectangleArea extends Area
	{
		private var _rect:Rectangle;
		private var w:Number;
		private var h:Number;

		public function RectangleArea(rect:Rectangle, row:int, col:int)
		{
			super(col, row);
			_rect = rect;
			w = _rect.width / _col;
			h = _rect.height / _row;
//			var s:Sprite = new Sprite();
//			s.graphics.lineStyle(2, 0x00ff00);
//			s.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
//			s.graphics.endFill();
//			StageInstance.stage.addChild(s);
		}

		/**
		 * @param x
		 * @param y
		 */
		public override function checkHitTest(x:Number, y:Number):Point
		{
			var tpx:Number = x;
			var tpy:Number = y;
			if (x < _rect.left)
				x = _rect.left;
			else if (x > _rect.right)
				x = _rect.right;

			if (y < _rect.top)
				y = _rect.top;
			else if (y > _rect.bottom)
				y = _rect.bottom;

			if (x == tpx && y == tpy)
				return null;
			else
				return new Point(x, y);
		}


		public override function getPostionsAt(index:int):Point
		{
			index = index % (_col * _row);
			var point:Point = _rect.topLeft;
			var x:Number = index % _col * w + point.x + w / 2;
			var y:Number = int(index / _col) * h + point.y + h / 2;
//			trace(x, y);
			return new Point(x, y);
		}
	}
}
