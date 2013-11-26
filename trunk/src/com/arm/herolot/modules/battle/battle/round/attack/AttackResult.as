package com.arm.herolot.modules.battle.battle.round.attack
{

	public class AttackResult
	{
		/**
		 *伤害 
		 */		
		public var damage:Number=0;
		
		/**
		 *是否暴击 
		 */		
		public var crit:Boolean;
		
		/**
		 *是否闪避 
		 */		
		public var dodge:Boolean;
		
		
		/**
		 *死亡 
		 */
		public var die:Boolean;
		
		/**
		 *战斗过程中的特殊事件 
		 */		
		public var eventList:Vector.<String> =new Vector.<String>();
	}
}