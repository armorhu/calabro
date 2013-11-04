package com.qzone.qfa.managers.resource
{

	import com.qzone.qfa.debug.Debugger;

	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;


	/**
	 * ResourceLoader的一个辅助类。
	 * 当ResourceLoader从网络下载到一个二进制流的资源。会调用net2Local做一些本地化的处理
	 * 当ResourceLoader从本地加载一个二进制的资源共上层使用时。会调用bytesArray2Resource转换为具体的Resource类型
	 * @author hufan
	 */
	public class ResourceParser
	{
		private var _lc:LoaderContext;

		public function ResourceParser()
		{
			_lc = new LoaderContext(false, ApplicationDomain.currentDomain);
			_lc.allowCodeImport = true;
		}

		public function bytesToResource(bytes:ByteArray, url:String, parserComplete:Function):void
		{
			var res:Resource = new Resource;
			res.type = getResourceType(url);
			res.url = url;
			switch (res.type)
			{
				case ResourceType.TYPE_XML:
				{
					try
					{
						bytes.position = 0;
						res.data = bytes.readUTFBytes(bytes.bytesAvailable);
						res.data = new XML(res.data);
					}
					catch (error:Error)
					{
						Debugger.log(error.getStackTrace());
						res.data = null;
					}
					parserComplete(res);
					break;
				}
				/**图片格式的回调函数不再是回调一个png，而是回调Resouce对象。上层请改一下。。**/
				case ResourceType.TYPE_BITMAP:
				case ResourceType.TYPE_SWF:
				{
					var loader:Loader = new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadedComplete);
					loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadedComplete);
					try
					{
						loader.loadBytes(bytes, _lc); //统一加载到子域。
					}
					catch (error:Error)
					{
						loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadedComplete);
						loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadedComplete);
						loader = null;
						parserComplete(res);
					}

					function onLoadedComplete(e:Event):void
					{
						var loaderInfo:LoaderInfo = e.target as LoaderInfo;
						loaderInfo.removeEventListener(Event.COMPLETE, onLoadedComplete);
						loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadedComplete);
						if (e.type == Event.COMPLETE)
						{
							res.data = loaderInfo.content;
							res.loader = loaderInfo.loader;
							res.loaderInfo = loaderInfo;
						}
						parserComplete(res);
					}
					break;
				}
				default:
				{
					res.data = bytes;
					parserComplete(res);
					break;
				}
			}

		}

		/**
		 * 从网络加载的二进制资源，可能需要预处理，然后存在本地
		 */
		public function netToLocal(bytes:ByteArray, url:String, parserComplete:Function):void
		{
			parserComplete(bytes);
		}

		public function getResourceType(url:String):String
		{
			return ResourceType.getType(url);
		}
	}
}
