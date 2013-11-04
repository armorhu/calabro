package com.snsapp.mobile.view.interactive.align.area.place
{
	import com.snsapp.mobile.view.interactive.align.area.IArea;
	
	import flash.geom.Point;

	public interface IPlaceArea extends IArea
	{
		/**
		 * 申请某行的位置id
		 * row:int = -1 时不限制哪行。
		 * **/
		function allocPlaceId(row:int = -1):int;

		/**
		 * 释放一个位置id
		 * **/
		function disposePlaceId(placeId:int):void;
	}
}
