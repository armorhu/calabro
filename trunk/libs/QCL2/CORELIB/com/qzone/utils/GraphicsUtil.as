package com.qzone.utils
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	/**
	 *  Graphics 操作工具
	 * @author cbm
	 * 
	 */	
	final public class GraphicsUtil
	{
		/**
		 * @private 
		 * 
		 */		
		public function GraphicsUtil()
		{
			
		}
		/**
		 * 绘制对象边缘，用于调试 
		 * @param sprite 含有graphics属性的操作对象。
		 * @param color 边框颜色，默认0。
		 * 
		 */		
		public static function draw(target:DisplayObject,color:uint = 0,alpha:Number = 1,rect:Rectangle = null,fill:Boolean = false,clear:Boolean = true):void{
			
			if(target.hasOwnProperty('graphics')){
				var g:Graphics = target['graphics'];
				if(clear)g.clear();
				if(fill)
					g.beginFill(color,alpha);
				else
					g.lineStyle(1,color,alpha);
				if(rect)
					g.drawRect(rect.x,rect.y,rect.width,rect.height);
				else
					g.drawRect(0,0,target.width,target.height)
				g.endFill();
			}
		}
		/**
		 * 水平线 
		 * @param target
		 * @param color
		 * @param alpha
		 * @param rect
		 * @param size
		 * 
		 */		
		public static function hLine(target:DisplayObject,color:uint = 0,alpha:Number = 1,rect:Rectangle = null,size:int = 0):void
		{
			if(target.hasOwnProperty('graphics')){
				
				var g:Graphics = target['graphics'];
				
				g.lineStyle(size,color,alpha);
				
				if(rect){
					
					g.moveTo(rect.x,rect.y);
					g.lineTo(rect.width,rect.y);

				}else{

					g.moveTo(target.x,target.y);
					g.lineTo(target.width,target.y);
				}		
				
				g.endFill();
			
			}

			
		}

	}
}
