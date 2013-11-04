package com.qzone.corelib.data
{   

	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;

	public class LocalData 
	{
	    /**
	     * SO文件存储文件名 
	     */		
	    public static var dataName:String = 'LocalData';
		public static var localPath:String
		public function LocalData()
		{
				
			throw new Error("实例化单例类出错-LocalData");
  			
		}
		/**
		 * 写入一个值
		 */
		public static function setObject(name:String,value:Object,time:Number = 0,flushNow:Boolean = false):Boolean
		{
			var so:SharedObject = SharedObject.getLocal(dataName,localPath);
			if(time == 0)
			{
				time = new Date(2038,12,31).time;

			}
			
			so.data[name] = {'value':value,'time':time};
			
			if(flushNow){
				
				var flushResult:Boolean = flush(so);
				
				if(flushResult == false){
					delete so.data[name];
				}
				return flushResult;
			}
			return flushNow;
		}

		/**
		 * 获得一个值
		 */
		public static function getObject(name:String,time:Number = 0):Object
		{
			
			var returnValue:Object;
			
			try{
				
				var so:SharedObject = SharedObject.getLocal(dataName,localPath);
				
				if(time == 0){
					time = new Date().time;
				}
				
				if(so.data[name])
				{
					if(so.data[name].hasOwnProperty('time')){//兼容老数据
						
						var dif:Number = so.data[name].time - time;
						
						if( dif >= 0 )
						{
							returnValue = so.data[name].value;
						}
						
					}else{
							returnValue = so.data[name];
						 
					}
				}
			}catch(e:Error){
				trace(e)
			}
			return returnValue;
		 }

		/**
		 * 判断是否有一个数据
		 */
 		private static function flush(so:SharedObject):Boolean{
 			
 			try
			{	
				var flushResult:String = so.flush();
				
				if(flushResult == SharedObjectFlushStatus.PENDING)
				{
					trace("PENDING -- 数据超出限制");
					
				}else if(flushResult == SharedObjectFlushStatus.FLUSHED){
					
					trace("FlUSHED -- 成功写入");
					
				}
				
				return true;
				
			}catch(e:Error){
				
				trace('ERROR -- 写入失败')
				
			}
        	return false
 		} 
        public static function hasObject(name:String):Boolean
        {
        	var so:SharedObject = SharedObject.getLocal(dataName,localPath);
        	
        	var _hasobj:Boolean;
        	var now:Number = new Date().time;
        	
        		if(so.data.hasOwnProperty(name))
				{
					var dif:Number = so.data[name].time - now;
					if( dif > 0 )
					{
						_hasobj = true;
					}
				}
			
            return _hasobj;
		 }

         /**
         * 清除数据
         */
         public static function clearObject(name:String):void
         {
         	var so:SharedObject = SharedObject.getLocal(dataName,localPath);
         	
         	delete so.data[name];
         }
         

	}
}