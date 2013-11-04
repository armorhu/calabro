package com.qzone.qfa.interfaces.module.model
{
	import flash.events.IEventDispatcher;

	public interface IModel extends IEventDispatcher
	{
		function destory():void;
		function retriveData(type:String,param:*):*;
	}
}
