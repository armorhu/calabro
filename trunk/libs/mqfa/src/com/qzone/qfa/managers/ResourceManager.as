package com.qzone.qfa.managers
{
	import com.qzone.qfa.managers.events.LoaderEvent;
	import com.qzone.qfa.managers.resource.Resource;
	import com.qzone.qfa.managers.resource.ResourceType;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;

	/**
	 * QFA资源管理器
	 * 
	 * @author Demon.S
	 */
	public class ResourceManager
	{
		private static var _instance:ResourceManager;
		
		private var _dataList:Dictionary;
		/**
		 * 加载资源的LoadManager实例 
		 */		
		public var loadManager:LoadManager;
		
		public function ResourceManager(enf:Enforcer) 
		{
			_dataList = new Dictionary(true);
		}
		/**
		 * 两种方法获取实例指针 
		 * @return 实例
		 * 
		 */		
		public static function gi():ResourceManager
		{
			return _instance ||= new ResourceManager(new Enforcer());
		}
		public static function get instance():ResourceManager
		{
			return gi();
		}
		
		private function findResource(url:String):Resource
		{
			return _dataList[url] as Resource;
		}
		
		/**
		 * 通过url取出一个资源
		 * @param	url 
		 * @return
		 */
		public function getResource(url:String):Resource
		{
			return findResource(url);
		}
		/**
		 * 增加资源
		 * 通常可以从外部读入配置文件来管理资源列表，资源列表名称则一般放在AppData中
		 * @param	res 资源数据
		 * @return
		 */
		public function addResource(res:Resource):Boolean
		{
			if (res && res.url && res.url.length > 4 && findResource(res.url) ==null) {
				_dataList[res.url] = res;
				return true;
			}
			return false;
		}
		/**
		 * 删除一个资源
		 * @param	url 地址
		 * @return	成功标志
		 */
		public function removeResource(url:String):Boolean
		{
			var res:Resource = findResource(url);
			if (res) {
				res.destroy();
				delete _dataList[url];
				return true;
			}
			return false;
		}
		/**
		 * 删除所有资源
		 */
		public function removeAll():void
		{
			for (var n:String in _dataList) {
				Resource(_dataList[n]).destroy();
				delete _dataList[n];
			}
		}
		
		/**
		 *  销毁函数
		 */
		public function destroy():void
		{
			removeAll();
			_dataList = null;
			_instance = null;
		}
		
		/**
		 * toString
		 * @return
		 */
		public function toString():String
		{
			var r:String = "";
			for (var n:String in _dataList) {
				r += "[Resource]" + n + "," + _dataList[n] + "\n";
			}
			return r;
		}
		
		/**
		 * 获取swf中的class
		 * @param	str class名
		 * @return
		 */		
		public function getClass(str:String):Class
		{
			var res:Resource;
			var context:ApplicationDomain;
			/**
			 * optimized for current domain
			 * PROBLEM: may conflicting classes with same name
			 */
			/*for (var n:String in _dataList) {
				res = _dataList[n];
				if (res.type == ResourceType.TYPE_SWF) {
					 if (res["applicationDomain"]) {
						context = res["applicationDomain"];
					}
					else*/ context =  ApplicationDomain.currentDomain;
					
					if (context.hasDefinition(str))
                        return context.getDefinition(str) as Class;
				//}
			//}
			return null;
		}
		
		/**
		 * 获取swf中的class ,并以instance返回
		 * @param	str class名
		 * @return class instance
		 */	
		public function getClassInstance(str:String):*
		{
			var cls:Class = getClass(str);
			if (!cls) return null;
			return new cls();
		}
		
		/**
		 * 根据URL获取一个图像,(可以是一个图片，也可以是一个swf)如果缓存中没有，就发起请求拉取完成后再把数据放到返回的Sprite实例中 
		 * @param url
		 * @onCompleted loadBytes完成的回调
		 * @width 当获取图片时可用，将Bitmap按比例缩放(width,height同时不为0)
		 * @height 当获取图片时可用，将Bitmap按比例缩放(width,height同时不为0)
		 * @return 
		 * 
		 */		
		public function getImageOrSwf(url:String,onCompleted:Function=null,width:int=0,height:int=0,autoBitmap:Boolean=true,failed:Function=null):Sprite
		{
			var img:Sprite = new Sprite();
			if(!url)return img;
			img.mouseChildren = false;
			img.cacheAsBitmap = true;
			var resource:Resource = findResource(url);
			var addImage:Function = function(res:Resource):void
			{
				var ld:Loader = new Loader();
				ld.contentLoaderInfo.addEventListener(Event.COMPLETE,function():void
				{
					ld.contentLoaderInfo.removeEventListener(Event.COMPLETE,arguments.callee);
					try
					{
						var bmp:Bitmap = ld.content as Bitmap;
						var bmpd:BitmapData;
						if(bmp)
						{
							bmpd = bmp.bitmapData.clone();
							if(width!=0 && height!=0)
							{
								bmpd = fixWH(bmpd,width,height,true);
							}
							img.addChild(new Bitmap(bmpd,"auto",true));
						}
						if(autoBitmap)
						{
							bmpd = new BitmapData(ld.width,ld.height,true,0x00000000);
							bmpd.draw(ld.content);
							if(width!=0 && height!=0)
							{
								bmpd = fixWH(bmpd,width,height,true);
							}
							img.addChild(new Bitmap(bmpd,"auto",true));
						}
						else
						{
							img.addChild(ld);
						}										
					}
					catch(err:Error)
					{
						img.addChild(ld);
					}
					if(onCompleted != null)
					{
						(!onCompleted.length)?onCompleted():onCompleted(img);
					}
				});
				ld.loadBytes(res.data);
			}
			if(resource&&resource.data&&resource.type==ResourceType.TYPE_BINARY)
			{
				addImage(resource);
			}
			else
			{
				//var type:String = (ResourceType.getType(url)==ResourceType.TYPE_SWF)?ResourceType.TYPE_BINARY:null;
				loadResource(url,function(res2:Resource):void
				{
					addImage(res2);
				},function():void{
					if (failed != null) {
						failed();
					}
				},null,ResourceType.TYPE_BINARY);
			}
			return img;
		}
		
		/**
		 * 异步加载资源，并回调 
		 * @param url 资源url
		 * @param onCompleted 成功回调：可以把对应该的resouce作为参数，也可以不带参数
		 * @param onError 失败的回调，无参数
		 * @param params 自定的一些参数，只透传不处理，会动态附加在resource实例中
		 * @param type 是否指定加载的类型，默认不指定
		 * 
		 */		
		public function loadResource(url:String,onCompleted:Function=null,onError:Function=null,params:Object=null,resourceType:String=null):void
		{
			var targetResource:Resource = findResource(url);
			if(targetResource&&targetResource.data&&(resourceType?(targetResource.type == resourceType):true))
			{
				if(onCompleted != null)
				{
					(!onCompleted.length)?onCompleted():onCompleted(targetResource);
				}
				return;
			}
			if(!loadManager)
			{
				loadManager = new LoadManager();
			}
			var succes:Function;
			var fault:Function;
			
			loadManager.addEventListener(LoaderEvent.COMPLETE,succes=function(e:LoaderEvent):void
			{
				if(e.item.url == url)
				{
					loadManager.removeEventListener(LoaderEvent.COMPLETE,arguments.callee);
					var temp:Resource = findResource(url);
					//正常情况下应该是相等的，但如果第一次加载发生了错误，第二次重试加载的Reasource实例会不相同，要重新添加
					if(temp != e.item)
					{
						delete _dataList[url];
						addResource(e.item);
					}
					if(fault != null)
					{
						loadManager.removeEventListener(LoaderEvent.ERROR,fault);
					}
					if(onCompleted != null)
					{
						(!onCompleted.length)?onCompleted():onCompleted(e.item);
					}
				}
			});
			
			if(onError != null)
			{
				loadManager.addEventListener(LoaderEvent.ERROR,fault=function(e:LoaderEvent):void
				{
					if(e.item && e.item.url == url)
					{
						loadManager.removeEventListener(LoaderEvent.ERROR,arguments.callee);
						if(succes != null)
						{
							loadManager.removeEventListener(LoaderEvent.COMPLETE,succes);
						}
						onError();
					}
				});
			}
			var newResource:Resource = loadManager.add(url,params);
			if(newResource)
			{
				if(resourceType)
				{
					newResource.type = resourceType;
				}
				addResource(newResource);
				loadManager.start();
			}
		}
		
		/**
		 * 缩放一个Bitmap 
		 * @param bmpd
		 * @param limitW
		 * @param limitH
		 * @param smoothing
		 * @return 
		 * 
		 */		
		protected function fixWH(bmpd:BitmapData,limitW:Number=670,limitH:Number=800,smoothing:Boolean=false):BitmapData
		{
			var w:int=bmpd.width;
			var h:int=bmpd.height;
			
			if(w==limitW&&h==limitH)
			{
				return bmpd;
			}
			
			if (w / limitW > h / limitH)
			{
				h=(h / w) * limitW;
				w=limitW;
			}
			else
			{
				w=(w / h) * limitH;
				h=limitH;
			}
			var bmp:Bitmap = new Bitmap(bmpd,"auto",smoothing);
			
			var temp:BitmapData = new BitmapData(w,h, true, 0x000000);
			
			temp.draw(bmp,new Matrix(w/bmpd.width,0,0,h/bmpd.height,0,0),null,null,null,smoothing);
			
			bmpd.dispose();
			
			return temp;
		}
	}
	
}

class Enforcer{}