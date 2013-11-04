package com.arm.herolot.modules.battle.battle.round
{
	import com.arm.herolot.modules.battle.battle.BattleEntity;
	import com.arm.herolot.modules.battle.battle.round.attack.AttackResult;
	import com.arm.herolot.modules.battle.battle.round.attack.AttackTemp;

	/**
	 *一个回合
	 * @author hufan
	 */
	public class BattleRound
	{
		/**
		 *进攻方 
		 */		
		public var a:BattleEntity;
		/**
		 *进攻方的计算buffer效果后的实际的战斗模型
		 * 仅在一回合有效
		 */
		public var at:AttackTemp;
		/**
		 *进攻方本次战斗的结果。
		 */
		public var ar:AttackResult;
		
		/**
		 *防守方 
		 */		
		public var d:BattleEntity;
		/**
		 *防守方的计算buffer效果后的实际的战斗模型
		 * 仅在一回合有效
		 */
		public var dt:AttackTemp;
		/**
		 *防守方的战斗结果。
		 */
		public var dr:AttackResult;
	}
}
