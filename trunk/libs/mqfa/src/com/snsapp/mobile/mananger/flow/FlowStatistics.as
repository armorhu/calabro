package com.snsapp.mobile.mananger.flow
{
	import com.qzone.utils.DateTimeUtils;
	import com.snsapp.mobile.device.network.NetworkHelper;
	import com.snsapp.mobile.utils.Cookies;


	public class FlowStatistics
	{
		public static const NAME:String = "FlowStatistics";
		private var _flowLogs:Vector.<FlowLog>;

		public function FlowStatistics()
		{
			_flowLogs = new Vector.<FlowLog>();
		}

		/**
		 * 添加流量
		 * @param flowSize 添加流量的大小
		 */
		public function addFlow(flowSize:Number):void
		{
			if (flowSize <= 0)
				return;
			//是否是3g网络
			try
			{
				var is3g:Boolean = NetworkHelper.is3G();
			}
			catch (error:Error)
			{

			}
			//当前的时间
			var date:Date = new Date();

			var flowLog:FlowLog = new FlowLog;
			//一条流量的记录.包括 大小 是否3g 时间
			flowLog.size = flowSize;
			flowLog.date = date;
			flowLog.is3g = is3g;
			_flowLogs.push(flowLog);
		}

		/**
		 * 先刷新内存中的流量数据.
		 * 并写文件
		 */
		public function save():void
		{
			/**
			 * 本地的log记录:
			 * localLogs = {bytesTotal,bytesTotal_3g,bytesToday,bytesToday_3g,today}
			 * */
			var localLogs:Object = Cookies.getObject(NAME) as Object;
			var today:Date = new Date();
			if (localLogs == null)
				localLogs = {bytesTotal: 0, bytesTotal_3g: 0, bytesToday: 0, bytesToday_3g: 0};
			else
			{
				if (localLogs.today != null)
				{
					var localToday:Date = DateTimeUtils.parseDate(localLogs.today); //本地数据中的日期数据
					if (sameDay(today, localToday) != 0) //如果本地的日期已经过期
					{
						localLogs.bytesToday = 0;
						localLogs.bytesToday_3g = 0;
					}
				}
			}

			for (var i:int = 0; i < _flowLogs.length; i++)
			{
				localLogs.bytesTotal = localLogs.bytesTotal + _flowLogs[i].size;
				if (_flowLogs[i].is3g) //是3g数据
					localLogs.bytesTotal_3g = localLogs.bytesTotal_3g + _flowLogs[i].size;

				if (sameDay(_flowLogs[i].date, today) == 0) //是今天的数据
				{
					localLogs.bytesToday = localLogs.bytesToday + _flowLogs[i].size;
					if (_flowLogs[i].is3g) //今天的3g数据
						localLogs.bytesToday_3g = localLogs.bytesToday_3g + _flowLogs[i].size;
				}
			}

			localLogs.today = DateTimeUtils.formatDate(today);
			//保存
			if (Cookies.setObject(NAME, localLogs, 0, true))
				_flowLogs = new Vector.<FlowLog>();
			else
			{ //如果写失败了..就先放在内存中。。。坐等下一次写操作
				Cookies.setObject(NAME, localLogs);
				_flowLogs = new Vector.<FlowLog>();
			}
		}

		/**
		 * 仅刷新内存中的流量数据.
		 * 并不写文件
		 * @return
		 */
		public function getFlowReport():FlowReport
		{
			var localLogs:Object = Cookies.getObject(NAME) as Object;
			var flowReport:FlowReport = new FlowReport();
			if (localLogs == null || localLogs.today == null)
				return flowReport;
			else
			{
				var localToday:Date = DateTimeUtils.parseDate(localLogs.today); //本地数据中的日期数据
				var today:Date = new Date();
				if (sameDay(today, localToday) != 0) //如果本地的日期已经过期
				{
					localLogs.bytesToday = 0;
					localLogs.bytesToday_3g = 0;
					localLogs.today = DateTimeUtils.formatDate(today);
				}

				for (var i:int = 0; i < _flowLogs.length; i++)
				{
					localLogs.bytesTotal = localLogs.bytesTotal == undefined ? 0 : localLogs.bytesTotal //
						+ _flowLogs[i].size; //多些判断。防止显示为NAN
					if (_flowLogs[i].is3g) //是3g数据
						localLogs.bytesTotal_3g = localLogs.bytesTotal_3g + _flowLogs[i].size;

					if (sameDay(_flowLogs[i].date, today) == 0) //是今天的数据
					{
						localLogs.bytesToday = localLogs.bytesToday + _flowLogs[i].size;
						if (_flowLogs[i].is3g) //今天的3g数据
							localLogs.bytesToday_3g = localLogs.bytesToday_3g + _flowLogs[i].size;
					}
				}
				_flowLogs = new Vector.<FlowLog>();
				Cookies.setObject(NAME, localLogs);
				flowReport.bytesTotal = localLogs.bytesTotal;
				flowReport.bytesTotal_3g = localLogs.bytesTotal_3g;
				flowReport.bytesToday_3g = localLogs.bytesToday_3g;
				flowReport.bytesToday = localLogs.bytesToday;
				return flowReport;
			}
		}

		private function sameDay(date1:Date, date2:Date):int
		{
			if (date1.fullYear != date2.fullYear)
				return Math.abs(date1.fullYear - date2.fullYear) / (date1.fullYear - date2.fullYear)

			if (date1.month != date2.month)
				return Math.abs(date1.month - date2.month) / (date1.month - date2.month)

			if (date1.day != date2.day)
				return Math.abs(date1.day - date2.day) / (date1.day - date2.day);

			return 0;
		}
	}
}

class FlowLog
{
	public var size:Number = 0;
	public var is3g:Boolean = false;
	public var date:Date;
}
