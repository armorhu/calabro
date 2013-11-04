package com.snsapp.charon
{
	import com.adobe.utils.StringUtil;
	import com.snsapp.charon.wtlogin.WtLogin;
	import com.snsapp.charon.wtlogin.WtLoginReplayCode;
	import com.snsapp.charon.wtlogin.WtloginEvent;
	import com.snsapp.mobile.view.CustomWebView;

	import flash.display.Stage;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;



	/**
	 *
	 * @author mobiuschen
	 *
	 */
	public class CharonContrller
	{

		//----------------------------------------------------------------------
		//
		//  Constructor
		//
		//----------------------------------------------------------------------

		public function CharonContrller(useAutoLogin:Boolean, charon:Charon)
		{
			_useAutoLogin = useAutoLogin;
			_charon = charon;
		}


		//----------------------------------------------------------------------
		//
		//  Varialbes
		//
		//----------------------------------------------------------------------


		private var _charon:Charon;

		/**
		 *
		 */
		private var _wLogin:WtLogin;

		/**
		 * 计时时间戳
		 */
		private var _timestamp:uint;

		/**
		 * 登录成功或失败，都将结果放到这个Object中，发送出去。
		 */
		private var _desc:LoginDesc;

		private var _session_a2:String;

		private var _loginView:CharonView;


		/**
		 * 只有在第一次进登录界面的时候，才使用自动登录.
		 * 后续使用退出等功能来到登录界面，则忽略自动登录.
		 * 这个值就是用来控制这个的.
		 */
		private var _useAutoLogin:Boolean = true;


		/**
		 * 是否使用a2登录
		 */
		private var _a2Login:Boolean;


		/**
		 * 获取skey的重试计数
		 */
		private var _getSkeyRetryCount:int = 3;


		//----------------------------------------------------------------------
		//
		//  主流程相关方法
		//
		//----------------------------------------------------------------------

		public function initialze():void
		{
			_wLogin = new WtLogin(_charon.appid, _charon.sub_appid);
			var so:Object = _wLogin.so;
			_wLogin.addEventListener(WtLogin.GET_IP_SIG, onGetIpSigComplete);
			_wLogin.addEventListener(WtloginEvent.LOGIN_RESULT, handleLoginResult);

			initView();
			var flg:Boolean = so.defaultUIN != undefined;
			var loginInfo:Object = _wLogin.getUserLoginInfoByUin(so.defaultUIN);
			flg &&= loginInfo && loginInfo.session_a2;
			flg &&= so.rememberPSW != undefined && so.rememberPSW > 0;
			flg &&= so.autoLogin != null && so.autoLogin > 0;
			flg &&= _useAutoLogin;
			if (flg)
			{
				_loginView.visible = false;
				//自动登录
				//这里要setTimeout，因为这里跟构造函数是在同一个程序栈里，如果不setTimeout，外部来不及监听事件
				setTimeout(startWLogin, 1000, so.defaultUIN, loginInfo.session_a2);
			}
		}


		public function finalize():void
		{
			_wLogin.removeEventListener(WtLogin.GET_IP_SIG, onGetIpSigComplete);
			_wLogin.removeEventListener(WtloginEvent.LOGIN_RESULT, handleLoginResult);
			_wLogin = null;

			_desc = null;
			_loginView.removeEventListener(CharonView.TO_LOGIN, onToLogin);
			_loginView.removeEventListener(CharonView.FORGET_PSW, onForgetPsw);
			_loginView.removeEventListener(CharonView.NEED_SIGN_UP, onToSignUp);
			_loginView.removeEventListener(CharonView.CHANGE_AUTOLOGIN_STATE, onChangeAutoLoginState);
			_loginView.removeEventListener(CharonView.CHANGE_REM_PSW_STATE, onChangeRemPswState);
			_loginView.removeEventListener(CharonView.COMMIT_PIC_CODE, onCommitPicCode);

			_charon.removeChild(_loginView);
			_charon = null;

			_loginView.finalize();
			_loginView = null;
		}


		private function initView():void
		{
			_loginView = new CharonView();
			_loginView.addEventListener(CharonView.TO_LOGIN, onToLogin);
			_loginView.addEventListener(CharonView.FORGET_PSW, onForgetPsw);
			_loginView.addEventListener(CharonView.NEED_SIGN_UP, onToSignUp);
			_loginView.addEventListener(CharonView.CHANGE_AUTOLOGIN_STATE, onChangeAutoLoginState);
			_loginView.addEventListener(CharonView.CHANGE_REM_PSW_STATE, onChangeRemPswState);
			_loginView.addEventListener(CharonView.COMMIT_PIC_CODE, onCommitPicCode);
			_loginView.addEventListener(CharonView.SHOW_SELECTPANEL, onShowSelectPanel);
			_loginView.addEventListener(CharonView.CHANGE_UIN, onChangeUin);

			_loginView.setRemPsw(false);
			_loginView.setAutoLogin(false);
			var so:Object = _wLogin.so;
			if (so.rememberPSW != undefined && so.rememberPSW > 0)
			{
				_loginView.setRemPsw(true);
				if (so.autoLogin > 0)
					_loginView.setAutoLogin(true);
			}

			if (so.defaultUIN != undefined)
				setUin(so.defaultUIN);
			_charon.addChild(_loginView);
		}

		private function setUin(uin:String):void
		{
			_loginView.setUin(uin);

			//有本地登录态尝试A2登录
			//是否有记住密码
			if (_loginView.getRemPsw())
			{
				var obj:Object = _wLogin.getUserLoginInfoByUin(uin);
				if (obj && obj.session_a2)
				{
					_session_a2 = obj.session_a2;
					_loginView.setPsw(obj.session_a2);
				}
			}
		}


		/**
		 * 登录失败, 流程最终出口.
		 * @param code
		 * @param msg
		 *
		 */
		private function loginFailed(code:int, msg:String):void
		{
			var newDesc:LoginDesc = new LoginDesc();
			newDesc.errCode = code;
			newDesc.errMsg = msg;
			newDesc.uin = _desc == null ? "" : _desc.uin;
			_desc = newDesc;

			_loginView.visible = true;
			_loginView.controlDisplay(true);

			var progress:LoginProgress = new LoginProgress(LoginProgress.LOGIN_COMPLETE, "登录失败！", _desc);
			_charon.dispatchEvent(new CharonEvent(CharonEvent.LOGIN_PROGRESS, progress));
		}

		public function showLoginView():void
		{
			_loginView.visible = true;
			_loginView.controlDisplay(true);
		}

		/**
		 * 登录成功, 流程最终出口.
		 *
		 */
		private function loginSuccess():void
		{
//			_loginView.visible = true;
//			_loginView.controlDisplay(true);
			_desc.errCode = 0;
			var progress:LoginProgress = new LoginProgress(LoginProgress.LOGIN_COMPLETE, "登录成功！", _desc);
			_charon.dispatchEvent(new CharonEvent(CharonEvent.LOGIN_PROGRESS, progress));
		}


		//----------------------------------------------------------------------
		//
		//  WLogin登录的逻辑块
		//
		//----------------------------------------------------------------------


		/**
		 *
		 * @param uin
		 * @param pswORa2
		 *
		 */

		private var start:int;

		private function startWLogin(uin:String, psw:String):void
		{

			start = getTimer();
			_desc = new LoginDesc();
			_desc.uin = uin;
			_a2Login = psw == _session_a2;
			_loginView.controlDisplay(false);
			var progress:LoginProgress = new LoginProgress(LoginProgress.START_LOGIN, "正在登录...", _desc);
			_charon.dispatchEvent(new CharonEvent(CharonEvent.LOGIN_PROGRESS, progress));
			_wLogin.getIpSig(uin, psw);
		}


		private function onGetIpSigComplete(evt:Event):void
		{
			_timestamp = getTimer();
			if (_a2Login)
			{
				/**SO中有a2票据,尝试使用A2登录**/
				_wLogin.getA2Login();
			}
			else
			{
				/**没有a2票据,使用帐号密码正常登录**/
				_wLogin.getLogin();
			}
		}


		protected function handleLoginResult(evt:WtloginEvent):void
		{
			if (evt.replayCode == WtLoginReplayCode.LOGIN_SUCCESS)
			{
				_charon.recordOZ(true, getTimer() - start, 0);
				_desc.nickName = _wLogin.nickName;
				var uin:String = _wLogin.uin;
				while (uin.length < 10)
					uin = "0" + uin;
				_desc.uin = uin;
				_desc.skey = _wLogin.Skey;
				_desc.g_tk = calcGTK(_desc.skey);
				_desc.cookies = "skey=" + _desc.skey + "; uin=o" + uin;
				loginSuccess();
			}
			else
			{
				_charon.recordOZ(false, getTimer() - start, evt.replayCode);
				if (evt.replayCode == WtLoginReplayCode.ERROR_PICCODE)
					onErrorPiccode(_wLogin.picData);
				else
				{
					loginFailed(evt.replayCode, evt.replayMsg);
					if (evt.replayCode == WtLoginReplayCode.A2_LOGIN_ERROR)
						_loginView.setPsw("");
				}
			}

		}


		private function onErrorPiccode(picData:ByteArray):void
		{
			var p:LoginProgress = new LoginProgress(LoginProgress.NEED_PIC_CODE, "请输入验证码.", null);
			_charon.dispatchEvent(new CharonEvent(CharonEvent.LOGIN_PROGRESS, p));
			_loginView.showPicCode(picData);
		}

		//----------------------------------------------------------------------
		//
		//  获取Skey的逻辑块
		//
		//----------------------------------------------------------------------
//
//		/**
//		 * 获取skey的入口方法.
//		 * 登录成功后并不意味着工作结束，还需要取到skey
//		 * 需要使用wlogin的带登录态跳转请求(jumpToQzone方法所构造的url)
//		 * 该请求的回包中会带有若干set-cookie字段,这些set-cookie字段保证了
//		 * 本次游戏中所有的与后台http通信时一些必要的cookie都会被带上,其中最重要的cookie是skey
//		 *
//		 */
//		private function getSKey(uin:String, clientkey:String):void
//		{
//			_getSkeyRetryCount--;
//
//			_timestamp = getTimer();
//
//			const jumpToQZoneURL:String = "http://ptlogin2.qq.com/jump?keyindex=19&" + "clientuin=" + uin + "&clientkey=" + clientkey + "&u1=http://qzone.qq.com";
//
//			var loader:URLLoader = new URLLoader();
//			var req:URLRequest = new URLRequest(jumpToQZoneURL);
//			//不跳转,因为cookie信息都在302的回包中
//			req.followRedirects = false;
//			/*
//			 这句代码异常重要
//			 如果不手动伪造Referer字段,该跳转的回包中是不会有set-cookie字段的！！！！
//			*/
//			req.requestHeaders.push(new URLRequestHeader("Referer", "http://qzone.qq.com"));
//
//			loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onHttpStatus, false, 0, true);
//			loader.addEventListener(IOErrorEvent.IO_ERROR, onError, false, 0, true);
//			loader.load(req);
//
//			function onHttpStatus(evt:HTTPStatusEvent):void
//			{
//				loader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onHttpStatus);
//				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
//
//				if (evt.status != 302 && evt.status != 200)
//				{
//					if (_getSkeyRetryCount > 0)
//						setTimeout(getSKey, 10, uin, clientkey);
//					else
//						loginFailed(ReplayCodeConfig.GET_SKEY_ERROR, "无法获取Cookies！");
//					return;
//				}
//
//				_desc.cookies = handleSKeyResponseHeaders(evt.responseHeaders);
//
//				/*Debugger.log(
//				"[GhostBridge]::获取Cookies信息耗时:" + (getTimer() - timestamp).toString() + "ms",
//				LogType.LOGIN_IN
//				);*/
//				_timestamp = getTimer();
//
//				//Debugger.log("Cookies:", cookies, LogType.LOGIN_IN);
//
//				var skey:String = getCookieByName("skey", _desc.cookies);
//				if (skey == "")
//				{
//					if (_getSkeyRetryCount > 0)
//						setTimeout(getSKey, 10, uin, clientkey);
//					else
//						loginFailed(ReplayCodeConfig.GET_SKEY_ERROR, "无法获取skey！");
//					return;
//				}
//				_desc.skey = skey;
//				_desc.g_tk = calcGTK(skey);
//
//				loginSuccess();
//				_getSkeyRetryCount = 3;
//			}
//
//			function onError(evt:IOErrorEvent):void
//			{
//				loader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onHttpStatus);
//				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
//
//				if (_getSkeyRetryCount > 0)
//					setTimeout(getSKey, 10, uin, clientkey);
//				else
//					loginFailed(ReplayCodeConfig.ERROR_IOERROR, "无法连接到服务器！");
//			}
//		}

//		/**
//		 * 处理ptLogin的回包, 提取Cookies.
//		 * @param headers
//		 * @return 包头里的cookies
//		 */
//		private function handleSKeyResponseHeaders(headers:Array):String
//		{
//			var reqHeader:URLRequestHeader;
//			var cookieStr:String;
//			var num:int = 0;
//			var subCookieList:Array;
//			var cookies:String = "";
//			for (var i:int = 0, n:int = headers.length; i < n; i++)
//			{
//				reqHeader = headers[i] as URLRequestHeader;
//				if (reqHeader.name == "Set-Cookie")
//				{
//					cookieStr = reqHeader.value;
//					subCookieList = cookieStr.split(";, ");
//					for (var j:int = 0, m:int = subCookieList.length; j < m; j++)
//					{
//						cookieStr = subCookieList[j];
//						num = cookieStr.indexOf(";");
//						if (num != -1)
//							cookieStr = cookieStr.substring(0, num);
//						if (cookies == "")
//							cookies = cookieStr;
//						else
//							cookies = cookies + "; " + cookieStr
//					}
//				}
//			}
//
//			return cookies;
//		}
//
//
//		/**
//		 * 获取cookies里的某个字段
//		 * @param name
//		 * @param cookies
//		 * @return
//		 *
//		 */
//		private function getCookieByName(name:String, cookies:String):String
//		{
//			var cookie_start:int = cookies.indexOf(name);
//			var cookie_end:int = cookies.indexOf(";", cookie_start);
//			return cookie_start == -1 ? '' : unescape(cookies.substring(cookie_start + name.length + 1, (cookie_end > cookie_start ? cookie_end : cookies.length)));
//		}


		/**
		 * 根据skey计算g_tk
		 * @param skey
		 * @return
		 *
		 */
		private function calcGTK(skey:String):String
		{
			var hash:uint = 5381;
			for (var i:int = 0; i < skey.length; ++i)
			{
				hash += (hash << 5) + skey.charCodeAt(i);
			}
			return (hash & 0x7fffffff).toString();
		}


		//----------------------------------------------------------------------
		//
		//  View events handlers
		//
		//----------------------------------------------------------------------


		private function onToLogin(evt:CharonViewEvent):void
		{
			var uin:String = evt.data.uin;
			var psw:String = evt.data.psw;

			if (uin == "")
			{
				loginFailed(WtLoginReplayCode.ERROR_INPUT, "帐号密码不能为空！");
				return;
			}

			psw = StringUtil.trim(psw);
			if (psw == "")
			{
				loginFailed(WtLoginReplayCode.ERROR_INPUT, "帐号密码不能为空！");
				return;
			}

			startWLogin(uin, psw);
		}


		/**
		 * 打开忘记密码的网页
		 * @param evt
		 *
		 */
		private function onForgetPsw(evt:CharonViewEvent):void
		{
			openURL("http://aq.qq.com/cn/findpsw/findpsw_index");
		}


		/**
		 * 打开注册的网页
		 * @param evt
		 *
		 */
		private function onToSignUp(evt:CharonViewEvent):void
		{
			openURL("http://pt.3g.qq.com/reg");
		}


		/**
		 * To do...
		 * @param evt
		 *
		 */
		private function onCommitPicCode(evt:CharonViewEvent):void
		{
			_wLogin.submitPicCode(evt.data.picCode);
		}

		private function onShowSelectPanel(evt:CharonViewEvent):void
		{
			var loginInfos:Array = _wLogin.loginInfos;
			var uins:Array = new Array();
			const len:int = loginInfos.length;
			for (var i:int = 0; i < len; i++)
				uins.push(loginInfos[i].uin);
			_loginView.setSelectUins(uins);
		}

		private function onChangeUin(e:CharonViewEvent):void
		{
			trace(e.data);
			setUin(e.data as String);
		}

		/**
		 * 用户点击时，就记录“记住密码”、“自动登录”状态
		 * @param evt
		 *
		 */
		private function onChangeRemPswState(evt:CharonViewEvent):void
		{
			_wLogin.so.rememberPSW = evt.data.state;
			_wLogin.flush();
		}


		/**
		 * 用户点击时，就记录“记住密码”、“自动登录”状态
		 * @param evt
		 *
		 */
		private function onChangeAutoLoginState(evt:CharonViewEvent):void
		{
			_wLogin.so.autoLogin = evt.data.state;
			_wLogin.flush();
		}


		private function openURL(url:String):void
		{
			var stage:Stage = _loginView.stage;
			if (stage == null)
				return;
			CustomWebView.show(url, stage, new DefaultCloseButton);
		}
	}
}
