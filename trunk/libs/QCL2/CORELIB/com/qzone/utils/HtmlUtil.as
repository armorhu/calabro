package com.qzone.utils
{
	import flash.text.TextField;

	/**
	 * 用于转换HTML实体和还原HTML实体的类 
	 * @author youyeelu
	 * 
	 */	
	public class HtmlUtil
	{
		private static var _textField:TextField;
		
		/**
		 * 还原HTML实体 
		 * @param source 文字源
		 * @return 还原后的HTML
		 * 
		 */		
		public static function restHTML(source:String):String
		{
			if (!_textField)
			{
				_textField = new TextField();
			}
			
			_textField.htmlText = source.replace(/#39/ig, "'");
			return _textField.text;
		}
		
		/**
		 * 将HTML转为实体 
		 * @param source 文字源
		 * @return 转译后的HTML
		 * 
		 */		
		public static function escHTML(source:String):String
		{
			return source.replace(/\&/g, "&amp;").replace(/\ /g, "&nbsp;").replace(/\</g, "&lt;").replace(/\>/g, "&gt;").replace(/\'/, "&apos;").replace(/\"/g, "&quot;");
		}
		
		/**
		 * 获取文本的真实长度
		 * @param str 需要被获取的长度
		 * @return 
		 * 
		 */		
		public static function getRealLength(str:String):uint
		{
			var len:uint = str.replace(/[^\x00-\xff]/mg, "00").length;
			return len;
		}
	}
}