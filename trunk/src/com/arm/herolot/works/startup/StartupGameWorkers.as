package com.arm.herolot.works.startup
{
	import com.arm.herolot.Consts;
	import com.arm.herolot.HerolotApplication;
	import com.arm.herolot.model.config.AppConfig;
	import com.arm.herolot.model.consts.ModuleDef;
	import com.arm.herolot.modules.battle.IBattleApi;
	import com.qzone.qfa.interfaces.IApplication;
	import com.snsapp.mobile.mananger.workflow.SimpleWork;
	import com.snsapp.mobile.mananger.workflow.WorkFlowEvent;
	import com.snsapp.mobile.mananger.workflow.Workflow;

	/**
	 * 启动游戏的worker。
	 * @author hufan
	 */
	public class StartupGameWorkers extends SimpleWork
	{
		/**初始化app的工作流。每次运行周期只运行一次**/
		private var _initliazeFlow:Workflow;

		/**开始游戏前，与后台的必要交互。（本游戏暂时木有。。。）**/
		private var _netFlow:Workflow;

		public function StartupGameWorkers(app:IApplication)
		{
			super(app);
		}

		override public function start():void
		{
			_initliazeFlow = new Workflow();
			_initliazeFlow.registeWork(_app.deviceInfo, false, '加载游戏.');
			_initliazeFlow.registeWork(_app.rsLoader, false, '加载游戏..');
			_initliazeFlow.registeWork(new StartupStarling(_app), false, '加载游戏...');
			_initliazeFlow.registeWork(AppConfig, false, '初始化配置文件');
			_initliazeFlow.addEventListeners(initiliazeFlowHanlder);
			_initliazeFlow.start();
		}

		private function initiliazeFlowHanlder(evt:WorkFlowEvent):void
		{
			switch (evt.type)
			{
				case WorkFlowEvent.COMPLETE:
				{
					break;
				}
				case WorkFlowEvent.QUEUE_COMPLETE:
				{
					startupGame();
					break;
				}
				case WorkFlowEvent.QUEUE_FAILED:
				{

					break;
				}
				default:
				{
					break;
				}
			}
		}

		private function destoryInitliazeFlow():void
		{
			_initliazeFlow.removeEventListeners(initiliazeFlowHanlder);
			_initliazeFlow.destory();
			_initliazeFlow = null;
		}



		public function get app():HerolotApplication
		{
			return _app as HerolotApplication
		}

		private function startupGame():void
		{
			destoryInitliazeFlow();
			//加载游戏数据
			HerolotApplication(_app).gameDataModel.loadGameData();
//			_app.loadModule(ModuleDef.MODULE_LAUNCH); //加载启动模块。
			_app.loadModule(ModuleDef.MODULE_BATTLE);


			var iBattle:IBattleApi = _app.getModuleAPI(ModuleDef.MODULE_BATTLE) as IBattleApi;
			iBattle.startBattle(app.gameDataModel.heros[0]);
		}
	}
}
