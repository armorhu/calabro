package com.arm.herolot.modules.battle.battle
{
	import com.arm.herolot.modules.battle.battle.buff.IBuffer;
	import com.arm.herolot.modules.battle.battle.propertyproxy.PropertyProxy;
	import com.arm.herolot.services.utils.GameMath;
	import com.arm.herolot.modules.battle.battle.round.BattleRound;
	import com.arm.herolot.modules.battle.battle.round.attack.AttackTemp;

	/**
	 * 战斗实体
	 * 英雄、怪物的基类。
	 * @author hufan
	 */
	public class BattleEntity
	{

		/**
		 * (hp*p1+addition)*p2;
		 * **/
		public var hp_proxy:PropertyProxy; //血
		public var dodge_proxy:PropertyProxy; //闪避[0,100]
		public var crit_proxy:PropertyProxy; //暴击[0,100]
		public var ack_proxy:PropertyProxy; //攻击
		public var armor_proxy:PropertyProxy; //防御
		public var speed_proxy:PropertyProxy; //速度
		public var critFator_proxy:PropertyProxy; //暴击系数。
		public var ethnicity:int = 0; //种族。


		public function get hp():Number
		{
			return hp_proxy.value;
		}

		public function set hp(value:Number):void
		{
			hp_proxy.value = value;
		}


		public function get dodge():Number
		{
			return dodge_proxy.value;
		}

		public function set dodge(value:Number):void
		{
			dodge_proxy.value = value;
		}

		public function get crit():Number
		{
			return crit_proxy.value;
		}

		public function set crit(value:Number):void
		{
			crit_proxy.value = value;
		}

		public function get armor():Number
		{
			return armor_proxy.value;
		}

		public function set armor(value:Number):void
		{
			armor_proxy.value = value;
		}

		public function get ack():Number
		{
			return ack_proxy.value;
		}

		public function set ack(value:Number):void
		{
			ack_proxy.value = value;
		}

		public function get speed():Number
		{
			return speed_proxy.value;
		}

		public function set speed(value:Number):void
		{
			speed_proxy.value = value;
		}

		public function get critFator():Number
		{
			return critFator_proxy.value;
		}

		public function set critFator(value:Number):void
		{
			critFator_proxy.value = value;
		}

		//buff...
		//各种技能，道具效果都被包装成一个Ibuffet接口
		public var buffers:Vector.<IBuffer>;

		public function BattleEntity()
		{
			hp_proxy = new PropertyProxy();
			ack_proxy = new PropertyProxy();
			armor_proxy = new PropertyProxy();
			crit_proxy = new PropertyProxy();
			critFator_proxy = new PropertyProxy();
			critFator_proxy.base = 1.5;
			dodge_proxy = new PropertyProxy();
			speed_proxy = new PropertyProxy();
			buffers = new Vector.<IBuffer>();
		}

		public function addBuffer(buffer:IBuffer, priority:int = int.MAX_VALUE):void
		{
			buffer.owner = this;
			if (priority == int.MAX_VALUE)
				buffers.push(buffer);
			else
				buffers.splice(priority, 0, buffer);
		}

		public function removeBuffer(buffer:IBuffer):IBuffer
		{
			var id:int = buffers.indexOf(buffer);
			if (id >= 0)
			{
				buffers.splice(id, 1);
				buffer.owner = null;
				return buffer;
			}
			else
				return null;
		}
	}
}
