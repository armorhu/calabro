package com.arm.herolot.services.conf
{

	/**
	 * 语言包。
	 * @author hufan
	 */
	public class Language
	{
		private static const lang:Object = {};

		public static function getTextById(id:String):String
		{
			return lang[id];
		}

		public static function init(xml:XML):void
		{
			var texts:XMLList = xml.text;
			const len:int = texts.length();
			var id:String, text:String;
			for (var i:int = 0; i < len; i++)
			{
				id = String(texts[i].@id);
				text = String(texts[i]);
				lang[id] = text;
			}
		}
	}
}
