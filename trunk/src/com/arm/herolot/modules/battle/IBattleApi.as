package com.arm.herolot.modules.battle
{
	import com.arm.herolot.modules.battle.battle.hero.HeroModel;
	import com.qzone.qfa.control.module.IModuleAPI;

	public interface IBattleApi extends IModuleAPI
	{
		function startBattle(hero:HeroModel):void
	}
}