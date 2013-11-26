package com.arm.herolot.modules.battle.model.map
{
	import com.arm.herolot.Consts;
	import com.arm.herolot.model.consts.MapEntityTypeDef;
	import com.arm.herolot.modules.battle.BattleModel;
	import com.arm.herolot.modules.battle.map.MapBuilder;
	import com.arm.herolot.modules.battle.map.MapData;
	import com.arm.herolot.modules.battle.map.MapMath;

	import starling.animation.IAnimatable;
	import starling.events.Event;
	import starling.events.EventDispatcher;

	public class MapDataModel extends EventDispatcher implements IAnimatable
	{
		private var _mapBuilder:MapBuilder;
		/**
		 *地图的格子数据模型
		 */
		public var mapGrids:Vector.<MapGridModel>;
		public var mapData:MapData;

		private var _msgCenter:EventDispatcher;

		public function MapDataModel(msgCenter:EventDispatcher)
		{
			super();
			_msgCenter = msgCenter;
			initliaze();
		}

		private function initliaze():void
		{
			_mapBuilder = new MapBuilder( //
				Consts.MAP_ROWS, //
				Consts.MAP_COLS, //
				Consts.TOTAL_FLOORS_COUNT);
			mapGrids = new Vector.<MapGridModel>();
			mapGrids.length = Consts.MAP_COLS * Consts.MAP_ROWS;
			mapGrids.fixed = true;
		}

		public function createFloor(floor:int):void
		{
			mapData = _mapBuilder.getMapData(floor);
			var len:int = mapGrids.length;
			for (var i:int = 0; i < len; i++)
			{
				if (mapGrids[i])
				{
					mapGrids[i].removeEventListener(MapGridModel.OPEN, gridModelEventHandler);
					mapGrids[i].removeEventListener(MapGridModel.TOUCH_ENTITY, gridModelEventHandler);

					mapGrids[i].dispose();
					mapGrids[i] = null;
				}

				mapGrids[i] = MapGridModel.createMapEntityModel(mapData.grids[i], i, floor);
				mapGrids[i].addEventListener(MapGridModel.OPEN, gridModelEventHandler);
				mapGrids[i].addEventListener(MapGridModel.TOUCH_ENTITY, gridModelEventHandler);


			}
			//把门所在的那个格子打开
			mapGrids[mapData.door].lock = false;
			mapGrids[mapData.door].reachable = true;
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
			else if (evt.type == MapGridModel.TOUCH_ENTITY)
			{
				switch (gridModel.entityConfig.EntityType)
				{
					case MapEntityTypeDef.MONSTER:
					{
						_msgCenter.dispatchEventWith(BattleModel.HERO_ATTACK, false, gridModel);
						break;
					}

					default:
					{
						break;
					}
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
