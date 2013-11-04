package com.arm.herolot.works.startup
{
	import com.arm.herolot.Consts;
	import com.arm.herolot.Vars;
	import com.arm.herolot.model.consts.ModuleDef;
	import com.arm.herolot.modules.launch.ModuleLaunch;
	import com.arm.herolot.works.HerolotWorker;
	import com.qzone.qfa.interfaces.IApplication;
	import com.snsapp.mobile.StageInstance;
	import com.snsapp.mobile.utils.MobileSystemUtil;
	
	import flash.geom.Rectangle;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Event;

	public class StartupStarling extends HerolotWorker
	{
		public function StartupStarling(app:IApplication)
		{
			super(app);
		}
		protected var m_starling:Starling;
		protected var viewPort:Rectangle;

		override public function start():void
		{
			viewPort = new Rectangle(0, 0, Vars.stageWidth, Vars.stageHeight);
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
			var scale:Number = Vars.nativeScreenScale;
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
			var root:Sprite = Starling.current.root as Sprite;
			var layer:Sprite;

			//启动模块
			layer = new Sprite();
			root.addChild(layer);
			_app.registerModule(ModuleDef.MODULE_LAUNCH, ModuleLaunch, layer);

//			//战斗模块
//			layer = new Sprite();
//			root.addChild(layer);
//			_app.registerModule(Consts.MODULE_BATTLE, ModuleBattle, layer);
		}

	}
}

import starling.display.Sprite;

class StarlingRoot extends Sprite
{
}
