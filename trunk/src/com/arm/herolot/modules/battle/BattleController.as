package com.arm.herolot.modules.battle
{
	import com.arm.herolot.modules.battle.battle.hero.HeroModel;
	
	import starling.display.Sprite;
	import starling.events.Event;

	public class BattleController
	{
		private var _module:ModuleBattle;
		private var _model:BattleModel;
		private var _view:BattleView;

		public function BattleController(module:ModuleBattle)
		{
			_module = module;
		}

		public function startBattle(hero:HeroModel):void
		{
			_model = new BattleModel(this);
			_model.addEventListener(BattleModel.COMLETE_LOAD_DATA, onLoadData);
			_model.addEventListener(BattleModel.REQUEST_DISPLAY_INTERACTION, onDisplayInteraction);
			_model.addEventListener(BattleModel.BOT_OPERATION, onBot);
			_model.addEventListener(BattleModel.GAME_OVER, onGameOver);

			_view = new BattleView(this);
			_view.addEventListener(BattleView.REQUEST_DATA, requestData);
			_view.addEventListener(BattleView.TILE_TOUCHED, onTileTouch);
			Sprite(_module.container).addChild(_view);
			_view.show(function viewSetUpComplete(suc:Boolean):void
			{
				//视图材质初始化成功。。。。
				if (suc)
				{
					_model.setBattleHero(hero); //设置英雄数据。
					_model.createMapDataAt(1); //构造第一层的地图数据。
				}
				else
				{ //do sth....
				}
			});
		}
		
		private function onBot(event:Event):void
		{
			_view.touchable = event.data.allowUserTouch as Boolean;
		}
		
		private function onGameOver(event:Event):void
		{
			Sprite(_module.container).removeChild(_view);
			_module.app.gameOver();
		}
		
		private function onTileTouch(event:Event):void
		{
			_model.processTileTouch(event.data.x, event.data.y);
		}

		private function requestData(event:Event):void
		{
			_model.requestData(event.data as String);
		}
		
		private function onDisplayInteraction(event:Event):void
		{
			_view.displayInteraction(event.data['type'], event.data['result']);
		}
		
		private function onLoadData(event:Event):void
		{
			if (event.type == BattleModel.COMLETE_LOAD_DATA)
				_view.setData(event.data['type'], event.data['data']); //设置视图数据。
		}

		public function get module():ModuleBattle
		{
			return _module;
		}
	}
}
