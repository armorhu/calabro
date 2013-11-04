package com.snsapp.mobile.view.interactive.scroll.blitmask.itemlist
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Point;

	/**
	 * 列表的代理
	 * 管理一份列表的数据，
	 * 并能告诉用户列表中每一项对应的item显示
	 * @author hufan
	 */
	public interface IItemListDelegate
	{
		/**
		 * 由上层代理为滚动组件的第i块画东西。
		 * 返回值为本次绘画是否成功，滚动组件会一直调用这个方法，直至返回true。
		 * **/
		function drawRealityItemRender(index:int, bmd:BitmapData, drawComplete:Function):void;
		/**第i个对象的模拟显示,返回一个Bitmapdata**/
		function getMockItemRender(index:int):BitmapData;
		/**列表每一项的宽**/
		function get itemWidth():Number;
		/**列表每一项的高**/
		function get itemHeight():Number;
		/**列表的宽**/
		function get listWidth():Number;
		/**列表的高**/
		function get listHeight():Number;
		/**
		 * 滚动组件告诉上层停止绘画。
		 * 改方法仅在延迟渲染的组件中使用，没有用到延迟渲染的组件，请保持这个方法为空逻辑。
		 * **/
		function stopDrawable():void;
	}
}
