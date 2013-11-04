package com.snsapp.mobile.view.interactive.align.setting
{
	import flash.geom.Point;

	/**
	 * 布局设置类
	 * @author armorhu
	 */
	public class AlignSetting
	{
		public var top:Number = 0;
		public var left:Number = 0;
		public var right:Number = 0;
		public var bottom:Number = 0;
		public var cellHeight:Number = 100;
		public var cellWidth:Number = 100;
		public var horCellGap:Number = 0;
		public var verCellGap:Number = 0;

		public function AlignSetting()
		{
//			throw new Error("AlignSetting can not be Create!");
		}

		public function getPostionOf(index:int):Point
		{
			// override by subclass
			return null;
		}

		public function getIndexOf(pt:Point):int
		{
			// override by subclass
			return 0;
		}

		public function computeColnumCount(itemSum:int):int
		{
			// override by subclass
			return 0;
		}

		public function computeRowCount(itemSum:int):int
		{
			// override by subclass
			return 0;
		}

		public function computeAlignWidth(itemSum:int):Number
		{
			if (itemSum == 0)
				return 0;
			var colCount:int = computeColnumCount(itemSum);
			return colCount * (cellWidth + horCellGap) - horCellGap + left + right;
		}

		public function computeAlignHeight(itemSum:int):Number
		{
			if (itemSum == 0)
				return 0;
			var rowCount:int = computeRowCount(itemSum);
			return rowCount * (cellHeight + verCellGap) - verCellGap + left + right;
		}
	}
}
