package com.snsapp.starling.texture.worker
{
	import com.qzone.qfa.interfaces.IApplication;
	import com.qzone.qfa.managers.resource.Resource;
	import com.snsapp.mobile.mananger.workflow.SimpleWork;
	import com.snsapp.starling.texture.implement.TextureBase;

	import flash.utils.getTimer;

	/**
	 * 加载Texture基类。
	 * 通过一个url，输出一个Texture数组。
	 * @author hufan
	 */
	public class WorkLoadTexture extends SimpleWork
	{
		protected var _url:String;
		protected var _textures:Vector.<TextureBase>;
		protected var _textureNames:Vector.<String>;
		protected var _resource:Resource;
		protected var _startTime:int;
		protected var _loadTime:int;
		protected var _progressTime:int;
		protected var className:String;
		protected var _loading:Boolean; //是否需要显示loading?

		public function WorkLoadTexture(app:IApplication, url:String, loading:Boolean)
		{
			super(app);
			_url = url;
			_textureNames = new Vector.<String>();
			_textures = new Vector.<TextureBase>();
			_loading = loading;
		}

		public function get url():String
		{
			return _url;
		}

		public function get textures():Vector.<TextureBase>
		{
			return _textures;
		}

		public function pushTextureName(textureName:String):void
		{
			if (_textureNames.indexOf(textureName) == -1)
			{
//				Debugger.log(className, 'push texture:' + textureName, LogType.ASSERT);
				_textureNames.push(textureName);
			}
		}

		override public function start():void
		{
//			Debugger.log(className, ":start...", LogType.ASSERT);
			super.start();
			_startTime = getTimer();
			_app.loadResource(url, onLoadResource);
		}

		protected function onLoadResource(res:Resource):void
		{
			_loadTime = getTimer() - _startTime;
			_resource = res;
		}

		protected override function workComplete():void
		{
			_progressTime = getTimer() - _startTime - _loadTime; //处理时间
			super.workComplete();
			var total:int = getTimer() - _startTime;
			var upload:int = total - _loadTime - _progressTime; //派发时间
//			Debugger.log(className + ":complete,耗时" + total + "ms(load:" + _loadTime + ",progress:" + _progressTime + ",upload:" + upload + ")", LogType.ASSERT);
		}

		protected override function workError():void
		{
//			Debugger.log(className + ":error,耗时" + (getTimer() - _startTime) + "ms", LogType.ASSERT);
			super.workError();
		}

		public override function dispose():void
		{
			super.dispose();
			_textures = null;
			_textureNames = null;
			if (_resource)
				_resource.destroy();
			_resource = null;
		}

		public function get showLoading():Boolean
		{
			return _loading;
		}
	}
}
