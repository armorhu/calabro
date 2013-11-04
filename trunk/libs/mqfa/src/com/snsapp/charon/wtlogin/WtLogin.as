package com.snsapp.charon.wtlogin
{
	import com.qzone.qfa.debug.Debugger;
	import com.qzone.qfa.debug.LogType;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.flash_proxy;
	import flash.utils.setTimeout;

	public class WtLogin extends EventDispatcher
	{
		private var SKEY:String = "";
		private var nick:String = "";
		private var key:Array;
		private var st_key:Array;
		private var IpSig:String;
		private var _uin:String = "";
		private var _passwd:String = "";
		private var _sigSession:String;
		private var _picData:ByteArray;
		private var _state:String;
		private var _A2Session:String;
		private var GTKEY_TGTGT:Array;
		private var _time:uint;

		/**
		 * 登陆态保存
		 * **/
		private var _shared:SharedObject; //wtlogin的登陆态信息，保存了多个用户。
		private var _localUserLoginSO:Array; //_shared里面存储的所有用户的登陆态信息
		private const MAX_COUNT:int = 5; //最多存5个

		public static const GET_IP_SIG:String = "GET_IP_SIG";
		public static const LOGIN:String = "LOGIN";
		protected static const CapPicCtrl:String = "1";

		/**
		 * so中记录的默认用户名
		 * 每次登录成功后都会更新so中的默认用户名
		 *
		 * */
		private var _defaultUIN:String;
		/**
		 * wlogin中一些登录态信息的so的key
		 * */
		private static const SO_KEY:String = "QQFarm_Mobile";
		private var _appid:String;
		private var _sub_appid:String;

		//		public static const _appid:String = "16";
		//		public static const _sub_appid:String =  "19";
//		'549007101', '1'
		public function WtLogin(appid:String = '549007101', sub_appid:String = '1')
		{
			_appid = appid, _sub_appid = sub_appid;
			_shared = SharedObject.getLocal(SO_KEY, "/");
			_localUserLoginSO = _shared.data.userloginInfo as Array;
			if (_localUserLoginSO == null)
				_localUserLoginSO = new Array();
			key = Base64.key;
			IpSig = "";
			_uin = "0";
			_passwd = "";
		}

		/*获取IP签名*/
		public function getIpSig(uin:String = "0", pwd:String = ""):void
		{
			SKEY = "";
			nick = "";
			_uin = uin;

			trace("getIpSig", uin, pwd);
			if (!checkUIN(uin))
			{
				//这里必须异步
				setTimeout(dispatchEvent, 10, new WtloginEvent(WtLoginReplayCode.ERROR_INPUT, "用户名不存在。"));
				return;
			}

			_passwd = pwd;
			_state = "getIpSig";
//			var session:String = _shared.data.session;
//			if (session != null)
//			{
//				IpSig = session;
//				_A2Session = _shared.data.session_a2;
//				this.dispatchEvent(new Event(HttpLogin.GET_IP_SIG));
//				return;
//			}
			var json:String = '{"Uin":"' + 0 + '","Appid":"' + _appid + '"}';
			var bytes:ByteArray = new ByteArray;
			var keyStr:String = "";
			for (var i:int = 0; i < 16; i++)
			{
				if (i >= 8)
				{
					keyStr += String.fromCharCode(key[i]);
				}
				else
				{
					bytes.writeMultiByte(String.fromCharCode(key[i]), "utf-8");
				}
			}

			bytes.writeMultiByte(keyStr, "utf-8");
			var gen:ByteArray = TeaEncrypt.encrypt(json.split(""), key);
			bytes.writeBytes(gen, 0, gen.length);
			var httpLoader:HttpLoader = new HttpLoader;
			httpLoader.addEventListener(Event.COMPLETE, onGetIpSigComplete, false, 0, true);
			httpLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
			httpLoader.post(Base64.encode2(bytes), "IP_SIG");
		}

		protected const NUMBER_SET:Array = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];

		protected function myParseInt(uin:String):String
		{
			const len:int = uin.length;
			for (var i:int = 0; i < len; i++)
			{
				if (NUMBER_SET.indexOf(uin.charAt(i)) == -1)
					return "0";
			}
			return uin;
//			
//            //uin可能超过20亿
//			if (isNaN(parseInt(uin)))
//				return 0;
//			else
//				return parseInt(uin);
		}

		/*Name换取Uin*/
		public function getNameToUin(name:String):void
		{
			if (!checkUIN(name))
			{
				setTimeout(dispatchEvent, 10, new WtloginEvent(WtLoginReplayCode.ERROR_USERNAME, "用户名不存在。"));
				return;
			}

			_state = "getNameToUin";
			var json:String = '{"Uin":"0","SubCmd":"4","IpSig":"' + IpSig + '","TLV":[' + //
				'{"0x100":{"DBBufVer":"11","SSOVer":"22","AppID":"' + _appid + '","SubAppID":"' + _sub_appid + '","AppClientVer":"45","GetSig":"65535"}},' + //
				'{"0x112":{"Name":"' + name + '"}},' + //
				'{"0x107":{"PicType":"1","CapType":"1","PicSize":"20","PicRetType":"1"}},' + //
				'{"0x108":{"Ksid":"eLE\/N+Nvk7tc8xSNHa8ftYO\/2yggJKcmNHaK0GJQBmc="}},' + //
				'{"0x109":{"IMEI":"cmd4_tlv109_Value"}}' + //
				',{"0x11b":{"cCapPicCtrl":"' + CapPicCtrl + '"}}' +
				']}';
			trace("[getNameToUin]:" + json);
			var bytes:ByteArray = new ByteArray;
			var keyStr:String = "";
			for (var i:int = 0; i < 16; i++)
			{
				if (i >= 8)
				{
					keyStr += String.fromCharCode(key[i]);
				}
				else
				{
					bytes.writeMultiByte(String.fromCharCode(key[i]), "utf-8");
				}
			}
			bytes.writeMultiByte(keyStr, "utf-8");
			var gen:ByteArray = TeaEncrypt.encrypt(json.split(""), key);
			bytes.writeBytes(gen, 0, gen.length);
			var httpLoader:HttpLoader = new HttpLoader;
			httpLoader.addEventListener(Event.COMPLETE, unifyReplayHandler, false, 0, true);
			httpLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
			Debugger.log("getNameToUin LOGIN", LogType.LOGIN);
			httpLoader.post(Base64.encode2(bytes), LOGIN);
		}

		/*Uin登录*/
		public function getLogin():void
		{
			if (isNaN(Number(_uin)))
			{
				this.getNameToUin(_uin);
				return;
			}
			_state = "getLogin";
			/**
			 * wlogin的一个限制
			 * 当密码长度大于１６位时，需要只取前１６位去校验
			 * 否则会校验失败。
			 * **/
			if (_passwd.length > 16)
				_passwd = _passwd.substr(0, 16);
			//不能记录用户密码
			Debugger.log("[GhostBridge]::开始登录.(uin=" + _uin + ")");
			var longCheckUin:ByteArray = Switch2(Number(_uin));
			var md5c:MD5 = new MD5();
			var passByte:ByteArray = new ByteArray();
			passByte.writeMultiByte(_passwd, "utf-8");
			passByte.position = 0;
			var md5:ByteArray = md5c.hash(passByte);
			st_key = [];
			md5.position = 0;
			md5.endian = Endian.LITTLE_ENDIAN;

			this.HexShow(md5);
			md5.position = 0;
			while (md5.bytesAvailable)
			{
				st_key.push(md5.readUnsignedByte());
			}

			md5.position = 0;
			var sPwdMd5Salt:ByteArray = new ByteArray();
			sPwdMd5Salt.endian = Endian.BIG_ENDIAN;
			md5.readBytes(sPwdMd5Salt, 0, md5.length);
			sPwdMd5Salt.position = sPwdMd5Salt.length;
			sPwdMd5Salt.writeBytes(longCheckUin, 0, longCheckUin.length);
			var sPwdMd5SaltMd5:ByteArray = md5c.hash(sPwdMd5Salt);
			sPwdMd5SaltMd5.writeBytes(md5, 0, md5.length);
			this.HexShow(sPwdMd5SaltMd5);
			var temp:Array = []
			while (sPwdMd5SaltMd5.bytesAvailable)
			{
				st_key.push(sPwdMd5SaltMd5.readUnsignedByte());
			}
			var byte:ByteArray = new ByteArray;
			byte.endian = Endian.BIG_ENDIAN;
			byte.writeShort(1);
			byte.writeUnsignedInt(0x29);
			byte.writeUnsignedInt((0x350));
			byte.writeUnsignedInt((parseInt(_appid)));
			byte.writeUnsignedInt((0x1));
			byte.writeBytes(longCheckUin, 0, longCheckUin.length);
			byte.writeUnsignedInt(_time); //这里不能用客户端时间
			byte.writeUnsignedInt((3682942537));
			byte.writeByte(1); //0表示记住密码  1表示不记住密码
			md5.position = 0;
			byte.writeBytes(md5, 0, md5.length);
			md5.position = 0;
			byte.writeBytes(md5, 0, md5.length);
			byte.writeShort(TeaEncrypt.htons(0)); /**/
			byte.position = 0;
			var a1:Array = [];
			var u:uint;
			while (byte.bytesAvailable)
			{
				u = byte.readUnsignedByte()
				a1.push(Number("0x" + u.toString(16)));
			}
			md5.position = 0;
			HexShow(sPwdMd5SaltMd5);
			sPwdMd5SaltMd5.position = 0;
			var keys:Array = [];
			while (sPwdMd5SaltMd5.bytesAvailable)
			{
				u = sPwdMd5SaltMd5.readUnsignedByte();

				keys.push(Number("0x" + u.toString(16)));
				if (keys.length >= 16)
				{
					break;
				}
			}
			GTKEY_TGTGT = keys;
			var json:String = '{"Uin":"' + _uin + '","SubCmd":"1","IpSig":"' + IpSig + '","TLV":[' + //
				'{"0x106":{"A1":"' + Base64.encode2(TeaEncrypt.encrypt(a1, keys, false)) + '"}},' + //
				'{"0x116":{"Ver":"5","MiscBitmap":"2","GetSig":"65535","AppidList":[]}},' + //
				'{"0x100":{"DBBufVer":"11","SSOVer":"22","AppID":"' + _appid + '","SubAppID":"' + _sub_appid + '","AppClientVer":"45","GetSig":"65535"}},' + //
				'{"0x107":{"PicType":"1","CapType":"1","PicSize":"20","PicRetType":"1"}}' + //
				',{"0x11b":{"cCapPicCtrl":"' + CapPicCtrl + '"}}' +
				']}';
			trace(json);
			var bytes:ByteArray = new ByteArray;
			var keyStr:String = "";
			for (var i:int = 0; i < 16; i++)
			{
				if (i >= 8)
				{
					keyStr += String.fromCharCode(key[i]);
				}
				else
				{
					bytes.writeMultiByte(String.fromCharCode(key[i]), "utf-8");
				}
			}
			bytes.writeMultiByte(keyStr, "utf-8");
			var gen:ByteArray = TeaEncrypt.encrypt(json.split(""), key);
//			_shared.data.st_key = st_key;
			bytes.writeBytes(gen, 0, gen.length);
			var httpLoader:HttpLoader = new HttpLoader;
			httpLoader.addEventListener(Event.COMPLETE, unifyReplayHandler, false, 0, true);
			httpLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
			Debugger.log("getNameToUin LOGIN", LogType.LOGIN);
			httpLoader.post(Base64.encode2(bytes), LOGIN);
		}

		public function getA2Login(uin:String = null):void
		{
			if (uin == null)
				uin = _uin;
			var loginInfo:Object = getUserLoginInfoByUin(uin);
			if (loginInfo == null || loginInfo.session_a2 == undefined)
			{
				trace("relogin:", _shared.data.session_a2);
				this.dispatchEvent(new WtloginEvent(WtLoginReplayCode.A2_LOGIN_ERROR, "请重新输入密码!"));
				return;
			}
			_uin = uin;
//			st_key = loginInfo.st_key;
			if (isNaN(Number(_uin)))
			{
				this.getNameToUin(_uin);
				return;
			}
			_state = "getA2Login";
			_A2Session = loginInfo.session_a2;
			var json:String = '{"Uin":"' + _uin + '","SubCmd":"5","IpSig":"' + IpSig + '","TLV":[' + //
				'{"0x100":{"DBBufVer":"11","SSOVer":"22","AppID":"' + _appid + '","SubAppID":"' + _sub_appid + '","AppClientVer":"45","GetSig":"65535"}},' + //
				'{"0x10a":{"A2":"' + _A2Session + '"}},' + //
				'{"0x116":{"Ver":"5","MiscBitmap":"2","GetSig":"65535","AppidList":[]}}]}';
			trace("A2 Login:", json);
			//不能记录用户密码
			Debugger.log("[GhostBridge]::开始登录.A2login(uin=" + _uin + ")");
			var bytes:ByteArray = new ByteArray;
			var keyStr:String = "";
			for (var i:int = 0; i < 16; i++)
			{
				if (i >= 8)
				{
					keyStr += String.fromCharCode(key[i]);
				}
				else
				{
					bytes.writeMultiByte(String.fromCharCode(key[i]), "utf-8");
				}
			}
			bytes.writeMultiByte(keyStr, "utf-8");
			var gen:ByteArray = TeaEncrypt.encrypt(json.split(""), key);
			bytes.writeBytes(gen, 0, gen.length);
			var httpLoader:HttpLoader = new HttpLoader;
			httpLoader.addEventListener(Event.COMPLETE, unifyReplayHandler, false, 0, true);
			httpLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
			Debugger.log("getA2Login LOGIN", LogType.LOGIN);
			httpLoader.post(Base64.encode2(bytes), LOGIN);
		}

		public function getPicCode():void
		{
			var json:String = '{"Uin":"' + myParseInt(_uin) + '","SubCmd":"3","TLV":[{"0x104":{"SigSession":"' + _sigSession + '"}}]}';
			var bytes:ByteArray = new ByteArray;
			var keyStr:String = "";
			for (var i:int = 0; i < 16; i++)
			{
				if (i >= 8)
				{
					keyStr += String.fromCharCode(key[i]);
				}
				else
				{
					bytes.writeMultiByte(String.fromCharCode(key[i]), "utf-8");
				}
			}
			bytes.writeMultiByte(keyStr, "utf-8");
			trace(json)
			var gen:ByteArray = TeaEncrypt.encrypt(json.split(""), key);
			bytes.writeBytes(gen, 0, gen.length);
			var httpLoader:HttpLoader = new HttpLoader;
			httpLoader.addEventListener(Event.COMPLETE, unifyReplayHandler, false, 0, true);
			httpLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
			Debugger.log("getPicCode LOGIN", LogType.LOGIN);
			httpLoader.post(Base64.encode2(bytes), LOGIN);
		}

		public function submitPicCode(str:String):void
		{
			var json:String = '{"Uin":"' + myParseInt(_uin) + '","SubCmd":"2","IpSig":"' + IpSig + '","TLV":[' + //
				'{"0x104":{"SigSession":"' + _sigSession + '"}},' + //
				'{"0x2":{"PicSigVer":"2","Code":"' + str + '","EncryptKey":"' + //
				Base64.encode(Math.floor(Math.random() * 8999 + 1000).toString()) + '"}}]}';
			Debugger.log("[HttpLogin]::submitPicCode: uin=" + _uin + ",picCode=" + str);
			var bytes:ByteArray = new ByteArray;
			var keyStr:String = "";
			for (var i:int = 0; i < 16; i++)
			{
				if (i >= 8)
				{
					keyStr += String.fromCharCode(key[i]);
				}
				else
				{
					bytes.writeMultiByte(String.fromCharCode(key[i]), "utf-8");
				}
			}
			trace(json);
			bytes.writeMultiByte(keyStr, "utf-8");
			var gen:ByteArray = TeaEncrypt.encrypt(json.split(""), key);
			bytes.writeBytes(gen, 0, gen.length);
			var httpLoader:HttpLoader = new HttpLoader;
			httpLoader.addEventListener(Event.COMPLETE, unifyReplayHandler, false, 0, true);
			httpLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
			Debugger.log("submitPicCode LOGIN", LogType.LOGIN);
			httpLoader.post(Base64.encode2(bytes), LOGIN);
		}

		private function onIOError(e:IOErrorEvent):void
		{
			this.dispatchEvent(new WtloginEvent(WtLoginReplayCode.ERROR_IOERROR, "网络通信失败。"));
		}

		private function onGetIpSigComplete(evt:Event):void
		{
			var result:String = evt.target.data;
			var decode:ByteArray = Base64.decodeToByteArray(result);
			var out:Array = [];
			while (decode.bytesAvailable)
			{
				out.push(decode.readUnsignedByte());
			}
			var bytes:ByteArray = TeaEncrypt.decrypt(out, key);
			var str:String = bytes.readMultiByte(bytes.length, "utf-8");
			var jsonObject:Object = JSON.parse(str);
			IpSig = jsonObject.IpSig;
			_time = jsonObject.Time;
//			_shared.data.session = IpSig;  不再保存
//			_shared.flush(100);
			this.dispatchEvent(new Event("GET_IP_SIG"));
		}

		private function Switch2(x:*):ByteArray
		{
			var longInt:LongInt = new LongInt();
			var a:String = longInt.BintoHex(longInt.DectoBin(x)).toLocaleLowerCase();
			var output:String = longInt.binMove(longInt.binOperator(longInt.HextoBin(a), longInt.HextoBin("ff00000000000000"), "&"), -56);
			output = longInt.binOperator(output, longInt.binMove(longInt.binOperator(longInt.HextoBin(a), longInt.HextoBin("00ff000000000000"), "&"), -40), "|");
			output = longInt.binOperator(output, longInt.binMove(longInt.binOperator(longInt.HextoBin(a), longInt.HextoBin("0000ff0000000000"), "&"), -24), "|");
			output = longInt.binOperator(output, longInt.binMove(longInt.binOperator(longInt.HextoBin(a), longInt.HextoBin("000000ff00000000"), "&"), -8), "|");
			output = longInt.binOperator(output, longInt.binMove(longInt.binOperator(longInt.HextoBin(a), longInt.HextoBin("00000000ff000000"), "&"), 8), "|");
			output = longInt.binOperator(output, longInt.binMove(longInt.binOperator(longInt.HextoBin(a), longInt.HextoBin("0000000000ff0000"), "&"), 24), "|");
			output = longInt.binOperator(output, longInt.binMove(longInt.binOperator(longInt.HextoBin(a), longInt.HextoBin("000000000000ff00"), "&"), 40), "|");
			output = longInt.binOperator(output, longInt.binMove(longInt.binOperator(longInt.HextoBin(a), longInt.HextoBin("00000000000000ff"), "&"), 56), "|");
			output = ("00000000" + longInt.BintoHex(output)).substr(-16, 16);
			var switch2:String = "";
			for (var i:int = 0; i < 16; i += 2)
			{
				switch2 = output.substr(i, 2) + switch2;
			}
			return StringToBytes(switch2);
		}

		private function StringToBytes(s:String):ByteArray
		{
			//trace(s);
			var bytes:ByteArray = new ByteArray;
			bytes.endian = Endian.LITTLE_ENDIAN;
			s = (s.length % 2 == 1 ? "0" : "") + s;
			for (var i:int = 0; i < s.length; i += 2)
			{
				bytes.writeByte(Number("0x" + s.substr(i, 2)));
			}
			bytes.position = 0;
			return bytes;
		}

		private function HexShow(byte:ByteArray):Number
		{
			byte.position = 0;
			var s:String = "";
			while (byte.bytesAvailable)
			{
				s += (byte.readUnsignedInt().toString(16)) + " ";
			}
			trace(s);
			return Number("0x" + s)
		}

		/**
		 * 统一的返回值处理函数。。
		 * wtlogin的设计是互不排斥的返回值。适用与各种情况的返回值处理
		 * **/
		protected function unifyReplayHandler(evt:Event):void
		{
			var result:String = evt.target.data;
			var decode:ByteArray = Base64.decodeToByteArray(result);
			var out:Array = [];
			while (decode.bytesAvailable)
			{
				out.push(decode.readUnsignedByte());
			}
			var bytes:ByteArray = TeaEncrypt.decrypt(out, key);
			result = bytes.readMultiByte(bytes.length, "utf-8");
			trace(this._state, ":\n", result);
			var jsonObject:Object = JSON.parse(result);
			if (jsonObject.ReplyCode == undefined)
			{ //没有返回码，重新拉~~
				getIpSig(_uin, _passwd);
			}
			else
			{
				var replayCode:int = parseInt(jsonObject.ReplyCode);
				switch (replayCode)
				{
					case WtLoginReplayCode.LOGIN_SUCCESS:
					{
						if (_state == "getNameToUin") //成功换到uin.继续往下走..这里并不抛事件
						{
							_uin = jsonObject.TLV[1]["0x113"]["Uin"];
							this.getLogin();
							return;
						}
						nick = Base64.decode(findTLVValue(jsonObject, "0x11a", "Nick"));
						SKEY = "";
						var skeyBytes:ByteArray;
						_uin = jsonObject.Uin;
						if (_state == "getLogin")
						{
							var loginInfo:Object = {uin: _uin};
							//用前台生成的st_key解码
							loginInfo.session_a2 = Base64.encode2(decodeData(jsonObject.TLV[1]["0x10a"]["A2"], st_key));
						}
						else
						{
							loginInfo = getUserLoginInfoByUin(_uin);
							if (loginInfo == null || loginInfo.st_key == null)
							{
								dispatchEvent(new WtloginEvent(WtLoginReplayCode.A2_LOGIN_ERROR, "请重新输入密码!"));
								return;
							}
							//用缓存里的st_key解码
							loginInfo.session_a2 = Base64.encode2(decodeData(findTLVValue(jsonObject, "0x10a", "A2"), loginInfo.st_key));
						}
						//解码skey
						skeyBytes = decodeData(findTLVValue(jsonObject, "0x120", "SKey"), st_key);
						while (skeyBytes.bytesAvailable)
							SKEY += String.fromCharCode(skeyBytes.readUnsignedByte());

						//生成新的st_key。
						var gtKey:String = findTLVValue(jsonObject, "0x10d", "GTKey_TGT");
						var keyBytes:ByteArray = decodeData(gtKey, st_key);
						st_key = [];
						while (keyBytes.bytesAvailable)
						{
							if (st_key.length < 16)
								st_key.push(keyBytes.readUnsignedByte());
							else
								break;
						}
						loginInfo.st_key = st_key;
						_defaultUIN = _uin
						this._shared.data.defaultUIN = _uin;
						pushLoginInfo(loginInfo);
						break;
					}

					case WtLoginReplayCode.ERROR_PICCODE:
					{
						_sigSession = jsonObject.TLV[0]["0x104"].SigSession;
						_picData = Base64.decodeToByteArray(jsonObject.TLV[1]["0x105"].PicData);
						break;
					}
				} // end switch
				var repalyMsg:String = findTLVValue(jsonObject, "0xa", "Error");
				if (repalyMsg == null)
					repalyMsg = "";
				else
					repalyMsg = Base64.decode(repalyMsg);
				dispatchEvent(new WtloginEvent(replayCode, repalyMsg)); //直接将错误信息抛出去
			} // end if
		}

		private function decodeData(str:String, keys:Array):*
		{
			var decode:ByteArray = Base64.decodeToByteArray(str);
			var out:Array = [];
			while (decode.bytesAvailable)
			{
				out.push(decode.readUnsignedByte());
			}
//			if (_shared.data.st_key != undefined)
//			{
//				st_key = _shared.data.st_key;
//			}
			if (keys != null)
			{
				st_key = keys;
			}
			decode = TeaEncrypt.decrypt(out, st_key);
			return decode;
		}

		/**
		 * 取回包中的某个属性.
		 * 如：findValue(jsonObject,"0x113","Uin");
		 * @param tlv
		 * @param type
		 * @param name
		 * @return
		 */
		protected function findTLVValue(json:Object, type:String, name:String):String
		{
			if (json == null)
				return null;
			var tlv:Array = json.TLV;
			if (tlv == null)
				return null;
			const len:int = tlv.length;
			for (var i:int = 0; i < len; i++)
				if (tlv[i].hasOwnProperty(type) && tlv[i][type].hasOwnProperty(name))
					return tlv[i][type][name];

			return null;
		}


		private function checkUIN(uin:String):Boolean
		{
			if (uin == null || uin == "")
				return false;
			var arr:Array = ["0123456789", "abcdefghijklmnopqrstuvwxyz", "ABCDEFGHIJKLMNOPQRSTUVWXYZ", ".-_@"];

			var scope:String = arr.join("");
			var char:String;
			for (var i:int = 0, n:int = uin.length; i < n; i++)
			{
				char = uin.charAt(i);
				if (scope.indexOf(char) < 0)
					return false;
			}
			return true;
		}



		public function get sigSession():String
		{
			return _sigSession;
		}

		public function get picData():ByteArray
		{
			return _picData;
		}

		public function get Skey():String
		{
			return this.SKEY
		}

		public function get nickName():String
		{
			return this.nick;
		}

		public function get uin():String
		{
			return this._defaultUIN;
		}

		public function get so():Object
		{
			return _shared.data;
		}

		public function flush():void
		{
			try
			{
				_shared.data.userloginInfo = _localUserLoginSO;
				_shared.flush(100);
			} 
			catch(error:Error) 
			{
//				_shared.clear();
			}
		}

		public function getUserLoginInfoByUin(uin:String):Object
		{
			const len:int = _localUserLoginSO.length;
			for (var i:int = 0; i < _localUserLoginSO.length; i++)
			{
				if (_localUserLoginSO[i].uin == uin)
					return _localUserLoginSO[i];
			}
			return null;
		}

		private function pushLoginInfo(loginInfo:Object):void
		{
			const len:int = _localUserLoginSO.length;
			for (var i:int = 0; i < len; i++)
				if (_localUserLoginSO[i].uin == loginInfo.uin)
					break;

			if (i < len)
			{ //之前没有登陆过
				_localUserLoginSO.splice(i, 1);
				_localUserLoginSO.unshift(loginInfo);
			}
			else
			{ //从前就登陆过
				if (len == MAX_COUNT)
					_localUserLoginSO.pop();
				_localUserLoginSO.unshift(loginInfo);
			}

			flush();
		}


		public function hasA2_Seesion(uin:String):Boolean
		{
			var obj:Object = getUserLoginInfoByUin(uin);
			return obj && obj.session_a2 != undefined;
		}

		public function get loginInfos():Array
		{
			return _localUserLoginSO;
		}
	}
}
