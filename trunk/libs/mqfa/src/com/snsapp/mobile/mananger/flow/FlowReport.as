package com.snsapp.mobile.mananger.flow
{

	public class FlowReport
	{
		public var bytesTotal:Number;
		public var bytesTotal_3g:Number;
		public var bytesToday:Number;
		public var bytesToday_3g:Number;

		public function toString():String
		{
			return "总流量:" + getSizeStr(bytesTotal) + //
				"\n其中窝蜂数据流量:" + getSizeStr(bytesTotal_3g) + //
				"\n今日流量:" + getSizeStr(bytesToday) + //
				"\n其中今日窝蜂数据流量:" + getSizeStr(bytesToday_3g);
		}

		private function getSizeStr(size:Number):String
		{
			var num:Number = size;
			if (isNaN( size)) num=0;
			if (num < 1024)
				return num.toFixed() + "byte";

			num /= 1024;
			if (num < 1024)
				return num.toFixed() + "KB";

			num /= 1024;
			if (isNaN(Number(num.toFixed(2)))) return "0MB";
			return num.toFixed(2) + "MB";
		}
	}
}
