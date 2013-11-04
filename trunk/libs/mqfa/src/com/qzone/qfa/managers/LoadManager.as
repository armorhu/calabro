package com.qzone.qfa.managers 
{
	import com.qzone.qfa.managers.events.LoaderEvent;
	import com.qzone.qfa.managers.resource.Resource;
	import com.qzone.qfa.managers.resource.ResourceType;
	
	import flash.display.*;
	import flash.events.*;
	import flash.media.Sound;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.system.ApplicationDomain;
	import flash.system.ImageDecodingPolicy;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.utils.Dictionary;
	
	/**
	 * QFA资源读取管理器
	 * 可以读取文本，音频，图片的加载管理器
	 * @author Demon.S
	 */
	[Event(name = "qfa.LoaderEvent.STATUS_CHANGED", type = "com.qzone.qfa.managers.events.LoaderEvent")]
	[Event(name = "qfa.LoaderEvent.ID3_COMPLETE", type = "com.qzone.qfa.managers.events.LoaderEvent")]
	[Event(name = "qfa.LoaderEvent.ERROR", type = "com.qzone.qfa.managers.events.LoaderEvent")]
	[Event(name = "qfa.LoaderEvent.START", type = "com.qzone.qfa.managers.events.LoaderEvent")]
	[Event(name = "qfa.LoaderEvent.PROGRESS", type = "com.qzone.qfa.managers.events.LoaderEvent")]
	[Event(name = "qfa.LoaderEvent.COMPLETE", type = "com.qzone.qfa.managers.events.LoaderEvent")]
	[Event(name = "qfa.LoaderEvent.QUEUE_CHANGED", type = "com.qzone.qfa.managers.events.LoaderEvent")]
	[Event(name = "qfa.LoaderEvent.QUEUE_START", type = "com.qzone.qfa.managers.events.LoaderEvent")]
	[Event(name = "qfa.LoaderEvent.QUEUE_PROGRESS", type = "com.qzone.qfa.managers.events.LoaderEvent")]
	[Event(name = "qfa.LoaderEvent.QUEUE_COMPLETE", type = "com.qzone.qfa.managers.events.LoaderEvent")]
	[Event(name = "qfa.LoaderEvent.COMPATIBLE_COMPLETE", type = "com.qzone.qfa.managers.events.LoaderEvent")]
	public class LoadManager extends EventDispatcher 
	{
		public static const STATUS_LOADING:String = "loading";	//读取状态
		public static const STATUS_STOPPED:String = "stopped";	//停止状态
		public static var flowReprotFunc:Function;        //统计网络流量的函数
		private var _queue:Array;							//读取队列，并行加载
		private var _map:Dictionary;						//读取映射，内含Resource类型的资源集合
		private var _itemLoaded:int;						//已经读取的item个数
		private var _itemFailed:int;						//读取出错的item个数
		private var _percentQueue:Number;					//队列进度
		private var _context:LoaderContext;					//传递applicationDomain的loader context
		private var _status:String;							//当前状态
		
		public function LoadManager() 
		{
			reset();
			_maxThreadCount=1;
			_context = new LoaderContext();
			_context.applicationDomain = ApplicationDomain.currentDomain;
		}
		private function reset():void{
			_itemLoaded = 0;
			_itemFailed=0;
			_loadingThreadCount=0;
			_percentQueue = 0;
			_map=new Dictionary();
			_queue=[];
			_loadingThreadCount=0;
			if (_status != STATUS_STOPPED) setStatus(STATUS_STOPPED);
		}
		/**
		 * 批量增加事件，简化使用方法 
		 * @param eventHandler
		 */
		private var _eventList:Array=[LoaderEvent.COMPLETE,LoaderEvent.ERROR,LoaderEvent.ID3_COMPLETE,LoaderEvent.PROGRESS,LoaderEvent.QUEUE_CHANGED,LoaderEvent.QUEUE_COMPLETE,LoaderEvent.QUEUE_PROGRESS,LoaderEvent.QUEUE_START,LoaderEvent.START,LoaderEvent.STATUS_CHANGED]
		public function addEventListeners(eventHandler:Function):void
		{
			for each(var s:String in _eventList) addEventListener(s, eventHandler,false,0,false);
		}
		/**
		 * 批量删除事件，简化使用方法 
		 * @param eventHandler
		 */		
		public function removeEventListeners(eventHandler:Function):void
		{
			for each(var s:String in _eventList) removeEventListener(s, eventHandler);
		}
		/**
		 * loader item 数量, int, read only
		 */
		public function get count():int
		{
			return _queue.length;
		}
		/**
		 * 并发加载的线程数量，当大于1开启并发模式。
		 */
		private var _maxThreadCount:uint;
		public function set maxThreadCount(c:uint):void
		{
			_maxThreadCount = Math.max(c,0);
		}
		public function get maxThreadCount():uint
		{
			return _maxThreadCount;
		}
		/**
		 * 正在使用中的线程数 
		 * @return 
		 */
		private var _loadingThreadCount:int;
		public function get loadingThreadCount():uint
		{
			return _loadingThreadCount;
		}
		private function loadItem():void {
			if (_status == STATUS_LOADING && _queue.length) 
			{
				var tempLoadItem:LoadItem;
				var res:Resource;
				var request:URLRequest;
				var _loader:*;
				for (var i:int=0,l:int=_queue.length;i<l && _loadingThreadCount<_maxThreadCount;i++,_loadingThreadCount++){
					//get a loadingitem
					tempLoadItem = LoadItem(_queue[_loadingThreadCount]);
					if( !tempLoadItem ) return;
					for(var o :* in _map) if (_map[o]==tempLoadItem) return;
					res = tempLoadItem.resource;
					request = new URLRequest(res.url);
					var header:URLRequestHeader;
					if ((res.type == ResourceType.TYPE_BITMAP) || (res.type == ResourceType.TYPE_SWF)) 
					{	
						if(res.type == ResourceType.TYPE_SWF && !res.url.indexOf("file://")){
							_context.securityDomain = SecurityDomain.currentDomain;
						}else{
							_context.securityDomain = null;//本地文件测试不需要securitydomain
						}
						_context.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
						//load image & swf
						_loader = new Loader();
						setListeners(Loader(_loader).contentLoaderInfo);
						
						//test for warning img
						header = new URLRequestHeader("Referer", " http://appbase.qzone.qq.com/cgi-bin/index/appbase_run_unity.cgi?appid=353&max=0&qz_height=600&qz_width=760&qz_ver=6&appcanvas=1&via=QZ.MYAPP");
						request.requestHeaders.push(header);
						
						Loader(_loader).load(request,_context);
						
						_loader = _loader.contentLoaderInfo;
						
						res.loaderInfo = _loader as LoaderInfo;		// 赋值提前
					}
					else if (res.type == ResourceType.TYPE_MP3) 
					{
						// load audio file
						_loader = new Sound();
						setListeners(_loader);
						Sound(_loader).load(request);
					}
					else 
					{
						_loader = new URLLoader();
						if(res.type == ResourceType.TYPE_BINARY)
						{
							URLLoader(_loader).dataFormat = "binary";
							
						}
						header = new URLRequestHeader("Referer", " http://appbase.qzone.qq.com/cgi-bin/index/appbase_run_unity.cgi?appid=353&max=0&qz_height=600&qz_width=760&qz_ver=6&appcanvas=1&via=QZ.MYAPP");
						request.requestHeaders.push(header);
						
						
						setListeners(_loader);
						URLLoader(_loader).load(request);
					}
					
					res.loader = _loader;
					tempLoadItem.loader = _loader;
					_map[_loader] = tempLoadItem;
				}				
			}
		}
		private function setListeners(dispatcher:IEventDispatcher):void 
		{
			dispatcher.addEventListener(Event.OPEN, openHandler,false,0,false);
			dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler,false,0,false);
			dispatcher.addEventListener(Event.COMPLETE, completeHandler,false,0,false);
			dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpstatusHandler,false,0,false);
			dispatcher.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpstatusHandler,false,0,false);
			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler,false,0,false);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, errorHandler,false,0,false);
            if (dispatcher is Sound) dispatcher.addEventListener(Event.ID3, ID3Handler,false,0,false);  
        }

		private function httpstatusHandler(e:HTTPStatusEvent):void
		{
			var tempItem:LoadItem = _map[e.target];
			if(e.type == HTTPStatusEvent.HTTP_STATUS){ //请求的
				tempItem.status = e.status;
				//skip error
				if (e.status == 404)
					tempItem.stopReportTimer();
			}
			else if(e.type == HTTPStatusEvent.HTTP_RESPONSE_STATUS){//回复的
				/**
				 * ProgressEvent.bytesTotals莫名奇妙会变成０
				 * 这种情况下，只能怒取responseHeaders中的Content—length字段了！
				 * **/
				if(e.responseHeaders){
					const len:int = e.responseHeaders.length;
					var header:URLRequestHeader
					for (var i:int = 0; i < len; i++) 
					{
						header = e.responseHeaders[i];
						if(header.name == "Content-Length")
							tempItem.bytesTotal = parseFloat(header.value);
					}
				}
			}
		}
		private function removeListeners(dispatcher:IEventDispatcher):void 
		{
			dispatcher.removeEventListener(Event.OPEN, openHandler);
			dispatcher.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
			dispatcher.removeEventListener(Event.COMPLETE, completeHandler);
			dispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			dispatcher.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpstatusHandler);
			dispatcher.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS,httpstatusHandler);
			dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
            if (dispatcher is Sound) dispatcher.removeEventListener(Event.ID3, ID3Handler);  
        }	
		private function openHandler(e:Event = null):void 
		{
			dispatchEvent(packageEvent(LoaderEvent.START,this,0,_percentQueue,_map[e.target].resource));
        }
        private function progressHandler(e:ProgressEvent):void 
        {
			//计算队列和当前的进度
			var len:int = _queue.length;
			var loaditem:LoadItem=_map[e.target];
			_percentQueue = 0;
			
			//fix 404时候进度不准
			if (e.bytesTotal < 1000) loaditem.percent = 50;
			else loaditem.percent = e.bytesLoaded/e.bytesTotal *100;
			loaditem.bytesLoaded = e.bytesLoaded;
			if(loaditem.bytesTotal == 0)
				loaditem.bytesTotal = e.bytesTotal;
			
			for(var o:* in _map)
			{
				if (_map[o].percent) _percentQueue += _map[o].percent;
			}
			
			_percentQueue= (100*_itemLoaded+_percentQueue) / (_itemLoaded+_itemFailed+len);
			var percentItem:Number = loaditem.percent;
			// item event
			dispatchEvent(packageEvent(LoaderEvent.PROGRESS,this,percentItem,_percentQueue,loaditem.resource));
			
			// queue event
			dispatchEvent(packageEvent(LoaderEvent.QUEUE_PROGRESS,this,percentItem,_percentQueue,loaditem.resource));
			
			//prepare to report unkonwn error
			loaditem.startReportTimer();			
		}
		
		private function completeHandler(e:* = null):void 
		{
			//停止报未知错误	
			var tempItem:LoadItem = _map[e.target];
			if (tempItem == null)
				return; // 主动stop的时候，会为null
			tempItem.stopReportTimer();
			tempItem.removeEventListener(LoaderEvent.ERROR, unknownErrorHandler);
			
			//处理文件
			processFile(e);
			delete _map[e.target];
			tempItem.percent=100;
			_itemLoaded++;
			clearCurrentItem(e);
			reportFlow(tempItem);
			
			afterComplete(tempItem);
        }
		private function afterComplete(tempItem:LoadItem):void
		{
			//准备下次读取
			for (var i:uint = 0, l:uint = _queue.length; i < l; i++)
			{
				if(_queue[i] == tempItem) _queue.splice(i,1);
			}
			if (_queue.length == 0) setStatus(STATUS_STOPPED);
			
			if (_loadingThreadCount>0) _loadingThreadCount--;

			if(tempItem.percent==100)
				dispatchEvent(packageEvent(LoaderEvent.COMPLETE,this,100,_percentQueue,tempItem.resource));
			
			if (_queue.length) 
			{		
				loadItem(); //load next
			}
			else
			{
				dispatchEvent(packageEvent(LoaderEvent.QUEUE_COMPLETE,this,100,100,tempItem.resource));
				clear();
			}
		}
        private function ID3Handler(e:Event):void 
        {
        	var event:LoaderEvent = packageEvent(LoaderEvent.ID3_COMPLETE,this,_map[e.target].percent,_percentQueue,_map[e.target].resource)
			event.id3Info = e.target['id3'];
			dispatchEvent(event);
        }
		private function errorHandler(e:*):void 
		{
			var tempItem:LoadItem = _map[e.target];
			dispatchEvent(packageEvent(LoaderEvent.ERROR,this,tempItem.percent,_percentQueue,tempItem.resource,e.text));
			//skip error
			_itemFailed++;
			clearCurrentItem(e);
			reportFlow(tempItem);
			afterComplete(tempItem);
		}
		private function unknownErrorHandler(e:LoaderEvent):void
		{
			var tempItem:LoadItem = e.target as LoadItem;
			
			// prevent from flashplayer bug
			if (tempItem.percent >= 100 || tempItem.status == 200)
			{
				dispatchEvent(packageEvent(LoaderEvent.COMPATIBLE_COMPLETE, this, tempItem.percent, _percentQueue, tempItem.resource, "[LoaderManager]compatible complete"));
				completeHandler( { target:tempItem.loader } );
				return;
			}
			
			dispatchEvent(packageEvent(LoaderEvent.ERROR,this,tempItem.percent,_percentQueue,tempItem.resource,"[LoaderManager] unkown error"));
			//skip error
			_itemFailed++;
			clearCurrentItem(e);
			reportFlow(tempItem);
			afterComplete(tempItem);
		}

		/**
		 * 统计流量
		 * @param tempItem
		 */
		private function reportFlow(tempItem:LoadItem):void
		{
			if (flowReprotFunc == null)
				return;
			if (tempItem.resource.url.indexOf("http://") == 0)
			{ //是网络请求...统计下流量..
				flowReprotFunc(Math.min(tempItem.bytesLoaded, tempItem.bytesTotal));
			}
		}
		/**
		 * 状态 
		 */		
		public function get status():String 
		{ 
			return _status; 
		}
		private function setStatus(value:String):void 
		{
			_status = value;
		}

		/**
		 * 把读入的数据存储在资源中
		 */		
		private function processFile(e:* = null):void 
		{
			if (e) 
			{
				var loadItem:LoadItem=_map[e.target] as LoadItem;
				if (!loadItem) return;
				var res:Resource = loadItem.resource;
				
				if (res.type == ResourceType.TYPE_BITMAP) 
				{
					var file:Bitmap = (LoaderInfo(e.target).content is MovieClip) ? MovieClip(LoaderInfo(e.target).content).getChildAt(0) as Bitmap : LoaderInfo(e.target).content as Bitmap;
					res.data = file;
				}
				else if (res.type == ResourceType.TYPE_SWF) 
				{
					try
					{
						res.applicationDomain = LoaderInfo(e.target).applicationDomain;	
						res.data = LoaderInfo(e.target).content;
					}
					catch (err : Error)
					{
						trace(err.toString());
					}
				}
				else if (res.type == ResourceType.TYPE_MP3) 
				{
					res.data=e.target;
				}
				else 
				{
					res.data=URLLoader(e.target).data;
				}
			}
		}
		
		private function packageEvent(type:String,loader:*,p:Number,pq:Number,r:Resource,msg:String=""):LoaderEvent
		{
			var event:LoaderEvent=new LoaderEvent(type);
			event.loader = loader;
			event.percentItem=p;
			event.percentQueue=pq;
			event.item = r;
			event.queue_count = _itemLoaded;
			event.fail_count = _itemFailed;
			event.queue_length = _queue.length;
			if (msg) event.msg = msg;
			return event;
		}
		
		private function clear(e:Event=null):void {
			clearCurrentItem(e);
			if (!_itemFailed) reset();
			//if (_queue.length > 0) dispatchEvent(new LoaderEvent(LoaderEvent.QUEUE_CHANGED));
		}
		
		private function clearCurrentItem(e:*=null):void {
			if (e){
				removeListeners(IEventDispatcher(e.target));
			}else{
				for(var target:* in _map) removeListeners(target);
			}
		}
		/**
		 * 开始,队列中必须至少含有一个资源 
		 */		
		public function start():void {
			
			if (_status == STATUS_STOPPED && _queue.length > 0) 
			{
				setStatus(STATUS_LOADING);
				dispatchEvent(new LoaderEvent(LoaderEvent.QUEUE_START));
				loadItem();
			}
		}
		
		/**
		 * 停止读取，并清除队列
		 */		
		public function stop():void 
		{
			if (_status == STATUS_LOADING) 
			{
				clear();
				dispatchEvent(new LoaderEvent(LoaderEvent.QUEUE_CHANGED));
			}
		}
		
		private function findItem(url:String):Resource
		{
			var len:int = _queue.length;
			var item:Resource;
			for (var i:int = 0; i < len; i++ ) 
			{
				item = LoadItem(_queue[i]).resource;
				if (item.url == url) return item;
			}
			return null;
		}
		
		/**
		 * 增加一个欲读入的内容 
		 * @param url 地址
		 * @param params 扩展对象，比如{var1:1,var2:"s",foo:234}
		 * @return 一个标准的资源
		 * 
		 */				
		public function add(url:String, params:Object=null):Resource 
		{
			return addAt(url, _queue.length, params);
		}
		/**
		 * 按特定id增加一个欲读入的内容 
		 * @param url 地址
		 * @param index id,如果读取已经开始，则id不能为0
		 * @param params 扩展对象，比如{var1:1,var2:"s",foo:234}
		 * @return 一个标准的资源
		 */		
		public function addAt(url:String, index:int, params:Object = null):Resource 
		{
			var item:Resource = findItem(url);
			var loaditem:LoadItem;
			if (item == null) {				
				item = new Resource();
				item.url = url;
				if (params && params.type != undefined)
					item.type = params.type;
				else
					item.type = ResourceType.getType(url);
				loaditem = new LoadItem();
				loaditem.percent=0;
				loaditem.resource = item;
				loaditem.addEventListener(LoaderEvent.ERROR, unknownErrorHandler);
			}else return null;  //existing loading resource
			
			if (params!=null) {
				for (var o:String in params) {
					item[o] = params[o];
				}
			}
			if (index < 0 || index > _queue.length) return null; 
			//[LoaderManager] cannot add in 0 position while loading.
			if (_status == STATUS_LOADING && index == 0) return null;
			//insert into the loading queue
			_queue.splice(index, 0,loaditem);
			
			return item;			
		}
		
		private function removeItem(url:String, index:int = -1):Boolean 
		{
			//如果是读取中的item，暂时不允许删除
			for (var loader:* in _map) {
				if (_status == STATUS_LOADING && _map[loader].url == url) return false;	
			}

			if (url != null && url.length > 4) {  //file name : x.xxx
				var len:int = _queue.length;
				var item:Resource;
				for (var i:int = 0; i < len; i++ ) {
					item = LoadItem(_queue[i]).resource;
					if (item.url == url) {
						_queue.splice(i, 1);
						return true;
					}
				}
			}
			if (index>-1){
				_queue.splice(index, 1);
				return true;
			}
			return false;			
		}
		/**
		 * 删除读取对象 
		 * @param url 地址
		 * @return 成功标志
		 */		
		public function remove(url:String):Boolean 
		{			
			return removeItem(url);
		}
		/**
		 * 按id来删除队列中的资源
		 * @param index id
		 * @return 成功标志
		 */		
		public function removeAt(index:int):Boolean 
		{
			return removeItem(null, index);
		}
		/**
		 * 删除队列，清空排队资源 
		 */		
		public function removeAll():void 
		{
			clear();
			reset();
			dispatchEvent(new LoaderEvent(LoaderEvent.QUEUE_CHANGED));
		}	
	}
}
import com.qzone.qfa.managers.events.LoaderEvent;
import com.qzone.qfa.managers.resource.Resource;
import com.qzone.qfa.managers.resource.ResourceType;

import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.EventDispatcher;
import flash.media.Sound;
import flash.net.URLLoader;
import flash.utils.clearInterval;
import flash.utils.setInterval;
/**
 * LoadItem
 * 用来判断异常读取状态，以及实现异步加载
 */
internal class LoadItem extends EventDispatcher {
	/**
	 * 负责读取的resource
	 */
	public var resource:Resource;
	/**
	 * 当前下载的百分比(浮点数，0~100)
	 */	
	public var percent:Number;
	
	/**
	 * 当前下载的字节数
	 * */
	public var bytesLoaded:Number;
	
	/**
	 * 需要下载的总字节数
	 * */
	public var bytesTotal:Number;
	
	// timer id
	private var tid:uint;	
	
	// http status
	public var status:int = -1;
	
	// loader target
	public var loader:EventDispatcher;
	
	private var _loop:int = 0
	
	/**
	 * 开始准备上报错误
	 */
	public function startReportTimer():void {
		stopReportTimer();
		
		var delay:int = percent >= 100? 1000 : 5000; 
		tid = setInterval(handleTimeComplete, delay);
	}
	/**
	 * 停止上报
	 */
	public function stopReportTimer():void
	{
		if (tid) 
		{
			clearInterval(tid);
			tid = 0;
		}
	}
	
	private function handleTimeComplete():void 
	{
		var condition:Boolean = false;
		if (resource.loader is URLLoader)
		{
			// 文本、二进制加载处理
			condition ||= (resource.loader as URLLoader).data == null;
		}
		else
		if (resource.loader is LoaderInfo)
		{
			// 显示对象加载
			condition ||= resource.loaderInfo.content == null;
		}
		else
		{
			// 声音是流式加载，所以暂不做处理
		}
		
		// 有时候虽然素材加载百分比为100%，但是相关数据不可用，所以增加循环检测
		if (percent >= 100 && condition && ++_loop <= 30)
		{
			startReportTimer(); return;
		}
		
		stopReportTimer();
		
		var event:LoaderEvent=new LoaderEvent(LoaderEvent.ERROR);
		event.item = this.resource;
		dispatchEvent(event);
	}
}
