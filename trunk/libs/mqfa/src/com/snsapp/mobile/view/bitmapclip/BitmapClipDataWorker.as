package com.snsapp.mobile.view.bitmapclip
{
	import com.qzone.qfa.interfaces.IApplication;
	import com.qzone.utils.DisplayUtil;
	import com.snsapp.mobile.StageInstance;
	import com.snsapp.mobile.mananger.workflow.SimpleWork;
	import com.snsapp.mobile.view.bitmapclip.vo.DrawSetting;

	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;

	/**
	 * 将一个矢量的MovieClip转换为BitmapClipData
	 * @author hufan
	 */
	public class BitmapClipDataWorker extends SimpleWork
	{
		private var _bitmapclipData:BitmapClipData; //位图动画数据。
		private var _source:MovieClip;
		private var _container:Sprite;
//		private var _gap:int;
		private var _totalFrames:int;
		private var _skip:int;
		private var _currentFrame:int;
		private var _currentKeyFrame:int;
		private var _asysn:Boolean; //同步draw还是异步draw?
		private var _name:String;
		private var _scale:Number = 1;
		private var _qulityX:Number = 1;
		private var _qulityY:Number = 1;
		private var _params:Object;

		public function BitmapClipDataWorker(name:String, mc:MovieClip, setting:DrawSetting, $asysn:Boolean = true, app:IApplication = null)
		{
			super(app);
			_name = name;
			_source = mc;
			_container = new Sprite();
			_bitmapclipData = new BitmapClipData();
			result = _bitmapclipData;
			if (setting)
			{
				_scale = setting.scale; //缩放
				_qulityX = setting.quality_x; //x轴质量
				_qulityY = setting.quality_y; //y轴质量
				_container.scaleX = _scale;// * _qulityX;
				_container.scaleY = _scale;// * _qulityY;
				_totalFrames = setting.totalFrames == 0 ? mc.totalFrames : setting.totalFrames; //位图化目标长度。
				if (_totalFrames < mc.totalFrames)
					_totalFrames = mc.totalFrames;
				_skip = Math.ceil(mc.totalFrames / _totalFrames);
				_skip = Math.max(_skip, 1); //skip至少是1
				_params = setting['params'];
			}
			else
			{
				_totalFrames = mc.totalFrames;
				_skip = 1;
			}
			_currentFrame = 1;
			_currentKeyFrame = 0;
			_asysn = $asysn;
			mc.gotoAndStop(1);
		}

		public function set asysn(value:Boolean):void
		{
			_asysn = value;
		}

		/**
		 * 同步draw还是异步draw。
		 * 默认是异步
		 */
		public function get asysn():Boolean
		{
			return _asysn;
		}

		private function getNextClipBMD():Boolean
		{
			var tempBMP:BitmapData = null;
			var drawMatrix:Matrix;
			var w:int, h:int;
			var tempPt:Point;
			while (true)
			{
				if ((_currentFrame - 1) % _skip == 0)
				{ //关键帧
//					frame = BitmapFrame.fromDisplayObj(_container, 1, 1, 1);
//					frame.scaleX = 1 / _qulityX;
//					frame.scaleY = 1 / _qulityY;
					var frame:BitmapFrame = DisplayUtil.cacheAsBitmap(_container, _qulityX, _qulityY, true);
					_bitmapclipData.push(frame);
				}
				_source.nextFrame();
				_currentFrame++;
				if (_currentFrame > _source.totalFrames) //动画结束，进入下一阶段。
					return false;
				if (tempBMP)
					return true;
			}
			return false;
		}

		override public function stop():void
		{
			StageInstance.stage.removeEventListener(Event.ENTER_FRAME, onEachFrame);
		}

		override public function start():void
		{
			DisplayUtil.gotoAndStop0(_source); //帧动画回到开头
			_container.addChild(_source);
			if (_asysn) //异步
				StageInstance.stage.addEventListener(Event.ENTER_FRAME, onEachFrame);
			else
			{
				while (getNextClipBMD())
				{
					stop();
					workComplete();
				}
			}
		}

		private function onEachFrame(e:Event):void
		{
			if (getNextClipBMD() == false)
			{
				stop();
				workComplete();
			}
		}

		override public function dispose():void
		{
			_app = null;
			_bitmapclipData.dispose();
			_bitmapclipData = null;
			_container = null;
			_source = null;
		}

		public function get name():String
		{
			return _name;
		}

		public function get params():Object
		{
			return _params;
		}
	}
}
