//------------------------------------------------------------------------------
//
//   Copyright 2010, Qzone, Tencent. 
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package com.qzone.utils
{
	import flash.display.DisplayObject;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	import flash.xml.XMLNodeType;

	/**
	 * 字符串操作工具集。
	 * @author cbm
	 *
	 */
	public final class StringUtil
	{

		/**
		 * 取得文件大小（file length）显示文本
		 * @param value 文件大小整数
		 * @param point 小数位数，默认2位。
		 * @return 文件大小显示文本
		 *
		 */
		public static function getByteSize(value : int, point : uint = 2) : String
		{
			if (value > 1024 * 1024 * 1024)
			{
				return getFloatNumber(value / 1024 / 1024 / 1024, point) + ' GB';
			}
			else if (value > 1024 * 1024)
			{
				return getFloatNumber(value / 1024 / 1024, point) + ' MB';
			}
			if (value > 1024)
			{
				return getFloatNumber(value / 1024, point) + ' KB';
			}
			else
			{
				return value.toString() + ' B';
			}
		}

		/**
		 * 获得汉字数字。
		 */
		public static function getChineseNum(value : Number) : String
		{
			var chineseNum : String = '';
			var chr : Array = ['零','一','二','三','四','五','六','七','八','九','十'];
			var num : Array = value.toString().split('')
			for each (var i : Number in num)
			{
				chineseNum += chr[num];
			}
			return chineseNum
		}

		/**
		 *
		 * @param value 浮点数值
		 * @param point 保留小数点位数，默认2位。
		 * @return 返回指定的浮点数。
		 *
		 */
		public static function getFloatNumber(value : Number, point : uint = 2) : String
		{
			return value.toFixed(2);
		}

		/**
		 * 补充需求长度，返回等长数字字符串，例如：1返回01
		 * @param value 数值
		 * @param point 补充长度，默认为2
		 * @return 格式后的字符串。
		 *
		 */
		public static function getZeroString(value : Number, point : uint = 2) : String
		{

			var str : String = value.toString();

			while (point > str.length)
			{
				str = '0' + str;
			}
			return str;
		}

		/**
		 * 模版文字替换工具，将模版中需要替换的变量名称，替换为replaceObject中同名key的数值。
		 * 模版中需要替换的变量使用｛｝包含，例如｛nickName｝，提供的Object同时设置有nickName为key的value，返回的文字即完成模板中的替换。</p>
		 * @param stringTemplate 模版文字
		 * @param replaceObject 替换数据集
		 *
		 * @return 替换结果
		 *
		 */
		public static function replaceText(stringTemplate : String, replaceObject : Object) : String
		{
			for (var n : String in replaceObject)
			{
				var r : RegExp = new RegExp("\{" + n + "\}", "g");
				stringTemplate = stringTemplate.replace(r, replaceObject[n]);
			}
			return stringTemplate;

		}
		
		public static function dateFormat(value : int) : String
		{
			var dateValue : Date = new Date(value * 1000);
			return doubleString(dateValue.getFullYear()) + "-" + 
				doubleString(dateValue.getMonth() + 1) + "-" + 
				doubleString(dateValue.getDate()) + " " + 
				doubleString(dateValue.getHours()) + ":" + 
				doubleString(dateValue.getMinutes());
			// +":" + doubleString(dateValue.getSeconds())
		}

		public static function htmlUnescape(str : String) : String
		{
			return new XMLDocument(str).firstChild.nodeValue;
		}

		public static function htmlEscape(str : String) : String
		{
			return XML(new XMLNode(XMLNodeType.TEXT_NODE, str)).toXMLString();
		}
		
		/**
		*	Removes whitespace from the front and the end of the specified
		*	string.
		* 
		*	@param input The String whose beginning and ending whitespace will
		*	will be removed.
		*
		*	@returns A String with whitespace removed from the begining and end	
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 9.0
		*	@tiptext
		*/			
		public static function trim(input:String):String
		{
			return StringUtil.ltrim(StringUtil.rtrim(input));
		}

		/**
		*	Removes whitespace from the front of the specified string.
		* 
		*	@param input The String whose beginning whitespace will will be removed.
		*
		*	@returns A String with whitespace removed from the begining	
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 9.0
		*	@tiptext
		*/	
		public static function ltrim(input:String):String
		{
			if (input == null)
				return "";
			var size:Number = input.length;
			for(var i:Number = 0; i < size; i++)
			{
				if(input.charCodeAt(i) > 32)
				{
					return input.substring(i);
				}
			}
			return "";
		}

		/**
		*	Removes whitespace from the end of the specified string.
		* 
		*	@param input The String whose ending whitespace will will be removed.
		*
		*	@returns A String with whitespace removed from the end	
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 9.0
		*	@tiptext
		*/	
		public static function rtrim(input:String):String
		{
			if (input == null)
				return "";
			var size:Number = input.length;
			for(var i:Number = size; i > 0; i--)
			{
				if(input.charCodeAt(i - 1) > 32)
				{
					return input.substring(0, i);
				}
			}

			return "";
		}

		private static function doubleString(intValue : int) : String
		{
			if (intValue < 10)
			{
				return "0" + intValue;
			}
			else
			{
				return intValue.toString();
			}
		}
		
	}
}
