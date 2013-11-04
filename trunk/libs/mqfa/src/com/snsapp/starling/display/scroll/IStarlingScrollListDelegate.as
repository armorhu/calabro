package com.snsapp.starling.display.scroll
{
	import starling.display.DisplayObject;

	public interface IStarlingScrollListDelegate
	{
		function renderItemAt(index:int, oldRender:DisplayObject):DisplayObject;
		function get itemWidth():Number;
		function get itemHeight():Number;
		function get level():int;
		function get length():int;
	}
}
