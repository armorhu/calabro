package com.snsapp.mobile.utils
{
	import com.snsapp.mobile.view.ScreenAdaptiveUtil;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;

	public class FeatureIntroduce
	{
		private static var view:IntroduceView;
		private static var bg:Bitmap;
		private static var complete:Function;

		public function FeatureIntroduce()
		{
		}

		public static function show(container:Sprite, completeFn:Function, page:int, btnArea:Rectangle):void
		{
			if (bg == null)
			{
				bg = new Bitmap(new BitmapData(1, 1, false, 0));
				bg.width = ScreenAdaptiveUtil.ACTUAL_SCREEN_RECT.width;
				bg.height = ScreenAdaptiveUtil.ACTUAL_SCREEN_RECT.height;
			}
			if (bg.stage == null)
				container.addChild(bg);
			complete = completeFn;
			view = new IntroduceView( //
				ScreenAdaptiveUtil.ACTUAL_SCREEN_RECT.width, // 
				ScreenAdaptiveUtil.ACTUAL_SCREEN_RECT.height, page, btnArea);
			view.addEventListener(Event.COMPLETE, onViewComplete);
			container.addChild(view);
		}

		private static function onViewComplete(evt:Event):void
		{
			view.removeEventListener(Event.COMPLETE, onViewComplete);
			if (view.parent)
				view.parent.removeChild(view);
			view = null;
			if (bg.stage)
				bg.parent.removeChild(bg);
			bg = null;
			if (complete != null)
				complete();
		}
	}
}

import com.qzone.qfa.managers.LoadManager;
import com.qzone.qfa.managers.events.LoaderEvent;
import com.qzone.qfa.managers.resource.Resource;
import com.snsapp.mobile.view.interactive.scroll.pageviewer.HorPageViewer;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;



class IntroduceView extends Sprite
{
	public function IntroduceView(stageWidth:Number, stageHeight:Number, num:int, btnArea:Rectangle):void
	{
		this.stageWidth = stageWidth;
		this.stageHeight = stageHeight;
		this.num = num;
		this.btnArea = btnArea;

		show();
	}

	private var stageWidth:Number;
	private var stageHeight:Number;
	private var res:Resource;
	private var num:int;
	private var btnArea:Rectangle;


	private function show():void
	{
		var loader:LoadManager = new LoadManager();
		loader.addEventListeners(loadHandler);
		loader.add("feturce_introduce.jpg");
		loader.start();
	}

	private function loadHandler(e:LoaderEvent):void
	{
		switch (e.type)
		{
			case LoaderEvent.COMPLETE:
			{
				res = e.item;
				var bitmap:Bitmap = e.item.data as Bitmap;
				var scaleX:Number = stageWidth / 960;
				var scaleY:Number = stageHeight / 640;
				var scale:Number = Math.min(scaleX, scaleY);

//				var horPageView:HorPageViewer = new HorPageViewer(bitmap, 4, false);
				var horPageView:HorPageViewer = new HorPageViewer(bitmap, num, false);
				stage.addChild(horPageView);
				horPageView.scaleX = scale, horPageView.scaleY = scale;
				horPageView.x = (stageWidth - horPageView.width) * .5;
				horPageView.y = (stageHeight - horPageView.height) * .5;
				horPageView.completeArea = btnArea; // new Rectangle(3267, 94, 250, 96);
				horPageView.addEventListener(Event.COMPLETE, newFeatureIntroduceComplete);
				break;
			}
			case LoaderEvent.ERROR:
			{
				e.loader.stop();
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
	}

	private function newFeatureIntroduceComplete(e:Event):void
	{
		var horPageView:HorPageViewer = e.target as HorPageViewer;
		horPageView.removeEventListener(Event.COMPLETE, newFeatureIntroduceComplete);
		horPageView.dispose(), horPageView = null;
		res.destroy(), res = null;
		dispatchEvent(new Event(Event.COMPLETE));
	}
}
