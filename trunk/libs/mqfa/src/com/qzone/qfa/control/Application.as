package com.qzone.qfa.control
{
	import com.qzone.qfa.control.module.IModule;
	import com.qzone.qfa.control.module.IModuleAPI;
	import com.qzone.qfa.debug.Debugger;
	import com.qzone.qfa.interfaces.IApplication;
	import com.qzone.qfa.interfaces.IPackage;
	import com.qzone.qfa.interfaces.IParser;
	import com.qzone.qfa.interfaces.IServerServices;
	import com.qzone.qfa.managers.resource.Resource;
	import com.qzone.qfa.managers.resource.ResourceLoader;
	import com.snsapp.charon.LoginData;
	import com.snsapp.mobile.device.DeviceInfo;
	import com.snsapp.starling.texture.TextureLoader;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.RemoteNotificationEvent;
	import flash.events.StatusEvent;
	import flash.net.URLVariables;
	import flash.notifications.RemoteNotifier;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;

	/**
	 * 应用程序的逻辑控制中心
	 * 管理各个模块,模块间通信的消息中心
	 * @author hf
	 */
	public class Application implements IApplication
	{
		//真正的消息派发者
		protected var _dispatcher:EventDispatcher;

		//modules
		protected var _modules:Vector.<IModule>;

		//模块的配置
		protected var _moduleConfig:Object;

		//应用程序的名字
		protected var _name:String;

		//管理游戏场景的对象
		protected var _appStage:Sprite;

		//主循环是否激活
		protected var _mainloop:Boolean;

		//服务器接口
		protected var _serverService:IServerServices;

		//素材控制器
		protected var _rsLoader:ResourceLoader;

		//材质控制器
		protected var _textureLoader:TextureLoader;

		public function Application(name:String = "mobile_qfa")
		{
			_name = name;
			_dispatcher = new EventDispatcher();
			_modules = new Vector.<IModule>();
			_moduleConfig = new Object();
		}

		//上一帧的时间
		private var _lastTime:int;

		private function onEachFrame(e:Event):void
		{
			var currentTime:int = getTimer();
			//这个循环在卸载模块的时候可能会报错...
			const len:int = _modules.length;
			for (var i:int = 0; i < len; i++)
				_modules[i].onGameLoop(currentTime - _lastTime);
			_lastTime = currentTime;
		}

		public function get name():String
		{
			return _name;
		}

		/**
		 * 启动app
		 * @param root 应用的显示列表的根对象
		 */
		public function startup(root:Sprite):void
		{
			throw new Error("pls implements startup method!!");
		}

		/**
		 * 根据模块名字获取模块实例
		 * @param name
		 * 注意：getModule方法可能会返回null
		 * @return
		 */
		public function getModule(name:String):IModule
		{
			const len:int = _modules.length;
			for (var i:int = 0; i < len; i++)
			{
				if (_modules[i].name == name)
					return _modules[i];
			}
			return null;
		}


		/**
		 * 根据名字获取ModuleAPI
		 * 注意：getModuleAPI方法可能会返回null
		 * **/
		public function getModuleAPI(name:String):IModuleAPI
		{
			var iModule:IModule = getModule(name);
			if (iModule)
				return iModule.mouduleAPI;
			else
				return null;
		}

		/**
		 * 加载module
		 * @param name 模块名
		 * 模块未注册，或模块已启动都会触发errorhandler
		 */
		public function loadModule(name:String, completeHandler:Function = null, errorHandler:Function = null):void
		{
			if (_moduleConfig[name] == undefined || _moduleConfig[name]["loaded"] == true) //模块未注册或者已经启动
			{
				if (errorHandler != null)
					errorHandler();
				return;
			}
			var moduleConfig:Object = _moduleConfig[name];
			if (moduleConfig["swf"] != null) //是否注册了模块素材
				loadResource(moduleConfig["swf"], startupModule);
			else
				startupModule(null);

			function startupModule(resource:Resource):void
			{
				if (resource != null && resource.data == null)
				{
					if (errorHandler != null)
						errorHandler();
				}
				else
				{
					moduleConfig["loaded"] = true;
					var theClass:Class = moduleConfig["c"] as Class;
					var module:IModule = new theClass(moduleConfig["name"]) as IModule;
					_modules.push(module);
					module.startup(app, moduleConfig["view"], resource);
					if (completeHandler != null)
						completeHandler();
				}
			}
		}

		/**
		 * 卸载module
		 * @param name 模块名
		 * @return
		 */
		public function unloadModule(name:String):void
		{
			var moduleConfig:Object = _moduleConfig[name];
			if (moduleConfig == null || moduleConfig["loaded"] == false)
				return;

			const len:int = _modules.length;
			for (var i:int = 0; i < len; i++)
				if (_modules[i].name == name)
				{
					trace("[Module " + name + "]: unload...");
					_modules[i].destroy();
					_modules.splice(i, 1);
					moduleConfig["loaded"] = false;
//					_moduleConfig[name] = null;
//					delete _moduleConfig[name];
					break;
				}
		}

		/**
		 * 需求：1 注册模块和buildlayer的代码在一处，这样方便理解整个程序的架构
		 *      2 兼容flashnative视图，和starling视图
		 *      3 允许设置模块素材。
		 * @param name 模块名 建议定义为一个全局的静态常量，方便通过
		 * @param theClass 模块的Module类
		 * @param view 该模块的视图,view是一个泛型，主要是为了同时兼容starling视图和flashnative视图
		 * @param swf  模块素材（可选项）--如果模块有设置素材地址，那么再启动模块之前，会先加载模块素材swf
		 *
		 * 使用示例
		 * <p>
		 * //ui module
		 * var s:Sprite = new Sprite();
		 * root.addChild(s);
		 * registerModule("ui",UIModule,s,"assets/ui.swf");
		 * //battle module
		 * s = new Sprite();
		 * root.addChild(s);
		 * registerModule("battle",BattleModule,s,".assets/battle.swf");
		 * </p>
		 */
		public function registerModule(name:String, theClass:Class, view:*, swf:String = null):void
		{
			if (_moduleConfig[name] != undefined) //关键字已经被注册
				throw new Error(name + "已经被注册了!");

			//注册配置
			view.name = name;
			_moduleConfig[name] = {name: name, c: theClass, view: view, swf: swf, loaded: false};
		}

//		/**
//		 * 显示用户自定义的框
//		 */
//		public function showCustomerDialog(dialog:DisplayObject, modal:Boolean = true, params:Object = null):void
//		{
//			//implements by subClass
//		}
//
//		/**
//		 * 关闭一个正在显示的框
//		 */
//		public function closeDialog(dialog:DisplayObject, params:Object = null):void
//		{
//			//implements by subClass
//		}
//
//		/**
//		 * 显示系统框
//		 * @return 返回根据参数构造的系统框对象
//		 */
//		public function showSystemDialog(type:int, modal:Boolean = true, params:Object = null):DisplayObject
//		{
//			//implements by subClass
//			return null;
//		}

		/**
		 * 读取外部素材，底层接入vfs。
		 * @param url
		 * @param onComplete 参数为具体的Resource对象-- resource.data == null 表示加载失败！
		 * @param version  这个素材是否纳入版本控制？
		 */
		public function loadResource(url:String, onComplete:Function):void
		{
			_rsLoader.loadResource(url, onComplete);
		}

		public function loadResourceWithVersion(url:String, onComplete:Function):void
		{
			_rsLoader.loadVersionResource(url, onComplete);
		}

		/**
		 * 读取外部素材，不走缓存，直接网络加载
		 * @param url
		 * @param onComplete 参数为具体的Resource对象 -- resource.data == null 表示加载失败！
		 */
		public function loadResourceWithOutCache(url:String, onComplete:Function):void
		{
			_rsLoader.loadResouceWithOutCache(url, onComplete);
		}

		public function saveVersionResource(name:String, bytes:ByteArray):void
		{
			_rsLoader.saveVersionResource(name, bytes);
		}

		public function appendBytesToVFS(name:String, bytes:ByteArray):Boolean
		{
			return _rsLoader.appendBytesToVFS(name, bytes);
		}

		public function hasFile(name:String):Boolean
		{
			return _rsLoader.hasFile(name);
		}

		/**
		 * 请求一张位图
		 * @param swf 必须为swf。
		 * @param onComplete 请求的回调函数。回调函数的参数为Bitmap类型。
		 * 					 请求失败的话，回调函数传null：onComplete(null);
		 * @param width 位图的宽 默认原始宽
		 * @param height 位图的高 默认原始高
		 */
		public function requestBitmap(swf:String, onComplete:Function, width:int = 0, height:int = 0):void
		{
			_rsLoader.requestBitmap(swf, onComplete, width, height);
		}

		/**
		 * 发送http请求
		 * @param requestId  后台接口id --- 业务应该实现一个自己的IServerServices服务.
		 * @param getParams  get参数
		 * @param postParams post参数
		 * @param onComplete 返回成功
		 * @param onNetError 请求失败
		 */
		public function request(requestId:int, //
			getParams:Object = null, //
			postParams:URLVariables = null, //
			onComplete:Function = null, //
			onNetError:Function = null, //
			packager:IPackage = null, //request
			parser:IParser = null //reponse
			):void
		{
			if (_serverService == null)
				throw new Error("ServerServie Must be Initalize!!");
			_serverService.request(requestId, getParams, postParams, onComplete, onNetError, packager, parser);
		}

		public function set mainloop(bool:Boolean):void
		{
			if (_appStage == null)
				return;
			if (_mainloop == bool)
				return;
			_mainloop = bool;
			if (_mainloop)
				_appStage.addEventListener(Event.ENTER_FRAME, onEachFrame);
			else
				_appStage.removeEventListener(Event.ENTER_FRAME, onEachFrame);
		}

		public function get app():IApplication
		{
			return this;
		}

		public function get rsLoader():ResourceLoader
		{
			return _rsLoader;
		}

		public function get textureLoader():TextureLoader
		{
			return _textureLoader;
		}

		/*******
		 *
		 * 自己构造对外的事件接口的目的是兼容Starling的消息事件模型。
		 * 同时，也方便未来的hook功能
		 *
		 * *********/
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			_dispatcher.addEventListener(type, listener, useCapture, 0, useWeakReference);
		}

		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			_dispatcher.removeEventListener(type, listener, useCapture);
		}

		public function dispatchEvent(event:Event):Boolean
		{
			return _dispatcher.dispatchEvent(event);
		}

		public function hasEventListener(type:String):Boolean
		{
			return _dispatcher.hasEventListener(type);
		}

		public function willTrigger(type:String):Boolean
		{
			return _dispatcher.willTrigger(type);
		}


		//********************************************************************************************************
		//********************************************************************************************************
		//APNS 基础服务逻辑
		//********************************************************************************************************
		//********************************************************************************************************
		private var _notifier:RemoteNotifier;
		private var _tokenId:String = null;
		private var _support:Boolean;

		/**
		 * 启动远程推送服务
		 */
		protected function setupRemoteNotificationService():void
		{
			if (_notifier == null)
			{
//				_notifier.unsubscribe()
				_notifier = new RemoteNotifier();
				_notifier.addEventListener(RemoteNotificationEvent.TOKEN, tokenHandler);
				_notifier.addEventListener(RemoteNotificationEvent.NOTIFICATION, notificationHandler);
				_notifier.addEventListener(StatusEvent.STATUS, statusHandler);
			}

			if (RemoteNotifier.supportedNotificationStyles.toString() != "")
			{
				_support = true;
				Debugger.log("[RemoteNotification]:subscribe remote notification.");
				_notifier.subscribe();
			}
			else
				Debugger.log("[RemoteNotification]:该设备不支持远程推送通知。");
		}

		protected function tokenHandler(e:RemoteNotificationEvent):void
		{
			Debugger.log("[RemoteNotification]:deviceToken=" + e.tokenId);
			_tokenId = e.tokenId;
		}

		protected function notificationHandler(e:RemoteNotificationEvent):void
		{
			Debugger.log("[RemoteNotification]:receiveNotification:", JSON.stringify(e.data));
		}

		protected function statusHandler(e:StatusEvent):void
		{
			Debugger.log("[RemoteNotification]:subscribe failed!(level=" + e.level + ",code=" + e.code + ",currentTarget=" + e.currentTarget.toString() + ")")
		}


		public function get tokenId():String
		{
			return _tokenId;
		}

		public function get isSupportRemoteNotifiction():Boolean
		{
			return _support;
		}

		public function get remoteNotifier():RemoteNotifier
		{
			return _notifier;
		}

		private var _deviceInfo:DeviceInfo;

		public function get deviceInfo():DeviceInfo
		{
			if (_deviceInfo == null)
				_deviceInfo = new DeviceInfo(null);
			return _deviceInfo;
		}

		//登录信息
		private var _loginInfo:LoginData;

		public function get loginInfo():LoginData
		{
			return _loginInfo;
		}

		public function set loginInfo(value:LoginData):void
		{
			_loginInfo = value;
		}


		public function get appStage():Sprite
		{
			return _appStage
		}
	}
}

