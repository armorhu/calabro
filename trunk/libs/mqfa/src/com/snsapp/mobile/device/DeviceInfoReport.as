package com.snsapp.mobile.device
{
	import com.qzone.qfa.debug.Debugger;
	import com.qzone.qfa.debug.LogType;
	import com.snsapp.mobile.utils.MobileSystemUtil;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	
	import nl.funkymonkey.android.deviceinfo.NativeDeviceProperties;


	/**
	 * 上报Android设备信息.
	 *
	 * @author mobiuschen
	 *
	 */
	public class DeviceInfoReport
	{
		static public const CGI:String = "http://nc.qzone.qq.com/cgi-bin/cgi_mobile_log_report";

		static public const SO_KEY:String = "DeviceInfoReportFlag";

		private var _params:Object;

		public function DeviceInfoReport()
		{
		}


		private var uin:String = "";

		/**
		 * 只在Android设备上报
		 * @param uin
		 *
		 */
		public function report(uin:String, deviceInfo:DeviceInfo,params:Object = null):void
		{
			if (!needReport())
				return;
			_params = params;
			this.uin = uin;
			if(MobileSystemUtil.isIOS())
				realReport([uin,deviceInfo.deviceName,deviceInfo.os].join("|"));
			else
				realReport([uin, //uin
					NativeDeviceProperties.PRODUCT_MANUFACTURER.value + "," + NativeDeviceProperties.PRODUCT_MODEL.value, //设备名
					NativeDeviceProperties.OS_VERSION.value, //操作系统
					getActiveNetWorkNames().join(",")].join("|"));
		}


		private function realReport(info:String):void
		{
			var ul:URLLoader = new URLLoader();
			ul.addEventListener(Event.COMPLETE, onResponse);
			ul.addEventListener(IOErrorEvent.IO_ERROR, onResponse);
			//for simulator test
			//info = "346404978|HTC,Desire|3.0.1|WIFI";

			//gzip压缩
			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes(info);
			var size1:int = ba.length;
			/*var encoder:GZIPBytesEncoder = new GZIPBytesEncoder();
			ba = encoder.compressToByteArray(ba);*/
			ba.compress();
			var size2:int = ba.length;

			//注意双引号
			var cgi:String = CGI + '?' + 'size1=' + size1 + '&size2=' + size2;
			if (_params)
			{ //把params里面的参数放在cgi里面
				for (var key:String in _params)
					cgi = cgi + "&" + key + "=" + _params[key];
			}
			var ur:URLRequest = new URLRequest(cgi);
			ur.method = URLRequestMethod.POST;
			ur.contentType = "application/x-gzip";
			ur.data = ba;
			var headers:Array = [];
			ul.load(ur);

			function onResponse(evt:Event):void
			{
				ul.removeEventListener(Event.COMPLETE, onResponse);
				ul.removeEventListener(IOErrorEvent.IO_ERROR, onResponse);
				
				if (evt.type == Event.COMPLETE)
				{
					Debugger.log("[DeviceInfoReport].report success.", info,LogType.MISC);
					trunOffFlg();
				}
				else
				{
					Debugger.log("[DeviceInfoReport].report fail.", info,LogType.MISC);
				}
			}
		}



//		/**
//		 * 搜集Android设备信息
//		 * @param callback
//		 *
//		 */
//		private function collectAndroidDeviceInfo(callback:Function):void
//		{
//			try
//			{
//				var deviceInfo:NativeDeviceInfo = new NativeDeviceInfo( /*File.applicationDirectory.nativePath + File.separator + "build.prop_htc_desire"*/);
//				deviceInfo.addEventListener(NativeDeviceInfoEvent.PROPERTIES_PARSED, handleDevicePropertiesParsed);
//				deviceInfo.setDebug(false);
//				deviceInfo.parse();
//			}
//			catch (err:Error)
//			{
//				deviceInfo.removeEventListener(NativeDeviceInfoEvent.PROPERTIES_PARSED, handleDevicePropertiesParsed);
//				if (callback != null)
//					callback();
//			}
//
//			function handleDevicePropertiesParsed(event:NativeDeviceInfoEvent):void
//			{
//				NativeDeviceInfo(event.target).removeEventListener(NativeDeviceInfoEvent.PROPERTIES_PARSED, handleDevicePropertiesParsed);
//
//				if (callback != null)
//					callback();
//			/*
//			trace(NativeDeviceProperties.OS_NAME.label + " - " + NativeDeviceProperties.OS_NAME.value);
//			trace(NativeDeviceProperties.OS_VERSION.label + " - " + NativeDeviceProperties.OS_VERSION.value);
//			trace(NativeDeviceProperties.OS_BUILD.label + " - " + NativeDeviceProperties.OS_BUILD.value);
//			trace(NativeDeviceProperties.OS_SDK_VERSION.label + " - " + NativeDeviceProperties.OS_SDK_VERSION.value);
//			trace(NativeDeviceProperties.OS_SDK_DESCRIPTION.label + " - " + NativeDeviceProperties.OS_SDK_DESCRIPTION.value);
//			trace(NativeDeviceProperties.PRODUCT_MODEL.label + " - " + NativeDeviceProperties.PRODUCT_MODEL.value);
//			trace(NativeDeviceProperties.PRODUCT_BRAND.label + " - " + NativeDeviceProperties.PRODUCT_BRAND.value);
//			trace(NativeDeviceProperties.PRODUCT_NAME.label + " - " + NativeDeviceProperties.PRODUCT_NAME.value);
//			trace(NativeDeviceProperties.PRODUCT_VERSION.label + " - " + NativeDeviceProperties.PRODUCT_VERSION.value);
//			trace(NativeDeviceProperties.PRODUCT_BOARD.label + " - " + NativeDeviceProperties.PRODUCT_BOARD.value);
//			trace(NativeDeviceProperties.PRODUCT_CPU.label + " - " + NativeDeviceProperties.PRODUCT_CPU.value);
//			trace(NativeDeviceProperties.PRODUCT_MANUFACTURER.label + " - " + NativeDeviceProperties.PRODUCT_MANUFACTURER.value);
//			trace(NativeDeviceProperties.OPENGLES_VERSION.label + " - " + NativeDeviceProperties.OPENGLES_VERSION.value);
//			trace(NativeDeviceProperties.LCD_DENSITY.label + " - " + NativeDeviceProperties.LCD_DENSITY.value);
//			trace(NativeDeviceProperties.DALVIK_HEAPSIZE.label + " - " + NativeDeviceProperties.DALVIK_HEAPSIZE.value);
//			*/
//			}
//		}


		private function getActiveNetWorkNames():Vector.<String>
		{
			var ntf:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
			var activeNames:Vector.<String> = new Vector.<String>();
			for each (var interfaceObj:NetworkInterface in ntf)
				if (interfaceObj.active)
					activeNames.push(interfaceObj.name);
			return activeNames;
		}


		/**
		 * 检查本地SO, 是否需要上报.
		 * @return
		 *
		 */
		private function needReport():Boolean
		{
			var so:SharedObject = SharedObject.getLocal(SO_KEY, "/");
			var flag:Boolean = so.data.hasReport != "true";
			return flag;
		}


		/**
		 * 已经上报过, 则此设备以后都不再上报.
		 *
		 */
		private function trunOffFlg():void
		{
			var so:SharedObject = SharedObject.getLocal(SO_KEY, "/");
			so.data.hasReport = "true";
			so.flush(50);
		}
	}
}
