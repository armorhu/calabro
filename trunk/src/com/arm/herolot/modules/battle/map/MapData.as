package com.arm.herolot.modules.battle.map
{
	import com.arm.herolot.modules.battle.battle.item.Item;
	import com.arm.herolot.modules.battle.battle.monster.Monster;
	
	import flash.geom.Point;

	/**
	 * 地图数据
	 * @author hufan
	 */
	public class MapData
	{
		public var groundData:Vector.<int>;
		public var blockData:Vector.<int>;
		public var monsterData:Vector.<Monster>;
		public var itemData:Vector.<Item>;
		public var matrixData:Vector.<Vector.<int>>;
		public var doorPosition:Point;
		public var level:int;
		public var hasKey:Boolean;
	}
}
