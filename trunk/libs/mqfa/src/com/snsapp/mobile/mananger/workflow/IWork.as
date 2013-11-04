package com.snsapp.mobile.mananger.workflow
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IEventDispatcher;

	/**
	 * 工作的接口
	 * 工作完成时,抛出Event,Complete事件
	 * 工作失败时,抛出ErrorEvent.ERROR
	 * @author armorhu
	 */
	[Event(name = "complete", type = "flash.events.Event")]
	[Event(name = "error", type = "flash.events.ErrorEvent")]
	public interface IWork extends IEventDispatcher
	{
		/**开始工作**/
		function start():void;
	}
}
