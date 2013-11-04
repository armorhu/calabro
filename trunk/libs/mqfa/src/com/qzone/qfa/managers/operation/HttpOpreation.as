package com.qzone.qfa.managers.operation
{
	import com.qzone.qfa.managers.errors.RequestError;
	import com.qzone.qfa.managers.events.RequestErrorEvent;
	import com.qzone.qfa.managers.events.RequestResultEvent;

	import flash.display3D.IndexBuffer3D;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.utils.Timer;
	import flash.utils.clearInterval;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	/**
	 * 对QFA框架底层类的一个扩展，增加了timeout控制，并且在此截获了一些常见的errors并处理，统一向上抛出
	 */
	[Event(name = "RequestErrorEvent_Error", type = "com.qzone.qfa.managers.events.RequestErrorEvent")]
	[Event(name = "RequestResultEvent_Result", type = "com.qzone.qfa.managers.events.RequestResultEvent")]
	public class HttpOpreation extends URLLoader implements IOperation
	{
//		/**检查超时的Timer**/
//		private static var timeOutTimer:Timer;
		private static const TIME_OUT:int = 15000;

		private var m_byteTotal:Number; //本次请求的数据量
		private var m_byteLoaded:Number; //已经加载了的数据量
		private var _sendTime:int; //发送的时间
		private var _timeoutID:uint;

		public function HttpOpreation()
		{
//			if (timeOutTimer == null)
//			{
//				timeOutTimer = new Timer(1000); //一秒一跳。
//				timeOutTimer.addEventListener(TimerEvent.TIMER, onEachTimer);
//			}

			addEventListener(Event.COMPLETE, handleComplete);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleError);
			addEventListener(IOErrorEvent.IO_ERROR, handleError); // http status code 500时捕捉不到
			addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseHandler);
			addEventListener(ProgressEvent.PROGRESS, onProgress); //http progress;
		}

		private function onEachTimer(e:Event):void
		{

		}

		public function send(body:Object = null):void
		{
			load(body as URLRequest);
			_sendTime = getTimer();
			m_byteTotal = 0;
			m_byteLoaded = 0;
			_timeoutID = setTimeout(handleTimeOut, TIME_OUT);
		}

		private function handleTimeOut():void
		{
			dispatchErrorEvent(RequestError.HTTP_ERR_TIMEOUT, "网络超时");
			close();
		}

		private function handleComplete(e:Event):void
		{
			dispatch(RequestResultEvent.RESULT, e.currentTarget.data);
			close();
		}

		private function handleError(e:Event):void
		{
			close();
			if (e.type == IOErrorEvent.IO_ERROR)
				dispatchErrorEvent(RequestError.HTTP_ERR_IOERROR, "网络io错误");
			else if (e.type == SecurityErrorEvent.SECURITY_ERROR)
				dispatchErrorEvent(RequestError.HTTP_ERR_SECURITY, "安全错误");
		}

		private function httpStatusHandler(e:HTTPStatusEvent):void
		{
			if (e.status > 400 && e.status <= 510)
			{
				close();
				if (e.status < 500)
					dispatchErrorEvent(RequestError.HTTP_ERR_HTTPSTATUS_4, e.status.toString());
				else
					dispatchErrorEvent(RequestError.HTTP_ERR_HTTPSTATUS_5, e.status.toString());
			}
		}

		private function httpResponseHandler(e:HTTPStatusEvent):void
		{
			if (e.responseHeaders)
			{
				const len:int = e.responseHeaders.length;
				var header:URLRequestHeader
				for (var i:int = 0; i < len; i++)
				{
					header = e.responseHeaders[i];
					if (header.name == "Content-Length")
						m_byteTotal = parseFloat(header.value);
				}
			}
		}

		private function onProgress(e:ProgressEvent):void
		{
			m_byteLoaded = e.bytesLoaded;
			if (m_byteTotal == 0)
				m_byteTotal = e.bytesTotal;
		}

		/**
		 * 抛事件的辅助方法
		 * @param type
		 * @param data
		 */
		protected function dispatch(type:String, data:*):void
		{
			var requestEvent:RequestResultEvent = new RequestResultEvent(type, data);
			requestEvent.bytesLoaded = m_byteLoaded;
			requestEvent.bytesTotal = m_byteTotal;
			requestEvent.responseTime = getTimer() - _sendTime; //响应时长
			dispatchEvent(requestEvent);
		}

		/**
		 * 抛错误事件的辅助方法。
		 * @param errorType
		 * @param errorContent
		 */
		protected function dispatchErrorEvent(errorType:int, errorContent:String):void
		{
			var requestEvent:RequestErrorEvent = new RequestErrorEvent(RequestErrorEvent.ERROR, errorType, errorContent);
			requestEvent.bytesLoaded = m_byteLoaded;
			requestEvent.bytesTotal = m_byteTotal;
			requestEvent.responseTime = getTimer() - _sendTime; //响应时长
			dispatchEvent(requestEvent);
		}

		public override function close():void
		{
//			try
//			{
//				super.close();
//			}
//			catch (error:Error)
//			{
//
//			}
			clearInterval(_timeoutID);
			this.removeEventListener(Event.COMPLETE, handleComplete);
			this.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handleError);
			this.removeEventListener(IOErrorEvent.IO_ERROR, handleError); // http status code 500时捕捉不到
			this.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			this.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseHandler);
			this.removeEventListener(ProgressEvent.PROGRESS, onProgress); //http progress;
		}
	}
}
