package com.snsapp.mobile.view.spritesheet
{
	import com.qzone.qfa.interfaces.IApplication;
	import com.qzone.qfa.managers.resource.Resource;
	import com.snsapp.mobile.mananger.workflow.SimpleWork;

	import flash.display.Bitmap;

	/**
	 * 加载SpriteSheet的Work。
	 * @author hufan
	 */
	public class SpriteSheetLoadWorker extends SimpleWork
	{
		private var _png:String;
		private var _xml:String;

		public function SpriteSheetLoadWorker(app:IApplication, png:String, xml:String)
		{
			super(app);
			_png=png;
			_xml=xml;
		}

		override public function start():void
		{
			var res1:Resource;
			var res2:Resource;
			_app.loadResource(_png, onLoadResource);
			_app.loadResource(_xml, onLoadResource);

			function onLoadResource(res:Resource):void
			{
				if (res.url == _png)
					res1=res;
				else if (res.url == _xml)
					res2=res;

				if (res1 && res2)
				{ //加载都完成了
					if (res1.data is Bitmap && res2.data is XML)
					{ //并且都加载成果
						result=new SpriteSheet(Bitmap(res1.data).bitmapData, res2.data as XML);
						workComplete();
					}
					else
						workError();

					res1.destroy();
					res2.destroy();
				}
			}
		}
	}
}
