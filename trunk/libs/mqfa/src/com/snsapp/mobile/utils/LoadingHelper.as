package com.snsapp.mobile.utils
{
	import com.qzone.qfa.interfaces.IApplication;
	import com.snsapp.mobile.StageInstance;
	import com.snsapp.mobile.view.bmpLib.BitmapMC;
	import com.snsapp.mobile.view.ScreenAdaptiveUtil;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;

	import flashx.textLayout.formats.TextAlign;


	/**################################
	 * @LoadingManager
	 * @author sevencchen
	 * @2012-8-28
	 * ###################################
	 */

	public class LoadingHelper
	{
		private var _loadingMap:Dictionary;
		private var _loginLoading:MovieClip;
		private var _globalLoaing:BitmapMC;
		private var _globalLoaingText:TextField;
		private var _loadingLayer:Sprite;
		private var _app:IApplication;
		private var _screenScale:Number;
		private var _embedFont:String;

		private var _liteLoading:Class;
		private var _movieLoading:Class;

		public function LoadingHelper(app:IApplication, embedFont:String, liteLoading:Class, movieLoading:Class)
		{
			_app = app;
			_embedFont = embedFont;
			_loadingMap = new Dictionary(true);
			_liteLoading = liteLoading;
			_movieLoading = movieLoading;
			_loadingLayer = _app.appStage.getChildByName("loadingLayer") as Sprite;
			_screenScale = ScreenAdaptiveUtil.SCALE_COMPARED_TO_IP4.maxScale;
		}

		/**
		 *
		 * @param container Loading容器
		 * @param x  Loaing.x
		 * @param y Loaing.y
		 * @param rect  是否显示Mask, null为不设
		 *
		 */
		public function showContainerLoading(container:DisplayObjectContainer, x:Number = 0, y:Number = 0, maskRect:Rectangle = null):void
		{
			if (_loadingMap[container] == null)
			{
				_loadingMap[container] = new BitmapMC(new _liteLoading, _screenScale);
				_loadingMap[container].mouseChildren = _loadingMap[container].mouseEnabled = false;
				_loadingMap[container].x = x - _loadingMap[container].width * .5;
				_loadingMap[container].y = y - _loadingMap[container].height * .5;
				if (maskRect != null)
					container.addChild(createMask(maskRect));
				container.addChild(_loadingMap[container]);
				_loadingMap[container].play();
			}

		}

		public function hideContainerLoading(container:DisplayObjectContainer):void
		{
			if (_loadingMap[container] != null)
			{
				_loadingMap[container].stop();
				var mask:Sprite = container.getChildByName("loadingMask") as Sprite;
				if (mask != null)
				{
					mask.graphics.clear();
					container.removeChild(mask);
					mask = null;
				}
				container.removeChild(_loadingMap[container]);
				delete _loadingMap[container];
				_loadingMap[container] == null;
			}
		}

		/**
		 *只有文字提示的loading
		 * @param msg
		 * @param color
		 *
		 */
		public function showLoadingText(msg:String, size:uint = 32, color:uint = 0xFFEC0B):void
		{
			if (_globalLoaingText == null)
			{
				_globalLoaingText = new TextField;
				_globalLoaingText.defaultTextFormat = new TextFormat(_embedFont, size, color);
				_globalLoaingText.antiAliasType = AntiAliasType.ADVANCED;
				_globalLoaingText.embedFonts = true;
				_globalLoaingText.filters = [new GlowFilter(0, 1, 2, 2, 100, 3)];
			}

			_globalLoaingText.text = msg;

			_globalLoaingText.autoSize = TextAlign.CENTER;
			_globalLoaingText.scaleX = _globalLoaingText.scaleY = _screenScale;
			_globalLoaingText.x = (stageRect.width - _globalLoaingText.width) * .5;
			_globalLoaingText.y = (stageRect.height - _globalLoaingText.height) * .5;

			hideLoading();

			_loadingLayer.addChild(createMask(stageRect));
			_loadingLayer.addChild(_globalLoaingText);
		}

		public function showLoading(x:Number, y:Number):void
		{
			if (_globalLoaing == null)
			{
				_globalLoaing = new BitmapMC(new _liteLoading, _screenScale)
				_globalLoaing.name = "globalLoaing";
			}

			if (_globalLoaing.stage != null)
				return;

			hideLoading();
			_loadingLayer.addChild(createMask(stageRect));

			if (x > 0)
				_globalLoaing.x = x - _globalLoaing.width * .5;
			else
				_globalLoaing.x = (stageRect.width - _globalLoaing.width) * .5;
			if (y > 0)
				_globalLoaing.y = y - _globalLoaing.height * .5;
			else
				_globalLoaing.y = (stageRect.height - _globalLoaing.height) * .5;
			_loadingLayer.addChild(_globalLoaing);
			_globalLoaing.play();

		}


		public function showLoadingWithLoginInfo(msg:String):void
		{
			if (_loginLoading == null)
			{
				_loginLoading = new _movieLoading;
				_loginLoading.name = "loginLoading";
				setSizeAndPos(_loginLoading);
			}
			_loginLoading.loadingInfo.text = msg;

			hideLoading();

			_loginLoading.y = stageRect.height * .5;
			_loadingLayer.addChild(createMask(stageRect));
			_loadingLayer.addChild(_loginLoading);
			_loginLoading.play();
		}

		public function hideLoading():void
		{
			while (_loadingLayer && _loadingLayer.numChildren > 0)
			{
				_loadingLayer.removeChildAt(0);
			}
			if (_globalLoaing != null)
				_globalLoaing.stop();
		}

		private function get stageRect():Rectangle
		{
			return MobileScreenUtil.getScreenRectInLandScape(StageInstance.stage);
		}


		private function setSizeAndPos(target:DisplayObject):void
		{
			var rect:Rectangle = ScreenAdaptiveUtil.ACTUAL_SCREEN_RECT;
			//设计尺寸是ip4的尺寸
			var minS:Number = ScreenAdaptiveUtil.getRectScale(ScreenAdaptiveUtil.IPHONE4_RECT, ScreenAdaptiveUtil.ACTUAL_SCREEN_RECT).minScale;

			target.scaleX = target.scaleY = minS;
			//居中
			target.x = rect.width >> 1;
			target.y = rect.height >> 1;
			//默认不显示
		}

		private function createMask(rect:Rectangle):Sprite
		{
			var mask:Sprite = new Sprite;
			mask.name = "loadingMask";
			var bmd:BitmapData = new BitmapData(1, 1, true, 0x55000000);
			mask.graphics.beginBitmapFill(bmd);
			mask.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
			mask.graphics.endFill();
			return mask;
		}
	}
}
