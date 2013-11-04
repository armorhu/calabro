package com.arm.herolot.modules.launch
{
	import com.arm.herolot.modules.HerolotModule;

	public class ModuleLaunch extends HerolotModule implements ILaunchApi
	{
		private var _controller:LaunchController;

		public function ModuleLaunch(name:String)
		{
			super(name);
		}

		override protected function initController():void
		{
			_controller = new LaunchController(this);
		}

		override public function destroy():void
		{
			_controller.dispose();
			_controller = null;
			super.destroy();
		}
	}
}
