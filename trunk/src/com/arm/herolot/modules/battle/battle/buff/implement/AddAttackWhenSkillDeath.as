package com.arm.herolot.modules.battle.battle.buff.implement
{
	import com.arm.herolot.model.consts.EthnicityDef;
	import com.arm.herolot.modules.battle.battle.buff.Buffer;
	import com.arm.herolot.modules.battle.battle.round.BattleRound;
	import com.arm.herolot.services.utils.GameMath;

	public class AddAttackWhenSkillDeath extends Buffer
	{
		private var percent:Number;
		private var probability:Number;

		private var active:Boolean;

		public function AddAttackWhenSkillDeath()
		{
			super();
		}

		override public function setParams(params:Object):void
		{
			var arr:Array = (params as String).split('|');
			probability = int(arr[0]) / 100;
			percent = int(arr[1]) / 100;
		}

		override public function after_attack(result:BattleRound):void
		{
			//如果已经生效，把旧的效果移除
			if (active)
			{
				result.a.ack_proxy.per -= percent;
				active = false;
			}

			//杀死一个亡灵，有一定概率触发buffer效果。
			if (result.dr.die && result.d.ethnicity == EthnicityDef.UnDeath && GameMath.random(probability))
			{
				result.a.ack_proxy.per += percent;
				active = true;
			}
		}

		override protected function removedFromOwner():void
		{
			//如果已经生效，把旧的效果移除
			if (active)
			{
				owner.ack_proxy.per -= percent;
				active = false;
			}
		}
	}
}
