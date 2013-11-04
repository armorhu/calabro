package com.qzone.utils
{
	import flash.display.DisplayObject;
	/**
	 * 时间操作工具集。 
	 * @author cbm
	 * 
	 */
	final public class DateUtil
	{
		public function DateUtil()
		{
			
		}
		/**
		 * 返回时间数值
		 * @param date 时间Date
		 * @return 格式范围0.0000~23.5959 
		 * 
		 */
		public static function getTimeNumber(date:Date):Number{
			
			var timeNum:Number;
			
			timeNum = date.getHours()*10000;
			timeNum += date.getMinutes()*100;
			timeNum += date.getSeconds();

			return timeNum/10000;
		}
		/**
		 * 从字符串时间转换为Date 
		 * 使用方法 ： DateUtil.getDateFromString('2009-12-08 23:59:59')
		 * @param dateDelimiter 日期分隔符，默认为 -
		 * @param timeDelimiter 时间分隔符，默认为 ：
		 * @param dateString 字符串时间
		 * @return 一个Date类型
		 * 
		 */		
		public static function getDateFromString(dateString:String,dateDelimiter:String = '-',timeDelimiter:String = ':'):Date
		{
			
			var dateTime:Array = dateString.split(' ');
			var date:Array = String(dateTime[0]).split(dateDelimiter);
			var time:Array = String(dateTime[1]).split(timeDelimiter);
			
			var newDate:Date = new Date(date[0],date[1]-1,date[2],time[0],time[1],time[2]);
			
			return newDate;
		}

	}
}
