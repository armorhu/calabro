package com.arm.herolot.modules.battle.map
{
	import com.arm.herolot.Consts;
	import com.arm.herolot.model.config.AppConfig;
	import com.arm.herolot.model.config.mapEntities.MapEntitiesConfig;
	import com.arm.herolot.model.consts.MapEntityClassDef;
	import com.arm.herolot.model.consts.MapEntityTypeDef;
	
	import flash.display3D.IndexBuffer3D;

	public class MapBuilder
	{
		public static const GRID_STATUS_IS_OPENED:uint = 1 << 0;
		public static const GRID_STATUS_CAN_BE_OPENED:uint = 1 << 1;
		public static const GRID_STATUS_MONSTER:uint = 1 << 2;
		public static const GRID_STATUS_ITEM:uint = 1 << 3;
		public static const GRID_STATUS_TRAP:uint = 1 << 4;

		private static const DEFAULT_MIN_MONSTER_DESITY:Number = 15 / 100;
		private static const DEFAULT_MAX_MONSTER_DENSITY:Number = 35 / 100;
		private static const DEFAULT_GAUSSIAN_LEFT_SHIFT:Number = 50 / 100;
		private static const DEFAULT_GAUSSIAN_RIGHT_SHIFT:Number = 10 / 100;

		private static const DEFAULT_MAX_ITEM_DENSITY:Number = 20 / 100;
		private static const DEFAULT_MIN_ITEM_DENSITY:Number = 10 / 100;
		private static const DEFAULT_MAX_TRAP_DENSITY:Number = 10 / 100;
		private static const DEFAULT_MIN_TRAP_DENSITY:Number = 0;

		private var _rows:int;
		private var _cols:int;
		private var _totalFloors:int;
		private var _maxItemDensity:Number;
		private var _minItemDensity:Number;
		private var _maxMonsterDensity:Number;
		private var _minMonsterDensity:Number;
		private var _maxTrapDensity:Number;
		private var _minTrapDensity:Number;
		private var _ranGenerator:GaussianGenerator;

		public function MapBuilder(rows:int, cols:int, minMonsterDensity:Number = DEFAULT_MIN_MONSTER_DESITY, maxMonsterDensity:Number = DEFAULT_MAX_MONSTER_DENSITY, minItemDensity:Number = DEFAULT_MIN_ITEM_DENSITY, maxItemDensity:Number = DEFAULT_MAX_ITEM_DENSITY, maxTrapDensity:Number = DEFAULT_MAX_TRAP_DENSITY, minTrapDensity:Number = DEFAULT_MIN_TRAP_DENSITY, gaussianLeftShift:Number = DEFAULT_GAUSSIAN_LEFT_SHIFT, gaussianRightShift:Number = DEFAULT_GAUSSIAN_RIGHT_SHIFT)
		{
			_rows = rows;
			_cols = cols;
			_minMonsterDensity = minMonsterDensity;
			_maxMonsterDensity = maxMonsterDensity;
			_minItemDensity = minItemDensity;
			_maxItemDensity = maxItemDensity;
			_minTrapDensity = minTrapDensity;
			_maxTrapDensity = maxTrapDensity;

			prepareGenerator(minMonsterDensity, maxMonsterDensity, gaussianLeftShift, gaussianRightShift);
		}

		private function prepareGenerator(minDens:Number, maxDens:Number, gls:Number, grs:Number):void
		{
			var total:int = _rows * _cols;
			var minCount:int = Math.ceil(minDens * total);
			var maxCount:int = Math.ceil(maxDens * total);
			_ranGenerator = new GaussianGenerator(minCount, maxCount, minCount * (1 + gls), maxCount * (1 - grs), _totalFloors);
		}


		private static const key:int =1;
		private static const door:int = 2;

		public function getMapData(floor:int):MapData
		{
			var map:MapData = new MapData();
			map.grids = new Vector.<MapGridData>();
			map.grids.length = _cols * _rows;
			map.grids.fixed = true;
			
			//随即生成底板和砖头的材质。
			for(i = 0; i<map.grids.length;i++)
			{
				map.grids[i] = new MapGridData();
				map.grids[i].blockType = random()*Consts.BLOCK_COUNT;
				map.grids[i].groundType = random()*Consts.GROUND_COUNT;
			}

			//生成格子的index池子
			var posPool:Vector.<int> = new Vector.<int>();
			posPool.length = map.grids.length;
			for (var i:int = 0; i < posPool.length; i++)
				posPool[i] = i;

			map.door = randomIndex();
			map.grids[map.door].entity.id = door;

			//获取当前楼层能够用的元素池子
			var availableEntitityDict:Object = getFloorAvailableEntities(floor);
			//特殊事件生成。。。todo

			//元素的覆盖率
			var entityCoverProbality:Number = getFloorCoverProbality(floor);
			var entitySum:int = Math.round(restMapSize() * entityCoverProbality);
			var badCoverProbality:Number = 0.5 + random();
			var badSum:int = Math.round(entitySum * badCoverProbality);
			var goodSum:int = entitySum - badSum;
			
			var badList:Vector.<MapEntityData> = generateBadList(badSum);
			var monsterList:Vector.<MapEntityData> = getMonsterList();
			var goodList:Vector.<MapEntityData> = generateGoodList(goodSum);
			var dropList:Vector.<MapEntityData> = getDropList();
			
			//给钥匙找一个怪物。
			//随机摆放怪物
			var len:int = monsterList.length;
			if(len == 0)
				throw new Error('怪物数量为0');
			var keyIndex:int = random()*len;
			for (i = 0; i < len; i++) {
				map.grids[randomIndex()].entity = monsterList[i];
				if(keyIndex == i)
					monsterList[i].dropID = key;
			}
			
			
			
			
			return map;

			function getMonsterList():Vector.<MapEntityData>
			{
				var result:Vector.<MapEntityData> = new Vector.<MapEntityData>();
				const len:int = badList.length;
				for (var j:int = len-1; j >=0; j--)
				{
					if (isMonster(badList[j].id)){
						result.push(badList[j]);
						badList.splice(j,1);
					}
				}
				return result;
			}

			function getDropList():Vector.<MapEntityData>
			{
				var result:Vector.<MapEntityData> = new Vector.<MapEntityData>();
				const len:int = goodList.length;
				for (var j:int = len-1; j >=0; j--)
				{
					if (isDrop(goodList[j].id)){
						result.push(goodList[j]);
						goodList.splice(j,1);
					}
				}
				return result;
			}


			function isDrop(id:int):Boolean
			{
				var config:MapEntitiesConfig = AppConfig.mapEntitiesConfigModel.getMapEntitiesConfigByID(id);
				return config.EntityType == MapEntityTypeDef.EQUIP || config.EntityType == MapEntityTypeDef.MAGIC || config.EntityType == MapEntityTypeDef.MEDICINE
			}
			
			function isMonster(id:int):Boolean
			{
				var config:MapEntitiesConfig = AppConfig.mapEntitiesConfigModel.getMapEntitiesConfigByID(id);
				return config.EntityType == MapEntityTypeDef.MONSTER;
			}

			function dropable(id:int):Boolean
			{
				var config:MapEntitiesConfig = AppConfig.mapEntitiesConfigModel.getMapEntitiesConfigByID(id);
				return config.Dropable;
			}

			function generateBadList(badSum:int):Vector.<MapEntityData>
			{
				var entityData:MapEntityData;
				var monsterPool:Vector.<int> = getRandomPool(availableEntitityDict[MapEntityTypeDef.MONSTER]);
				var result:Vector.<MapEntityData> = new Vector.<MapEntityData>();
				var basicMonsterCount:int = badSum > 3 ? 3 : badSum;
				badSum -= basicMonsterCount;

				if (monsterPool.length > 0)
					for (j = 0; j < basicMonsterCount; j++)
					{
						entityData = new MapEntityData();
						entityData.id = monsterPool[int(monsterPool.length*random())];
						result.push(entityData);
					}

				var badRandomPool:Vector.<int> = getRandomPool(availableEntitityDict[MapEntityClassDef.BAD]);
				var len:int = badRandomPool.length;
				if (len > 0)
					for (var j:int = 0; j < badSum; j++)
					{
						entityData = new MapEntityData();
						entityData.id = badRandomPool[int(len*random())];
						result.push(entityData);
					}
				return result;
			}

			function generateGoodList(goodSum:int):Vector.<MapEntityData>
			{
				var goodRandomPool:Vector.<int> = getRandomPool(availableEntitityDict[MapEntityClassDef.GOOD]);
				var len:int = goodRandomPool.length;
				var result:Vector.<MapEntityData> = new Vector.<MapEntityData>();
				var entityData:MapEntityData;
				if (len > 0)
					for (var j:int = 0; j < goodSum; j++)
					{
						entityData = new MapEntityData();
						entityData.id = goodRandomPool[int(len*random())];
						result.push(entityData);
					}
				return result;
			}


			function randomIndex():int
			{
				var randomId:int = int(posPool.length * random());
				return posPool.splice(randomId, 1)[0]
			}

			function restMapSize():int
			{
				return posPool.length;
			}

			/**
			 * 获取当前楼层的可获得的实体
			 * @return
			 */
			function getFloorAvailableEntities(floor:int):Object
			{
				var result:Object = {};
				const len:int = AppConfig.mapEntitiesConfigModel.mapEntities.length;
				for (var j:int = 0; j < len; j++)
				{
					if (AppConfig.mapEntitiesConfigModel.mapEntities[j].MaxAppearFloor >= floor && AppConfig.mapEntitiesConfigModel.mapEntities[j].MinAppearFloor <= floor)
						push(result, AppConfig.mapEntitiesConfigModel.mapEntities[j]);
				}
				return result;
			}

			function push(obj:Object, entity:MapEntitiesConfig):void
			{
				if (obj[entity.EntityClass] == undefined)
					obj[entity.EntityClass] = new Vector.<MapEntitiesConfig>;
				if (obj[entity.EntityType] == undefined)
					obj[entity.EntityType] = new Vector.<MapEntitiesConfig>;
				(obj[entity.EntityType] as Vector.<MapEntitiesConfig>).push(entity);
				(obj[entity.EntityClass] as Vector.<MapEntitiesConfig>).push(entity);
			}

			function getRandomPool(source:Vector.<MapEntitiesConfig>):Vector.<int>
			{
				var pool:Vector.<int> = new Vector.<int>();
				if(source)
				{
					const len:int = source.length;
					for (var j:int = 0; j < len; j++)
					{
						for (var k:int = 0; k < source[j].RandomWeight; k++)
							pool.push(source[j].ID);
					}
				}
		
				return pool;
			}
		}



		private function random():Number
		{
			return Math.random();
		}

		/**
		 * 返回楼层的覆盖率
		 * @param floor
		 */
		private function getFloorCoverProbality(floor:int):Number
		{
			var result:Number = 0.3 + int(floor / 10) / 10;
			if (result >= 0.7)
				return 0.7;
			else
				return result
		}


//		public function getMapData(floor:int):MapData
//		{
//		}


//		public function getMapData(floor:int):MapData
//		{
//			if (floor > _totalFloors)
//				return null;
//
//			const totalGrids:int = _rows * _cols;
//
//			/*for random position that not duplicate*/
//			var positions:Vector.<Point> = new Vector.<Point>(totalGrids);
//			for (var i:int = 0; i < _rows; i++)
//				for (var j:int = 0; j < _cols; j++)
//					positions[i * _cols + j] = new Point(i, j);
//
//			positions.sort(function compare(elementA:Object, elementB:Object):Number
//			{
//				return (Math.random() - 0.5);
//			});
//
//			var matrix:Vector.<Vector.<int>> = new Vector.<Vector.<int>>(_rows);
//			for (i = 0; i < _rows; i++)
//				matrix[i] = new Vector.<int>(_cols);
//
//			/*ret map data*/
//			var mapData:MapData = new MapData();
//
//			/*random background data & grid data begin*/
//			var retGroundData:Vector.<int> = new Vector.<int>(totalGrids);
//			var retBlockData:Vector.<int> = new Vector.<int>(totalGrids);
//			for (i = 0; i < totalGrids; i++)
//			{
//				retGroundData[i] = Math.random() * 5 + 1;
//				retBlockData[i] = Math.random() * 5 + 1;
//			}
//			mapData.groundData = retGroundData;
//			mapData.blockData = retBlockData;
//			/*random background data & grid data end*/
//
//			var retMonsterData:Vector.<Monster> = new Vector.<Monster>(totalGrids);
//			var retItemData:Vector.<Item> = new Vector.<Item>(totalGrids);
//			var monsterCount:int = _ranGenerator.getRandom(floor);
//			var itemCount:int = Math.ceil(_minItemDensity * totalGrids) + Math.random() * (Math.ceil((_maxItemDensity - _minItemDensity) * totalGrids) + 1);
////			var trapCount:int = Math.ceil(_minTrapDensity * totoalGrids) + Math.random() * (Math.ceil((_maxTrapDensity - _minTrapDensity) * totoalGrids) + 1);
//
//			trace("m:" + monsterCount + " i:" + itemCount /*+ " t:" + trapCount*/);
//
//			var monsterSrc:Vector.<MapEntitiesConfig> = getAvailableSource(MapEntityTypeDef.MONSTER);
//			var itemSrc:Vector.<MapEntitiesConfig> = getAvailableSource(MapEntityTypeDef.ITEM);
//
//			var temp:Object = {};
//
//			var retMonsters:Vector.<Monster> = new Vector.<Monster>();
//			var minLife:int = Math.ceil(0.67 * floor);
//			var maxLife:int = Math.ceil(1.5 * floor);
//			var minAtt:int = Math.ceil(Number(floor) / 3) - 1;
//			var maxAtt:int = minAtt + 2;
//
//			var keyIndex:int = Math.random() * monsterCount;
//
//			while (monsterCount--)
//			{
//				if (monsterSrc.length > 0)
//				{
//					var index:int = int(monsterSrc.length * Math.random());
//					var pos:Point = positions.pop() as Point;
//
//					matrix[pos.x][pos.y] |= GRID_STATUS_MONSTER;
//					var monster:Monster = new Monster(monsterSrc[index].ID);
//					monster.crit_proxy.orignal = monsterSrc[index].Crit / 100; //暴击
//					monster.speed_proxy.orignal = monsterSrc[index].Speed; //速度
//					monster.dodge_proxy.orignal = monsterSrc[index].Dudoge / 100; //闪避
//
//					monster.hp_proxy.orignal = minLife + Math.ceil(Math.random() * (maxLife - minLife)); //生命
//					monster.ack_proxy.orignal = minAtt + Math.ceil(Math.random() * (maxAtt - minAtt)); //攻击
//
//					retMonsterData[pos.x * _cols + pos.y] = monster;
//
//					if (monsterCount == keyIndex)
//						keyIndex = pos.x * _cols + pos.y;
//					temp[monsterSrc[index].ID] = int(temp[monsterSrc[index].ID]) + 1;
//					if (monsterSrc[index].MaxAppearFloor == temp[monsterSrc[index].ID])
//						monsterSrc.splice(index, 1);
//				}
//			}
//			mapData.monsterData = retMonsterData;
//
//			while (itemCount--)
//			{
//				if (itemSrc.length > 0)
//				{
//					//plus '2' in order to exclude the door and key
//					index = int(2 + (itemSrc.length - 2) * Math.random());
//					pos = positions.pop() as Point;
//
//					matrix[pos.x][pos.y] |= GRID_STATUS_ITEM;
//					var item:Item = new Item(itemSrc[index].ID);
//					retItemData[pos.x * _cols + pos.y] = item;
//
//
//					temp[itemSrc[index].ID] = int(temp[itemSrc[index].ID]) + 1;
//					if (itemSrc[index].MaxPerFloor == temp[itemSrc[index].ID])
//						itemSrc.splice(index, 1);
//				}
//			}
//
//			/*door*/
//			var doorPos:Point = positions.pop();
//			matrix[doorPos.x][doorPos.y] |= GRID_STATUS_CAN_BE_OPENED | GRID_STATUS_ITEM;
//			var door:Item = new Item(2);
//			retItemData[doorPos.x * _cols + doorPos.y] = door;
//
//			/*key hide under monster*/
//			var key:Item = new Item(1);
//			retItemData[keyIndex] = key;
//			matrix[int(keyIndex / _cols)][keyIndex % _cols] |= GRID_STATUS_ITEM;
////			trace("key pos:", int(keyIndex / _cols), keyIndex % _cols);
//
//			mapData.itemData = retItemData;
//
//			mapData.matrixData = matrix;
//			mapData.doorPosition = doorPos;
//			mapData.hasKey = false;
//			return mapData;
//
//			/*this method select the available src according to the given floor*/
//			function getAvailableSource(type:String):Vector.<MapEntitiesConfig>
//			{
//				var ret:Vector.<MapEntitiesConfig> = new Vector.<MapEntitiesConfig>();
//				const len:int = AppConfig.mapEntitiesConfigModel.mapEntities.length;
//
//				for (var k:int = 0; k < len; k++)
//				{
//					if (AppConfig.mapEntitiesConfigModel.mapEntities[k].Name == 'door' || AppConfig.mapEntitiesConfigModel.mapEntities[k].Name == 'key')
//					{
//						continue;
//					}
//
//					if (AppConfig.mapEntitiesConfigModel.mapEntities[k].Type == type)
//					{
//						if (floor >= AppConfig.mapEntitiesConfigModel.mapEntities[k].MinAppearFloor //
//							&& floor <= AppConfig.mapEntitiesConfigModel.mapEntities[k].MaxAppearFloor)
//							ret.push(AppConfig.mapEntitiesConfigModel.mapEntities[k]);
//					}
//				}
//				return ret;
//			}
//		}
	}
}
