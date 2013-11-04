package com.qzone.qfa.control
{
	import com.qzone.qfa.debug.Debugger;
	import com.qzone.qfa.debug.LogType;
	import com.qzone.qfa.interfaces.IPackage;
	import com.qzone.qfa.interfaces.IParser;
	import com.qzone.qfa.interfaces.IServerServices;
	import com.qzone.qfa.managers.errors.RequestError;
	import com.qzone.qfa.managers.errors.ServerLogicError;
	import com.qzone.qfa.managers.events.RequestErrorEvent;
	import com.qzone.qfa.managers.events.RequestEvent;
	import com.qzone.qfa.managers.events.RequestResultEvent;
	import com.qzone.qfa.managers.events.ServerLogicErrorVO;
	import com.qzone.qfa.managers.operation.HttpOpreation;
	
	import flash.net.URLRequest;

	/**
	 * 服务器服务的基类。
	 * @author hufan
	 */
	public class BaseServerServices implements IServerServices
	{
		public function BaseServerServices()
		{
		}

		public function getRequestURL(requestId:int):String
		{
			return null;
		}

		public function request( //
			requestId:int, //
			getParams:Object = null, //
			postParams:Object = null, //
			onComplete:Function = null, //
			onNetError:Function = null, //
			packager:IPackage = null, //request
			parser:IParser = null //reponse
			):void
		{

			var url:String = getRequestURL(requestId); //获取配置的url
			if (url == null)
			{
				if (onNetError != null)
					onNetError(new RequestErrorEvent(RequestErrorEvent.ERROR, RequestError.HTTP_ERR_UNKOWN_REQUESTID, "未知的请求id:" + requestId));
				return;
			}
			var backupGetParams:Object = clone(getParams);
			var backupPostParams:Object = clone(postParams);
			var http:HttpOpreation = new HttpOpreation();
			url = appendGetParams(url, getParams); //包装get参数
			var req:URLRequest = new URLRequest(url); //req
			req.data = postParams;
			req.method = "post";
			http.addEventListener(RequestErrorEvent.ERROR, onRequestError);
			http.addEventListener(RequestResultEvent.RESULT, onRequestComplete);
			encodeURLRequest(req);
			if (packager)
				packager.pack(req, http);
			if (parser == null)
				parser = getParser(requestId);
			http.send(req);

			function onRequestError(e:RequestErrorEvent):void
			{
				http.removeEventListener(RequestErrorEvent.ERROR, onRequestError);
				http.removeEventListener(RequestResultEvent.RESULT, onRequestComplete);
				http = null;
				Debugger.log("request error:", url, e.errorType, e.errorContext, LogType.NETWORK);
				trace("request error:", url);
				e.getParam = backupGetParams;
				e.postParam = backupPostParams;
				e.requestId = requestId;
				requestCompleteHook(e);
				if (onNetError != null)
					onNetError(e);
			}

			function onRequestComplete(e:RequestResultEvent):void
			{
				http.removeEventListener(RequestErrorEvent.ERROR, onRequestError);
				http.removeEventListener(RequestResultEvent.RESULT, onRequestComplete);
				http = null;
				Debugger.log("request complete:", url, "\nresposeDelay:" + e.responseTime + "ms", LogType.NETWORK);
				var respose:String = e.data;
				if (parser)
				{
					//当parser失败的时候，抛出数据解析失败的事件。
					try
					{
						e.data = parser.parser(e.data);
					}
					catch (error:Error)
					{
						Debugger.log(error.getStackTrace(), LogType.ERROR);
						if (error is ServerLogicError)
						{ //后台的逻辑错误。
							var err:RequestErrorEvent = new RequestErrorEvent(RequestErrorEvent.ERROR, //
								RequestError.HTTP_ERR_LOGIC_ERROR, '服务器逻辑失败!');
							Debugger.log("response parser failed:", url, "respose content:", respose, LogType.NETWORK);
							err.getParam = backupGetParams;
							err.postParam = backupPostParams;
							err.requestId = requestId;
							//将后台不统一的协议，在JSONParser层将协议统一了。。。
							//后台虽然协议不统一，但是咱们前台协议终于统一了！！！！。
							//如果发现后台的错误返回码的协议有问题。。。请到JSONParser里去规范。
							
							err.serverLogicErrorVO = error.message as ServerLogicErrorVO;
							requestCompleteHook(err);
							if (onNetError != null)
								onNetError(err);
							return;
						}
						e.data = null;
					}

					if (e.data == null)
					{
						var error:RequestErrorEvent = new RequestErrorEvent(RequestErrorEvent.ERROR, RequestError.HTTP_ERR_DATA_PARSER, '数据解析失败!');
						Debugger.log("response parser failed:", url, "respose content:", respose, LogType.NETWORK);
						error.getParam = backupGetParams;
						error.postParam = backupPostParams;
						error.requestId = requestId;
						requestCompleteHook(error);
						if (onNetError != null)
							onNetError(error);
						return;
					}
				}
				respose = null;
				e.getParam = backupGetParams;
				e.postParam = backupPostParams;
				e.requestId = requestId;
				requestCompleteHook(e);
				if (onComplete != null)
					onComplete(e);
			}
		}


		private function clone(obj:Object):Object
		{
			if (obj == null)
				return null;

			var r:Object = new Object();
			for (var key:String in obj)
				r[key] = obj[key];
			return r;
		}


		/**
		 * 辅助方法，在一个url后面追加get参数
		 * @param url
		 * @param getParams
		 * @return
		 */
		public function appendGetParams(url:String, getParams:Object):String
		{
			if (getParams != null)
			{
				var temp:int = url.indexOf("?");
				var getStr:String = "";
				if (temp != -1)
				{
					getStr = url.substr(temp + 1);
					url = url.substr(0, temp);
				}
				for (var key:String in getParams)
				{
					if (getStr == "")
						getStr = key + "=" + getParams[key];
					else
						getStr = getStr + "&" + key + "=" + getParams[key];
				}

				url = url + "?" + getStr;
			}

			return url;
		}

		protected function getParser(requestId:int):IParser
		{
			throw new Error("getParser method must implements by subclass!!");
		}

		/**
		 * URLRequest的编码方法。
		 * 交给子类实现
		 */
		protected function encodeURLRequest(req:URLRequest):void
		{
			//implements by sub class;
			throw new Error("pls override encodeURLRequest method!!");
		}

		protected function requestCompleteHook(e:RequestEvent):void
		{
		}
	}
}
