package com.qzone.qfa.debug
{
	import flash.events.IEventDispatcher;

	public interface IConsoleWindow extends IEventDispatcher
	{
        function update():void;
        
        function setLogBatch(value:LogBatch):void;
        
		function isHidden():Boolean;
		
		function hide():void;
        function show():void;
	}
}