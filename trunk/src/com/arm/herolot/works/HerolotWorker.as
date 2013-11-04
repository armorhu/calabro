package com.arm.herolot.works
{
	import com.arm.herolot.HerolotApplication;
	import com.qzone.qfa.interfaces.IApplication;
	import com.snsapp.mobile.mananger.workflow.SimpleWork;

	public class HerolotWorker extends SimpleWork
	{
		public function HerolotWorker(app:IApplication)
		{
			super(app);
		}

		protected function get app():HerolotApplication
		{
			return _app as HerolotApplication;
		}
	}
}
