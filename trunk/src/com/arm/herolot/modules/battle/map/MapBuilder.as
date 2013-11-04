package com.arm.herolot.modules.battle.map
{
	import com.arm.herolot.modules.battle.battle.item.Item;
	import com.arm.herolot.modules.battle.battle.monster.Monster;
	
	import flash.geom.Point;

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

		public function MapBuilder(rows:int, cols:int, totalFloors:int, minMonsterDensity:Number = DEFAULT_MIN_MONSTER_DESITY, maxMonsterDensity:Number = DEFAULT_MAX_MONSTER_DENSITY, minItemDensity:Number = DEFAULT_MIN_ITEM_DENSITY, maxItemDensity:Number = DEFAULT_MAX_ITEM_DENSITY, maxTrapDensity:Number = DEFAULT_MAX_TRAP_DENSITY, minTrapDensity:Number = DEFAULT_MIN_TRAP_DENSITY, gaussianLeftShift:Number = DEFAULT_GAUSSIAN_LEFT_SHIFT, gaussianRightShift:Number = DEFAULT_GAUSSIAN_RIGHT_SHIFT)
		{
			_rows = rows;
			_cols = cols;
			_totalFloors = totalFloors;
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
//			if(_debug)trace("min monster count:" + minCount + "   max monster count:" + maxCount);

			_ranGenerator = new GaussianGenerator(minCount, maxCount, minCount * (1 + gls), maxCount * (1 - grs), _totalFloors);
		}

//		public function getMatrix(floor:int):Vector.<Vector.<Object> >
//		{
//			if(floor > _totalFloors)
//				return null;
//			
//			var retGrid:Vector.<Vector.<Object> > = new Vector.<Vector.<Object>>();
//			retGrid.length = _rows;
//			
//			var grid:Vector.<Vector.<int> > = new Vector.<Vector.<int> >();
//			grid.length = _rows;
//			for(var i:int = 0; i < _rows; i ++)
//			{
//				grid[i] = _gridForRandom[i].concat();
//				retGrid[i] = new Vector.<Object>();
//				retGrid[i].length = _cols;
//				for(var j:int = 0; j < _cols; j++)
//				{
//					retGrid[i][j] = new Object();
//					retGrid[i][j].type = GRID_TYPE_NONE;
////					retGrid[i][j].tileId = _tileIds[int(Math.random() * _tileIds.length)];
////					retGrid[i][j].blockId = _blockIds[int(Math.random() * _blockIds.length)];
//				}
//			}
//			
//			var monsterCount:int = _ranGenerator.getRandom(floor);
//			if(_debug)trace("generate monster count:" + monsterCount);
//			
//			/*look for max available index of monster ID according to _monsterLimits*/
//			var maxMonsterIndex:int = _monsterLimits.length;
//			for(var jj:int = 0; jj < _monsterLimits.length; jj++)
//			{				
//				if(_monsterLimits[jj] > floor)
//				{
//					maxMonsterIndex = jj - 1;
//					if(_debug)trace("max avaiable monster index:" + maxMonsterIndex);
//					break;
//				}
//			}
//			
//			
//			/*generate random monsters*/
//			var minLife:int = Math.ceil(0.67 * floor);
//			var maxLife:int = Math.ceil(1.5 * floor);
//			var minAtt:int = Math.ceil(Number(floor)/3) - 1;
//			var maxAtt:int = minAtt + 2;
//			while(monsterCount-- > 0)
//			{
//				var r:int = int(Math.random() * _rows);
//				while(grid[r].length == 0)
//					r++;
//				var c:int = int(Math.random() * grid[r].length);
//				retGrid[r][grid[r][c]].type = GRID_TYPE_MONSTER;
//				retGrid[r][grid[r][c]].id = _monsterIds[int(Math.random() * maxMonsterIndex)];
//				retGrid[r][grid[r][c]].hp = minLife + Math.ceil(Math.random() * (maxLife - minLife));
//				retGrid[r][grid[r][c]].att = minAtt + Math.ceil(Math.random() * (maxAtt - minAtt));
//				
//				grid[r].splice(c, 1);
//			}
//			
//			/*generate random items*/
//			var itemsCount:int = _itemsPerFloor;
//			while(itemsCount-- > 0)
//			{
//				var rr:int = int(Math.random() * _rows);
//				while(grid[rr].length == 0)
//					rr++;
//				var cc:int = int(Math.random() * grid[rr].length);
//				retGrid[rr][grid[rr][cc]].type = GRID_TYPE_ITEM;
//				retGrid[rr][grid[rr][cc]].id = _itemIds[int(Math.random() * _itemIds.length)];
//				grid[rr].splice(cc, 1);
//			}
//			
//			return retGrid;
//		}

		public function getMapData(floor:int):MapData
		{
			if (floor > _totalFloors)
				return null;

			const totalGrids:int = _rows * _cols;

			/*for random position that not duplicate*/
			var positions:Vector.<Point> = new Vector.<Point>(totalGrids);
			for (var i:int = 0; i < _rows; i++)
				for (var j:int = 0; j < _cols; j++)
					positions[i * _cols + j] = new Point(i, j);

			positions.sort(function compare(elementA:Object, elementB:Object):Number
			{
				return (Math.random() - 0.5);
			});

			var matrix:Vector.<Vector.<int>> = new Vector.<Vector.<int>>(_rows);
			for (i = 0; i < _rows; i++)
				matrix[i] = new Vector.<int>(_cols);

			/*ret map data*/
			var mapData:MapData = new MapData();

			/*random background data & grid data begin*/
			var retGroundData:Vector.<int> = new Vector.<int>(totalGrids);
			var retBlockData:Vector.<int> = new Vector.<int>(totalGrids);
			for (i = 0; i < totalGrids; i++)
			{
				retGroundData[i] = Math.random() * 5 + 1;
				retBlockData[i] = Math.random() * 5 + 1;
			}
			mapData.groundData = retGroundData;
			mapData.blockData = retBlockData;
			/*random background data & grid data end*/

			var retMonsterData:Vector.<Monster> = new Vector.<Monster>(totalGrids);
			var retItemData:Vector.<Item> = new Vector.<Item>(totalGrids);
			var monsterCount:int = _ranGenerator.getRandom(floor);
			var itemCount:int = Math.ceil(_minItemDensity * totalGrids) + Math.random() * (Math.ceil((_maxItemDensity - _minItemDensity) * totalGrids) + 1);
//			var trapCount:int = Math.ceil(_minTrapDensity * totoalGrids) + Math.random() * (Math.ceil((_maxTrapDensity - _minTrapDensity) * totoalGrids) + 1);

			trace("m:" + monsterCount + " i:" + itemCount /*+ " t:" + trapCount*/);

			var monsterSrc:Vector.<Object> = getAvailableSource(Monster.CONFIG);
//			var trapSrc:Vector.<Object> = getAvailableSource(Trap.CONFIG);
			var itemSrc:Vector.<Object> = getAvailableSource(Item.CONFIG);

//			while(trapCount--)
//			{
//				if(trapSrc.length > 0)
//				{
//					var index:int = int(trapSrc.length * Math.random());
//					var pos:Point = positions.pop() as Point;
//					
//					matrix[pos.x][pos.y] |= GRID_STATUS_TRAP;
//					
//					if(--trapSrc[index].tmp == 0)
//						trapSrc.splice(index, 1);
//				}
//			}

			var retMonsters:Vector.<Monster> = new Vector.<Monster>();
			var minLife:int = Math.ceil(0.67 * floor);
			var maxLife:int = Math.ceil(1.5 * floor);
			var minAtt:int = Math.ceil(Number(floor) / 3) - 1;
			var maxAtt:int = minAtt + 2;

			var keyIndex:int = Math.random() * monsterCount;

			while (monsterCount--)
			{
				if (monsterSrc.length > 0)
				{
					var index:int = int(monsterSrc.length * Math.random());
					var pos:Point = positions.pop() as Point;

					matrix[pos.x][pos.y] |= GRID_STATUS_MONSTER;
					var monster:Monster = new Monster();
					//属性copy。
					for (var property:String in monsterSrc[index])
						if (monster.hasOwnProperty(property))
							monster[property] = monsterSrc[index][property];
					monster.id = monsterSrc[index].id;
					monster.name = monsterSrc[index].name;
					monster.ethnicity = monsterSrc[index].ethnicity;
					monster.pcrit.orignal = monsterSrc[index].crit; //暴击
					monster.pspeed.orignal = monsterSrc[index].speed; //速度
					monster.php.orignal = minLife + Math.ceil(Math.random() * (maxLife - minLife)); //生命
					monster.pack.orignal = minAtt + Math.ceil(Math.random() * (maxAtt - minAtt)); //攻击
					monster.pdodge.orignal = monsterSrc[index].dodge; //闪避

					retMonsterData[pos.x * _cols + pos.y] = monster;

					if (monsterCount == keyIndex)
						keyIndex = pos.x * _cols + pos.y;

					if (--monsterSrc[index].tmp == 0)
						monsterSrc.splice(index, 1);
				}
			}
			mapData.monsterData = retMonsterData;

			while (itemCount--)
			{
				if (itemSrc.length > 0)
				{
					//plus '2' in order to exclude the door and key
					index = int(2 + (itemSrc.length - 2) * Math.random());
					pos = positions.pop() as Point;

					matrix[pos.x][pos.y] |= GRID_STATUS_ITEM;
					var item:Item = new Item();
					item.id = itemSrc[index].id;
					item.name = itemSrc[index].name;
					retItemData[pos.x * _cols + pos.y] = item;
					if (--itemSrc[index].tmp == 0)
						itemSrc.splice(index, 1);
				}
			}

			/*door*/
			var doorPos:Point = positions.pop();
			matrix[doorPos.x][doorPos.y] |= GRID_STATUS_CAN_BE_OPENED | GRID_STATUS_ITEM;
			var door:Item = new Item();
			door.id = itemSrc[1].id;
			door.name = itemSrc[1].name;
			retItemData[doorPos.x * _cols + doorPos.y] = door;

			/*key hide under monster*/
			var key:Item = new Item();
			key.id = itemSrc[0].id;
			key.name = itemSrc[0].name;
			retItemData[keyIndex] = key;
			matrix[int(keyIndex / _cols)][keyIndex % _cols] |= GRID_STATUS_ITEM;
//			trace("key pos:", int(keyIndex / _cols), keyIndex % _cols);

			mapData.itemData = retItemData;

			mapData.matrixData = matrix;
			mapData.doorPosition = doorPos;
			mapData.hasKey = false;
			mapData.level = floor;
			return mapData;

			/*this method select the available src according to the given floor*/
			function getAvailableSource(config:Object):Vector.<Object>
			{
				var ret:Vector.<Object> = new Vector.<Object>();
				var limit:String;
				var reg:RegExp = new RegExp("\\s*\\[\\s*\\d+\\s*,\\s*\\d+\\s*\\]\\s*"); /*match format like [4,6]*/
				var segs:Array;
				for (var id:String in config)
				{
					limit = config[id].appearAt as String;
					if (limit == "-1")
						continue;

					segs = limit.split("/");
					const segCount:uint = segs.length;
					for (var l:uint = 0; l < segCount; l++)
					{
						if (String(segs[l]).match(reg) != null)
						{
							var index:int = String(segs[l]).search(",");
							var min:int = int(String(segs[l]).substr(1, index - 1));
							var max:int = int(String(segs[l]).substr(index + 1, String(segs[l]).length - 1 - index - 1));

							if (floor >= min && floor <= max)
							{
								/*tmp may be used later*/
								config[id].tmp = config[id].maxPerFloor;
								config[id].id = id;
								ret.push(config[id]);
								break;
							}

						}
						else if (int(segs[l]) == floor)
						{
							/*tmp may be used later*/
							config[id].tmp = config[id].maxPerFloor;
							config[id].id = id;
							ret.push(config[id]);
							break;
						}
					}
				}
				return ret;
			}

		}
	}
}
