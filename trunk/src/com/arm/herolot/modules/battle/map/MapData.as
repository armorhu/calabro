package com.arm.herolot.modules.battle.map
{
	import flash.geom.Point;

	/**
	 * 地图数据
	 * @author hufan
	 */
	public class MapData
	{
		/**
		 *格子
		 */		
		public var grids:Vector.<MapGridData>;
		
		public var floor:int;
		/**
		 *起始位置 
		 */		
		public var door:int;
		
		/**
		 *攻击增加的buff。
		 */
		public var ackBufferRange:Point;
		
		/**
		 *生命增加的buff。
		 */		
		public var hpBufferRange:Point;
		
	}
}
