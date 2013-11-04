package com.snsapp.mobile.utils
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class StoreUtil
	{
		public function StoreUtil()
		{
		}
		public static function saveToLocal(path:String, data:ByteArray):void
		{
			var file:File = new File(path);
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.WRITE);
			if (data == null)
			{
				trace("Can not save null to file.");
			}
			else
			{
				fs.writeBytes(data);
			}
			fs.close();
		}
	}
}