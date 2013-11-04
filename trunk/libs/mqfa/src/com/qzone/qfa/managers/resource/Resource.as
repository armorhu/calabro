package com.qzone.qfa.managers.resource
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.media.Sound;
	import flash.utils.ByteArray;

	/**
	 * 标准化外部资源类
	 */
	dynamic public class Resource
	{

		public function Resource()
		{

		}

		//类型
		public var type:String;

		//地址
		public var url:String;

		//包含的数据
		public var data:*;

		// loaderInfo object
		public var loaderInfo:LoaderInfo;

		// 资源加载器
		public var loader:Object;

		// string format
		public function toString():String
		{
			return "[Resource]{url:" + url + ", type:" + type + "}";
		}

		/*
		 * destroy resouce flow
		 * */
		public function destroy():void
		{
			if (data is DisplayObject)
			{
				var p:DisplayObjectContainer = DisplayObject(data).parent;
				if (p is Loader)
				{
					if (Loader(p).hasOwnProperty("unloadAndStop"))
						Loader(p)["unloadAndStop"]();
					else
						Loader(p).unload();
				}
			}
			//remove swf
			if (data is MovieClip && !(p is Loader) && p)
			{
				p.removeChild(MovieClip(data));
			}
			//dispose image
			else if (data is Bitmap)
			{
				Bitmap(data).bitmapData.dispose();
				Bitmap(data).bitmapData = null;
			}
			else if (data is ByteArray)
				ByteArray(data).clear();

			url = undefined;
			type = undefined;
			data = null;
		}
	}
}
