package com.qzone.qfa.control.module
{
	import com.qzone.qfa.interfaces.IApplication;
	import com.qzone.qfa.managers.resource.Resource;
	
	import flash.events.EventDispatcher;

	public class Module extends EventDispatcher implements IModule
	{
		protected var _name:String; //模块名

		protected var _app:IApplication;

		protected var _container:*; //显示对象

		public function Module(name:String)
		{
			_name = name;
		}

		/**
		 * 模块启动
		 * @param app
		 * @param container
		 */
		public function startup(app:IApplication, container:*, resource:Resource = null):void
		{
			trace("[Module:" + _name + "]::startup...");
			_app = app;
			_container = container;
			initController();
		}

		/**
		 * 初始化Controller
		 * 交给子类来完成
		 */
		protected function initController():void
		{
			//implements by sub class
			throw new Error("pls implements by sub class");
		}

		/**
		 * 销毁模块
		 */
		public function destroy():void
		{
//			if (_controller)
//				_controller.destory();
//			_controller = null;
			_app = null;
			_container = null;
		}

		public function onGameLoop(elapsed:int):void
		{
//			_controller.onGameLoop(elapsed);
		}

		public function sleep():void
		{

		}

		public function revoke():void
		{

		}

		public function get name():String
		{
			return _name;
		}

		public function get container():*
		{
			return _container;
		}

		public function get mouduleAPI():IModuleAPI
		{
			return null;
		}
//		public function get app():*
//		{
//			return _app;
//		}
	}
}
