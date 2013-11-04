package com.qzone.qfa.control.module
{
	import com.qzone.qfa.interfaces.IApplication;
	import com.qzone.qfa.managers.resource.Resource;

	/**
	 * 模块的接口实际上只是为两者公开.
	 * 1 Application
	 * 2 模块内部的类
	 * 永远不要让两个模块直接交互,这样会造成不必要的耦合
	 * 模块间的通信,统一使用Application作为消息的中转站
	 * @author hf
	 */
	public interface IModule
	{
		/**启动模块
		 * app: 当前应用的app对象
		 * container: 当前模块的view.
		 *            注意,container是一个泛型。这是为了兼容Starling的Sprite类型和Flash原生的Sprite类型.
		 * resource:  当前模块的资源文件
		 * **/
		function startup(app:IApplication, container:*, resource:Resource = null):void;

		/**
		 * 彻底销毁模块
		 * **/
		function destroy():void;

		/**
		 * 游戏主循环
		 * @params elapsed 帧间距，单位为ms
		 * **/
		function onGameLoop(elapsed:int):void

		function get name():String

		function get container():*

//		function get app():*

		function get mouduleAPI():IModuleAPI

		/**
		 * 模块休眠
		 * 与destory不同，sleep方法并不会清除module对象。
		 * 是一种轻量级的回收内存的方式。具体的实现方式托管给子类来实现
		 * **/
		function sleep():void;

		/**
		 * 重新唤起模块
		 * **/
		function revoke():void;
	}
}
