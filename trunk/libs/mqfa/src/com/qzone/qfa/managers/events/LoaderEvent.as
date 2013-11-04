package com.qzone.qfa.managers.events
{
	import com.qzone.qfa.managers.LoadManager;
	import com.qzone.qfa.managers.resource.Resource;
	
	import flash.events.Event;
	import flash.media.ID3Info;
	
	/**
	 * LoadManager事件
	 */
	public class LoaderEvent extends Event 
	{
		
		//状态变化事件 (loading, paused, stopped)
		public static const STATUS_CHANGED: String = "LoaderEvent.STATUS_CHANGED";
		//ID3读取完毕事件，只有音频资源会触发
		public static const ID3_COMPLETE: String = "LoaderEvent.ID3_COMPLETE";
		//错误事件，包含任何错误
		public static const ERROR: String = "LoaderEvent.ERROR";
		//单个资源读取开始事件
		public static const START: String = "LoaderEvent.START";
		//单个资源读入过程事件
		public static const PROGRESS: String = "LoaderEvent.PROGRESS";
		//单个资源读取完毕事件
		public static const COMPLETE: String = "LoaderEvent.COMPLETE";
		//队列信息改变事件
		public static const QUEUE_CHANGED: String = "LoaderEvent.QUEUE_CHANGED";
		//队列开始事件
		public static const QUEUE_START: String = "LoaderEvent.QUEUE_START";
		//队列过程事件		
		public static const QUEUE_PROGRESS: String = "LoaderEvent.QUEUE_PROGRESS";
		//队列读取完毕事件
		public static const QUEUE_COMPLETE: String = "LoaderEvent.QUEUE_COMPLETE";
		// 在兼容模式下派发的complete事件
		public static const COMPATIBLE_COMPLETE:String = "LoaderEvent.COMPATIBLE_COMPLETE";
		
		//所属的loadmanager
		public var loader:LoadManager;
		//队列百分比
		public var percentQueue:Number;
		//当前资源读取百分比		
		public var percentItem:Number;
		//事件信息
		public var msg:String="";
		//当前被读取的资源
		public var item:Resource;
		//已读入的数量
		public var queue_count:int;
		//队列长度
		public var queue_length:int;
		
		//当前资源已读取的字节
		public var bytesLoaded:Number;
		//当前资源的字节总数
		public var bytesTotal:Number;
		//音频信息
		public var id3Info:ID3Info;
		
		public var fail_count:int;
		
		public function LoaderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new LoaderEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String
		{ 
			var list:Array = ["LoaderEvent", "type", "percentQueue", "percentItem",
								"item",	"queue_count",	"fail_count", "queue_length", "loader"];
			if (msg) list.push("msg");
			
			return formatToString.apply(this, list);
		}
		
	}
	
}