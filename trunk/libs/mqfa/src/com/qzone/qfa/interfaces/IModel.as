package com.qzone.qfa.interfaces 
{
	/**
	 * Interface Model
	 * @author Demon.S
	 */
	public interface IModel extends INotifier
	{
		/**
		 * 获取数据
		 * @param	name ,字符串数据名称
		 * @return  任意类型数据对象
		 */
		function getData(name:String):Object;
		
		/**
		 * 设定数据
		 * @param	name, 字符串数据名
		 * @param	value，任意数据类型
		 * @return	成功标志, true/false
		 */
		function setData(name:String, value:Object):Boolean;
		
		/**
		 * 清空数据
		 */
		function flush():void;
		
		
	}

}