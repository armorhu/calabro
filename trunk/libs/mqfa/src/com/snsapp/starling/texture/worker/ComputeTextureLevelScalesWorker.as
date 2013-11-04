package com.snsapp.starling.texture.worker
{
	import com.snsapp.mobile.mananger.workflow.SimpleWork;
	import com.snsapp.mobile.utils.MaxRectsBinPack;

	import flash.geom.Point;

	/**
	 * 计算材质等级的scale分布的逻辑类。
	 * @author hufan
	 */
	public class ComputeTextureLevelScalesWorker extends SimpleWork
	{
		private var _rects:Vector.<Point>;
		private var _texture_level:Vector.<Point>;

		public function ComputeTextureLevelScalesWorker(rects:Vector.<Point>, texture_level:Vector.<Point>)
		{
			super(null);
			_rects=rects;
			_texture_level=texture_level;
		}

		override public function start():void
		{
			var scale:Number;
			var scales:Array=[];
			scale=1;
			trace(_rects);
			for (var level:int=0; level < _texture_level.length; level++)
			{
				while (MaxRectsBinPack.batchInsert(_texture_level[level].x, _texture_level[level].y, _rects, 1, scale) == null)
				{
					if (scale < 0)
						break;
					scale-=.01;
					if (scale < 1 && level == 0)
						throw new Error('当前材质内容在没有缩放的时候无法使用一张' + _texture_level[0] + '的Texture装下。');
				}
				scale=Number(scale.toFixed(2));
				trace('Level' + level + '=' + scale);
				scales.push(scale);
			}
			trace('result:' + scales);
		}
	}
}
