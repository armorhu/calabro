package com.qzone.qfa.managers.operation 
{
	import flash.events.Event;
	
	/**
	 * Operation接口
	 * @author Demon.S
	 */
	public interface IOperation 
	{
		/**
		 * 发送请求 
		 * @param args，请求参数对象
		 * 
		 */		
		function send(body:Object=null):void;
	}
	
}