package com.snsapp.starling.texture
{

	public class ClientTextureParams
	{
		public var deviceName:String; //设备名称 --- 用来检索该设备的默认材质等级
		public var deviceDefalutLevelConfig:XML; //设备默认材质等级配置
		
		public var clientVersion:String; //app版本号 --app版本号和操作系统用来检索设备的动态材质配置
		public var os:String; //操作系统
		
		public var screenScale:Number; //屏幕缩放
		public var textureVersion:String; //材质版本号
		
		public var resouceSwf:String; //资源包
	}
}
