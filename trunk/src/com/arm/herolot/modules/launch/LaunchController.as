package com.arm.herolot.modules.launch
{
	import com.arm.herolot.modules.launch.screens.BaseScreen;
	
	import starling.display.Sprite;
	import starling.events.Event;

	public class LaunchController
	{
		private var _module:ModuleLaunch;
//		private var _model:LaunchModel;
		private var _view:LaunchView;

		public function LaunchController(module:ModuleLaunch)
		{
			_module = module;
			initialize();
		}

		public function get module():ModuleLaunch
		{
			return _module;
		}


		private function initialize():void
		{
//			_model = new LaunchModel(this);
//			_model.addEventListener(LaunchModel.BEGIN_LOAD_DATA, loadDataHandler);
//			_model.addEventListener(LaunchModel.COMLETE_LOAD_DATA, loadDataHandler);
//			_model.addEventListener(LaunchModel.FAILED_LOAD_DATA, loadDataHandler);

			_view = new LaunchView(this);
			_view.addEventListener(LaunchView.REQUEST_DATA, requestData);
			_view.addEventListener(LaunchView.START_BATTLE, startBattleHandler);
			_view.addEventListener(LaunchView.REQUEST_UPGRADE_SKILL, upgradeSkillHandler);
			Sprite(_module.container).addChild(_view);
			_view.show(function createViewComplete(suc:Boolean):void
			{
			})
		}

		private function requestData(e:Event):void
		{
			var dataType:String = e.data as String;
			
			if(dataType == LaunchModel.HERO_DATA)
			{
				setDataToActiveScreen(dataType,_module.app.gameDataModel.heros);
			}
			else if(dataType == LaunchModel.PLAYER_DATA)
			{
				setDataToActiveScreen(dataType,_module.app.gameDataModel.data);
			}
			
			
//			this._model.loadData(e.data as String);
		}

		private function startBattleHandler(e:Event):void
		{
//			var heroId:int = int(e.data);
//			var hero:Hero = _model.heros[heroId];
//			_module.app.startBattle(hero);
		}

		private function upgradeSkillHandler(e:Event):void
		{
//			_model.upgradeSkill(e.data['hero'], e.data['skill']);
		}

//		private function loadDataHandler(e:Event):void
//		{
//			if (e.type == LaunchModel.COMLETE_LOAD_DATA)
//			{
//				if (_view && _view.activeScreen)
//					BaseScreen(_view.activeScreen).setData(e.data['type'], e.data['data']);
//			}
//			else if (e.type == LaunchModel.FAILED_LOAD_DATA)
//			{
//			}
//		}
		
		public function setDataToActiveScreen(type:String,data:Object):void
		{
			if (_view && _view.activeScreen)
				BaseScreen(_view.activeScreen).setData(type, data);
		}

		public function dispose():void
		{
			_view.removeEventListeners(LaunchView.REQUEST_DATA);
			_view.removeEventListeners(LaunchView.START_BATTLE);
			_view.addEventListener(LaunchView.START_BATTLE, startBattleHandler);
			_view.removeFromParent(true);
			_view = null;

//			_model.removeEventListeners(LaunchModel.BEGIN_LOAD_DATA);
//			_model.removeEventListeners(LaunchModel.COMLETE_LOAD_DATA);
//			_model.removeEventListeners(LaunchModel.FAILED_LOAD_DATA);
//			_model = null;
		}
	}
}
