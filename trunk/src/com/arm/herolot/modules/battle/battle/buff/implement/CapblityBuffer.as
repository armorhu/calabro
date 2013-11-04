package com.arm.herolot.modules.battle.battle.buff.implement
{
	import com.arm.herolot.modules.battle.battle.buff.Buffer;

	public class CapblityBuffer extends Buffer
	{
		private var hp:int;
		private var ack:int;
		private var speed:int;
		private var crit:Number;

		public function CapblityBuffer()
		{
			super();
		}

		override public function setParams(params:Object):void
		{
			var arr:Array = (params as String).split('|');
			hp = int(arr[0]);
			ack = int(arr[1]);
			speed = int(arr[2]);
			crit = int(arr[3]) / 100;
		}

		override protected function addedToOwner():void
		{
			owner.hp_proxy.orignal += hp;
			owner.speed_proxy.orignal += speed;
			owner.ack_proxy.orignal += ack;
			owner.crit_proxy.orignal += crit;
		}

		override protected function removedFromOwner():void
		{
			owner.hp_proxy.orignal -= hp;
			owner.speed_proxy.orignal -= speed;
			owner.ack_proxy.orignal -= ack;
			owner.crit_proxy.orignal -= crit;
		}
	}
}
