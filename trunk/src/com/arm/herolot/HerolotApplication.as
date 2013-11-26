package com.arm.herolot
{
	import com.arm.herolot.model.config.AppConfig;
	import com.arm.herolot.model.config.AppConfigModel;
	import com.arm.herolot.model.data.model.GameDataModel;
	import com.arm.herolot.modules.battle.IBattleApi;
	import com.arm.herolot.modules.battle.battle.hero.HeroModel;
	import com.arm.herolot.services.notice.GameNoticeManager;
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
	import com.snsapp.mobile.utils.MessageBoxHelper;
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
		
		/**
		 *游戏提醒 
		 */		
		public var noticeManager:GameNoticeManager;
		
		
		private var _msgBox:MessageBoxHelper
		
		public function HerolotApplication(name:String = "mobile_qfa")
		{
			super(name);
			instance = this;
		}

		override public function startup(root:Sprite):void
		{
			_appStage = root;
			buildLayers();
			initStatic();
			new StartupGameWorkers(this).start();
		}


		private function buildLayers():void
		{
			var s:Sprite;
			
			s = new Sprite();
			s.name = 'dialogLayer';
			_appStage.addChild(s);
			
			s = new Sprite();
			s.name = 'tipLayer';
			_appStage.addChild(s);
			
			
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
			
			_msgBox = new MessageBoxHelper(this,EmbedFont.fontName,stageWidth,stageHeight,null,null);
			noticeManager = new GameNoticeManager(appStage.getChildByName('tipLayer') as Sprite);
			
			_rsLoader = new ResourceLoader(Consts.RSL_VERSION);
			_textureLoader = new TextureLoader(this, Vars.starlingScreenScale);
			setupRemoteNotificationService();
		}
		
		public function get stageWidth():Number{
			return Vars.stageWidth;
		}
		public function get stageHeight():Number{
			return Vars.stageHeight;
		}

		/**
		 * 玩家用某个英雄，开始战斗。。。。
		 * @param hero
		 */
		public function startBattle(hero:HeroModel):void
		{
		}

		public function gameOver():void
		{
		}

		public function loadPlayerData(complete:Function):void
		{
		}
	}
}
