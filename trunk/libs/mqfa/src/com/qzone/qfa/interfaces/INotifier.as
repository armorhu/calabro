package com.qzone.qfa.interfaces 
{
	/**
	 * Interface Notifier
	 * 广播器
	 * @author Demon.S
	 */
	public interface INotifier 
	{
		/**
		 * 增加监听者
		 * @param	dataStr,被监听的数据名 ,非空字符串
		 * @param	callback,监听的函数体
		 */
		function addNotifier(dataStr:String, callback:Function) :void
		
		/**
		 * 移除监听者
		 * @param	dataStr,被监听的数据名 ,非空字符串
		 * @param	callback,监听的函数体
		 */
		function removeNotifier(dataStr:String, callback:Function) :void
		
		/**
		 * 按名称广播
		 * @param	dataStr 数据名
		 */
		function notify(dataStr:String):void
		
	}
	
}