package com.arm.herolot.modules.battle.map
{
	import com.arm.herolot.Consts;
	import com.arm.herolot.modules.battle.BattleModel;
	
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import starling.events.Event;
	import starling.events.EventDispatcher;

	public class BattleBot extends EventDispatcher
	{
		public static const INFINITE:int = -2;
		private static const AUTO_OPERATION_INTERVAL:Number = 100;
		
		private var invokeTouchOnTileAt:Function;
		private var transmitEvent:Function;
		
		private var _lastTile:Point;
		private var _timer:Timer;
		private var _mapData:MapData;
		private var _mapHandler:MapHandler;
		private var _owner:EventDispatcher;
		private var _autoFloorsCount:int;
		
		public function BattleBot(owner:EventDispatcher, invokeTouchFunc:Function, dispatchProxy:Function)
		{
			_owner = owner;
			invokeTouchOnTileAt = invokeTouchFunc;
			transmitEvent = dispatchProxy;
			_mapHandler = new MapHandler();
		}
		
		private function onMapChanged(event:Event):void
		{
			if(event.data['type'] == BattleModel.DATA_MAP)
			{
				mapData = event.data['data'] as MapData;
				if(_autoFloorsCount != INFINITE)
				{
					_autoFloorsCount--;
					if(_autoFloorsCount == 0)
						stopAuto();
				}
			}
		}
		
		protected function onTimer(event:TimerEvent):void
		{
			if(_mapData)
				singleSimulation();
			else
				stopAuto();
		}
		
		public function beginAuto(autoFloors:int = INFINITE, interval:Number = AUTO_OPERATION_INTERVAL):void
		{
			_autoFloorsCount = autoFloors;
			transmitEvent(BattleModel.BOT_OPERATION, {allowUserTouch:false});
			_owner.addEventListener(BattleModel.COMLETE_LOAD_DATA, onMapChanged);
			
			_timer = new Timer(interval, 0);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			_timer.start();
		}
		
		public function stopAuto():void
		{
			if(isRunning())
			{
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER, onTimer);
				_owner.removeEventListener(BattleModel.COMLETE_LOAD_DATA, onMapChanged);
				transmitEvent(BattleModel.BOT_OPERATION, {allowUserTouch:true});
			}
		}
		
		private function singleSimulation():void
		{
			_lastTile = findNextTile(_lastTile);
			invokeTouchOnTileAt(_lastTile.x, _lastTile.y);
		}
		
		/*simple algorithm of tile searching for bot*/
		private function findNextTile(lastPos:Point = null):Point
		{
			/*check last touched tile whether it can be touched again*/
			if(lastPos == null)
			{
				var i:int, j:int;
				for(i = 0; i < Consts.MAP_ROWS; i++)
				{
					for(j = 0; j < Consts.MAP_COLS; j++)
					{
						with(MapBuilder)
						if((!_mapHandler.checkStatus(i, j, GRID_STATUS_IS_OPENED)&&_mapHandler.checkStatus(i, j, GRID_STATUS_CAN_BE_OPENED))
							||_mapHandler.checkStatus(i, j, GRID_STATUS_IS_OPENED | GRID_STATUS_ITEM)
							||_mapHandler.checkStatus(i, j, GRID_STATUS_IS_OPENED | GRID_STATUS_MONSTER))
						{
							/*skip door if has no key*/
							if(!_mapData.hasKey 
								&& (_mapData.doorPosition.x == i && _mapData.doorPosition.y == j))
								continue;
							else
							{
								lastPos = new Point(i, j);
								return lastPos;
							}
						}
					}
				}
			}
			else
			{
				with(MapBuilder)
				if(_mapHandler.checkStatus(lastPos.x, lastPos.y, GRID_STATUS_IS_OPENED|GRID_STATUS_ITEM)
					||_mapHandler.checkStatus(lastPos.x, lastPos.y, GRID_STATUS_IS_OPENED|GRID_STATUS_MONSTER))
					return lastPos;
				else
					return findNextTile();
			}
			return null;
		}

		public function isRunning():Boolean
		{
			return _timer.running;
		}

		public function set mapData(value:MapData):void
		{
			_lastTile = null;
			_mapData = value;
			_mapHandler.setMatrixData(value.matrixData);
		}
	}
}