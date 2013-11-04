package com.qzone.corelib.net
{
	import com.qzone.qfa.managers.resource.ResourceLoader;

	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.system.ApplicationDomain;

	/**
	 *
	 * @author cbm
	 */


	/**
	 * requestClass 完成时的 complete 事件。
	 */
	[Event(name = "complete", type = "flash.events.Event")]

	public class RSLManager
	{
		/**
		 *
		 * @throws Error
		 */
		public function RSLManager()
		{
			if (instance != null)
			{
				throw new Error("实例化单例类出错");
			}
		}
		/**
		 * 设置 RSLLoader 实例。
		 */
		public var rslLoader:RSLLoader;


		/**
		 * 设置AssestManager 实例。
		 * **/
		public var assetsManager:ResourceLoader;

		/**
		 * 查询的 ApplicationDomain
		 */
		public static var applicationDomain:ApplicationDomain;

		private static var instance:RSLManager;


		/**
		 * 获得 RSLManager 实例
		 */
		public static function getInstance():RSLManager
		{
			if (instance == null)

				instance = new RSLManager();

			return instance;
		}

		/**
		 * 获得一个素材的类
		 */
		public static function getClass(name:String):Class
		{
			trace("get class:" + name);
			if (applicationDomain.hasDefinition(name))
			{

				return applicationDomain.getDefinition(name) as Class;
			}

			return null;
		}

		/**
		 * 获得素材实例
		 */

		public static function getMaterial(name:String):Object
		{
			var cls:Class = getClass(name) as Class;

			if (cls)
			{
				return new cls();
			}

			return null;
		}

		/**
		 * 检查程序内存中的资源，如果存在则发送 Event.COMPLETE 事件，不存在则发起网络加载，完成时再次检查资源并发送完成事件。
		 *
		 * @param name 导出资源名称。
		 * @param callback 完成时或存在时的回调函数
		 * @param url 资源所在的 url 地址。
		 * @param rest 回调函数callback中的不定项参数
		 */
		public function requestClass(name:String, callback:Function, url:String = null, data:Object = null):void
		{

			trace("[RSLManager] requestClass() name=" + name, "url=" + url);
			if (getClass(name))
			{
				if (data)
				{
					callback && callback(data);
				}
				else
				{
					callback && callback();
				}
			}
			else
			{
				if (url == null || url == "")
					return;

				rslLoader.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void
				{
					e.currentTarget.removeEventListener(Event.COMPLETE, arguments.callee);
					requestClass(name, callback, url, data);
				})

				if (url.indexOf("appimg1.") != -1 && callback != null)
				{ // 404错误特殊反馈
					rslLoader.loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, function(e:HTTPStatusEvent):void
					{
						if (e.status == 404)
							callback({"404": true});
					});
				}
				trace("rsl loading url:" + url)
				rslLoader.load([{'url': url}]);
			}
		}

		/**
		 * 仅仅是assetsManager的中转站
		 * @param callback
		 * @param url
		 * @param useCache
		 */
		public function requestFile(callback:Function, url:String = null, useCache:Boolean = true):void
		{
			assetsManager.requestFile(callback, url, useCache);
		}

	} //class
}
