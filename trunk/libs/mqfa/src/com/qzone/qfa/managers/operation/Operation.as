package com.qzone.qfa.managers.operation 
{
	import flash.events.EventDispatcher;
	/**
	 * 一个请求操作
	 * @author Demon.S
	 */
	public class Operation extends EventDispatcher implements IOperation
	{
		
		public function Operation() 
		{
			
		}	
		/**
		 * 发送
		 * @param	arg ,发送的内容对象
		 */
		public function send(arg:Object=null):void
		{
			
		}
		
		/**
		 * URL , String
		 * 请求地址
		 */
		protected var _url:String;
		public function get url():String { return _url; }
		
		public function set url(value:String):void 
		{
			_url = value;
		}		
		
	}

}