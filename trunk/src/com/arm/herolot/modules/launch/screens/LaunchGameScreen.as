package com.arm.herolot.modules.launch.screens
{
	import com.arm.herolot.model.data.database.GameData;
	import com.arm.herolot.modules.launch.LaunchModel;
	import com.arm.herolot.modules.launch.texture.LaunchTexture;
	import com.arm.herolot.services.conf.Language;
	import com.snsapp.starling.display.Button;
	
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.VAlign;

	/**
	 * 进入游戏后的第一个视图。
	 * 启动游戏的入口
	 * @author hufan
	 */
	public class LaunchGameScreen extends BaseScreen
	{
		private var _level:starling.text.TextField; //打到第几关
		private var _killPoint:starling.text.TextField; //杀了多少个敌人
		private var _btnStart:Button; //开始按钮

		public function LaunchGameScreen()
		{
			super();
		}

		protected override function screen_addedToStageHandler(event:starling.events.Event):void
		{
			if (this.isInitialized)
				requestData(LaunchModel.PLAYER_DATA);
		}

		protected override function initialize():void
		{
			super.initialize();
			addChildImage(LaunchTexture.MAIN_BG);
			addTextField(Language.getTextById('10001'), 120, 32, 8, 120);
			addTextField(Language.getTextById('10002'), 120, 32, 8, 180);
			addChildImage(LaunchTexture.TF_BG, 145, 120);
			addChildImage(LaunchTexture.TF_BG, 145, 180);
			_level = addTextField('100', 170, 32, 150, 121);
			_level.vAlign = VAlign.CENTER;
			_killPoint = addTextField('10000000', 170, 32, 150, 181);
			_killPoint.vAlign = VAlign.CENTER;
			addChildBtn(LaunchTexture.START_BTN, triggerBtnStart, 360, 140);
			requestData(LaunchModel.PLAYER_DATA);
		}

		private function triggerBtnStart(e:starling.events.Event):void
		{
			dispatchEventWith(Event.COMPLETE);
//			new HandleMonsterPNG().start();
//			if (_mock == null)
//			_mock = new MockBattleWorker();
//			_mock.start();
		}

		public override function setData(type:String, data:*):void
		{
			if (type == LaunchModel.PLAYER_DATA)
			{
				var p:GameData = data as GameData;
				_level.text = p.maxFloor.toString();
				_killPoint.text = p.kills.toString();
			}
		}

//		public function setPlayerData(p:Player):void
//		{
//			_level.text = p.level.toString();
//			_killPoint.text = p.kill.toString();
//		}
	}
}
