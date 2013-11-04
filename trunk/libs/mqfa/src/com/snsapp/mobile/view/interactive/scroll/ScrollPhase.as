package com.snsapp.mobile.view.interactive.scroll
{
	public class ScrollPhase
	{
		public static const PreScroll:int = 0; //准备开始滑
		public static const Scroll:int = 1; //滑动中
		public static const PreEndScroll:int = 2; //滑了一会停下来了
		public static const Inertance:int = 3; //惯性
		public static const Stop:int = 4; //停止
		
		public function ScrollPhase()
		{
		}
	}
}