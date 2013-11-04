package unittest
{
	import asunit.framework.TestSuite;

	import unittest.com.snsapp.mobile.utils.URLUtilTest;

	public class MqfaTestSuite extends TestSuite
	{
		public function MqfaTestSuite()
		{
			super();
			addTest(new URLUtilTest);
		}
	}
}
