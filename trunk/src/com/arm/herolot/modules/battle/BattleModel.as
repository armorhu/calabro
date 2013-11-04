package com.arm.herolot.modules.battle
{
	import com.arm.herolot.Consts;
	import com.arm.herolot.modules.battle.battle.hero.HeroModel;
	import com.arm.herolot.modules.battle.battle.item.Item;
	import com.arm.herolot.modules.battle.battle.monster.Monster;
	import com.arm.herolot.modules.battle.map.BattleBot;
	import com.arm.herolot.modules.battle.map.MapBuilder;
	import com.arm.herolot.modules.battle.map.MapData;
	import com.arm.herolot.modules.battle.map.MapHandler;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import starling.events.EventDispatcher;

	public class BattleModel extends EventDispatcher
	{
		private var _controller:BattleController;

		public static const COMLETE_LOAD_DATA:String = 'complete_load_data';
		public static const REQUEST_DISPLAY_INTERACTION:String = 'request_display_interaction';
		public static const BOT_OPERATION:String = 'bot_operation';
		public static const GAME_OVER:String = 'game_over';
		
		public static const DATA_MAP:String = 'data_map';
		public static const DATA_HERO:String = 'data_hero';
		public static const DATA_ITEMS:String = 'data_items';
		
		public static const INTERACTION_BLOCK:String = 'interaction_block';
		public static const INTERACTION_MONSTER:String = 'interaction_monster';
		public static const INTERACTION_ITEM_PICK:String = 'interaction_item_pick';
		public static const INTERACTION_ITEM_USE:String = 'interaction_item_use';

		private var _mapBuilder:MapBuilder;//地图构造器
		private var _mapHandler:MapHandler;
		private var _mapData:MapData; //地图数据
		private var _items:Vector.<Item>; //背包物品数据
		private var _hero:HeroModel; //英雄数据
		
		private var _bot:BattleBot;
		private var _botInvoke:int = 1;

		public function BattleModel(controller:BattleController)
		{
			super();
			_controller = controller;
			_mapBuilder = new MapBuilder(Consts.MAP_ROWS, Consts.MAP_COLS, Consts.TOTAL_FLOORS_COUNT);
			_mapHandler = new MapHandler();
		}
		
		private function transmitEvent(type:String, data:Object = null):void
		{
			dispatchEventWith(type, false, data);
		}
		
		private function openBlock(row:int, col:int):void
		{
			if(_botInvoke == 0)
			{
				_botInvoke = -1;
				_bot = new BattleBot(this, processTileTouch, transmitEvent);
				_bot.mapData = _mapData;
				_bot.beginAuto(BattleBot.INFINITE);
			}
			else if(_botInvoke != -1)_botInvoke--;
			
			_mapHandler.setStatus(row, col, MapBuilder.GRID_STATUS_IS_OPENED);
			if (_mapHandler.checkStatus(row, col, MapBuilder.GRID_STATUS_MONSTER))
			{
				var disableList:Vector.<Point> = _mapHandler.setAroundDisOpenable(row, col);
				transmitEvent(REQUEST_DISPLAY_INTERACTION, {type:INTERACTION_BLOCK, result:{openBlock: new Point(row, col), disableList: disableList}});
			}
			else
			{
				var availableList:Vector.<Point> = _mapHandler.setAroundOpenable(row, col);
				transmitEvent(REQUEST_DISPLAY_INTERACTION, {type:INTERACTION_BLOCK, result:{openBlock: new Point(row, col), availableList: availableList}});
			}
		}
		
		private function processMonsterDie(row:int, col:int):void
		{
			var result:Object = _mapHandler.setAroundOnMonsterDie(row, col);
			transmitEvent(REQUEST_DISPLAY_INTERACTION, {type:INTERACTION_BLOCK, result:result});
		}
		
		private function fightMonster(row:int, col:int):void
		{
			var m:Monster = _mapData.monsterData[row * Consts.MAP_COLS + col];
			var result:Object = _hero.attack(m);
			result.position = new Point(row, col);
			
			/*monster die*/
			if((result.firstHandResult.target is Monster && result.firstHandResult.die)
				||(result.secondHandResult && result.secondHandResult.target is Monster && result.secondHandResult.die))
			{
				_mapData.monsterData[row * Consts.MAP_COLS + col] = null;
				_mapHandler.unsetStatus(row, col, MapBuilder.GRID_STATUS_MONSTER);
				processMonsterDie(row, col);
			}
			
			transmitEvent(REQUEST_DISPLAY_INTERACTION, {type:INTERACTION_MONSTER, result:result});
			
			/*hero die*/
			if((result.firstHandResult.target is HeroModel && result.firstHandResult.die)
				||(result.secondHandResult && result.secondHandResult.target is HeroModel && result.secondHandResult.die))
			{
				if(_bot && _bot.isRunning())_bot.stopAuto();
				transmitEvent(GAME_OVER);
			}
		}
		
		private function interactWithItem(row:int, col:int):void
		{
			var item:Item = _mapData.itemData[row * Consts.MAP_COLS + col];
			
			if(item == null)
				return;
			
			if(item.name == 'door')
			{
				if(_mapData.hasKey)createMapDataAt(_mapData.level + 1);
			}
			else
			{
				_mapHandler.unsetStatus(row, col, MapBuilder.GRID_STATUS_ITEM);
				_mapData.itemData[row * Consts.MAP_COLS + col] = null;
				
				if(item.name == 'key')
					_mapData.hasKey = true;
				transmitEvent(REQUEST_DISPLAY_INTERACTION, {type:INTERACTION_ITEM_PICK, result:{itemPos:new Point(row, col)}});
			}
		}

		///======================================================================
		///======================================================================
		///============        PUBLICK  FUNCTION				=================
		///======================================================================
		///======================================================================

		public function processTileTouch(row:int, col:int):void
		{
			trace('tileTouch', row, col);
			if (!(_mapHandler.checkStatus(row, col, MapBuilder.GRID_STATUS_IS_OPENED))
				&& _mapHandler.checkStatus(row, col, MapBuilder.GRID_STATUS_CAN_BE_OPENED))
			{
				openBlock(row, col);
			}
			else if(_mapHandler.checkStatus(row, col, MapBuilder.GRID_STATUS_IS_OPENED)
					&& _mapHandler.checkStatus(row, col, MapBuilder.GRID_STATUS_MONSTER))
			{
				fightMonster(row, col);
			}
			else if(_mapHandler.checkStatus(row, col, MapBuilder.GRID_STATUS_IS_OPENED)
					&& _mapHandler.checkStatus(row, col, MapBuilder.GRID_STATUS_ITEM))
			{
				interactWithItem(row, col);
			}
		}
		
		/**
		 * 创建某层的数据。
		 * @param floor
		 */
		public function createMapDataAt(floor:int):void
		{
			_mapData = _mapBuilder.getMapData(floor);
			_mapHandler.setMatrixData(_mapData.matrixData);

//			for(var i:int = 0; i < _mapData.matrixData.length; i++)
//				trace(_mapData.matrixData[i]);
			
			//生成了地图数据主动push给view。
			transmitEvent(COMLETE_LOAD_DATA, {type: DATA_MAP, data: _mapData});
			openBlock(_mapData.doorPosition.x, _mapData.doorPosition.y); //自动打开门。。。
		}

		public function setBattleHero(hero:HeroModel):void
		{
			_hero = hero;
			//拿到英雄数据。。。主动push消息给view.
			transmitEvent(COMLETE_LOAD_DATA, {type: DATA_HERO, data: _hero});
		}

		/**
		 * 请求数据。
		 * @param type
		 * 触发COMLETE_LOAD_DATA事件，event.data = {type: type, data: data};
		 */
		public function requestData(type:String):void
		{
			var data:Object;
			switch (type)
			{
				case DATA_MAP:
				{
					data = _mapData;
					break;
				}

				case DATA_HERO:
				{
					data = _hero;
					break;
				}

				case DATA_ITEMS:
				{
					data = _items;
					break;
				}

				default:
				{
					break;
				}
			}
			if (data)
				dispatchEventWith(COMLETE_LOAD_DATA, {type: type, data: data});
		}
	}
}
