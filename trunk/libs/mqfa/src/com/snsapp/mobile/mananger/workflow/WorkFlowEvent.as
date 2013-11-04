package com.snsapp.mobile.mananger.workflow
{
	import flash.events.Event;

	public class WorkFlowEvent extends Event
	{
		/**
		 * 队列开始
		 * **/
		public static const QUEUE_START:String = "WorkEvent_Queue_Start";

		/**
		 * 队列完成
		 * **/
		public static const QUEUE_COMPLETE:String = "WorkEvent_Queue_COMPLETE";

		/**
		 * 队列失败
		 * **/
		public static const QUEUE_FAILED:String = "WorkEvent_Queue_Failed"

		/**
		 * 单个工作开始
		 * **/
		public static const START:String = "WorkEvent_Start";

		/**
		 * 单个工作完成
		 * **/
		public static const COMPLETE:String = "WorkEvent_Complete";

		/**
		 * 单个工作失败
		 * **/
		public static const FAILED:String = "WorkEvent_Failed";

		/**
		 * 当前进行到第几个工作
		 * **/
		public var currentCount:int;

		/**
		 * 工作的数量
		 * **/
		public var totalCount:int;

		/**
		 * 失败的工作数量
		 * **/
		public var failedCount:int;

		/**
		 * 抛出事件时,被执行的工作对象
		 * QUEUE_START 、QUEUE_COMPLETE这两个事件无效
		 * **/
		public var work:IWork;

		/**
		 * 工作描述
		 * **/
		public var workDescribe:String;

		public function WorkFlowEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
