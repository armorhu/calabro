package com.qzone.qfa.interfaces
{

	import com.qzone.qfa.control.module.IModule;
	import com.qzone.qfa.control.module.IModuleAPI;
	import com.qzone.qfa.managers.resource.ResourceLoader;
	import com.snsapp.charon.LoginData;
	import com.snsapp.mobile.device.DeviceInfo;
	import com.snsapp.starling.texture.TextureLoader;

	import flash.display.Sprite;
	import flash.events.IEventDispatcher;
	import flash.net.URLVariables;
	import flash.notifications.RemoteNotifier;
	import flash.utils.ByteArray;

	public interface IApplication extends IEventDispatcher
	{
		/**[只读]:app名称**/
		function get name():String;

		/**启动应用**/
		function startup(root:Sprite):void;

		/**根据名字获取Module**/
		function getModule(name:String):IModule;

		/**根据名字获取ModuleAPI**/
		function getModuleAPI(name:String):IModuleAPI;


		/**注册一个Module**/
		function registerModule(moduleName:String, moduleClass:Class, moduleContainer:*, swf:String = null):void

		/**
		 * 加载module
		 * @param name 模块名
		 */
		function loadModule(name:String, completeHandler:Function = null, errorHandler:Function = null):void

		/**
		 * 卸载module
		 * @param name 模块名
		 * @return
		 */
		function unloadModule(name:String):void;

		/**
		 * 读取外部素材，底层接入vfs。
		 * @param url
		 * @param onComplete 参数为具体的Resource对象 -- resource.data == null 表示加载失败！
		 * @param version  这个素材是否纳入版本控制？
		 */
		function loadResource(url:String, onComplete:Function):void;

		function loadResourceWithVersion(url:String, onComplete:Function):void;

		/**
		 * 读取外部素材，不走缓存，直接网络加载
		 * @param url
		 * @param onComplete 参数为具体的Resource对象 -- resource.data == null 表示加载失败！
		 */
		function loadResourceWithOutCache(url:String, onComplete:Function):void;

		/**
		 * 往vfs中追加文件。
		 * **/
		function appendBytesToVFS(name:String, bytes:ByteArray):Boolean;

		/**
		 * 保存新版本的素材文件，保存的同时会把本地旧文件删除。
		 * **/
		function saveVersionResource(name:String, bytes:ByteArray):void;

		function hasFile(name:String):Boolean;
		
		/**
		 * 请求一张位图
		 * @param swf 必须为swf。
		 * @param onComplete 请求的回调函数。回调函数的参数为Bitmap类型。
		 * 					 请求失败的话，回调函数传null：onComplete(null);
		 * @param width 位图的宽 默认原始宽
		 * @param height 位图的高 默认原始高
		 */
		function requestBitmap(swf:String, onComplete:Function, width:int = 0, height:int = 0):void

		/**
		 * 发送http请求
		 * @param requestId  后台接口id
		 * @param getParams  get参数
		 * @param postParams post参数
		 * @param onComplete 返回成功
		 * @param onNetError 请求失败
		 */
		function request(requestId:int, //
			getParams:Object = null, //
			postParams:URLVariables = null, //
			onComplete:Function = null, //
			onNetError:Function = null, //
			packager:IPackage = null, //request
			parser:IParser = null //reponse
			):void;

//		/**显示用户自定义的对话框**/
//		function showCustomerDialog(dialog:DisplayObject, modal:Boolean = true, params:Object = null):void;
//
//		/**显示系统框,该函数的返回值为生产的系统框对象**/
//		function showSystemDialog(type:int, modal:Boolean = true, params:Object = null):DisplayObject;
//
//		/**关闭对话框**/
//		function closeDialog(dialog:DisplayObject, params:Object = null):void;

		/**控制主循环的开关**/
		function set mainloop(bool:Boolean):void;

		function get app():IApplication;

		function get rsLoader():ResourceLoader
		function get textureLoader():TextureLoader;
		// 登录信息
		function set loginInfo(data:LoginData):void
		function get loginInfo():LoginData

		//-------apns api------------------------//
		function get tokenId():String
		function get remoteNotifier():RemoteNotifier
		function get isSupportRemoteNotifiction():Boolean

		//-------AIR Only ---------------------//
		function get deviceInfo():DeviceInfo

		function get appStage():Sprite
	}
}
