package com.arm.herolot.modules.battle
{
	import com.arm.herolot.Consts;
	import com.arm.herolot.modules.battle.battle.hero.HeroModel;
	import com.arm.herolot.modules.battle.map.MapBuilder;
	import com.arm.herolot.modules.battle.map.MapData;
	import com.arm.herolot.modules.battle.model.MapGridModel;
	
	import starling.events.EventDispatcher;

	public class BattleModel extends EventDispatcher
	{
		/**
		 *更改层级
		 */
		public static const CHANGE_FLOOR:String = 'change_floor'
			
		private var _hero:HeroModel;
		
		private var _mapBuilder:MapBuilder;
		/**
		 *地图的格子数据模型 
		 */		
		private var _currentMapGrids:Vector.<MapGridModel>;
		
		/**
		 *当前层数 
		 */		
		private var _currentFloor:int;
		

		public function BattleModel()
		{
		}


		public function start(hero:HeroModel):void
		{
			_hero = hero;
			_mapBuilder = new MapBuilder( //
				Consts.MAP_ROWS, //
				Consts.MAP_COLS, //
				Consts.TOTAL_FLOORS_COUNT);
			
			_currentMapGrids = new Vector.<MapGridModel>();
			_currentMapGrids.length = Consts.MAP_COLS*Consts.MAP_ROWS;
			_currentMapGrids.fixed = true;
			_currentFloor = 0;
		}

		public function nextFloor():void
		{
			var floorData:MapData = _mapBuilder.getMapData(++_currentFloor);
			var len:int = _currentMapGrids.length;
			for (var i:int = 0; i < len; i++) 
			{
				if(_currentMapGrids[i])
				{
					_currentMapGrids[i].dispose();
					_currentMapGrids[i] = null;
				}
				_currentMapGrids[i] = MapGridModel.createMapEntityModel(floorData.grids[i]);
			}
			
			dispatchEventWith(CHANGE_FLOOR,false,_currentMapGrids);
		}
		
		
		/**
		 * 开启某个格子
		 */		
		public function openGrid(gridIndex:int):void
		{
		}
	}
}
