package com.qzone.qfa.utils
{
	import com.qzone.qfa.managers.ResourceManager;
	
	import flash.display.BitmapData;

	public class JsonUtil
	{
		private static var _cachedBitmapData:Object = {};
		private static var _nameMap:Object = null;
		/**
		 * 方便从一个object中得到一个int属性
		 */
		public static function getIntAttribute(obj:*, attr:String):int
		{
			if (obj == null)
				return 0;
			if (attr == null || attr.length == 0)
				return 0;
			if (obj[attr] == undefined)
				return 0;
			return parseInt(obj[attr]);
		}
		
		/**
		 * 方便从一个object中得到一个String属性
		 */
		public static function getStrAttribute(obj:*, attr:String):String
		{
			if (obj == null)
				return "";
			if (attr == null || attr.length == 0)
				return "";
			if (obj[attr] == undefined)
				return "";
			return obj[attr] as String;
		}
		public static function getClass(name:String):Class
		{
			if (name == null || name.length == 0)
				return null;
			return ResourceManager.gi().getClass(name);
		}
		
		public static function getCachedBitmapData(bitmapName:String, w:int, h:int):BitmapData
		{
			if (_cachedBitmapData.hasOwnProperty(bitmapName))
				return _cachedBitmapData[bitmapName];
			
			var C:Class = getClass(bitmapName);
			if (C != null)
			{
				var bitmapData:BitmapData = new C(w, h) as BitmapData;
				if (bitmapData is BitmapData)
				{
					_cachedBitmapData[bitmapName] = bitmapData;
				}
				return bitmapData
			}
			return null;
		}
		
//		/**
//		 * 通过uId字段查询cache里的好友的姓名
//		 */
//		public static function getNameById(uId:int):String
//		{
//			if (_nameMap == null)
//				_nameMap = Cookies.getObject("nameMap", 1)
//			
//			if (_nameMap != null && _nameMap[uId] != undefined)
//			{
//				return _nameMap[uId]["qz"];
//			}
//			return "";
//		}
//		/**
//		 *
//		 * @param path
//		 * @param data
//		 *
//		 */
//		public static function saveToLocal(path:String, data:ByteArray):void
//		{
//			var file:File = new File(path);
//			var fs:FileStream = new FileStream();
//			fs.open(file, FileMode.WRITE);
//			if (data == null)
//			{
//				trace("Can not save null to file.");
//			}
//			else
//			{
//				fs.writeBytes(data);
//			}
//			fs.close();
//		}
	}
}