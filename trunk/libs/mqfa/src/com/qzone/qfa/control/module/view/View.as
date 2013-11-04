package com.qzone.qfa.control.module.view
{
	import com.qzone.qfa.interfaces.module.controller.IController;
	import com.qzone.qfa.interfaces.module.view.IView;

	import flash.display.Sprite;
	import flash.events.Event;

	public class View extends Sprite implements IView
	{

		public function View(controller:IController)
		{
			super();
			initiatize();
			registerListenners();
			if (stage)
				firstAddedToStage();
			else
				addEventListener(Event.ADDED_TO_STAGE, function addtoStage():void
				{
					removeEventListener(Event.ADDED_TO_STAGE, addtoStage);
					firstAddedToStage();
				})
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

		/**
		 * 第一次被加入舞台
		 * 视图类经常会用这个方法.
		 * 使一些视图对象延迟初始化
		 */
		protected function firstAddedToStage():void
		{
			//implements by sub class
		}

		public function destroy():void
		{
			registerListenners();
		}
	}
}
