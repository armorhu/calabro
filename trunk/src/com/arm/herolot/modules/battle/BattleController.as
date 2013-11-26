package com.arm.herolot.modules.battle
{
	import com.arm.herolot.Consts;
	import com.arm.herolot.Vars;
	import com.arm.herolot.modules.battle.battle.hero.HeroModel;
	import com.arm.herolot.modules.battle.model.map.MapGridModel;
	import com.arm.herolot.modules.battle.texture.BattleTexture;
	import com.snsapp.mobile.utils.MobileSystemUtil;
	import com.snsapp.starling.texture.ClientTextureParams;
	
	import flash.utils.setTimeout;
	
	import starling.display.Sprite;
	import starling.events.Event;

	public class BattleController
	{
		private var _module:ModuleBattle;
		private var _model:BattleModel;
		private var _view:BattleView;
		private var _texture:BattleTexture;

		public function BattleController(module:ModuleBattle)
		{
			_module = module;
		}

		public function startBattle(hero:HeroModel):void
		{
			setupTexture();
			function setupTexture():void
			{
				var clientParams:ClientTextureParams = new ClientTextureParams();
				clientParams.deviceDefalutLevelConfig = new XML;
				clientParams.clientVersion = Consts.VERSION;
				clientParams.deviceName = _module.app.deviceInfo.deviceName;
				clientParams.os = MobileSystemUtil.os;
				clientParams.screenScale = Vars.starlingScreenScale;
				clientParams.textureVersion = "1";
				clientParams.resouceSwf = Consts.RES_BATTLE;
				_texture = new BattleTexture(_module.app);
				_texture.setup(clientParams, onComplete);
				/**材质启动成功。**/
				function onComplete(suc:Boolean):void
				{
					if (suc == false)
					{
						_texture.dispose();
						_texture = null;
					}
					else
					{
						initaliaze();
					}
				}
			}

			function initaliaze():void
			{
				_view = new BattleView();
				Sprite(_module.container).addChild(_view);
				_view.initaliaze(_texture);

				_model = new BattleModel();
				_model.addEventListener(BattleModel.CHANGE_FLOOR, modelEventHandler);
				_model.addEventListener(BattleModel.BATTLE_RESULT, modelEventHandler);

				_model.start(hero);
				_model.nextFloor();

				_view.setBattleuiModel(_model.battleuiModel);
			}
		}

		private function viewEventHandler(evt:Event):void
		{
		}

		private function modelEventHandler(evt:Event):void
		{
			if (evt.type == BattleModel.CHANGE_FLOOR)
			{
				_view.setMapdata(_model.mapDataModel.mapGrids);
				//一定的延迟后，将门的那个格子打开。
				var door:MapGridModel = _model.mapDataModel.mapGrids[_model.mapDataModel.mapData.door];
				setTimeout(door.touchHandler, 1000);
				_view.setFloor(_model.floor);
			}
			else if (evt.type == BattleModel.BATTLE_RESULT)
			{
				_view.displayBattleResult(evt.data);
			}
		}
	}
}
