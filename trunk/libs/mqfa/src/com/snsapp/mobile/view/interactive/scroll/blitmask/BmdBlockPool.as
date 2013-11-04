package com.snsapp.mobile.view.interactive.scroll.blitmask
{
	import com.snsapp.mobile.view.bitmapclip.BitmapClipData;

	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	/**
	 * 供blitmask使用的位图块缓存池。
	 * @author hufan
	 */
	public class BmdBlockPool
	{
		private static var _pool:Object = new Object();
		private static const MAX_SIZE:int = 4 * 1024 * 1024; //缓存池的最大的大小
		private static var _size:int; //当前缓存池大小

		public function BmdBlockPool()
		{

		}

		public static function apply(width:int, height:int):BitmapData
		{
			var key:String = width + '-' + height;
			if (_pool[key] == undefined || _pool[key].length == 0)
			{
				trace("[BmdBlockPool]new BitmapData(", width, height, ").");
				return new BitmapData(width, height, true, 0x0);
			}
			else
			{
				_size -= width * height * 4; //一个像素4个字节
				var bmd:BitmapData = _pool[key].pop() as BitmapData;
				bmd.fillRect(bmd.rect, 0x0);
				return bmd;
			}
		}

		public static function recycle(bmd:BitmapData):void
		{
			if (_size + bmd.height * bmd.width * 4 >= MAX_SIZE)
			{ //缓存池爆炸了
				bmd.dispose();
				bmd = null;
			}
			else
			{
				var key:String = bmd.width + '-' + bmd.height;
				if (_pool[key] == undefined)
					_pool[key] = new Vector.<BitmapData>;
				_pool[key].push(bmd);
				_size += bmd.height * bmd.width * 4; //一个像素4个字节
			}
		}
	}
}
