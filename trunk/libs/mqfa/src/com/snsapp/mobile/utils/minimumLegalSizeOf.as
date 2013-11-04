package com.snsapp.mobile.utils
{
	import flash.geom.Point;

	/**
	 * 返回能装下面积area的最小的TextureSize
	 */
	public function minimumLegalSizeOf(area:int):Point
	{
		const LEVEL:Array = [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048];
		var w:int, h:int;
		for (var i:int = 1; i < LEVEL.length; i++)
		{
			w = LEVEL[i - 1];
			h = LEVEL[i - 1];
			if (w * h >= area)
				return new Point(w, h);

			w = LEVEL[i];
			h = LEVEL[i - 1];
			if (w * h >= area)
				return new Point(w, h);

			if (i == LEVEL.length - 1)
			{
				w = LEVEL[i];
				h = LEVEL[i];
				if (w * h > area)
					return new Point(w, h);
			}
		}

		return null;
	}
}
