package com.arm.herolot.works.controller
{
	import com.arm.herolot.modules.battle.battle.BattleEntity;
	import com.arm.herolot.works.HerolotWorker;
	import com.qzone.qfa.interfaces.IApplication;

	/**
	 * 模拟战斗的逻辑块
	 * @author hufan
	 */
	public class MockBattleWorker extends HerolotWorker
	{
		private var a:BattleEntity;
		private var b:BattleEntity;

		public function MockBattleWorker()
		{
			super(null);

			a = new BattleEntity();
			a.name = '胡帆';
			a.ack = 10;
			a.hp = 100;
			a.armor = 2;
			a.speed = 10;
			a.critFator = 1.5;
			a.crit = 30;
			a.dodge = 20;

			b = new BattleEntity();
			b.name = '李润发';
			b.ack = 10;
			b.hp = 100;
			b.armor = 4;
			b.crit = 20;
			b.critFator = 1.5;
			b.dodge = 20;
			b.speed = 10;
		}

		override public function start():void
		{
			while (a.hp > 0 && b.hp > 0) //都还活着。
				a.attack(b);
		}
	}
}
