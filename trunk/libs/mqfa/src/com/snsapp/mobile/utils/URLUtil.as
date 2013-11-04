package com.snsapp.mobile.utils
{

	/**
	 * url的解析工具类
	 * @author hufan
	 */
	public class URLUtil
	{
		/**
		 * 根据一个url，返回它的文件名，带扩展名!
		 * @param url
		 * @return
		 * eg:
		 * url = appimg.qq.com/a.swf
		 * return a.swf
		 */
		public static function getName(url:String, ext:Boolean = true):String
		{
			var start:int = url.lastIndexOf('/');
			var end:int = ext ? int.MAX_VALUE : url.lastIndexOf('.');
			if (end <= start)
				end = int.MAX_VALUE;
			return url.substring(start + 1, end);
		}

		/**
		 * 根据一个url，返回它的路径名
		 * @param url
		 * @return
		 * eg:
		 * url = appimg.qq.com/a.swf
		 * return appimg.qq.com
		 */
		public static function getPath(url:String):String
		{
			var start:int = url.lastIndexOf('/');
			if (start > 0)
				return url.substr(0, start);
			else
				return '';
		}
	}
}
