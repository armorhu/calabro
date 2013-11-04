package com.qzone.utils
{
	public class ImageSizeUtil
	{
		private static var __style:Number;
		public static const NO_SCALE_CENTER:int = 0;
		public static const SCALE_WITH_BIG_CENTER:int = 1;
		public static const SCALE_WITH_SMALL:int = 3;
		public static const SCALE_WITH_SMALL_TOP:int = 5;
		public static const SCALE_WITH_SMALL_BUTTOM:int = 6;
		public static const NO_HANDEL:int = -1;
		public static const NO_SCALE_CENTER_AND_KEEP_IN_RECT:int = 4;
		//0为原始大小并居中,1为居中拉伸,3为放大拉申,2为变形拉申,-1不作改动,4当目标原始大小不超过给定的宽高就	使用0反之使用1
		public static function setSize1(mc1:Object, mc2:Object, style:Number):void
		{
			setSize2(mc1,mc2.x,mc2.y,mc2.width,mc2.height,style);
		}
		public static function setSize2(pic:Object, x:Number,y:Number,w:Number,h:Number, style:Number):void
		{
			//第一个参数为图片,第二个为参照物
			if(style==-1)return;
			pic.scaleX=pic.scaleY=1;
	        if(style==0)
			{
				pic.scaleX=pic.scaleY=1;
			}
			else if (style == 1)
			{
				if (pic.width/w>pic.height/h)
				{
					pic.height = (pic.height/pic.width)*w;
					pic.width = w;
				}
				else
				{
					pic.width = (pic.width/pic.height)*h;
					pic.height = h;
				}
			}
			else if (style == 3)
			{
				if (pic.width/w<pic.height/h)
				{
					pic.height = (pic.height/pic.width)*w;
					pic.width = w;
				}
				else
				{
					pic.width = (pic.width/pic.height)*h;
					pic.height = w;
				}
			}
			else if (style == 2)
			{
				pic.width = w;
				pic.height = h;
			}
			else if (style == 4)
			{
				if(pic.width>w||pic.height>h)
				{
					if (pic.width/w>pic.height/h)
					{
						pic.height = (pic.height/pic.width)*w;
						pic.width = w;
					}
					else
					{
						pic.width = (pic.width/pic.height)*h;
						pic.height = h;
					}
				}
				else
				{
					pic.scaleX=pic.scaleY=1;
				}
			}
			else if(style == 5)
			{
				if (pic.width/w<pic.height/h)
				{
					pic.height = (pic.height/pic.width)*w;
					pic.width = w;
				}
				else
				{
					pic.width = (pic.width/pic.height)*h;
					pic.height = w;
				}
				pic.x=x+w/2-pic.width/2;
				pic.y=y;
				return;
			}
			else if(style == 6)
			{
				if (pic.width/w<pic.height/h)
				{
					pic.height = (pic.height/pic.width)*w;
					pic.width = w;
				}
				else
				{
					pic.width = (pic.width/pic.height)*h;
					pic.height = w;
				}
				pic.x=x+w/2-pic.width/2;
				pic.y=h-pic.height;
				return;
			}
			
			pic.x=x+w/2-pic.width/2;
			pic.y=y+h/2-pic.height/2;
		}

	}
}