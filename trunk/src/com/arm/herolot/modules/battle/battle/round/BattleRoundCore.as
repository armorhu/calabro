package com.arm.herolot.modules.battle.battle.round
{
	import com.arm.herolot.modules.battle.battle.BattleEntity;
	import com.arm.herolot.modules.battle.battle.round.attack.AttackResult;
	import com.arm.herolot.modules.battle.battle.round.attack.AttackTemp;
	import com.arm.herolot.services.utils.GameMath;

	/**
	 *战斗核心逻辑
	 * @author hufan
	 *
	 */
	public class BattleRoundCore
	{
		public function BattleRoundCore()
		{
		}


		/**
		 * 使用传入的两个战斗对象，进行一个回合的战斗
		 * @param attacker
		 * @param defenser
		 * 返回一个战斗结果数组。
		 */
		public static function round(attacker:BattleEntity, defenser:BattleEntity):BattleRound
		{
			var round:BattleRound = new BattleRound();
			round.attackerResult = new AttackResult();
			round.attackerTemp = new AttackTemp();
			round.attackerTemp.entity = attacker;

			round.defenseResult = new AttackResult();
			round.defenseTemp = new AttackTemp();
			round.defenseTemp.entity = defenser;

			//攻击前判定
			if (attacker.buffers)
				for (var i:int = 0, len:int = attacker.buffers.length; i < len; i++)
					attacker.buffers[i].before_attack(round);
			if (defenser.buffers)
				for (i = 0, len = defenser.buffers.length; i < len; i++)
					defenser.buffers[i].before_injured(round);

			//战斗模型

			//先判定是否会闪避
			if (GameMath.random(round.defenseTemp.dodge / 100))
			{ //闪避了！
				round.defenseResult.dodge = true;
			}
			else
			{
				round.defenseResult.dodge = false;

				//本游戏的伤害计算就是：我的攻击-他的防御
				var damage:int = Math.round(round.attackerTemp.attack - round.defenseTemp.armor);
				//看看有没有暴击
				if (GameMath.random(round.attackerTemp.crit / 100))
				{
					damage *= round.attackerTemp.critFactor;
					round.defenseResult.crit = true;
				}
				else
				{
					round.defenseResult.crit = false;
				}
				//伤害最少为1
				if (damage < 1) //最少1.
					damage = 1;
				round.defenseResult.damage = damage;
				//真正把伤害给扣了。
				defenser.hp -= damage;
			}


			//攻击后判定
			if (attacker.buffers)
				for (i = 0, len = attacker.buffers.length; i < len; i++)
					attacker.buffers[i].after_attack(round);
			if (defenser.buffers)
				for (i = 0, len = defenser.buffers.length; i < len; i++)
					defenser.buffers[i].after_injured(round);

			if (defenser.hp <= 0)
			{ //目标死掉了！！。
				round.defenseResult.die = true;
			}
			else
			{
				round.defenseResult.die = false;
			}

			return round;
		}
	}
}
