package com.qzone.qfa.managers.resource
{
	/**
	 * 资源类型
	 */
	public class ResourceType
	{
		
		/**
		 * 支持的类型 
		 */		
		public static const TYPE_BITMAP:String = "tBitmap";		//位图
		public static const TYPE_XML:String = "tXML";			//xml数据
		public static const TYPE_CSS:String = "tCSS";			//css数据
		public static const TYPE_TEXT:String = "tText";			//文本数据
		public static const TYPE_SWF:String = "tSWF";			//swf
		public static const TYPE_MP3:String = "tMP3";			//mp3音频
		public static const TYPE_UNKNOWN:String = "tUnknown";	//未知类型	
		public static const TYPE_BINARY:String = "tBinary";     //二进制
		
		public static function getType(aUrl:String):String {
			var regExpBitmap:RegExp = /(.*?).(jpg|jpeg|png|gif)/i;
			var regExpXML:RegExp = /(.*?).(xml)/i;
			var regExpCSS:RegExp = /(.*?).(css)/i;
			var regExpText:RegExp = /(.*?).(txt|rtf)/i;
			var regExpSWF:RegExp = /(.*?).(swf)/i;
			var regExpMP3:RegExp = /(.*?).(mp3)/i;
			if (regExpBitmap.test(aUrl)) return ResourceType.TYPE_BITMAP;
			else if (regExpXML.test(aUrl)) return ResourceType.TYPE_XML;
			else if (regExpCSS.test(aUrl)) return ResourceType.TYPE_CSS;
			else if (regExpText.test(aUrl)) return ResourceType.TYPE_TEXT;
			else if (regExpSWF.test(aUrl)) return ResourceType.TYPE_SWF;
			else if (regExpMP3.test(aUrl)) return ResourceType.TYPE_MP3;
			else return ResourceType.TYPE_UNKNOWN;
		}
	}

}