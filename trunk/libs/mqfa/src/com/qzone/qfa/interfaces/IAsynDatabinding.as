package com.qzone.qfa.interfaces
{
	import flash.events.IEventDispatcher;

	public interface IAsynDatabinding extends IEventDispatcher, IDatabinding
	{
		function isComplete():Boolean;
	}
}
