package com.qzone.utils
{
	import flash.utils.ByteArray;
	
	public class ObjectUtil
	{
		/**
		 * 克隆Object数据 
		 * @param source
		 * @return 
		 * 
		 */		
		public static function clone(source:Object):Object 
		{ 
			var bytes:ByteArray = new ByteArray();
			bytes.writeObject(source);
			bytes.position = 0;
			return bytes.readObject();
		}
	}
}
