package com.qzone.corelib.controls.renderers 
{
	import com.qzone.corelib.controls.interfaces.IRenderer;
	
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * 类似苹果停靠图标式列表的渲染器基类
	 * VDockScrollView和HDockScrollView的渲染器最好继承此类，可以减少代码量
	 * 
	 * <p>使用案例</p>
	 * <listing version="3.0">
	 *  package 
	 *	{
	 *		import com.greensock.TweenLite;
	 *		import com.qzone.corelib.controls.renderers.BasicDockItemRenderer;
	 *		import flash.display.MovieClip;
	 *		import flash.events.MouseEvent;
	 *		import flash.text.TextField;
	 *		import flash.utils.getDefinitionByName;
	 * 
	 *		//
	 *		// 渲染器实例
	 *		// ☀author Larry H.
	 *		//
	 *		public class ScaleRenderer extends BasicDockItemRenderer
	 *		{		
	 *			private var _itemView:MovieClip = null;
	 *			
	 *			private var _counter:TextField = null;
	 *			
	 *			private var _data:Object = null;
	 *			
	 *			private var _tween:TweenLite = null;
	 *			
	 *			//
	 *			// 构造函数
	 *			// create a [ScaleRenderer] object
	 *			//
	 *			public function ScaleRenderer() 
	 *			{
	 *				var ViewClass:Class = getDefinitionByName("corelib.view.ScaleRendererView") as Class;
	 *				
	 *				_itemView = new ViewClass() as MovieClip;
	 *				_itemView.mouseChildren = false;
	 *				
	 *				_counter = _itemView["counter"];
	 *				
	 *				addChild(_itemView);
	 *				
	 *				_targetScale = 1.5;
	 *			}
	 *			
	 *			//
	 *			// 鼠标移开
	 *			// ☀param	e
	 *			//
	 *			override protected function outHandler(e:MouseEvent):void 
	 *			{			
	 *				scaleTweenTo();
	 *			}
	 *			
	 *			//
	 *			// 鼠标滑过
	 *			// ☀param	e
	 *			//
	 *			override protected function overHandler(e:MouseEvent):void 
	 *			{
	 *				super.overHandler(e);
	 *				
	 *				scaleTweenTo(_targetScale);
	 *			}
	 *			
	 *			//
	 *			// 大小缓动
	 *			// ☀param	targetScale
	 *			//
	 *			private function scaleTweenTo(targetScale:Number = 1):void
	 *			{			
	 *				TweenLite.to(this, 0.3, { scaleX:targetScale, scaleY:targetScale,onComplete:stopScale } );
	 *				
	 *				startScale();
	 *			}
	 *			
	 *			//
	 *			// 复写数据
	 *			//
	 *			override public function get data():Object { return _data;	}
	 *			override public function set data(value:Object):void 
	 *			{
	 *				_data = value;
	 *				
	 *				if(_data)
	 *				{
	 *					_counter.text = "" + _data.value;
	 *				}
	 *				else
	 *				{
	 *					_counter.text = "";
	 *				}
	 *			}
	 *			
	 *		}
	 * 
	 *	}
	 * </listing>
	 * @author Larry H.
	 */
	public class BasicDockItemRenderer extends Sprite implements IRenderer
	{
		protected var _targetScale:Number = 1;
		
		/**
		 * 构造函数
		 * create a [BasicDockItemRenderer] object
		 */
		public function BasicDockItemRenderer()
		{
			init();
		}
		
		/**
		 * 初始化
		 */
		protected function init():void
		{
			addEventListener(MouseEvent.ROLL_OVER, overHandler);
			addEventListener(MouseEvent.ROLL_OUT, outHandler);
		}
		
		/**
		 * 鼠标滑过处理
		 * @param	e
		 */
		protected function overHandler(e:MouseEvent):void 
		{
			this.parent.dispatchEvent(new DataEvent(DataEvent.DATA, true, false, _targetScale.toString()));
		}
		
		/**
		 * 鼠标移开处理
		 * @param	e
		 */
		protected function outHandler(e:MouseEvent):void 
		{
			
		}
		
		/**
		 * 开始缩放
		 */
		protected function startScale():void
		{
			addEventListener(Event.ENTER_FRAME, sendNotification);
		}
		
		/**
		 * 停止放缩
		 */
		protected function stopScale():void
		{
			sendNotification();
			
			removeEventListener(Event.ENTER_FRAME, sendNotification);
		}
		
		/**
		 * 向容器派发事件
		 * @param	e
		 */
		private function sendNotification(e:Event = null):void 
		{
			if (e == null)
			{
				removeEventListener(Event.ENTER_FRAME, arguments.callee);
			}
			
			this.parent.dispatchEvent(new Event(Event.RESIZE, true));
		}
		
		/* INTERFACE com.qzone.corelib.controls.interfaces.IRenderer */
		
		public function get data():Object { return null; }
		public function set data(value:Object):void 
		{
			
		}
	}

}