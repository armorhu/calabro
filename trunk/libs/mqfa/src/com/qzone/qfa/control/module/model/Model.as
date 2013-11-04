package com.qzone.qfa.control.module.model
{
	import com.qzone.qfa.interfaces.module.controller.IController;
	import com.qzone.qfa.interfaces.module.model.IModel;

	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class Model extends EventDispatcher implements IModel
	{
		public function Model(controller:IController)
		{
			super();
			initiatize();
			registerListenners();
		}

		/**
		 * 初始化函数
		 */
		protected function initiatize():void
		{
			//implements by sub class;
		}

		/**
		 * 注册事件
		 */
		protected function registerListenners():void
		{
			//implements by sub class
		}

		/**
		 * 移除事件
		 */
		protected function removeListenners():void
		{
			//implements by sub class
		}

		public function destory():void
		{
			removeListenners();
		}

		public function retriveData(type:String, parmas:*):*
		{
			return null;
		}
	}
}
