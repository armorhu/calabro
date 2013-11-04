package com.snsapp.workers
{
	import com.qzone.qfa.interfaces.IApplication;
	import com.snsapp.mobile.StageInstance;
	import com.snsapp.mobile.mananger.workflow.SimpleWork;
	import com.snsapp.mobile.utils.MobileSystemUtil;
	import com.snsapp.mobile.view.ScreenAdaptiveUtil;
	
	import flash.geom.Rectangle;
	
	import starling.core.Starling;
	import starling.events.Event;

	public class StartupStarlingWorker extends SimpleWork
	{
		protected var m_starling:Starling;
		protected var viewPort:Rectangle;

		public function StartupStarlingWorker(app:IApplication)
		{
			super(app);
		}

		override public function start():void
		{
			viewPort = new Rectangle();
			viewPort.width = Math.max(StageInstance.stage.fullScreenWidth, StageInstance.stage.fullScreenHeight);
			viewPort.height = Math.min(StageInstance.stage.fullScreenWidth, StageInstance.stage.fullScreenHeight);

			Starling.handleLostContext = MobileSystemUtil.isAndroid(); //android建议处理
			m_starling = new Starling(StarlingRoot, StageInstance.stage, viewPort);
			m_starling.addEventListener(Event.ROOT_CREATED, onCreateContext3d);
			m_starling.simulateMultitouch = false;
			m_starling.enableErrorChecking = false;
		}


		/**
		 * Context3d构造成功
		 * @param e
		 */
		private function onCreateContext3d(e:Event):void
		{
			var scale:Number = ScreenAdaptiveUtil.SCALE_COMPARED_TO_IPAD.maxScale;
			if (scale > 1)
			{
				m_starling.stage.stageWidth = viewPort.width / scale;
				m_starling.stage.stageHeight = viewPort.height / scale;
			}

			e.target.removeEventListener(Event.ROOT_CREATED, onCreateContext3d);

			Starling.current.start();
			buildStarlingLayers();
			workComplete();
		}

		protected function buildStarlingLayers():void
		{
			throw new Error("pls implements by sub class!");
		}
	}
}

import starling.display.Sprite;

class StarlingRoot extends Sprite
{
}
