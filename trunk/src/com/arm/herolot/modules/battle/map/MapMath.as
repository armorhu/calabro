package com.arm.herolot.modules.battle.map
{
	import com.arm.herolot.Consts;
	
	import flash.geom.Point;

	public class MapMath
	{
		public function MapMath()
		{
		}

		public static function pointOf(gid:int, result_point:Point = null):Point
		{
			if (result_point == null)
				result_point = new Point();
			result_point.x = gid % Consts.MAP_COLS;
			result_point.y = int(gid / Consts.MAP_COLS);

			return result_point;
		}

		public static function gridIdOf(mx:int, my:int):int
		{
			return my * Consts.MAP_COLS + mx;
		}


		public static function getAroundGridIds(gid:int):Vector.<int>
		{
			var point:Point = pointOf(gid);
			var points:Vector.<Point> = new Vector.<Point>();
			points.push(new Point(point.x - 1, point.y - 1));
			points.push(new Point(point.x - 1, point.y));
			points.push(new Point(point.x - 1, point.y + 1));
			points.push(new Point(point.x, point.y - 1));
			points.push(new Point(point.x, point.y + 1));
			points.push(new Point(point.x + 1, point.y - 1));
			points.push(new Point(point.x + 1, point.y));
			points.push(new Point(point.x + 1, point.y + 1));
			var gids:Vector.<int> = new Vector.<int>();
			const len:int = points.length;
			for (var i:int = 0; i < len; i++)
				if (points[i].x >= 0 && points[i].x < Consts.MAP_COLS && points[i].y >= 0 && points[i].y < Consts.MAP_ROWS)
					gids.push(gridIdOf(points[i].x, points[i].y));

			points = null, point = null;
			return gids;
		}

		public static function getHpByFloor(floor:int):int
		{
			return floor*10;
		}

		public static function getAckByFloor(floor:int):int
		{
			return floor*10;
		}
	}
}
