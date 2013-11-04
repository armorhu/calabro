package com.snsapp.mobile.utils
{
	import com.qzone.utils.DisplayUtil;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;

	/**
	 * movieclip的工具类
	 * @author armorhu
	 */
	public class MovieClipUtil
	{
		public function MovieClipUtil()
		{
		}

		/**
		 * 返回mc的真实的totalframe
		 * @param clip
		 * @param offset
		 * @return
		 */
		public static function caculateTotalFrames(clip:MovieClip, offset:int = 0):int
		{
			var child:DisplayObject;
			var length:int = clip.totalFrames;

			var position:int, totalFrames:int = 0;
			var currentFrame:int = clip.currentFrame;
			for (var i:int = 1; i <= length; i++)
			{
				clip.gotoAndStop(i);

				var depth:int = clip.numChildren;
				for (var j:int = 0; j < depth; j++)
				{
					position = offset + i;
					child = clip.getChildAt(j);
					if (child is MovieClip)
					{
						position = caculateTotalFrames(child as MovieClip, position - 1);
					}

					if (totalFrames < position)
						totalFrames = position;
				}
			}
			clip.gotoAndPlay(currentFrame);
			return totalFrames;
		}

		/**
		 * 将mc回到第一桢
		 * @param clip
		 */
		public static function gotoAndStopHead(clip:MovieClip):void
		{
			const len:int = clip.numChildren;
			clip.gotoAndStop(1);
			for (var i:int = 0; i < len; i++)
			{
				var child:DisplayObject = clip.getChildAt(i);
				if (child is MovieClip)
					gotoAndStopHead(child as MovieClip);
			}
		}

		/**
		 * 将mc播放到下一帧
		 * 注意：播放到最后一桢时不会调回到第一桢重新播
		 * @param clip
		 */
		public static function nextframe(clip:MovieClip):void
		{
			var currentFrame:int = clip.currentFrame;
			var totalFrame:int = clip.totalFrames;
			if (currentFrame < totalFrame)
				clip.nextFrame();
			else
			{
				const len:int = clip.numChildren;
				for (var i:int = 0; i < len; i++)
				{
					var child:DisplayObject = clip.getChildAt(i);
					if (child is MovieClip)
						nextframe(child as MovieClip);
				}
			}
		}


//		/**
//		 * 分析一个mc,返回预处理信息对象
//		 * @param mc
//		 * @param skipNum 跳帧数
//		 * @return
//		 */
//		public static function analyse(mc:MovieClip, skipNum:int = 0):MovieClipInfo
//		{
//			var preInfo:MovieClipInfo = new MovieClipInfo(mc);
//			const totalFrame:uint = MovieClipUtil.caculateTotalFrames(mc);
//			MovieClipUtil.gotoAndStopHead(mc);
//			for (var i:int = 1; i < totalFrame; i++)
//			{
//				preInfo.addFrame(DisplayUtil.getRealBounds(mc)); //记录当前的位置信息
//				/**跳帧**/
//				for (var j:int = 0; j < skipNum; j++)
//				{
//					i++;
//					MovieClipUtil.nextframe(mc);
//				}
//			}
//
//			return preInfo;
//		}
	}
}
