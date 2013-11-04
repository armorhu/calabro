package com.snsapp.starling.texture.worker
{
	import com.qzone.qfa.debug.Debugger;
	import com.qzone.qfa.debug.LogType;
	import com.qzone.qfa.interfaces.IApplication;
	import com.qzone.qfa.managers.resource.Resource;
	import com.snsapp.starling.texture.implement.TextureBase;
	
	import flash.utils.ByteArray;

	public class WorkLoadCacheTexture extends WorkLoadTexture
	{
		public function WorkLoadCacheTexture(app:IApplication, url:String, loading:Boolean)
		{
			super(app, url, loading);
		}

		override protected function onLoadResource(res:Resource):void
		{
			super.onLoadResource(res);
			if (res.data == null)
				workError();
			else
			{
				try
				{
					var ba:ByteArray = res.data as ByteArray;
					var texture:TextureBase = TextureBase.fromByteArray(ba, res.url);
					ba.clear(), ba = null;
				}
				catch (error:Error)
				{
					Debugger.log(error.getStackTrace(), LogType.ERROR);
				}

				if (texture)
				{
					_textures.push(texture);
					workComplete();
				}
				else
					workError();
			}
		}
	}
}
