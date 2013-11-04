package com.arm.herolot.modules.battle.battle.round.attack
{
	/**
	 *战斗过程中，buffer不是直接修改战斗对象的数据，而是修改这个中间变量。
	 * 这样战斗结束后，战斗对象的数据其实并不会被buffer改变。
	 * @author hufan
	 */
	public class AttackTemp
	{
		/**
		 *加几点攻击 
		 */		
		public var ackAdd:Number = 0;
		
		/**
		 *按百分比加攻击 
		 */		
		public var ackPer:Number = 1;
		
		/**
		 *加护甲 
		 */		
		public var armorAdd:Number = 0;
		
		/**
		 *按百分比加护甲 
		 */		
		public var armorPer:Number = 1;

		/**
		 *按百分比加躲闪
		 */		
		public var dodgeAdd:Number = 0;
		
		/**
		 *按百分比加暴击 
		 */		
		public var critAdd:Number = 0;
	}
}
