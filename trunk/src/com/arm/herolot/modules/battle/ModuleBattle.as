package com.arm.herolot.modules.battle
{
	import com.arm.herolot.modules.HerolotModule;
	import com.arm.herolot.modules.battle.battle.hero.HeroModel;
	import com.arm.herolot.modules.battle.model.map.entities.MonsterModel;
	import com.arm.herolot.modules.battle.view.map.entities.MonsterRender;

	public class ModuleBattle extends HerolotModule implements IBattleApi
	{
		private var _controller:BattleController;

		public function ModuleBattle(name:String)
		{
			super(name);
		}

		override protected function initController():void
		{
			_controller = new BattleController(this);
		}

		public function startBattle(hero:HeroModel):void
		{
			_controller.startBattle(hero);
		}
		
		
		private function complieMe():void
		{
			var mm:MonsterModel;
			var mr:MonsterRender;
		}
	}
}
