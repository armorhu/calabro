/*
 * QFA framework
 */
package com.qzone.qfa.control 
{
	import com.qzone.qfa.QFAInternal;
	import com.qzone.qfa.events.CommandEvent;
	import com.qzone.qfa.interfaces.IApplication;
	import com.qzone.qfa.interfaces.ICommand;
	
	import flash.events.EventDispatcher;
	use namespace QFAInternal;
	
	/**
	 * Command, 由view或Application 发出的通讯关系
	 * @author Demon.S
	 */
	
	public class Command extends EventDispatcher implements ICommand
	{
		protected var app:IApplication;
		private static var _lastId:int = 0;
		public var log:Boolean = true;
		
		private var _body:Object;
		private var _id:int;
		
		public function Command() 
		{
			_id=++_lastId;
			init();
		}
		
		/**
		 * 命令内部id号，用来区分命令
		 * @return 
		 * 
		 */		
		public function get id():int
		{
			return _id;
		}
		public function get owner():IApplication
		{
			return app;
		}
		public function set owner(_app:IApplication):void
		{
			app=_app;
		}
		
		/**
		 * 命令体 
		 * 
		 */		
		public function get body():Object 
		{ 
			return _body; 
		}
		
		public function set body(value:Object):void 
		{
			_body = value;
		}
		/**
		 * 命令发起者 
		 * 
		 */		
		public function get requester():* { 
			if (_body && _body.requester) return _body.requester;
			return null; 
		}
		
		/**
		 * 命令的执行过程，需要在继承的命令中override
		 * 
		 */		
		public function execute():void 
		{
			finish();
		}
		/**
		 * 命令的初始化，需要在继承的命令中override
		 * 
		 */	
		public function init():void
		{
			
		}
		/**
		 * 结束命令
		 */
		protected function finish(resultData:*=null):void
		{
			var event:CommandEvent = new CommandEvent(CommandEvent.COMPLETE);
			if (resultData)event.result = resultData;
			if (_body != null)
				event.body = _body;
			dispatchEvent(event);
		}
		/**
		 * 命令出错
		 * @param	errorData，出错信息
		 */
		protected function error(errorData:*=null):void
		{
			var event:CommandEvent = new CommandEvent(CommandEvent.ERROR);
			if (errorData) event.result = errorData;
			if (_body != null)
				event.body = _body;
			dispatchEvent(event);
		}
		/**
		 * 命令的销毁，需要在继承的命令中override
		 * 
		 */	
		public function destory():void
		{
			
		}
		
	}

}