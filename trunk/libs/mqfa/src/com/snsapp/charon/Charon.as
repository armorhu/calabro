package com.snsapp.charon
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.sendToURL;

	/**
	 * 标准登录组件。
	 * 集成了自动登录、记住密码功能，使用WLogin。
	 * To do...多帐号登录记录
	 *
	 * </p>
	 * Charon：是希腊神话中冥河上的摆渡者，还肩负了分辨亡灵和活人的任务，被称为分辨之神。
	 *
	 * </p>
	 * http://en.wikipedia.org/wiki/Charon_(mythology)
	 *
	 * </p>
	 * 有一天，他来到了农场，变成了标准登录组件 = =|||
	 *
	 * @author mobiuschen
	 *
	 */
	public class Charon extends Sprite
	{
		public function Charon(useAutoLogin:Boolean, appid:String, subappid:String, ozFlag1:int = 0, resURL:String = null)
		{
			super();
			_useAutoLogin = useAutoLogin;
			_appid = appid;
			_subappid = subappid;
			_ozFlag1 = ozFlag1;

			if (resURL)
			{
				_resLoader = new Loader();
				_resLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadResComplete);
				_resLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadResComplete);
				_resLoader.load(new URLRequest(resURL));
			}
			else
			{
				_controller = new CharonContrller(_useAutoLogin, this);
				_controller.initialze();
			}
		}

		private function onLoadResComplete(e:Event):void
		{
			if (e.type == Event.COMPLETE)
			{
				_controller = new CharonContrller(_useAutoLogin, this);
				_controller.initialze();
			}
			else
			{
				throw new IOError(e.toString());
			}
		}


		private var _useAutoLogin:Boolean = false;
		private var _controller:CharonContrller;
		private var _appid:String;
		private var _subappid:String;
		private var _ozFlag1:int;
		private var _resLoader:Loader;

		public function showLoginView():void
		{
			if (_controller)
				_controller.showLoginView();
		}

		public function destroy():void
		{
			if (_controller != null)
				_controller.finalize();

			if (_resLoader)
				_resLoader.unloadAndStop();

			_controller = null;
		}

		public function get appid():String
		{
			return _appid;
		}

		public function get sub_appid():String
		{
			return _subappid;
		}

		public function get loader():Loader
		{
			return _resLoader;
		}

		/**
		 * OZ上报的URL
		 */
		private static const OZ_RECORD_URL:String = "http://isdspeed.qq.com/cgi-bin/v.cgi";

		public function recordOZ(success:Boolean, delay:Number, errorCode:int):void
		{
			if (_ozFlag1 == 0)
				return;
			var flag1:int = _ozFlag1;
			var flag2:int, flag3:int, probability:int;
			if (success)
				flag2 = 1, flag3 = 0, probability = 5;
			else
				flag2 = 2, flag3 = errorCode, probability = 1;
			if (int(Math.random() * probability) != 0)
				return;

			var vars:URLVariables = new URLVariables();
			vars.flag1 = flag1.toString();
			vars["flag2"] = flag2;
			vars["flag3"] = flag3;
			vars["1"] = probability; //取样率
			vars["2"] = delay.toString();

			var req:URLRequest = new URLRequest(OZ_RECORD_URL); //new URLRequest(_recordUrl+sign+"flag1="+pid+"&flag2="+code);
			req.data = vars;
			req.method = URLRequestMethod.GET;
			sendToURL(req);
		}
	}
}
