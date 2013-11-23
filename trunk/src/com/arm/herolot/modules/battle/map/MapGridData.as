package com.arm.herolot.modules.battle.map
{
	

	/**
	 *地图的一个格子的数据 
	 * @author hufan
	 * 
	 */	
	public class MapGridData
	{
		/**
		 *地表类型 
		 */		
		public var groundType:int;
		/**
		 *石头类型
		 * */
		public var blockType:int;
		
		/**
		 *格子上的地图元素，可以为空。
		 */		
		public var entity:MapEntityData;
		
		
		/**
		 *状态 
		 */		
		public var state:int;
		
		public function MapGridData()
		{
			entity = new MapEntityData();
		}
	}
}