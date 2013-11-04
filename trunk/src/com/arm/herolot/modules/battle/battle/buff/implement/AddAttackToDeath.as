package com.arm.herolot.modules.battle.battle.buff.implement
{
	import com.arm.herolot.model.consts.EthnicityDef;
	import com.arm.herolot.modules.battle.battle.buff.Buffer;
	import com.arm.herolot.modules.battle.battle.round.BattleRound;

	public class AddAttackToDeath extends Buffer
	{
		public function AddAttackToDeath()
		{
			super();
		}

		override public function before_attack(result:BattleRound):void
		{
			//目标是不死族。
			if (result.d.ethnicity == EthnicityDef.UnDeath)
				result.at.ackPer += int(_params) / 100;
		}
		
		
	}
}
