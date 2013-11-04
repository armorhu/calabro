package com.arm.herolot
{
	import flash.geom.Rectangle;

	/**
	 * 将应用的全局常量定义在这个类里面
	 * @author hufan
	 */
	public class Consts
	{
		public static const DEBUG:Boolean = false;
		public static const VERSION:String = '1.0';
		public static const RSL_VERSION:int = 1;
		public static const IP4:Rectangle = new Rectangle(0, 0, 640, 960);

		//==============================so-start ====================================//
		public static const SO_CLIENT_VERSION:String = 'so_client_version';
		//==============================so-end   ====================================//

		//==============================res-start ====================================//
		public static const RES_LAUNCH:String = 'res/swf/mainmenu.swf';
		public static const RES_BATTLE:String = 'res/swf/battle.swf';
		//==============================res-end   ====================================//

		//===========================battle consts-start ==============================//
		public static const MAP_ROWS:int = 6;
		public static const MAP_COLS:int = 5;
		public static const TILE_SIZE:Number = 128;
		public static const TOTAL_FLOORS_COUNT:int = 100;
		public static const EQUIPMENT_ROWS:int = 2;
		public static const EQUIPMENT_COLS:int = 4;
		//===========================battle consts-end ================================//
	}
}
