package com.arm.herolot
{
	import com.arm.herolot.model.config.AppConfig;
	import com.arm.herolot.model.config.AppConfigModel;
	import com.arm.herolot.model.data.model.GameDataModel;
	import com.arm.herolot.modules.battle.IBattleApi;
	import com.arm.herolot.modules.battle.battle.hero.HeroModel;
	import com.arm.herolot.services.utils.EmbedFont;
	import com.arm.herolot.works.startup.StartupGameWorkers;
	import com.qzone.qfa.control.Application;
	import com.qzone.qfa.debug.DarkFog;
	import com.qzone.qfa.debug.Debugger;
	import com.qzone.qfa.debug.IConsoleWindow;
	import com.qzone.qfa.debug.Stats;
	import com.qzone.qfa.managers.resource.ResourceLoader;
	import com.qzone.qfa.utils.CommonUtil;
	import com.snsapp.mobile.StageInstance;
	import com.snsapp.mobile.utils.Cookies;
	import com.snsapp.mobile.utils.MobileScreenUtil;
	import com.snsapp.starling.texture.TextureLoader;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.media.AudioPlaybackMode;
	import flash.media.SoundMixer;
	import flash.text.Font;

	/**
	 * 游戏的主类
	 * @author hufan
	 */
	public class HerolotApplication extends Application
	{
		public static var instance:HerolotApplication;

		private var _debugLayer:Sprite;
		/**
		 *游戏数据模型 
		 */		
		public var gameDataModel:GameDataModel;

		public function HerolotApplication(name:String = "mobile_qfa")
		{
			super(name);
			instance = this;
		}

		override public function startup(root:Sprite):void
		{
//			var obj:Object = EnhanceCapacityBuffer.PropertyProxyReg.exec('t.a*&t.a2');
//			var obj2:Object = EnhanceCapacityBuffer.PropertyProxyReg.exec('tt.0111');
////			trace(parseFloat('-1'));
//			return;
			_appStage = root;
			buildLayers();
			initStatic();
			new StartupGameWorkers(this).start();
		}


		private function buildLayers():void
		{
			_debugLayer = new Sprite;
			_debugLayer.name = "debugLayer";
			_appStage.addChild(_debugLayer);
		}

		private function createStatus():void
		{
			var fps:Stats = new Stats({stage: StageInstance.stage})
			fps.y = 100;
			_debugLayer.addChild(fps);
			var logUI:IConsoleWindow = new DarkFog();
			_debugLayer.addChild(logUI as DisplayObject);
			Debugger.init(StageInstance.stage, new Date().time);
			Debugger.setUI(logUI);
		}

		private function initStatic():void
		{
			gameDataModel = new GameDataModel();
			StageInstance.stage = this._appStage.stage;
			AppConfig = new AppConfigModel(this);
			Cookies.initialize(name);
			Debugger.init(StageInstance.stage, new Date().time);
			if (Consts.DEBUG)
				createStatus();
			SoundMixer.audioPlaybackMode = AudioPlaybackMode.AMBIENT; //硬件静音
			var version:String = Cookies.getObject(Consts.SO_CLIENT_VERSION) as String;
			Vars.isNewApp = version == null ? true : CommonUtil.compareVersionLabel(version, Consts.VERSION) < 0; //是否是新安装的应用。

			//屏幕自适应参数初始化逻辑。
			const rect:Rectangle = MobileScreenUtil.getScreenRectInLandScape(StageInstance.stage);
			Vars.stageHeight = rect.height;
			Vars.stageWidth = rect.width;
			const vScale:Number = rect.height / Consts.IP4.height;
			const hScale:Number = rect.width / Consts.IP4.width;
			const maxScale:Number = vScale > hScale ? vScale : hScale;
			Vars.nativeScreenScale = maxScale;
			if (Vars.nativeScreenScale > 1)
			{
				Vars.starlingScreenScale = 1;
				Vars.sStageHeight = Vars.stageHeight / Vars.nativeScreenScale;
				Vars.sStageWidth = Vars.stageWidth / Vars.nativeScreenScale;
			}
			else
			{
				Vars.starlingScreenScale = Vars.nativeScreenScale;
				Vars.sStageHeight = Vars.stageHeight;
				Vars.sStageWidth = Vars.stageWidth;
			}

			Font.registerFont(KAI);
			EmbedFont.font = new KAI();

			_rsLoader = new ResourceLoader(Consts.RSL_VERSION);
			_textureLoader = new TextureLoader(this, Vars.starlingScreenScale);
			setupRemoteNotificationService();
		}

		/**
		 * 玩家用某个英雄，开始战斗。。。。
		 * @param hero
		 */
		public function startBattle(hero:HeroModel):void
		{
//			this.unloadModule(Consts.MODULE_LAUNCH);
//			this.loadModule(Consts.MODULE_BATTLE);
//			var battleM:IBattleApi = getModuleAPI(Consts.MODULE_BATTLE) as IBattleApi;
//			battleM.startBattle(hero);
		}

		public function gameOver():void
		{
//			this.unloadModule(Consts.MODULE_BATTLE);
//			this.loadModule(Consts.MODULE_LAUNCH);
		}

		public function loadPlayerData(complete:Function):void
		{
//			if (_player == null)
//			{
//				var obj:Object = Cookies.getObject(SO_PLAYER);
//				obj = {level: 100, kill: 200, money: 20000};
//				_player = new GameData(obj);
//			}
//			complete(_player);
		}
	}
}
