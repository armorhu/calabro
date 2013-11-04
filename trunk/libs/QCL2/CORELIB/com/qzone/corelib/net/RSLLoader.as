//------------------------------------------------------------------------------
//
//   Copyright 2010, Qzone, Tencent. 
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package com.qzone.corelib.net
{
	import com.snsapp.mobile.utils.MobileSystemUtil;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.utils.Timer;

	/**
	 * 资源加载器，用于逻辑程序和框架素材分离。包含在程序入口，进行需要的资源列表加载。
	 * @author cbm
	 * 
	 * 2010.08.17 修复了加载列表中存在空url的漏洞 
	 */
	public class RSLLoader
	{

		/**
		 * 设置被加载的 ApplicationDomain ，默认为当前域。在 load 之前设置有效。
		 */
		public var applicationDomain : ApplicationDomain;

		/**
		 * 列表某个完成时的回调函数。
		 */
		public var completeFn : Function;

		/**
		 * 等待加载 complete 事件的超时，默认 3000ms.
		 */
		public var contentCheckDelay : int = 3000;
		
		/**
		 * 错误回调
		 */
		public var errorFn : Function;

		/**
		 * 加载失败的url列表
		 */
		public var faultList : Array = [];

		/**
		 * 忽略错误
		 */
		public var ignoreError : Boolean;

		/**
		 * 列表全部完成时的回调
		 */
		public var listCompleteFn : Function;
		
		/**
		 * 重试次数
		 */
		public var retryTimes : uint = 1;
		
		/**
		 * 加载列表
		 */
		public var rsls : Array = [];
		
		private var _index : int; // 当前加载序号
		
		/**
		 * 设置被加载的 SecurityDomain 跨域加载素材需要设置。
		 */
		public var securityDomain : SecurityDomain;
		
		private var _checkTimer : Timer;
		
		private var _lc : LoaderContext;
		private var _loader : Loader;
		private var _req : URLRequest;
		private var _loading : Boolean;

		private var _retryUrls : Object = {};
		private var _url : String;
		
		private var _urls : Object = {};
		
		public function RSLLoader()
		{
			ignoreError = false;
			
			applicationDomain = ApplicationDomain.currentDomain;

			_lc = new LoaderContext();
			if (MobileSystemUtil.isMobile()) _lc.allowCodeImport=true;
			_req = new URLRequest();
			_loader = new Loader();
			_index = 0;
			_loading = false;

			_checkTimer = new Timer(contentCheckDelay, 1);
			_checkTimer.addEventListener(TimerEvent.TIMER, onTimeOut);

			//某些版本的FP的COMPLETE事件发不出来,换用OPEN事件开其检查.
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);
			_loader.contentLoaderInfo.addEventListener(Event.OPEN, onLoadOpen);
			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
		}
		
		/**
		 * 重置当前加载列表，使得可以开始下一次新的加载
		 */
		public function reset() : void
		{
			_urls = {};
			rsls = [];
			faultList = [];
			_retryUrls = {};
			_index = 0;
			_loading = false;
		}
		
		/**
		 * 开始加载资源列表，需要有url字段，预期格式为：{"url" : "http://resource_path"}
		 * @param rsls
		 */
		public function load(rsls : Array) : void
		{
			
			//this.rsls = this.rsls.concat(rsls);
			for each (var item : Object in rsls)
			{
				if (item == null || item["url"] == undefined)
					continue;
				var url : String = item["url"];
				trace("RSLLoader:url:"+url)
				if (url == "" || url == null)
					continue;
				if (_urls[url] === undefined)
				{
					this.rsls.push(item);
					_urls[url] = false;
				}
			}

			if (_loading == false)
			{
				if (_index < this.rsls.length)
				{
					_lc.applicationDomain = applicationDomain;
					if(!MobileSystemUtil.isMobile()) 
						_lc.securityDomain = securityDomain;
					loadRSL();
				}
			}
		}

		/**
		 * 获得loader的实例。可以直接访问loader的各种属性和方法以及事件。
		 * @return
		 */
		public function get loader() : Loader
		{
			return _loader;
		}

		public function get loading() : Boolean
		{
			return _loading;
		}

		private function loadNext(e : Event) : void
		{
			if (_index < rsls.length)
				loadRSL();
			else
				loadAllComplete(e);
		}

		private function loadRSL() : void
		{
			_url = rsls[_index]["url"];
			if (_url == "")
			{
				_loading = false;
				_index++;
				onLoadComplete(null);
			}
			else
			{
				_req.url = _url;
				_loading = true;
				_index++;
				
				/*if (_urls[_url] == true)
				{
					onLoadComplete(null);
				}
				else
				{*/
					trace("RSLLoader.loadRSL:"+_req.url)
					
					MobileSystemUtil.addRequestHeader(_req)
					_loader.load(_req, _lc);
				//}
			}
		}
		
		/**
		 * 超时后，重新加载当前请求
		 */
		private function loadRetry() : void
		{
			var url : String = _req.url;
			if (retryTimes == 0 || _retryUrls[url] >= retryTimes)
			{
				trace("RSLLoader timeout, force to load next one!");
				faultList.push(url);
				loadNext(null);
			}
			else
			{
				trace("RSLLoader Retry Load Again!");
				_loader.load(_req, _lc);
				if (_retryUrls[url] == undefined)
					_retryUrls[url] = 1; // reload for the first time
				else
					_retryUrls[url]++;
			}
		}
		
		/**
		 * 加载列表处理完毕，即使中间有失败的，也会通知客户完毕
		 */
		private function loadAllComplete(e : Event) : void
		{
			_loading = false;
			listCompleteFn && listCompleteFn(e);
		}
		
		private function onLoadOpen(e : Event) : void
		{
			_checkTimer.reset();
			_checkTimer.start();
		}
		
		private function onLoadProgress(e : ProgressEvent) : void
		{
			// do nothing
		}
		
		private function onLoadComplete(e : Event) : void
		{
			_checkTimer.stop();
			_urls[_url] = true;
			completeFn && completeFn(e);
			loadNext(e);
		}

		private function onLoadError(e : Event) : void
		{
			_checkTimer.stop();
			errorFn && errorFn(e);

			var url : String = _req.url;
			faultList.push(url);

			if (ignoreError)
			{
				loadNext(e);
			}
		}
		
		/**
		 * 超时处理，检查是否需要重新加载
		 * @param e
		 * @return
		 */
		private function onTimeOut(e : Event) : void
		{
			_checkTimer.stop();
			loadRetry();
		}
		
	}
}