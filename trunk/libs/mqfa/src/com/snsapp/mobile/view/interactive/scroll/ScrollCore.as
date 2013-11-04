package com.snsapp.mobile.view.interactive.scroll
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;
	import com.snsapp.mobile.StageInstance;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	/**
	 * 触摸滚动逻辑的辅助类
	 * 传入一个DisplayObject,并设置一些参数,实现相应的触摸滚动效果
	 * @author armorhu
	 */
	[Event(name = "EffectiveClick", type = "com.snsapp.mobile.view.interactive.scroll.ScollHelperEvent")]
	[Event(name = "ParsueScroll", type = "com.snsapp.mobile.view.interactive.scroll.ScollHelperEvent")]
	[Event(name = "Scrolling", type = "com.snsapp.mobile.view.interactive.scroll.ScollHelperEvent")]
	[Event(name = "EndScroll", type = "com.snsapp.mobile.view.interactive.scroll.ScollHelperEvent")]
	[Event(name = "Swipe", type = "com.snsapp.mobile.view.interactive.scroll.ScollHelperEvent")]
	public class ScrollCore extends EventDispatcher
	{
		protected static const RenderTime:int = 30;
		protected const Debug:Boolean = false;

		/**
		 * 滚动的对象
		 * **/
		protected var _target:Object;

		/**
		 * 舞台实例
		 * **/
		protected var _stage:Stage;

		/**
		 * 水平方向上的范围,弹性
		 * **/
		protected var _horizontalRange:Point;
		protected var _horizontalFlexble:Number;

		/**
		 * 竖直方向上的范围,弹性
		 * **/
		protected var _verticalRange:Point;
		protected var _verticalFlexble:Number;

		/**
		 * 滚动策略
		 * **/
		protected var _scrollPolicy:int;

		/**
		 * 触发swipe的两个参数
		 * 当一次点击的时间小于_trigSwipe_Time并鼠标位移小于_trigSwipe_Offset
		 * 触发Swipe事件
		 * **/
		protected var _trigSwipe_Time:int;
		protected var _trigSwipe_Offset:Number;
		protected var _swipeInitSpeed:Number;

		/**
		 * 触发Click事件的参数
		 * 当一次拖拽的鼠标位移小于_trigClick_Offset,则认为是点击事件
		 * 另一方面,这个参数还决定何时抛出BeignScrolling事件
		 * **/
		protected var _trigClick_Offset:Number;

		/**
		 * 是否可以滑动
		 * **/
		protected var _scrollEnable:Boolean;

		/**
		 * -1 仅支持内滚动
		 * 0 都支持
		 * 1 仅支持外滚动
		 * **/
		protected var _horizontalSupport:int
		protected var _verticalSupport:int

		protected var _inertanceEasing:Number; //惯性移动时的缓动系数

		protected var _moving:Boolean;

		/**
		 * 水平方向是否内滚动
		 * @return
		 */
		public var _horizontalInnner:Boolean;

		/**
		 * 竖直方向是否内滚动
		 * @return
		 */
		public var _verticalInner:Boolean;


		public var _hhh:Number;
		public var _vvv:Number;

		/**
		 *
		 * @param target 拖拽对象
		 * @param $horizontalRange 拖拽的水平范围       <p>_horizontalInnner</p>属性由该参数决定
		 * @param $verticalRange 推拽的竖直范围         <p>verticalInnner</p>属性由该参数决定
		 * @param $horizontalFlexble 拖拽的水平弹性区域
		 * @param $verticalFlexble 拖拽的竖直弹性区域
		 * @param $trigClick_Offset 一次拖拽的位移小于这个值,则会抛出鼠标事件
		 * @param $trigSwipe_Time   触发swipe事件的参数:时间
		 * @param $trigSwipe_Offset 触发swipe事件的参数:位移
		 * @param $minSwipeSpeed    触发了swipe事件,目标滚动的最小速度
		 * @param $inertanceEasing  惯性的缓动参数
		 * @throws Error
		 */
		public function ScrollCore( //
			target:Object, //拖拽对象
			$horizontalRange:Point = null, //拖拽的水平范围
			$verticalRange:Point = null, //推拽的竖直范围
			$horizontalFlexble:Number = 0, //拖拽的水平弹性区域
			$verticalFlexble:Number = 0, //拖拽的竖直弹性区域
			$horizontalSupport:int = 0, //
			$verticalSupport:int = 0, //
			$trigClick_Offset:Number = 5, //
			$trigSwipe_Time:int = 400, //
			$trigSwipe_Offset:Number = 20, //
			$minSwipeSpeed:Number = 5, $inertanceEasing:Number = 0.8 // 惯性移动时的缓动系数
			)
		{
			if (target == null)
				throw new Error("不要乱传空对象进来!");

			_target = target;
			_horizontalRange = $horizontalRange;
			_verticalRange = $verticalRange;
			_horizontalFlexble = $horizontalFlexble;
			_verticalFlexble = $verticalFlexble;
			_horizontalSupport = $horizontalSupport;
			_verticalSupport = $verticalSupport;
			_trigSwipe_Time = $trigSwipe_Time;
			_trigSwipe_Offset = $trigSwipe_Offset;
			_trigClick_Offset = $trigClick_Offset;
			_swipeInitSpeed = $minSwipeSpeed;
			_inertanceEasing = $inertanceEasing;
			_speed = new Point();
			_effectiveOffset = new Point();
			this.scrollEnable = true;
			this.scrollPolicy = ScrollPolicy.AUTO;
			if (target is DisplayObject && target.stage == null)
				target.addEventListener(Event.ADDED_TO_STAGE, init);
			else
				this.init();
		}

		protected function init(e:Event = null):void
		{
			if (e != null)
				_target.removeEventListener(Event.ADDED_TO_STAGE, init);
			_stage = StageInstance.stage; //_target.stage;
			updateScrollParams(_target.parent);
		}

		/**==================================================================================
		 * 拖拽逻辑
		 * ==================================================================================**/
		protected var _lastX:Number; //上一次渲染时的鼠标位置
		protected var _lastY:Number; // 上一次渲染时的鼠标位置
		protected var _lastTime:Number;
		protected var _effectiveOffset:Point; //鼠标偏移量
		protected var _speed:Point; //最后一次渲染的速度

		protected var _beginTime:Number; //一次拖拽的开始时间
		protected var _beginX:Number; //一次拖拽的开始时的鼠标位置
		protected var _beginY:Number; //一次拖拽的开始时的鼠标位置

		protected var _phase:int; //标识当前拖拽是何阶段
		protected const PhaseFunctionMap:Array = [ //
			preScroll, //
			scroll, //
			preEndScroll, //
			inertance, //
			endDrag];

		public function beginDrag():void
		{
			if (_stage == null && this.scrollEnable == false)
				return;

			TweenLite.killTweensOf(this._target);
			_lastX = _beginX = _stage.mouseX;
			_lastY = _beginY = _stage.mouseY;
			_speed.x = _speed.y = 0;
			_beginTime = _lastTime = getTimer();
			_phase = ScrollPhase.PreScroll;
			_moving = true;
			_effectiveOffset.x = _effectiveOffset.y = 0;

			_stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUp, false, 0, true);
			_stage.addEventListener(Event.ENTER_FRAME, rending, false, -10, true);
		}

		/**
		 * 滚动时的渲染目标位置函数
		 * @param e
		 */
		protected function rending(e:Event = null):void
		{
			var time:Number = getTimer() - _lastTime; //暂时这么办
			if (time < 1)
				time = 1;
			_lastTime = getTimer();
			var currentX:Number = _stage.mouseX;
			var currentY:Number = _stage.mouseY;
			var offsetX:Number = currentX - _lastX;
			var offsetY:Number = currentY - _lastY;
			_lastX = currentX;
			_lastY = currentY;
			if (this._phase == ScrollPhase.Inertance)
			{ //惯性阶段慢慢飘
				_speed.x *= 0.8;
				_speed.y *= 0.8;
			}
			else
			{
				_effectiveOffset = getEffectiveOffset(offsetX, offsetY);
				_speed.x = _effectiveOffset.x / time;
				_speed.y = _effectiveOffset.y / time;
				if (distSQ(_speed) < 4)
				{ //当速度很小的时候就将速度放大一些.
					_speed.x *= 1.5;
					_speed.y *= 1.5;
				}
			}

			_target.x += _speed.x * time;
			_target.y += _speed.y * time;
			if (Debug)
				trace("1 pahse:", this._phase, ",targetX:", this._target.x, ",targetY:", this._target.y, ",speed:", this._speed);

			//边界判断
			var rangeRet:Object = this.rangeTest(true);
			if (rangeRet.x == -1)
			{
				if (Debug)
					trace("x 左边碰界")
				this._speed.x = 0;
				targetLeft = rangeRet.xRange;
			}
			else if (rangeRet.x == 1)
			{
				if (Debug)
					trace("x 右边碰界")
				this._speed.x = 0;
				targetRight = rangeRet.xRange;
			}
			if (rangeRet.y == -1)
			{
				if (Debug)
					trace("y 上边碰界")
				this._speed.y = 0;
				targetTop = rangeRet.yRange;
			}
			else if (rangeRet.y == 1)
			{
				if (Debug)
					trace("y 下边碰界")
				this._speed.y = 0;
				targetButtom = rangeRet.yRange;
			}

			PhaseFunctionMap[this._phase]();
			if (Debug)
				trace("2 pahse:", this._phase, " ,targetX:", this._target.x, ",targetY:", this._target.y, ",speed:", this._speed);
		}

		protected function stageMouseUp(e:MouseEvent):void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUp);
//			Debugger.log("------Debug-stageMouseUp" + this._target.x);
			if (this._target is InteractiveObject)
				(this._target as InteractiveObject).mouseEnabled = true;
			if (this._phase == ScrollPhase.PreScroll)
			{
				_effectiveOffset = getEffectiveOffset(_stage.mouseX - _beginX, _stage.mouseY - _beginY); //先更新一下有效距离
				if (getTimer() - _beginTime <= this._trigSwipe_Time && _effectiveOffset.x < 10 && _effectiveOffset.y < 10)
					this.effctiveClick(e);
			}
			else if (getTimer() - _beginTime <= this._trigSwipe_Time)
			{
				_effectiveOffset = getEffectiveOffset(_stage.mouseX - _beginX, _stage.mouseY - _beginY); //先更新一下有效距离
				var offset:Number = distSQ(_effectiveOffset)
				if (offset >= this._trigSwipe_Offset * this._trigSwipe_Offset)
				{ //触发了swpie事件
					_speed.x = _effectiveOffset.x;
					_speed.y = _effectiveOffset.y;
					offset = Math.sqrt(offset);
					_speed.x *= this._swipeInitSpeed / offset;
					_speed.y *= this._swipeInitSpeed / offset;
					this.dispatchEvent(new ScrollHelperEvent(ScrollHelperEvent.Swipe));
					this._phase = ScrollPhase.Inertance; //进入惯性阶段
					if (Debug)
						trace("[swipe] pahse:", this._phase, " ,targetX:", this._target.x, ",targetY:", this._target.y, ",speed:", this._speed);
				}
			}
			else
				this._phase = ScrollPhase.Inertance;

			if (this._phase != ScrollPhase.Inertance)
				this.endDrag();
		}

		/**
		 * 抛出有效点击事件
		 */
		protected function effctiveClick(e:MouseEvent):void
		{
			if (this._target is DisplayObject)
			{
				var localPoint:Point = this._target.globalToLocal(new Point(e.stageX, e.stageY));
				this.dispatchEvent(new ScrollHelperEvent(ScrollHelperEvent.EffectiveClick, localPoint));
			}
		}

		protected function endDrag():void
		{
//			Debugger.log("Debug-endDrag-Start" + this._target.x);
			if (_target is Sprite)
				(_target as Sprite).mouseChildren = true;
			this._phase = ScrollPhase.Stop;

			_stage.removeEventListener(Event.ENTER_FRAME, rending)
//			EnterFrameManager.destroy(rending);
			/**
			 * 停止拖拽时有可能超出了边界,使用TweenLit把目标弹回去
			 * **/
			var targetX:Number = this._target.x;
			var targetY:Number = this._target.y;
			var rangeRet:Object = this.rangeTest(false);
			if (rangeRet.x == -1)
				targetLeft = this._horizontalRange.x;
			else if (rangeRet.x == 1)
				targetRight = this._horizontalRange.y;
			if (rangeRet.y == -1)
				targetTop = this._verticalRange.x;
			else if (rangeRet.y == 1)
				targetButtom = this._verticalRange.y;

			if (targetX != this._target.x || targetY != this._target.y)
				TweenLite.from(this._target, 0.5, {x: targetX, y: targetY, ease: Strong.easeOut, onComplete: function():void
				{
					_moving = false;
					dispatchEvent(new ScrollHelperEvent(ScrollHelperEvent.EndScroll));
				}});
			else
			{
				_moving = false;
				dispatchEvent(new ScrollHelperEvent(ScrollHelperEvent.EndScroll));
			}
//			Debugger.log("Debug-endDrag-End" + this._target.x);
		}

		protected function preScroll():void
		{
			var effectiveOffset:Point = getEffectiveOffset(_stage.mouseX - _beginX, _stage.mouseY - _beginY);
			if (distSQ(effectiveOffset) > this._trigClick_Offset * this._trigClick_Offset)
			{
				//进入了拖拽状态.同时意味着此次拖拽不会抛出点击事件
				this._phase = ScrollPhase.Scroll;
				if (this._target is InteractiveObject)
					(this._target as InteractiveObject).mouseEnabled = false;
				if (_target is Sprite)
					(_target as Sprite).mouseChildren = false;
				this.dispatchEvent(new ScrollHelperEvent(ScrollHelperEvent.BeginScroll));
			}
		}

		protected function scroll():void
		{
			if (_speed.x == 0 && _speed.y == 0)
			{
				//进入了暂停状态
				this._phase = ScrollPhase.PreEndScroll;
				this.dispatchEvent(new ScrollHelperEvent(ScrollHelperEvent.ParsueScroll));
			}
		}

		protected function preEndScroll():void
		{
			if (_speed.x != 0 || _speed.y != 0)
			{
				//回到了拖拽状态
				this._phase = ScrollPhase.Scroll;
				this.dispatchEvent(new ScrollHelperEvent(ScrollHelperEvent.BeginScroll));
			}
		}

		protected function inertance():void
		{
			//惯性阶段,速度小到极限了...则停止！
			if ((_speed.x * _speed.x + _speed.y * _speed.y) < 0.01)
			{
//				Debugger.log("Debug-inertance" + this._target.x);
				endDrag();
			}
		}

		/**
		 * 根据x y轴的偏移量和当前的滚动策略,更新有效偏移量
		 * @param offsetX
		 * @param offsetY
		 */
		protected function getEffectiveOffset(offsetX:Number, offsetY:Number):Point
		{
			var effectiveOffset:Point = new Point();
			if (this.scrollPolicy == ScrollPolicy.AUTO)
			{ //auto mode
				if (Math.abs(offsetX) >= Math.abs(offsetY))
				{
					effectiveOffset.x = offsetX;
					effectiveOffset.y = 0;
				}
				else
				{
					effectiveOffset.x = 0;
					effectiveOffset.y = offsetY;
				}
			}
			else if (this.scrollPolicy == ScrollPolicy.HorizontalOnly)
			{ //水平
				effectiveOffset.x = offsetX;
				effectiveOffset.y = 0;
			}
			else if (this.scrollPolicy == ScrollPolicy.VerticalOnly)
			{ //垂直
				effectiveOffset.x = 0;
				effectiveOffset.y = offsetY;
			}
			else if (this.scrollPolicy == ScrollPolicy.BOTH)
			{ //both
				effectiveOffset.x = offsetX;
				effectiveOffset.y = offsetY
			}

			return effectiveOffset;
		}

		/**
		 * 边界测试
		 * @return 返回边界测试的结果
		 * 返回{x:direction,y:direction}
		 * direction的取值-1 0 1....
		 */
		protected function rangeTest(flexable:Boolean):Object
		{
			var time:uint = getTimer();
			var obj:Object = {x: 0, y: 0};
			/**
			 * 如果你对这个逻辑感觉很难理解...就不要尝试理解了...............
			 * **/
			if (_horizontalRange)
			{
				var minX:Number = _horizontalRange.x;
				var maxX:Number = _horizontalRange.y; //Math.min(_horizontalRange.y, (_horizontalRange.x + _target.width));
				if (flexable)
				{
					if (this._horizontalInnner)
					{
						minX -= _horizontalFlexble;
						maxX += _horizontalFlexble;
					}
					else
					{
						minX += _horizontalFlexble;
						maxX -= _horizontalFlexble;
					}
				}

				if (_hhh > 0)
				{
					obj.x = -1;
					obj.xRange = _horizontalRange.x;
				}
				else if (this._scrollPolicy != ScrollPolicy.VerticalOnly && //
					_hhh <= 0)
				{
					if (minX > targetLeft == this._horizontalInnner)
					{
						obj.x = -1;
						obj.xRange = minX;
					}
					else if (maxX < targetRight == this._horizontalInnner)
					{
						obj.x = 1;
						obj.xRange = maxX;
					}
				}
			}
			if (_verticalRange)
			{
				var minY:Number = _verticalRange.x;
				var maxY:Number = _verticalRange.y;
				if (flexable)
				{
					if (this._verticalInner)
					{
						minY -= _verticalFlexble;
						maxY += _verticalFlexble;
					}
					else
					{
						minY += _verticalFlexble;
						maxY -= _verticalFlexble;
					}
				}

				if (_vvv > 0)
				{
					obj.y = -1;
					obj.yRange = _verticalRange.x;
				}
				else if (this._scrollPolicy != ScrollPolicy.HorizontalOnly && //
					_vvv <= 0)
				{
					if (minY > targetTop == this._verticalInner)
					{
						obj.y = -1;
						obj.yRange = minY;
					}
					else if (maxY < targetButtom == this._verticalInner)
					{
						obj.y = 1;
						obj.yRange = maxY;
					}
				}
			}
			return obj;
		}

		protected function distSQ(point:Point):Number
		{
			return point.x * point.x + point.y * point.y;
		}

		/**
		 * 目标的坐标信息
		 * **/
		protected var _topOffset:Number;
		protected var _leftOffset:Number;
		protected var _rightOffset:Number;
		protected var _buttomOffset:Number;

		public function get targetLeft():Number
		{
			return this._leftOffset + _target.x
		}

		public function set targetLeft(value:Number):void
		{
			_target.x += value - targetLeft;
		}

		public function get targetRight():Number
		{
			return this._rightOffset + _target.x
		}

		public function set targetRight(value:Number):void
		{
			_target.x += value - targetRight;
		}

		public function get targetTop():Number
		{
			return this._topOffset + _target.y
		}

		public function set targetTop(value:Number):void
		{
			_target.y += value - targetTop;
		}

		public function get targetButtom():Number
		{
			return this._buttomOffset + _target.y
		}

		public function set targetButtom(value:Number):void
		{
			_target.y += value - targetButtom;
		}

		/**==================================================================================
		 * PUBLIC
		 * ==================================================================================**/
		/**
		 * 设置滚动策略
		 * 默认为ScrollPolicy.AUTO
		 * @param policy - 可选参数见ScrollPolicy
		 */
		public function get scrollPolicy():int
		{
			return this._scrollPolicy
		}

		public function set scrollPolicy(policy:int):void
		{
			this._scrollPolicy = policy;
		}

		/**
		 * 设置是否可以滚动
		 * 默认是true
		 * **/
		public function get scrollEnable():Boolean
		{
			return this._scrollEnable && _target != null;
		}

		/**
		 * 该方法在dispose调用后将无效
		 * @param bool
		 */
		public function set scrollEnable(bool:Boolean):void
		{
			if (_target == null)
				return;
			this._scrollEnable = bool;
		}

//		public function get verticalInner():Boolean{return _verticalInner;}
//		public function get horizontalInnner():Boolean{return _horizontalInnner};

		/**
		 * 销毁这个滚动对象占用的资源
		 */
		public function dispose():void
		{
			TweenLite.killTweensOf(_target);

			//延迟销毁处理, 因为在当前帧可能还会有事件触发逻辑
			setTimeout(delayDispose, 20);

			function delayDispose():void
			{
				if (_stage)
				{
					_stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUp);
					_stage.removeEventListener(Event.ENTER_FRAME, rending)
					_stage = null;
				}
			}
		}


		/**
		 * 更新滚动的参数
		 * 当滚动目标的大小发生改变时调用
		 * container target的父亲容器
		 */
		protected function updateScrollParams(container:DisplayObjectContainer = null):void
		{
			if (container == null)
				container = this._target.parent;
			if (container)
			{
				var bounds:Rectangle = this._target.getBounds(container);
				_leftOffset = bounds.left - _target.x;
				_rightOffset = bounds.right - _target.x;
				_topOffset = bounds.top - _target.y;
				_buttomOffset = bounds.bottom - _target.y;
			}
			else
			{
				_leftOffset = 0;
				_rightOffset = _target.width;
				_topOffset = 0;
				_buttomOffset = _target.height;
			}

			_horizontalInnner = this._horizontalRange == null || (_horizontalRange.y - _horizontalRange.x) > this._target.width;
			_verticalInner = this._verticalRange == null || (_verticalRange.y - _verticalRange.x) > this._target.height;
			if (_horizontalRange)
				_hhh = (_horizontalRange.y - _horizontalRange.x - _target.width) * _horizontalSupport;
			if (_verticalRange)
				_vvv = (_verticalRange.y - _verticalRange.x - _target.height) * _verticalSupport;
		}
	}
}
