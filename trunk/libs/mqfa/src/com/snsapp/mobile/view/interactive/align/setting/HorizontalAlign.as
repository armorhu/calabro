package com.snsapp.mobile.view.interactive.align.setting
{
	import flash.geom.Point;

	public class HorizontalAlign extends AlignSetting
	{
		public var rowSize:int;

		public function HorizontalAlign(rowSize:int = 1)
		{
			this.rowSize = rowSize;
		}

		override public function getPostionOf(index:int):Point
		{
			var cols:int = index / rowSize;
			var rows:int = index - rowSize * cols;
			return new Point(left + cols * (cellWidth + horCellGap), top + rows * (cellHeight + verCellGap));
		}

		override public function computeColnumCount(itemSum:int):int
		{
			if (itemSum % rowSize == 0)
				return itemSum / rowSize;
			else
				return Math.floor(itemSum / rowSize) + 1;
		}

		override public function computeRowCount(itemSum:int):int
		{
			return Math.min(itemSum, rowSize);
		}

		override public function getIndexOf(pt:Point):int
		{
			return Math.floor((pt.x - left) / (this.cellWidth + horCellGap) * this.rowSize) + //
				Math.floor((pt.y - top) / (this.cellHeight + verCellGap))
		}
	}
}
