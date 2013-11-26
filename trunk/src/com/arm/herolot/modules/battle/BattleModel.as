package com.arm.herolot.modules.battle
{
	import com.arm.herolot.Consts;
	import com.arm.herolot.modules.battle.battle.hero.HeroModel;
	import com.arm.herolot.modules.battle.map.MapBuilder;
	import com.arm.herolot.modules.battle.map.MapData;
	import com.arm.herolot.modules.battle.map.MapMath;
	import com.arm.herolot.modules.battle.model.MapGridModel;

	import starling.animation.IAnimatable;
	import starling.events.Event;
	import starling.events.EventDispatcher;

	public class BattleModel extends EventDispatcher implements IAnimatable
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
		public var mapGrids:Vector.<MapGridModel>;

		public var mapData:MapData;

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

			mapGrids = new Vector.<MapGridModel>();
			mapGrids.length = Consts.MAP_COLS * Consts.MAP_ROWS;
			mapGrids.fixed = true;
			_currentFloor = 0;
		}

		public function nextFloor():void
		{
			mapData = _mapBuilder.getMapData(++_currentFloor);
			var len:int = mapGrids.length;
			for (var i:int = 0; i < len; i++)
			{
				if (mapGrids[i])
				{
					mapGrids[i].removeEventListener(MapGridModel.OPEN, gridModelEventHandler);
					mapGrids[i].dispose();
					mapGrids[i] = null;
				}

				mapGrids[i] = MapGridModel.createMapEntityModel(mapData.grids[i]);
				mapGrids[i].gid = i;
				mapGrids[i].floor = _currentFloor;
				mapGrids[i].addEventListener(MapGridModel.OPEN, gridModelEventHandler);

			}

			//把门所在的那个格子打开
			mapGrids[mapData.door].lock = false;
			mapGrids[mapData.door].reachable = true;

			dispatchEventWith(CHANGE_FLOOR, false, mapGrids);
		}


		private function gridModelEventHandler(evt:Event):void
		{
			var gridModel:MapGridModel = evt.target as MapGridModel;
			if (evt.type == MapGridModel.OPEN)
			{
				var arounds:Vector.<int> = MapMath.getAroundGridIds(gridModel.gid);
				var len:int = arounds.length;
				for (var i:int = 0; i < len; i++)
				{
					//变的可以达到了
					if (!mapGrids[arounds[i]].reachable)
						mapGrids[arounds[i]].reachable = true;
					if (!mapGrids[arounds[i]].open)
						mapGrids[arounds[i]].lock = checkGridIsLock(arounds[i]);
				}

			}
		}

		public function advanceTime(time:Number):void
		{
			if (mapGrids)
			{
				var len:int = mapGrids.length;
				for (var i:int = 0; i < len; i++)
					mapGrids[i].advanceTime(time);
			}
		}

		/**
		 * 检查某个格子是否被锁
		 * @param gid
		 * @return 锁上返回true，否则返回false
		 */
		public function checkGridIsLock(gid:int):Boolean
		{
			var aroundGids:Vector.<int> = MapMath.getAroundGridIds(gid);
			var len:int = aroundGids.length;
			for (var i:int = 0; i < len; i++)
			{
				if (mapGrids[aroundGids[i]].hasMonster)
					return true;
			}
			return false;
		}
	}
}
