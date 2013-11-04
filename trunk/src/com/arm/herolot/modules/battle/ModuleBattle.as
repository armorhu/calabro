package com.arm.herolot.modules.battle
{
	import com.arm.herolot.modules.battle.battle.hero.HeroModel;
	import com.arm.herolot.modules.HerolotModule;

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
	}
}
