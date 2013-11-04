package com.qzone.corelib.data
{
	import flash.events.StatusEvent;
	import flash.net.LocalConnection;
	import flash.text.TextField;
	import flash.utils.setTimeout;

	public class LocalBridge
	{
		public static var SYS:String = "_qzoneLocalBridge_";
		private static const INIT_ERROR:String = "请先初始化";
		private static var _instance:LocalBridge;
		private var _lcSys:LocalConnection;
		private var _lcClient:LocalConnection;
		public var shareData:Object;
		private var _appName:String;
		public var _callBAckList:Object;
		public static var dataChangeCallBack:Function;
		public static var initedCallBack:Function;
		public static var inited:Boolean;
		
		public static var debugText:TextField;
		protected var retry:int = 0;
		
		
		/**
		 * 目前打开的应用列表，命名格式：_appName_uin,例： _happyfarm_82822239
		 */		
		private var _apps:Array;
		
		public function LocalBridge(sub:Sub)
		{
			_apps=[];
			_callBAckList = {};
		}
		private static function gi():LocalBridge
		{
			return _instance ||= new LocalBridge(new Sub());
		}
		public static function init(appName:String,data:Object=null):void
		{
			gi()._init(appName,data);
		}
		public static function data():Object
		{
			if(!_instance)
			{
				throw new Error(INIT_ERROR);
			}
			return _instance.shareData;
		}
		public static function addCallBack(functionName:String,callBack:Function):void
		{
			if(!_instance)
			{
				throw new Error(INIT_ERROR);
			}
			_instance._callBAckList[functionName] = callBack;
		}
		public static function call(appName:String,functionName:String,param:*=null):void
		{
			if(!_instance)
			{
				throw new Error(INIT_ERROR);
			}
			_instance._call(appName,functionName,param);
		}
		/**
		 * 如果data不为null,就把data通步到SYS  反之把data同步回来 
		 * @param data
		 * 
		 */		
		public static function syncData(data:Object=null):void
		{
			if(!_instance)
			{
				throw new Error(INIT_ERROR);
			}
			if(!data)
			{
				_instance._getData();
			}
			else
			{
				_instance.shareData = data;
				_instance._setData(data);
			}
		}
		public function _call(appName:String,functionName:String,param:*):void
		{
			_lcClient.send(appName,"callFunction",{functionName:functionName,param:param});
		}
		public function _getData():void
		{
			_lcClient.send(SYS,"getData",_appName);
		}
		public function _setData(data:Object):void
		{
			_lcClient.send(SYS,"setData",data);
		}
		public function _init(appName:String,data:Object=null):void
		{
			var uin:Number = Number(appName.replace(/_.+_/,""));
			if(isNaN(uin)||uin<10000)
			{
				throw new Error("APPName的格式不正确，应该是:'_应用名称_QQ号码'这样的格式，如:_happfarm_82822239");
			}
			trace2("init:"+appName);
			_appName = appName;
			this.shareData = data;
			SYS += uin.toString();//appName.replace(/_.+_/,"");
			if(data)
			{
				_lcSys = new LocalConnection();
				_lcSys.allowDomain("*");
				_lcSys.client = _instance;
				_lcSys.addEventListener(StatusEvent.STATUS,function(e:StatusEvent):void
				{
					trace2("SYS:"+e.level)
					if(e.level == "error")
					{
						//tryConnect(_lcSys,SYS);
					}
				});
				tryConnect(_lcSys,SYS);
			}
			else
			{
				_lcClient = new LocalConnection();
				_lcClient.allowDomain("*");
				_lcClient.client = _instance;
				_lcClient.addEventListener(StatusEvent.STATUS,function(e:StatusEvent):void
				{
					trace2("client:"+e.level);
				});
				tryConnect(_lcClient,_appName);
			}
		}
		protected function tryConnect(lc:LocalConnection,n:String):void
		{
			try
			{
				lc.connect(n);
				trace2(n+" connected.");
				if(initedCallBack != null)
				{
					initedCallBack();
					trace2("initedCallBack setTimeout");
				}
				inited = true;
			}
			catch(err:Error)
			{
				lc.send(n,"disconnect");
				trace2("call "+n+":disconnect");
				retry++;
				trace2(retry+" Retry...");
				setTimeout(function():void
				{
					tryConnect(lc,n);
				},100);
			}
		}
		
		
		
		public function callFunction(p:Object):void
		{
			if(p&&p.functionName&&_callBAckList[p.functionName])
			{
				_callBAckList[p.functionName](p.param);
			}
		}
		public function onData(data:Object):void
		{
			shareData = data;
			if(dataChangeCallBack != null)
			{
				dataChangeCallBack(shareData);
			}
		}
		public function setData(data:Object):void
		{
			shareData = data;
		}
		public function getData(appName:String):void
		{
			_lcSys.send(appName,"onData",shareData);
		}
		public function disconnect():void
		{
			try
			{
				_lcClient.close();
			}
			catch(err:Error){}
			try
			{
				_lcSys.close();
			}
			catch(err:Error){}
		}
		
		public static function trace2(s:String):void
		{
			if(debugText)
			{
				debugText.appendText(s+"\n");
			}
		}
	}
}
class Sub{}