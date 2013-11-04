package com.qzone.qfa.interfaces.module.controller
{
	import flash.events.IEventDispatcher;

	public interface IController extends IEventDispatcher
	{
//		function get view():IView;
//		function get model():IModel;
//		function get module():IModule;
		function destory():void;
		function onGameLoop(elapsed:int):void;
	}
}
