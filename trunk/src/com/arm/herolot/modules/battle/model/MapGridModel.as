package com.arm.herolot.modules.battle.model
{
	import com.arm.herolot.modules.battle.map.MapGridData;
	
	import starling.animation.IAnimatable;
	import starling.events.Event;
	import starling.events.EventDispatcher;

	public class MapGridModel extends EventDispatcher implements IAnimatable
	{
		/**
		 *格子数据
		 */
		public var gridData:MapGridData;

		/**
		 *格子状态
		 * 详情请见 MapGridStateDef。
		 */
		private var _gridState:int;

		protected var _eventList:Vector.<String>;

		/**
		 *是否可见
		 */
		private var _visible:Boolean=false;

		/**
		 *是否被锁
		 */
		private var _lock:Boolean=false;

		private var _modelChange:Boolean;

		public function MapGridModel()
		{
			super();
			initalize();
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

		public function get visible():Boolean
		{
			return _visible;
		}

		public function set visible(bool:Boolean):void
		{
			if (bool == _visible)
				return;
			_visible = bool;
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

		public function dispose():void
		{
		}

		public function advanceTime(time:Number):void
		{
			if(_modelChange)
			{
				_modelChange=false;
				dispatchEventWith(Event.CHANGE);
			}
		}


		public static function createMapEntityModel(gridData:MapGridData):MapGridModel
		{
			var model:MapGridModel = new MapGridModel();
			model.gridData = gridData;
			return model;
		}
	}
}
