package
{
	import com.arm.herolot.services.utils.Csv2asCommand;
	
	import flash.display.Sprite;

	public class herolot_proj_test extends Sprite
	{
		public function herolot_proj_test()
		{
			super();
			stage.scaleMode = "noScale";
			stage.align = "topLeft";

//			trace('o.ack = t.ack*3 + 1-5'.replace(/\-/g, '+-'));
//			var o:BattleEntity = new BattleEntity();
//			o.ack = 10, o.armor = 2, o.hp = 100, o.critFator = 1.5, o.speed = 10, o.dodge = 10, o.crit = 20;
//			var t:BattleEntity = new BattleEntity();
//			t.ack = 10, t.armor = 2, t.hp = 100, t.critFator = 1.5, t.speed = 10, t.dodge = 10, t.crit = 30;
//
//			EnhanceCapacityBuffer.excuteMathCmd('o.ack = o.ack + 1', o, t, null);
//			return;
//			var testRunner:TestRunner = new TestRunner();
//			this.addChild(testRunner);
//			testRunner.start(HerolotTestSuite);
			
			new Csv2asCommand().start();
		}
	}
}
