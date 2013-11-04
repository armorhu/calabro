package com.snsapp.mobile.device
{
	import com.qzone.qfa.debug.Debugger;
	import com.qzone.qfa.debug.LogType;
	import com.qzone.qfa.interfaces.IApplication;
	import com.snsapp.mobile.mananger.workflow.SimpleWork;
	import com.snsapp.mobile.utils.MobileSystemUtil;
	
	import flash.system.Capabilities;
	import flash.utils.setTimeout;
	
	import nl.funkymonkey.android.deviceinfo.NativeDeviceInfo;
	import nl.funkymonkey.android.deviceinfo.NativeDeviceInfoEvent;
	import nl.funkymonkey.android.deviceinfo.NativeDeviceProperties;
	
	public class DeviceInfo extends SimpleWork
	{
		private var _deviceName:String; //设备名字
		private var _os:String;         //系统版本号
		
		public function DeviceInfo(app:IApplication)
		{
			super(app);
		}
		
		override public function start():void{
			if(MobileSystemUtil.isAndroid())
				collectAndroidDeviceInfo();
			else　
			{
				var info:Array = Capabilities.os.split(" ");
				if (info[0] + " " + info[1] != "iPhone OS") {
					_deviceName = "unknow";
					_os = MobileSystemUtil.os;
				}else{
					_deviceName = info[3];
					_os = MobileSystemUtil.os + " " + info[2];
				}
				
				setTimeout(onGetDeviceInfo,10);
			}
		}
		
		protected function collectAndroidDeviceInfo():void{
			try
			{
				var deviceInfo:NativeDeviceInfo = new NativeDeviceInfo( /*File.applicationDirectory.nativePath + File.separator + "build.prop_htc_desire"*/);
				deviceInfo.addEventListener(NativeDeviceInfoEvent.PROPERTIES_PARSED, handleDevicePropertiesParsed);
				deviceInfo.setDebug(false);
				deviceInfo.parse();
			}
			catch (err:Error)
			{
				deviceInfo.removeEventListener(NativeDeviceInfoEvent.PROPERTIES_PARSED, handleDevicePropertiesParsed);
				_deviceName = "unknow";
				_os = Capabilities.os;
				setTimeout(onGetDeviceInfo,10);
			}
			

		}
		
		protected	function handleDevicePropertiesParsed(event:NativeDeviceInfoEvent):void
		{
			NativeDeviceInfo(event.target).removeEventListener(NativeDeviceInfoEvent.PROPERTIES_PARSED, handleDevicePropertiesParsed);
			_deviceName =  NativeDeviceProperties.PRODUCT_MANUFACTURER.value + " " + NativeDeviceProperties.PRODUCT_MODEL.value;
			_os = MobileSystemUtil.os + " " + NativeDeviceProperties.OS_VERSION.value;
			onGetDeviceInfo();
		}
		
		protected function onGetDeviceInfo():void{
			Debugger.log(_deviceName+"|"+_os,LogType.SYSTEM);
			workComplete();
		}
		
		public function get deviceName():String{return _deviceName;}
		public function get os():String{return _os;}
	}
}