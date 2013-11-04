package com.arm.herolot.modules.launch
{
	import com.arm.herolot.Consts;
	import com.arm.herolot.Vars;
	import com.arm.herolot.modules.launch.screens.HeroScreen;
	import com.arm.herolot.modules.launch.screens.LaunchGameScreen;
	import com.arm.herolot.modules.launch.texture.LaunchTexture;
	import com.snsapp.mobile.utils.MobileSystemUtil;
	import com.snsapp.starling.texture.ClientTextureParams;
	
	import feathers.controls.ScreenNavigator;
	import feathers.controls.ScreenNavigatorItem;
	import feathers.motion.transitions.ScreenSlidingStackTransitionManager;
	
	import starling.events.Event;

	public class LaunchView extends ScreenNavigator
	{
		public static const LAUNCH:String = 'launch';
		public static const HERO:String = 'hero';
		public static const SHOP:String = 'shop';

		public static const REQUEST_DATA:String = 'request_data';
		public static const REQUEST_UPGRADE_SKILL:String = 'request_upgrade_SKILL';
		public static const START_BATTLE:String = 'start_battle';

		private var _texture:LaunchTexture;
		private var _controller:LaunchController;
		private var _transitionManager:ScreenSlidingStackTransitionManager;

		public function LaunchView(controller:LaunchController)
		{
			super();
			_controller = controller;
		}

		public function show(complete:Function):void
		{
			var clientParams:ClientTextureParams = new ClientTextureParams();
			clientParams.deviceDefalutLevelConfig = new XML;
			clientParams.clientVersion = Consts.VERSION;
			clientParams.deviceName = _controller.module.app.deviceInfo.deviceName;
			clientParams.os = MobileSystemUtil.os;
			clientParams.screenScale = Vars.starlingScreenScale;
			clientParams.textureVersion = "1";
			clientParams.resouceSwf = Consts.RES_LAUNCH;
			_texture = new LaunchTexture(_controller.module.app);
			_texture.setup(clientParams, onComplete);
			_transitionManager = new ScreenSlidingStackTransitionManager(this);
			_transitionManager.duration = 0.4;

			function onComplete(suc:Boolean):void
			{
				if (suc == false)
				{
					_texture.dispose();
					_texture = null;
					complete(false);
				}
				else
				{
					addScreen(LAUNCH, new ScreenNavigatorItem(new LaunchGameScreen, //
						{complete: HERO, request_data: transmitEvent}));
					addScreen(HERO, new ScreenNavigatorItem(new HeroScreen, //
						{start_battle: transmitEvent, back: LAUNCH, request_data: transmitEvent}));
//					addScreen(SHOP, new ScreenNavigatorItem(new ShopScreen, //
//						{complete: startBattle, back: LAUNCH, request_data: transmitEvent}));
					showScreen(LAUNCH);
					complete(true);
				}
			}
		}

		/**
		 * 转发MainMenuScreen的事件。
		 */
		private function transmitEvent(e:Event):void
		{
			trace("transmitEvent(" + e.type, e.data + ")")
			dispatchEventWith(e.type, false, e.data);
		}

		public function get texture():LaunchTexture
		{
			return _texture;
		}

		public function get scale():Number
		{
			return Vars.starlingScreenScale;
		}

		public override function dispose():void
		{
			super.dispose();
			_texture.dispose();
			_texture = null;
			_controller = null;
			_transitionManager.clearStack();
			_transitionManager = null;
		}
	}
}
