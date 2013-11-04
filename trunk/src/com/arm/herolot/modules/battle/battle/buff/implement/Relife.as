package com.arm.herolot.modules.battle.battle.buff.implement
{
	import com.arm.herolot.modules.battle.battle.buff.Buffer;
	import com.arm.herolot.modules.battle.battle.round.BattleRound;
	import com.arm.herolot.modules.battle.battle.round.attack.AttackEventDef;

	/**
	 * 复活buff。
	 * @author hufan
	 */
	public class Relife extends Buffer
	{
		private var _count:int = 1;
		private var _hpPer:Number;

		public function Relife()
		{
		}

		override public function after_injured(result:BattleRound):void
		{
			checkRelife(result);
		}

		override public function after_attack(result:BattleRound):void
		{
			checkRelife(result)
		}

		private function checkRelife(result:BattleRound):void
		{
			var relife:Boolean = false;
			if (result.a == owner && result.ar.die)
			{
				result.ar.die = true;
				result.ar.eventList.push(AttackEventDef.Relife);
				relife = true;
			}

			if (result.d == owner && result.dr.die)
			{
				result.dr.die = true;
				result.dr.eventList.push(AttackEventDef.Relife);
				relife = true;
			}

			if (relife)
				owner.hp = owner.hp_proxy.orignal * _hpPer;
		}


		override public function setParams(params:Object):void
		{
			_hpPer = int(params) / 100;
		}
	}
}
