package com.snsapp.charon
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Back;
	import com.qzone.utils.DisplayUtil;

	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;



	/**
	 * 登录
	 */
	[Event(name = "toLogin", type = "com.snsapp.charon.CharonView")]

	/**
	 * 忘记密码
	 */
	[Event(name = "forgetPsw", type = "com.snsapp.charon.CharonView")]


	/**
	 * 需要注册新用户
	 */
	[Event(name = "needSignUp", type = "com.snsapp.charon.CharonView")]

	/**
	 * 提交验证码
	 */
	[Event(name = "commitPicCode", type = "com.snsapp.charon.CharonView")]

	/**
	 * 自动登录状态改变
	 */
	[Event(name = "changeAutoLoginState", type = "com.snsapp.charon.CharonView")]

	/**
	 * 记住密码状态改变
	 */
	[Event(name = "changeRemPswState", type = "com.snsapp.charon.CharonView")]

	/**
	 * 改变uin
	 */
	[Event(name = "changeRemPswState", type = "com.snsapp.charon.CharonView")]

	/**
	 * 弹出选择uin面板
	 */
	[Event(name = "callOutSelectedPanel", type = "com.snsapp.charon.CharonView")]
	public class CharonView extends Sprite
	{
		//----------------------------------------------------------------------
		//
		//  Constants
		//
		//----------------------------------------------------------------------

		/**
		 * 目标屏幕尺寸
		 */
		static public const TARGET_SCREEN_RECT:Rectangle = new Rectangle(0, 0, 960, 640);

		static internal const TO_LOGIN:String = "toLogin";

		static internal const FORGET_PSW:String = "forgetPsw";

		static internal const NEED_SIGN_UP:String = "needSignUp";

		static internal const COMMIT_PIC_CODE:String = "commitPicCode";

		static internal const CHANGE_AUTOLOGIN_STATE:String = "changeAutoLoginState";

		static internal const CHANGE_REM_PSW_STATE:String = "changeRemPswState";

		static internal const CHANGE_UIN:String = "changeUin";

		static internal const SHOW_SELECTPANEL:String = "callOutSelectedPanel";

		//----------------------------------------------------------------------
		//
		//  Variables
		//
		//----------------------------------------------------------------------


		private var _ui:LoginViewUI;

		/**
		 * 验证码输入框
		 */
		private var _picCodeUI:PicCodeViewUI;

		/**
		 * 加载验证码图片的
		 */
		private var _picCodeLoader:Loader;

		/**
		 * 这个scale用于屏幕自适应
		 */
		private var _viewScale:Number;

		//----------------------------------------------------------------------
		//
		//  Constructor
		//
		//----------------------------------------------------------------------

		public function CharonView()
		{
			init();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}



		//----------------------------------------------------------------------
		//
		//  Public methods
		//
		//----------------------------------------------------------------------


		public function setUin(value:String):void
		{
			_ui.uin.text = value;
			_ui.psw.text = "";
			checkPrompt();
		}

		public function setSelectUins(values:Array):void
		{
			const len:int = values.length;
			var tf:TextField;
			for (var i:int = 0; i < len; i++)
			{
				tf = TextField(_ui.selectedUinPanel.getChildByName("uin" + i));

				if (tf == null)
					break;
				tf.text = values[i];
				if (values[i] == _ui.uin.text)
					tf.textColor = 0xFF6532;
				else
					tf.textColor = 0x591806;
			}
		}

		public function setPsw(value:String):void
		{
			_ui.psw.text = value;
			checkPrompt();
		}


		public function setAutoLogin(value:Boolean):void
		{
			_ui.autoLoginCheckBox.gotoAndStop(value ? "checkState" : "uncheckState");
		}


		public function setRemPsw(value:Boolean):void
		{
			_ui.rememberPSWCheckBox.gotoAndStop(value ? "checkState" : "uncheckState");
		}

		public function getRemPsw():Boolean
		{
			return _ui.rememberPSWCheckBox.currentFrameLabel == "checkState";
		}

		public function getAutoLogin():Boolean
		{
			return _ui.autoLoginCheckBox.currentFrameLabel == "checkState";
		}

		/**
		 * 显示验证码
		 * @param byteArray
		 *
		 */
		public function showPicCode(byteArray:ByteArray):void
		{
			if (_picCodeUI == null)
			{
				_picCodeUI = new PicCodeViewUI();
				_picCodeLoader = new Loader();
				_picCodeUI.scaleX = _viewScale, _picCodeUI.scaleY = _viewScale;
				_picCodeUI.picBox.addChild(_picCodeLoader);
				_picCodeUI.addEventListener(MouseEvent.MOUSE_DOWN, onSubmitPicCode);
			}
			_picCodeUI.x = _stageWidth / 2;
			stage.addChild(_picCodeUI);
			_picCodeLoader.unloadAndStop(true);
			_picCodeLoader.loadBytes(byteArray);

			function onSubmitPicCode(evt:MouseEvent):void
			{
				evt.stopImmediatePropagation(); //不希望这个事件冒泡。
				if (evt.target == _picCodeUI.submitBtn)
				{
					_picCodeLoader.unloadAndStop(true);
					if (_picCodeUI.parent)
						_picCodeUI.parent.removeChild(_picCodeUI);
					dispatchEvent(new CharonViewEvent(COMMIT_PIC_CODE, {"picCode": _picCodeUI.piccode.text}));
					_picCodeUI.piccode.text = "";
				}
			}
		}


		/**
		 * 控制登录框是否出现
		 * @param display
		 *
		 */
		public function controlDisplay(display:Boolean):void
		{
			if (display)
				TweenLite.to(_ui, 1, {y: 45 * _viewScale, "ease": Back.easeOut});
			else
				TweenLite.to(_ui, 0.5, {y: -_ui.height * 1.5, "ease": Back.easeIn});
		}


		public function finalize():void
		{
			_ui.psw.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDownAtPsw);
			_ui.login.removeEventListener(MouseEvent.CLICK, onClickLogin);
			_ui.autoLoginCheckBox.removeEventListener(MouseEvent.CLICK, onClickCheckBox);
			_ui.rememberPSWCheckBox.removeEventListener(MouseEvent.CLICK, onClickCheckBox);
			_ui.zc.removeEventListener(MouseEvent.CLICK, onClickSignUp);
			_ui.forgetPSWBtn.removeEventListener(MouseEvent.CLICK, onClickForgetPsw);
			_ui.selectedUinPanel.removeEventListener(MouseEvent.CLICK, onClickSelectUinPanel);

			_ui.uin.removeEventListener(FocusEvent.FOCUS_IN, checkPrompt);
			_ui.uin.removeEventListener(FocusEvent.FOCUS_OUT, checkPrompt);
			_ui.psw.removeEventListener(FocusEvent.FOCUS_OUT, checkPrompt);
			_ui.psw.removeEventListener(FocusEvent.FOCUS_IN, onFocusInPsw);

			DisplayUtil.removeAllChild(_ui);

			_ui = null;

			if (_picCodeLoader)
				_picCodeLoader.unloadAndStop();
			if (_picCodeUI)
				DisplayUtil.removeAllChild(_picCodeUI);
			_picCodeLoader = null;
			_picCodeUI = null;
		}

		//----------------------------------------------------------------------
		//
		//  Internal methods
		//
		//----------------------------------------------------------------------

		private function init():void
		{
			_ui = new LoginViewUI();
			_ui.psw.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownAtPsw);
			_ui.login.addEventListener(MouseEvent.CLICK, onClickLogin);
			_ui.autoLoginCheckBox.addEventListener(MouseEvent.CLICK, onClickCheckBox);
			_ui.rememberPSWCheckBox.addEventListener(MouseEvent.CLICK, onClickCheckBox);
			_ui.zc.addEventListener(MouseEvent.CLICK, onClickSignUp);
			_ui.forgetPSWBtn.addEventListener(MouseEvent.CLICK, onClickForgetPsw);
			_ui.selectedUinPanel.addEventListener(MouseEvent.CLICK, onClickSelectUinPanel);

			_ui.uin.addEventListener(FocusEvent.FOCUS_OUT, checkPrompt);
			_ui.uin.addEventListener(FocusEvent.FOCUS_IN, checkPrompt);
			_ui.psw.addEventListener(FocusEvent.FOCUS_OUT, checkPrompt);
			_ui.psw.addEventListener(FocusEvent.FOCUS_IN, onFocusInPsw);

			_ui.selectedUinPanel.gotoAndStop(1);
		}


		private function initPosAndSize():void
		{
			_ui.scaleX = _ui.scaleY = _viewScale;
			_ui.x = getScreenRectInLandScape(stage).width >> 1;
			_ui.y = -_ui.height * 1.5;
			addChild(_ui);

			controlDisplay(true);
		}


		private function getScreenRectInLandScape(stage:Stage):Rectangle
		{
			var rect:Rectangle;
			if (stage && stage.fullScreenSourceRect)
				return stage.fullScreenSourceRect.clone();

			var h:int = stage.fullScreenHeight;
			var w:int = stage.fullScreenWidth;
			if (h > w)
				return new Rectangle(0, 0, h, w);
			return new Rectangle(0, 0, w, h);
		}

		//----------------------------------------------------------------------
		//
		//  Event handlers
		//
		//----------------------------------------------------------------------


		/**
		 * 点击密码输入框,则清空密码.
		 * @param evt
		 *
		 */
		private function onFocusInPsw(evt:FocusEvent):void
		{
			_ui.psw.text = "";
			checkPrompt();
		}


		private function onClickLogin(evt:Event):void
		{
			dispatchEvent(new CharonViewEvent(CharonView.TO_LOGIN, {"uin": _ui.uin.text, "psw": _ui.psw.text}));
		}


		private function onClickCheckBox(evt:MouseEvent):void
		{
			var type:String;
			var state:String;
			if (evt.currentTarget == _ui.autoLoginCheckBox)
			{
				type = CHANGE_AUTOLOGIN_STATE;
				state = _ui.autoLoginCheckBox.currentLabel == "checkState" ? "uncheckState" : "checkState";
				_ui.autoLoginCheckBox.gotoAndStop(state);

				//如果选中了“自动登录”，记住密码也要选中
				if (state == "checkState")
				{
					setRemPsw(true);
					dispatchEvent(new CharonViewEvent(CHANGE_REM_PSW_STATE, {"state": 1}));
				}

			}
			else if (evt.currentTarget == _ui.rememberPSWCheckBox)
			{
				type = CHANGE_REM_PSW_STATE;
				state = _ui.rememberPSWCheckBox.currentLabel == "checkState" ? "uncheckState" : "checkState";
				_ui.rememberPSWCheckBox.gotoAndStop(state);


				//如果取消了“记住密码”，则“自动登陆”也取消
				if (state == "uncheckState")
				{
					setAutoLogin(false);
					dispatchEvent(new CharonViewEvent(CHANGE_AUTOLOGIN_STATE, {"state": 0}));
				}
			}

			dispatchEvent(new CharonViewEvent(type, {"state": state == "checkState" ? 1 : 0}));
		}


		private function onClickSignUp(evt:MouseEvent):void
		{
			dispatchEvent(new CharonViewEvent(NEED_SIGN_UP, null));
		}


		private function onClickForgetPsw(evt:MouseEvent):void
		{
			dispatchEvent(new CharonViewEvent(FORGET_PSW, null));
		}

		private function onClickSelectUinPanel(evt:MouseEvent):void
		{
			if (evt.target == _ui.selectedUinPanel.btnCallOut)
			{
				selectedPanelVisble = !selectedPanelVisble;
				return;
			}

			var targetName:String = evt.target.name;
			if (targetName.indexOf('btns') == 0)
			{
				try
				{
					var id:int = int(targetName.charAt(targetName.length - 1));
					var uin:String = TextField(_ui.selectedUinPanel.getChildByName("uin" + id)).text;
					dispatchEvent(new CharonViewEvent(CHANGE_UIN, uin));
					selectedPanelVisble = false;
				}
				catch (error:Error)
				{
				}
			}
		}

		private function get selectedPanelVisble():Boolean
		{
			return _ui.selectedUinPanel.currentFrame == 2;
		}

		private function set selectedPanelVisble(value:Boolean):void
		{
			if (selectedPanelVisble == value)
				return;
			if (value)
			{
				stage.addEventListener(MouseEvent.CLICK, onClickStage);
				_ui.selectedUinPanel.gotoAndStop(2);
				dispatchEvent(new CharonViewEvent(SHOW_SELECTPANEL, null));
			}
			else
			{
				stage.removeEventListener(MouseEvent.CLICK, onClickStage);
				_ui.selectedUinPanel.gotoAndStop(1);
			}
		}

		private function onClickStage(e:MouseEvent):void
		{
			trace("click stage");
			var test:DisplayObject = e.target as DisplayObject;
			var flag:Boolean;
			do
			{
				if (test == _ui.selectedUinPanel)
				{
					flag = true;
					break;
				}
				else
					test = test.parent;
			} while (test)

			if (!flag)
				this.selectedPanelVisble = false;
		}


		private function onKeyDownAtPsw(evt:KeyboardEvent):void
		{
			if (evt.keyCode == Keyboard.ENTER)
			{
				_ui.login.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			}
		}


		private function checkPrompt(evt:Event = null):void
		{
			var flg:Boolean;
			if (_ui != null)
			{
				flg = _ui.uin.text == "";
				flg &&= stage == null || stage.focus != _ui.uin;
				_ui.uinPromot.visible = flg;

				flg = _ui.psw.text == "";
				flg &&= stage == null || stage.focus != _ui.psw;
				_ui.pswPromot.visible = flg;
			}
		}


		private function onAddedToStage(evt:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			var stageRect:Rectangle = getScreenRectInLandScape(stage);
			var vScale:Number = stageRect.height / TARGET_SCREEN_RECT.height;
			var hScale:Number = stageRect.width / TARGET_SCREEN_RECT.width;
			_stageWidth = stageRect.width, _stageHeight = stageRect.height;
			_viewScale = Math.min(vScale, hScale);

			initPosAndSize();
		}

		private var _stageWidth:Number;
		private var _stageHeight:Number;
	}
}
