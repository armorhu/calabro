package com.qzone.utils
{
	import flash.display.DisplayObject;

	/**
	 * 对齐工具
	 * @author cbm
	 * */
	final public class AlignUtil
	{

		public function AlignUtil()
		{

		}

		/**
		 * 获取中间位置数值
		 * @param maxValue 参照物大小数值
		 * @param value 可视化对象大小数值
		 * @return 返回的位置数值
		 * */
		public static function middle(maxValue:Number, value:Number):Number
		{
			var v:Number=0;
			v = (maxValue - value) >> 1;
			return v;
		}

		/**
		 * 获取右边或底部位置数值
		 * @param maxValue 参照物大小数值
		 * @param value 可视化对象大小数值
		 * @return 返回的位置数值
		 * */
		public static function right(maxValue:Number, value:Number):Number
		{
			var v:Number=0;
			v = maxValue - value;
			return v;
		}

		/**
		 * 移动到中心
		 * @param obj 可视化对象
		 * @param stageWidth 参照物宽度
		 * @param stageHeight 参照物高度
		 * */
		public static function moveToCenter(obj:DisplayObject, stageWidth:Number, stageHeight:Number):void
		{
			obj.x=int(middle(stageWidth, obj.width));
			obj.y=int(middle(stageHeight, obj.height));
		}

		/**
		 * 移动到右下
		 * @param obj 可视化对象
		 * @param stageWidth 参照物宽度
		 * @param stageHeight 参照物高度
		 * */
		public static function moveToBR(obj:DisplayObject, stageWidth:Number, stageHeight:Number):void
		{
			var x:Number=0;
			var y:Number=0
			x=right(stageWidth, obj.width);
			y=right(stageHeight, obj.height);
			obj.x=x;
			obj.y=y;
		}

	}
}
