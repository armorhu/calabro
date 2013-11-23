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
		/**
		 *
		 * @param attacker
		 * @param defenser
		 * @return
		 *
		 */
		public static function round(attacker:BattleEntity, defenser:BattleEntity):BattleRound
		{
			var round:BattleRound = new BattleRound();
			round.a = attacker, round.d = defenser;
			round.at = new AttackTemp();
			round.ar = new AttackResult();
			round.dt = new AttackTemp();
			round.dr = new AttackResult();

			//攻击前判定
			if (attacker.buffers)
				for (var i:int = 0, len:int = attacker.buffers.length; i < len; i++)
					attacker.buffers[i].before_attack(round);
			if (defenser.buffers)
				for (i = 0, len = defenser.buffers.length; i < len; i++)
					defenser.buffers[i].before_injured(round);
			//战斗模型

			//先判定是否会闪避
			//闪避的概率
			var dodgeProbablity:Number = round.dt.dodgeAdd + defenser.dodge;
			if (GameMath.random(dodgeProbablity))
			{ //闪避了！
				round.dr.dodge = true;
			}
			else
			{
				round.dr.dodge = false;
				//计算攻击者的攻击
				var ack:Number = attacker.ack * (1 + round.at.ackPer) + round.at.ackAdd;
				var armor:Number = defenser.armor * (1 + round.dt.armorPer) + round.dt.armorAdd;
				//本游戏的伤害计算就是：我的攻击-他的防御
				var damage:int = Math.round(ack - armor);

				//计算暴击率
				var critProbablity:Number = round.at.critAdd + attacker.crit;
				//看看有没有暴击
				if (GameMath.random(critProbablity))
				{
					damage *= attacker.critFator;
					round.dr.crit = true;
				}
				else
				{
					round.dr.crit = false;
				}
				//伤害最少为1
				if (damage < 1) //最少1.
					damage = 1;
				round.dr.damage = damage;
				//真正把伤害给扣了。
				defenser.hp -= damage;
			}

			if (defenser.hp <= 0)
			{ //目标死掉了！！。
				defenser.hp = 0;
				round.dr.die = true;
			}
			else
			{
				round.dr.die = false;
			}

			//攻击后判定
			if (attacker.buffers)
				for (i = 0, len = attacker.buffers.length; i < len; i++)
					attacker.buffers[i].after_attack(round);
			if (defenser.buffers)
				for (i = 0, len = defenser.buffers.length; i < len; i++)
					defenser.buffers[i].after_injured(round);


			return round;
		}
	}
}
