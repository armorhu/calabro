package com.qzone.utils
{
	/**
	 * 设置HtmlText单元样式
	 * @author arthurhong
	 * 
	 */	
	public class HtmlTextUtil
	{
		public function HtmlTextUtil()
		{
		}
		
		public static function getFontTag(text:String, color:String, size:int=0, bold:Boolean=false, eventType:String=null, leading:int=0):String
		{
			var htmlStr:String = "";
			var fontBold:String;
			var fontBoldEnd:String;
			
			if(leading>0)
			{
				htmlStr += "<textformat leading='"+leading+"'>";
			}
			if(eventType)
			{
				htmlStr += "<a herf='event:"+eventType+"'>"
			}
			
			htmlStr += "<font ";
//			if(face && face!="")
//			{
//				htmlStr += "face='"+face+"' ";
//			}
			if(size != 0)
			{
				htmlStr += "size='"+size+"' ";
			}
			if(bold)
			{
				fontBold = "<b>";
				fontBoldEnd = "</b>";
			}
			else
			{
				fontBold = "";
				fontBoldEnd = "";
			}
			htmlStr += "color='"+color+"'>";
			
			htmlStr += fontBold;
			htmlStr += text;
			htmlStr += fontBoldEnd;
			htmlStr += "</font>";
			
			if(eventType)
			{
				htmlStr += "</a>";
			}
			if(leading>0)
			{
				htmlStr += "</textformat>";
			}
			
			return htmlStr;
		}
	}
}