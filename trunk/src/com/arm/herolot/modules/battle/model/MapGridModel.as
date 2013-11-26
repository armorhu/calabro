package com.arm.herolot.modules.battle.model
{
	import com.arm.herolot.model.config.AppConfig;
	import com.arm.herolot.model.config.mapEntities.MapEntitiesConfig;
	import com.arm.herolot.model.consts.MapEntityTypeDef;
	import com.arm.herolot.modules.battle.map.MapGridData;

	import flash.utils.getDefinitionByName;

	import starling.animation.IAnimatable;
	import starling.events.Event;
	import starling.events.EventDispatcher;

	public class MapGridModel extends EventDispatcher implements IAnimatable
	{
		public static const OPEN:String = 'open';
		/**
		 *格子数据
		 */
		public var gridData:MapGridData;

		/**
		 *这个格子的实体的配置
		 */
		public var entityConfig:MapEntitiesConfig;

		/**
		 *格子状态
		 * 详情请见 MapGridStateDef。
		 */
		private var _gridState:int;

		protected var _eventList:Vector.<String>;

		/**
		 *是否可见
		 */
		private var _reachable:Boolean = false;

		/**
		 *是否被锁
		 */
		private var _lock:Boolean = false;


		/**
		 *是否打开的
		 */
		private var _open:Boolean = false;


		private var _modelChange:Boolean;

		public var gid:int;
		
		public var floor:int;

		public function MapGridModel()
		{
			super();
		}

		protected function initalize():void
		{
			_eventList = new Vector.<String>();
			_eventList.push(Event.CHANGE);
		}

		public function get eventsTypeList():Vector.<String>
		{
			return _eventList;
		}

		public function get reachable():Boolean
		{
			return _reachable;
		}

		public function set reachable(bool:Boolean):void
		{
			if (bool == _reachable)
				return;
			_reachable = bool;
			_modelChange = true;
		}

		public function get lock():Boolean
		{
			return _lock;
		}

		public function set lock(bool:Boolean):void
		{
			if (bool == _lock)
				return;
			_lock = bool;
			_modelChange = true;
		}


		public function get open():Boolean
		{
			return _open;
		}

		public function set open(bool:Boolean):void
		{
			if (bool == open)
				return;
			_open = bool;
			_modelChange = true;
		}


		public function get hasMonster():Boolean
		{
			return open && entityConfig && entityConfig.EntityType == MapEntityTypeDef.MONSTER;
		}

		public function dispose():void
		{
		}

		public function advanceTime(time:Number):void
		{
			if (_modelChange)
			{
				_modelChange = false;
				dispatchEventWith(Event.CHANGE);
			}
		}

		public function get entityId():int
		{
			return gridData.entity.id;
		}


		public static function createMapEntityModel(gridData:MapGridData):MapGridModel
		{
			if (gridData.entity.id > 0)
			{
				var modelClassName:String = 'com.arm.herolot.modules.battle.model.entities.' + AppConfig.mapEntitiesConfigModel.getMapEntitiesConfigByID(gridData.entity.id).ModelClassName;
				var modelClass:Class;
				try
				{
					modelClass = getDefinitionByName(modelClassName) as Class;
				}
				catch (error:Error)
				{
				}
			}

			if (modelClass == null)
				modelClass = MapGridModel;

			var model:MapGridModel = new modelClass();
			model.gridData = gridData;
			model.entityConfig = AppConfig.mapEntitiesConfigModel.getMapEntitiesConfigByID(gridData.entity.id);
			model.initalize();
			return model;
		}

		public function touchHandler():void
		{
			if (open)
			{
			}
			else
			{
				if (!reachable)
				{
					return;
				}

				if (lock)
				{
					return;
				}

				open = true;
				//抛打开事件。
				dispatchEventWith(OPEN);
			}
		}
	}
}
