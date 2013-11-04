package com.qzone.qfa.debug
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;

	public class Debugger extends EventDispatcher
	{

		static public const SAVE_PATH:String = "com.qzone.qfa.debug/";

		/**
		 * Debugger是否可用的开关
		 */
		static public var ENABLED:Boolean = true;

		/**
		 * To do...这里应该使用服务器时间
		 */
		static private var _fileName:String;


		static private var _logBatch:LogBatch;

		static private var _ui:IConsoleWindow;

		static private var _stage:Stage;



		public static function init(stage:Stage, serverTime:Number, ui:IConsoleWindow = null):void
		{
			_fileName = serverTime + ".log";
			_stage = stage;
			_logBatch = new LogBatch();
		}


		public static function setUI(ui:IConsoleWindow):void
		{
			_ui = ui;
			if (_ui != null)
				_ui.setLogBatch(_logBatch);
		}


		/**
		 * 打印Log信息, 增加分类功能.
		 *
		 * @param args 如果最后一个参数是LogType枚举的类型, 则会将其记录进该类型的Log.
		 *             否则认为是LogType.MISC类型的Log.
		 *
		 * Demo:
		 * Debugger.log("123", "456", LogType.MISC);
		 *
		 */
		public static function log(... args):void
		{
			if (!ENABLED)
				return;

			var type:String = args[args.length - 1];
			var str:String = args.join(", ");
			if (args.length <= 1 || LogType.ALL_TYPES.indexOf(type) < 0)
			{
				type = LogType.MISC;
				str = args.join(", ");
			}
			else
			{
				str = args.slice(0, args.length - 1).join(", ");
			}
			if (_logBatch)
				_logBatch.createLog(type, str);
			trace(str);

			//更新ui
			if (_ui != null)
				_ui.update();
		}


		/**
		 * 断言.
		 *
		 * </p>
		 * ENABLED == true, 失败的断言会抛错。
		 * ENABLED == false, 失败的断言作为log纪录下来.
		 *
		 * @param expr
		 * @param errorMsg
		 *
		 */
		static public function assert(expr:Boolean, errorMsg:String = null):void
		{
			if (expr)
				return;

			var error:Error = new Error(errorMsg == null ? "Assert Error." : errorMsg);

			if (Capabilities.isDebugger)
				//debugger无法读取Error.getStackTrace()
				log(error.message, error.getStackTrace(), LogType.ASSERT);
			else
				log(error.message, LogType.ASSERT);

//			if (ENABLED)
//				//Treat ASSERT as ERROR.
//				throw new Error(error);
		}


		/**
		 * 将本次进程的所有Log保存到本地。
		 *
		 * @param file
		 * @return
		 *
		 */
		static public function save(uin:String, version:String, appid:String):Boolean
		{
			if (_logBatch == null)
				return false;
			var xml:XML = LogBatch.serialize(_logBatch);

			var so:SharedObject = SharedObject.getLocal("debugger");
			var u:String;
			if (uin == null || uin == "")
			{
				//如果没有uin，此时可能用户尚未登录。
				//就沿用旧的uin
				if (so.data.uin != null)
					u = so.data.uin;
			}
			else
			{
				u = uin;
				so.data.uin = uin;
				try
				{
					so.flush(100);
				}
				catch (error:Error)
				{

				}
			}

			xml.@uin = u;
			xml.@ts = new Date().time;
			xml.@version = version;
			xml.@appid = appid;

			var content:String = xml.toXMLString();
			//去换行
			content = content.replace(/[\n|\r]/g, "")

			try
			{
				var file:File = File.applicationStorageDirectory.resolvePath(SAVE_PATH + _fileName);
				var fs:FileStream = new FileStream();
				fs.open(file, FileMode.WRITE);
				fs.writeUTFBytes(content);
				fs.close();
			} 
			catch(error:Error) 
			{
				
			}
			return true;
		}


		/**
		 * 从本地加载某个log文件
		 * @param file
		 * @return
		 *
		 */
		static public function load(file:File):Boolean
		{
			if (file == null || !file.exists)
				return false;

			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.READ);
			var content:String = fs.readUTFBytes(fs.bytesAvailable);
			var xml:XML;
			var lb:LogBatch;
			try
			{
				xml = new XML(content);
				lb = LogBatch.deserialize(xml);
			}
			catch (err:Error)
			{
				return false;
			}

			if (lb == null)
				return false;

			//trace(xml.toXMLString());

			_logBatch = lb;
			return true;
		}



		/**
		 * 将最近一次登录的LogBatch提交到服务器。<br/>
		 * To do...如何把这个接口抽象，做成可配置，与业务无关。
		 * @params   跟随上报cgi的参数信息
		 * @callback 操作完成之后的返回，原型是callback(success:Boolean)，参数success表示成功与否。
		 */
		static public function uploadLastLoginBatch(params:Object, callback:Function):void
		{
			const firstSepr:String = "@@";
			const secondarySepr:String = "##";

			var file:File = File.applicationStorageDirectory.resolvePath(SAVE_PATH);
			if (!file.exists)
			{
				if (callback != null)
					setTimeout(callback, 10, false);
				return;
			}

			var arr:Array = file.getDirectoryListing();
			if (arr.length == 0)
			{
				if (callback != null)
					setTimeout(callback, 10, false);
				return;
			}

			arr.sort(compare);
			file = arr[arr.length - 1];
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.READ);
			var ba:ByteArray = new ByteArray();
			fs.readBytes(ba, 0, fs.bytesAvailable);
			fs.close();
			//压缩前大小
			var size1:int = ba.length;
			ba.compress();
			//压缩后大小
			var size2:int = ba.length;

//			if (Consts.DEBUG)
//			{
//				//debug时，把gzip包保存到本地
//				var zipFile:File = new File(file.nativePath.replace(".log", ".gzip"));
//				fs.open(zipFile, FileMode.WRITE);
//				fs.writeBytes(ba, 0, ba.length);
//				fs.close();
//			}

			var cgi:String = "http://nc.qzone.qq.com/cgi-bin/cgi_mobile_log_report?size1=" + size1 + "&size2=" + size2;
			if (params)
			{ //把params里面的参数放在cgi里面
				for (var key:String in params)
					cgi = cgi + "&" + key + "=" + params[key];
			}
			var ul:URLLoader = new URLLoader();
			var ur:URLRequest = new URLRequest(cgi);
			ur.contentType = "application/x-gzip";
			ur.data = ba;
			ur.method = URLRequestMethod.POST;
			ul.addEventListener(Event.COMPLETE, onResponse);
			ul.addEventListener(IOErrorEvent.IO_ERROR, onResponse);
			ul.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onResponse);
			ul.load(ur);

			function onResponse(evt:Event):void
			{
				ul.removeEventListener(Event.COMPLETE, onResponse);
				ul.removeEventListener(IOErrorEvent.IO_ERROR, onResponse);
				ul.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onResponse);

				if (callback != null)
					callback(evt.type == Event.COMPLETE);
			}

			//按创建时间，从旧到新排列
			function compare(file1:File, file:File):int
			{
				if (file.creationDate.time < file.creationDate.time)
					return -1;
				else if (file.creationDate.time > file.creationDate.time)
					return 1;
				return 0;
			}
		}


		/**
		 * 清除数据
		 */
		public static function clear():void
		{
			_logBatch.clear();
		}


		public static function controlUIDisplay(display:Boolean):void
		{
			if (_ui == null)
				return;
			display ? _ui.show() : _ui.hide();
		}


		public function Debugger()
		{
		}


		static public function __getLogBatch():LogBatch
		{
			return _logBatch;
		}
	}
}
