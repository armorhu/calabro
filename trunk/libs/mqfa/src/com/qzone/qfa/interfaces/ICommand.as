package com.qzone.qfa.interfaces 
{
	/**
	 * Interface Command
	 * @author Demon.S
	 */
	public interface ICommand
	{
		/**
		 * 命令内部id,初始化时被自动设定,read only
		 */
		function get id():int;
		/**
		 * 命令作用域的application
		 * 
		 */		
		function get owner():IApplication;
		function set owner(app:IApplication):void;
		/**
		 * 命令体
		 */
		function get body():Object;
		function set body(obj:Object):void;
		/**
		 * 请求者,read only
		 */
		function get requester():*;	
		/**
		 * 初始化命令部分,可选
		 */		
		function init():void
		/**
		 * 执行部分,必须有
		 */
		function execute():void
		/**
		 * 销毁部分,可选，如果init里面使用了对象，在这个里面要销毁掉
		 */
		function destory():void
		
		/**
		 * 取消执行,未完成
		 */
		/*function cancel():void
		{
			
		}*/
	}

}