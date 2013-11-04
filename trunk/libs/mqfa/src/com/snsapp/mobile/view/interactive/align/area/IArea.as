package com.snsapp.mobile.view.interactive.align.area
{
	import flash.geom.Point;

	public interface IArea
	{
		/**
		 * 是否包含点x,y
		 * **/
		function checkHitTest(x:Number, y:Number):Point;
		
		/**
		 * 第几个点
		 * **/
		function getPostionsAt(index:int):Point;
	}
}