package test.arm.herolot
{
	import asunit.framework.TestSuite;

	import test.arm.herolot.model.battle.MathCmdTest;

	public class HerolotTestSuite extends TestSuite
	{
		public function HerolotTestSuite()
		{
			super();
			addTest(new MathCmdTest);
		}
	}
}
