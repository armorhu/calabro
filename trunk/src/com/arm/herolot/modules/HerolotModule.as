package com.arm.herolot.modules
{
	import com.arm.herolot.HerolotApplication;
	import com.qzone.qfa.control.module.IModuleAPI;
	import com.qzone.qfa.control.module.Module;

	public class HerolotModule extends Module implements IModuleAPI
	{
		public function HerolotModule(name:String)
		{
			super(name);
		}

		public function get app():HerolotApplication
		{
			return _app as HerolotApplication;
		}

		public override function get mouduleAPI():IModuleAPI
		{
			return this;
		}
	}
}
