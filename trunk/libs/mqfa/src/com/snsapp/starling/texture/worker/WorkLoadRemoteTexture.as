package com.snsapp.starling.texture.worker
{
	import com.qzone.qfa.interfaces.IApplication;
	import com.qzone.qfa.managers.resource.Resource;
	import com.qzone.qfa.utils.CommonUtil;
	import com.qzone.utils.DisplayUtil;
	import com.snsapp.mobile.view.bitmapclip.BitmapClipData;
	import com.snsapp.mobile.view.bitmapclip.BitmapClipDataWorker;
	import com.snsapp.mobile.view.bitmapclip.BitmapFrame;
	import com.snsapp.mobile.view.bitmapclip.vo.DrawSetting;
	import com.snsapp.starling.texture.implement.BatchTexture;
	import com.snsapp.starling.texture.implement.SingleTexture;
	import com.snsapp.starling.texture.implement.TextureBase;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;

	public class WorkLoadRemoteTexture extends WorkLoadTexture
	{
		private var _setting:DrawSetting;
		private var _cacheURL:String;

		public function WorkLoadRemoteTexture(app:IApplication, url:String, cacheURL:String, setting:DrawSetting, loading:Boolean)
		{
			super(app, url, loading);
			_setting = setting;
			_cacheURL = cacheURL;
		}

//		override public function start():void
//		{
//			if (ApplicationDomain.currentDomain.hasDefinition(url))
//			{
//				//是embed的元件。。。直接可以返回成功了。。。
//				var displayObj:DisplayObject = CommonUtil.getInstance(url) as DisplayObject;
//				drawAndCacheDisplayObj(displayObj);
//			}
//			else
//				super.start();
//		}

		override protected function onLoadResource(res:Resource):void
		{
			super.onLoadResource(res);
			if (res == null || res.data == null || !res.data is DisplayObject)
				workError();
			else
				drawAndCacheDisplayObj(res.data as DisplayObject);
		}

		private function drawAndCacheDisplayObj(displayObj:DisplayObject):void
		{
			if (displayObj is MovieClip && MovieClip(displayObj).totalFrames > 1)
			{ //动画
				var mc:MovieClip = displayObj as MovieClip;
				var worker:BitmapClipDataWorker = new BitmapClipDataWorker(_cacheURL, mc, _setting);
				worker.addEventListener(Event.COMPLETE, onCacheComplete);
				worker.addEventListener(ErrorEvent.ERROR, onCacheComplete);
				worker.start();
			}
			else
			{ //位图
				var texture:TextureBase;
				if (_setting)
				{
					var scale:Number = _setting.scale; //缩放
					var qulityX:Number = _setting.quality_x; //x轴质量
					var qulityY:Number = _setting.quality_y; //y轴质量
				}
				else
					scale = 1, qulityX = 1, qulityY = 1;

				if (_setting.maxSize)
				{ //通过修改qulityX和qulityY，保证最终位图化的大小是小于_setting.maxSize的大小的。
					if ((displayObj.width * scale * qulityX) > _setting.maxSize.x)
						qulityX *= _setting.maxSize.x / (displayObj.width * scale * qulityX);
					if ((displayObj.height * scale * qulityY) > _setting.maxSize.y)
						qulityY *= _setting.maxSize.y / (displayObj.height * scale * qulityY);
				}

				if (displayObj is Bitmap && scale * qulityX >= 1 && scale * qulityY >= 1)
				{
					texture = SingleTexture.fromBitmapdata( //
						new BitmapFrame(Bitmap(displayObj).bitmapData, 0, 0, scale * qulityX, scale * qulityY), //
						_cacheURL);
				}
				else
				{
					displayObj.scaleX = scale * qulityX;
					displayObj.scaleY = scale * qulityY;
					var frame:BitmapFrame = DisplayUtil.cacheAsBitmap(displayObj as DisplayObject, 1, 1);
					frame.scaleX = 1 / qulityX;
					frame.scaleY = 1 / qulityY;
					if (displayObj is Bitmap)
						Bitmap(displayObj).bitmapData.dispose();
					texture = SingleTexture.fromBitmapdata(frame, _cacheURL);
				}
				onLoadTextureComplete(texture);
			}
		}

		private function onCacheComplete(evt:Event):void
		{
			var worker:BitmapClipDataWorker = evt.currentTarget as BitmapClipDataWorker;
			worker.removeEventListener(Event.COMPLETE, onCacheComplete);
			worker.removeEventListener(ErrorEvent.ERROR, onCacheComplete);
			if (evt.type == Event.COMPLETE)
			{
				var v:Vector.<BitmapClipData> = new Vector.<BitmapClipData>();
				v.push(worker.result);
				var texture:TextureBase = BatchTexture.fromBitmapclipDatas(v, worker.name);
				onLoadTextureComplete(texture);
			}
			else if (evt.type == ErrorEvent.ERROR)
				workError();

			worker.dispose();
		}

		private function onLoadTextureComplete(texture:TextureBase):void
		{
			var ba:ByteArray = texture.toByteArray();
			_app.appendBytesToVFS(_cacheURL, ba);
			ba.clear(), ba = null;
			_textures.push(texture);
			workComplete();
		}

	}
}
