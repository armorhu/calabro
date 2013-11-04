package com.snsapp.mobile.mananger.workflow
{
	import com.qzone.qfa.interfaces.IApplication;

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;

	[Event(name = "complete", type = "flash.events.Event")]
	[Event(name = "error", type = "flash.events.ErrorEvent")]
	public class SimpleWork extends EventDispatcher implements IWork
	{
		protected var _app:IApplication;
		protected var _complete:Boolean;
		protected var _start:Boolean;
		public var result:*; //工作成果。

		public function SimpleWork(app:IApplication)
		{
			super(null);
			_app = app;
			_complete = false;
			_start = false;
		}

		public function start():void
		{
			_start = true;
		}

		public function stop():void
		{
		}

		public function dispose():void
		{
			result = null;
		}

		/**
		 * 工作成功或者失败，返回都是true
		 */
		public function get complete():Boolean
		{
			return _complete;
		}

		protected function workComplete():void
		{
			_complete = true;
			dispatchEvent(new Event(Event.COMPLETE));
		}

		public function get isStart():Boolean
		{
			return _start;
		}

		protected function workError():void
		{
			_complete = true;
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
		}

	}
}
