package com.qzone.qfa.events
{
	import flash.events.Event;

	public class CommandEvent extends Event
	{
		/**
		 * 请求执行事件
		 */
		public static const REQUEST:String = "RequestCommand";
		/**
		 * 命令执行完毕事件
		 */
		public static const COMPLETE:String = "CommandComplete";
		/**
		 * 命令执行出错事件
		 */
		public static const ERROR:String = "CommandError";
		
		/**
		 * 命令参数
		 * 
		 */
		public var command:Class;
		/**
		 * 命令参数体
		 */
		public var body:*;
		/**
		 * 欲绑定的数据模型
		 */
		public var dataBindStr:String;
		/**
		 * 数据模型更新时的回调函数
		 */
		public var dataBindCall:Function;
		/**
		 * 命令结束时的事件监听函数
		 */
		public var completeHandler:Function;
		/**
		 * 命令出错是的事件监听函数
		 */
		public var errorHandler:Function;
		/**
		 * 命令结束后的结果数据，可选
		 */
		public var result:*;
		
		/**
		 * 总共需要加载的数据,可选
		 * **/
		public var bytesTotal:Number;
		
		/**
		 * 已经加载了的数据,可选
		 * **/
		public var bytesLoaded:Number ; 
		
		public function CommandEvent(type:String,
									cmd:Class=null, 
									body:*= null, 
									dataBindStr:String = "", 
									dataBindCall:Function = null, 
									completeHandler:Function = null,
									errorHandler:Function=null,
									bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.command=cmd;
			this.body=body;
			this.dataBindStr = dataBindStr;
			this.dataBindCall = dataBindCall;
			this.completeHandler = completeHandler;
			this.errorHandler = errorHandler;
			super(type, bubbles, cancelable);
		}
		
	}
}