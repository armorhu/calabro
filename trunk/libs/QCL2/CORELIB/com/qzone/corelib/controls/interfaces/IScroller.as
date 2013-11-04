package com.qzone.corelib.controls.interfaces
{
	import flash.events.IEventDispatcher;
	
	/**
	 * 滚动控件接口
	 * @author Larry H.
	 */
	public interface IScroller extends IEventDispatcher
	{
		/**
		 * 滑块值，是一个百分比，介于0~100%
		 */
		function get value():Number;
		function set value(position:Number):void;
		
		/**
		 * 是否激活控件
		 */
		function get enabled():Boolean;
		function set enabled(value:Boolean):void;
		
		/**
		 * 设置当前行数量
		 */
		function setCurrentLineCount(value:int):void;
	}
}