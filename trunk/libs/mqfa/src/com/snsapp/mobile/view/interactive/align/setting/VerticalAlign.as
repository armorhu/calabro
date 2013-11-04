package com.snsapp.mobile.view.interactive.align.setting
{
	import flash.geom.Point;

	public class VerticalAlign extends AlignSetting
	{
		public var colSize:int;

		public function VerticalAlign(colSize:int = 1)
		{
			this.colSize = colSize;
		}

		override public function getPostionOf(index:int):Point
		{
			var rows:int = index / colSize;
			var cols:int = index - rows * colSize;
			return new Point(left + cols * (cellWidth + horCellGap), top + rows * (cellHeight + verCellGap));
		}


		override public function computeColnumCount(itemSum:int):int
		{
			if (itemSum % colSize == 0)
				return itemSum / colSize;
			else
				return Math.floor(itemSum / colSize) + 1;
		}

		override public function computeRowCount(itemSum:int):int
		{
			return Math.min(itemSum, colSize);
		}

		override public function getIndexOf(pt:Point):int
		{
			return Math.floor((pt.x - left) / this.cellWidth * this.colSize) + //
				Math.floor((pt.y - top) / this.cellHeight)
		}
	}
}
