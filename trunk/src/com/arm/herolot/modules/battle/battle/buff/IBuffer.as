package com.arm.herolot.modules.battle.battle.buff
{
	import com.arm.herolot.modules.battle.battle.BattleEntity;
	import com.arm.herolot.modules.battle.battle.round.BattleRound;

	/**
	 * 影响战斗过程的一个特殊的存在。。。
	 * @author hufan
	 */
	public interface IBuffer
	{
		/**攻击前判定**/
		function before_attack(round:BattleRound):void;
		/**攻击后判定**/
		function after_attack(round:BattleRound):void;
		/**受伤前判定**/
		function before_injured(round:BattleRound):void;
		/**受伤后判定**/
		function after_injured(round:BattleRound):void;
		/**宿主**/
		function get owner():BattleEntity;
		function set owner(target:BattleEntity):void;
		/**参数设定**/
		function setParams(params:Object):void;
		/**重置，将该buffer带来的效果取消**/
		function reset():void
	}
}
