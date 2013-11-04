package com.snsapp.mobile.mananger.workflow
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;

	/**
	 * 工作流
	 * 管理一个工作流,使之分时进行.
	 * @author armorhu
	 */

	[Event(name = "WorkEvent_Queue_Start", type = "com.snsapp.mobile.mananger.workflow.WorkFlowEvent")]
	[Event(name = "WorkEvent_Queue_COMPLETE", type = "com.snsapp.mobile.mananger.workflow.WorkFlowEvent")]
	[Event(name = "WorkEvent_Queue_Failed", type = "com.snsapp.mobile.mananger.workflow.WorkFlowEvent")]
	[Event(name = "WorkEvent_Start", type = "com.snsapp.mobile.mananger.workflow.WorkFlowEvent")]
	[Event(name = "WorkEvent_Complete", type = "com.snsapp.mobile.mananger.workflow.WorkFlowEvent")]
	[Event(name = "WorkEvent_Failed", type = "com.snsapp.mobile.mananger.workflow.WorkFlowEvent")]
	public class Workflow extends EventDispatcher
	{
		/**
		 * 需要执行的工作队列
		 * **/
		protected var _workQueue:Vector.<IWork>;

		/**
		 * 与工作队列对应的参数队列
		 * **/
		protected var _workParams:Vector.<Boolean>;

		/**
		 * 是否正在工作
		 * **/
		protected var _working:Boolean;

		protected var _isComplete:Boolean = true;

		/**
		 * 描述表
		 * key-work
		 * **/
		protected var _describeMap:Dictionary;
		protected var _currentCount:int;
		protected var _failedCount:int;
		protected var _totalCount:int;
		protected var _complete:Boolean;

		public function Workflow(target:IEventDispatcher = null)
		{
			super(target);
			_workQueue = new Vector.<IWork>();
			_workParams = new Vector.<Boolean>();
			_describeMap = new Dictionary(true);
			_working = false;
			_currentCount = 0;
		}


		private static const EVENTLIST:Array = [WorkFlowEvent.COMPLETE, WorkFlowEvent.START, WorkFlowEvent.QUEUE_START, WorkFlowEvent.QUEUE_FAILED, WorkFlowEvent.QUEUE_COMPLETE, WorkFlowEvent.FAILED]

		/**
		 * 批量添加事件，简化使用方法
		 * @param eventHandler
		 */
		public function addEventListeners(eventHandler:Function):void
		{
			for each (var s:String in EVENTLIST)
				addEventListener(s, eventHandler, false, 0, false);
		}

		/**
		 * 批量删除事件，简化使用方法
		 * @param eventHandler
		 */
		public function removeEventListeners(eventHandler:Function):void
		{
			for each (var s:String in EVENTLIST)
				removeEventListener(s, eventHandler);
		}

		/**
		 * 注册工作
		 * @param $work 子工作
		 * @param errorSkip 该工作失败时是否跳过错误
		 * @oaram describe  该工作的描述
		 */
		public function registeWork($work:IWork, errorSkip:Boolean = true, describe:String = null):Boolean
		{
			if ($work == null)
				return false;
			if (_working) //工作中不允许添加工作
				return false;
			$work.addEventListener(Event.COMPLETE, workEventHandler);
			$work.addEventListener(ErrorEvent.ERROR, workEventHandler);
			_workParams.push(errorSkip);
			_workQueue.push($work);
			_describeMap[$work] = describe;
			_isComplete = false;
			return true;
		}

		/**
		 * 开始工作
		 */
		public function start():void
		{
			_isComplete = false;
			_working = true;
			_currentCount = -1;
			_failedCount = 0;
			_totalCount = _workQueue.length;
			dispatch(WorkFlowEvent.QUEUE_START, null);
			startWork();
		}

		/**
		 * 销毁一切
		 */
		public function destory():void
		{
			const len:int = _workQueue.length;
			for (var i:int = 0; i < len; i++)
			{
				_workQueue[i].removeEventListener(Event.COMPLETE, workEventHandler);
				_workQueue[i].removeEventListener(ErrorEvent.ERROR, workEventHandler);
			}
			_workQueue = null;
			_describeMap = null;
			_workParams = null;
		}


		/**
		 * 某个工作完成了,或者成功,或者失败
		 * **/
		protected function workEventHandler(e:Event):void
		{
			var target:IWork = e.target as IWork;
			if (target == null)
				return;
			target.removeEventListener(Event.COMPLETE, workEventHandler);
			target.removeEventListener(ErrorEvent.ERROR, workEventHandler);

			var errorSkip:Boolean = _workParams.shift(); //是否跳过错误
			if (e.type == Event.COMPLETE)
			{
				trace("[Workflow]::" + getWorkDescribe(_currentCount) + ":" + " complete.");
				dispatch(WorkFlowEvent.COMPLETE, target);
			}
			else if (e.type == ErrorEvent.ERROR)
			{
				trace("[Workflow]::" + getWorkDescribe(_currentCount) + ":" + " error.");
				_failedCount++; //失败++
				dispatch(WorkFlowEvent.FAILED, target);
				if (errorSkip == false) //不跳过错误，则中断工作流
				{
					const len:int = _workQueue.length;
					for (var i:int = _currentCount + 1; i < len; i++)
					{
						_workQueue[i].removeEventListener(Event.COMPLETE, workEventHandler);
						_workQueue[i].removeEventListener(ErrorEvent.ERROR, workEventHandler);
					}
					dispatch(WorkFlowEvent.QUEUE_FAILED, target);
					return;
				}
			}
			startWork();
		}

		/**
		 * 从队列的头部拿一项子工作开始搞起
		 */
		protected function startWork():void
		{
			if (_currentCount < _workQueue.length - 1)
			{
				_currentCount++;
				var $work:IWork = _workQueue[_currentCount];
				trace("[Workflow]::" + getWorkDescribe(_currentCount) + ":" + " start.");
				dispatch(WorkFlowEvent.START, $work);
				$work.start();
			}
			else
			{
				_working = false;
				_isComplete = true;
				dispatch(WorkFlowEvent.QUEUE_COMPLETE, null);
			}
		}

		public function get working():Boolean
		{
			return _working;
		}

		public function isComplete():Boolean
		{
			return _isComplete;
		}

		protected function dispatch(type:String, $work:IWork):void
		{
			var event:WorkFlowEvent = new WorkFlowEvent(type);
			event.currentCount = _currentCount + 1;
			event.failedCount = _failedCount;
			event.totalCount = _totalCount;
			event.work = $work;
			if (event.work)
				event.workDescribe = getWorkDescribe(_currentCount);
			dispatchEvent(event);
		}

		/**
		 * 获取工作的描述
		 * @param index
		 * @return
		 */
		private function getWorkDescribe(index:int):String
		{
			if (_describeMap[_workQueue[index]] == undefined)
				return "work" + index;
			else
				return _describeMap[_workQueue[index]] as String;
		}
	}
}
