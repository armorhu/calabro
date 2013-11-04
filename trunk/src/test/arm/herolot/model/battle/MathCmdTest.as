package test.arm.herolot.model.battle
{
	import asunit.framework.TestCase;
	
	import com.arm.herolot.modules.battle.battle.BattleEntity;
	import com.arm.herolot.modules.battle.battle.buff.implement.EnhanceCapacityBuffer;

	/**
	 * 数学命令行单元测试。
	 */
	public class MathCmdTest extends TestCase
	{
		public function MathCmdTest(testMethod:String = null)
		{
			super(testMethod);
		}

		public function test1():void
		{
			var o:BattleEntity = new BattleEntity();
			o.ack = 10, o.armor = 2, o.hp = 100, o.critFator = 1.5, o.speed = 10, o.dodge = 10, o.crit = 20;
			var t:BattleEntity = new BattleEntity();
			t.ack = 5, t.armor = 2, t.hp = 100, t.critFator = 1.5, t.speed = 10, t.dodge = 10, t.crit = 30;

			EnhanceCapacityBuffer.excuteMathCmd('o.ack = o.ack + 1', o, t, null);
			assertEquals(11, o.ack);
			EnhanceCapacityBuffer.excuteMathCmd('o.ack = t.ack + 1', o, t, null);
			assertEquals(6, o.ack);
			EnhanceCapacityBuffer.excuteMathCmd('o.ack = t.ack*3 + 1', o, t, null);
			assertEquals(16, o.ack);
			EnhanceCapacityBuffer.excuteMathCmd('o.ack = t.ack*3 + 1-5', o, t, null);
			assertEquals(11, o.ack);
			EnhanceCapacityBuffer.excuteMathCmd('o.ack = 3 + t.ack * 3 - 2 * o.ack + t.ack', o, t, null);
			assertEquals(1, o.ack);
			EnhanceCapacityBuffer.excuteMathCmd('o.php.base = 3 +o.php.base', o, t, null);
			assertEquals(103, o.php.base);
			EnhanceCapacityBuffer.excuteMathCmd('o.php.base += 3 ', o, t, null);
			assertEquals(106, o.php.base);
			EnhanceCapacityBuffer.excuteMathCmd('php.base += 3 ', o, t, null);
			assertEquals(109, o.php.base);
			EnhanceCapacityBuffer.excuteMathCmd('hp += 3 ', o, t, null);
			assertEquals(112, o.php.base);
			EnhanceCapacityBuffer.excuteMathCmd('hp += -3 ', o, t, null);
			assertEquals(109, o.php.base);
			EnhanceCapacityBuffer.excuteMathCmd('hp -= -3 ', o, t, null);
			assertEquals(112, o.php.base);
			EnhanceCapacityBuffer.excuteMathCmd('hp /= 2 ', o, t, null);
			assertEquals(56, o.php.base);
			EnhanceCapacityBuffer.excuteMathCmd('hp *= 2 ', o, t, null);
			assertEquals(112, o.php.base);
		}

		public function test2():void
		{
			var o:BattleEntity = new BattleEntity();
			o.ack = 10, o.armor = 2, o.hp = 100, o.critFator = 1.5, o.speed = 10, o.dodge = 10, o.crit = 20;
			var t:BattleEntity = new BattleEntity();
			t.ack = 5, t.armor = 2, t.hp = 100, t.critFator = 1.5, t.speed = 10, t.dodge = 10, t.crit = 30;

			assertTrue(EnhanceCapacityBuffer.isTrue('o.ack - 5 == t.ack', o, t));
			assertTrue(EnhanceCapacityBuffer.isTrue('o.ack  != t.ack', o, t));
			assertTrue(EnhanceCapacityBuffer.isTrue('o.ack  > t.ack', o, t));
			assertTrue(EnhanceCapacityBuffer.isTrue('o.ack  >= t.ack', o, t));
			assertFalse(EnhanceCapacityBuffer.isTrue('o.ack  < t.ack', o, t));
			assertFalse(EnhanceCapacityBuffer.isTrue('o.ack  <= t.ack', o, t));
		}

		public function test3():void
		{
			assertEquals(EnhanceCapacityBuffer.Decision, EnhanceCapacityBuffer.getExpressionType('t.ethnicity==1'));
			assertEquals(EnhanceCapacityBuffer.Assignment, EnhanceCapacityBuffer.getExpressionType('t.ethnicity=1'));
		}

	}
}
