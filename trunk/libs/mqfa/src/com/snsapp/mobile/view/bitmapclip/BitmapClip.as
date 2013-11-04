package com.snsapp.mobile.view.bitmapclip
{
	import com.snsapp.mobile.StageInstance;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	public class BitmapClip extends Sprite
	{
		private var _bitmap:Bitmap; //位图
		private var _renderFreq:int; // 渲染频率
		private var _renderCount:int; // 渲染计数
		private var _playing:Boolean; // 是否正在播放
		private var _currentFrame:int; // 当前帧数
		private var _frameScripts:Vector.<Function>; //脚本
		private var _bmcd:BitmapClipData; //显示数据

		public function BitmapClip(_bmcd:BitmapClipData, autoPlay:Boolean = true)
		{
			super();
			_renderFreq = 1;
			_currentFrame = 0;
			this._bmcd = _bmcd;
			_bitmap = new Bitmap(_bmcd.getFrameData(0), "auto", true);
			addChild(_bitmap);
			_bitmap.x = _bmcd.getFramePostion(0).x,_bitmap.x = _bmcd.getFramePostion(0).y,
			_frameScripts = new Vector.<Function>(totalFrames);

			init(); //static init

			if (autoPlay)
				play();
		}

		public function set renderFreq(value:int):void
		{
			_renderFreq = value;
		}

		public function get renderFreq():int
		{
			return _renderFreq;
		}

		public function play():void
		{
			if (_playing)
				return;

			_renderCount = 0; //每次播放时都重置
			registeBmClip(this);
			_playing = true;
		}

		public function stop():void
		{
			if (!_playing)
				return;

			removeBmClip(this);
			_renderCount = 0;
			_playing = false;
		}

		public function gotoAndPlay(frame:int):void
		{

		}

		public function get totalFrames():int
		{
			return _bmcd.totalFrames;
		}

		public function get currentFrame():int
		{
			return _currentFrame + 1;
		}

		public function addFrameScript(frame:int, script:Function):void
		{
			if (frame >= 0 && frame < totalFrames)
				_frameScripts[frame] = script;
		}

		/**
		 * 每个时间片调用一次的方法
		 */
		private var temp:Point;

		protected function render():void
		{
			if (_renderCount % _renderFreq == 0)
			{
				_bitmap.bitmapData = _bmcd.getFrameData(_currentFrame);
				temp = _bmcd.getFramePostion(_currentFrame);
				if (temp != null)
				{
					_bitmap.x = temp.x;
					_bitmap.y = temp.y;
				}

				if (_frameScripts[_currentFrame])
					_frameScripts[_currentFrame]();
			}
			_renderCount++;
			if (_renderCount % _renderFreq == 0)
				_currentFrame = (_currentFrame + 1) % totalFrames;
		}

		/***********************************************************************************************
		 * static
		 * *********************************************************************************************/
		private static var stage:Stage;
		private static var renderMap:Vector.<BitmapClip>;
		private static var preRenderMap:Vector.<BitmapClip>;
		private static var initliaze:Boolean; //是否初始化

		protected static function onRender(e:Event):void
		{
			const len:int = renderMap.length;
			preRenderMap = renderMap.concat();

			for (var i:int = len - 1; i >= 0; i--)
				preRenderMap[i].render();
		}

		/**
		 * 注册
		 * @param bmClip
		 */
		protected static function registeBmClip(bmClip:BitmapClip):void
		{
			init();

			if (renderMap.indexOf(bmClip) == -1)
				renderMap.push(bmClip);

			if (renderMap.length > 0)
				stage.addEventListener(Event.ENTER_FRAME, onRender);
		}

		/**
		 * 移除
		 * @param bmClip
		 */
		protected static function removeBmClip(bmClip:BitmapClip):void
		{
			init();
			var index:int = renderMap.indexOf(bmClip);
			if (index >= 0)
				renderMap.splice(index, 1);

			if (renderMap.length == 0)
				stage.removeEventListener(Event.ENTER_FRAME, onRender);
		}

		/**
		 * 初始化
		 */
		protected static function init():void
		{
			if (initliaze)
				return;

			renderMap = new Vector.<BitmapClip>();
			initliaze = true;
			stage = StageInstance.stage;
		}


		/**
		 * 克隆位图动画
		 * @return 克隆的对象
		 */
		public static function clone(source:BitmapClip):BitmapClip
		{
			return new BitmapClip(source.bitmapClipData);
		}

		public function get bitmapClipData():BitmapClipData
		{
			return _bmcd;
		}
	}
}
