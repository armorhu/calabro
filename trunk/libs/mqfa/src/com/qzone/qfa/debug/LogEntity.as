package com.qzone.qfa.debug
{

    /**
     * 单条的记录 
     * @author chenmobius
     * 
     */    
    public class LogEntity
    {
        
        /**
         * 序列化 
         * @return 
         * 
         */    
        static public function serialize(log:LogEntity):XML
        {
            if(log == null)
                return null;
            
            var xml:XML = <log/>;
            xml.@type = log.type;
            xml.@msg = log.msg;
            xml.@time = log.time;
            
            //xml format: 
            //<log type="misc" msg="Serialize" time="1339765141319"/>
            return xml;
        }
        
        
        /**
         * 反序列化 
         * 
         * @param value
         * 
         */    
        static public function deserialize(xml:XML):LogEntity
        {
            //xml format
            //<log type="misc" msg="Serialize" time="1339765141319"/>
            
            if(xml == null || xml.@msg.length() == 0 || xml.name() != "log") 
                return null;
            
            var t:String = xml.@type.length() == 0 ? LogType.MISC : xml.@type;
            var log:LogEntity = new LogEntity(xml.@msg, 0, t);
            log.time = isNaN(xml.@time) ? 0 : Number(xml.@time);
            
            return log;
        }
        
        
        
        /**
         * log内容 
         */        
        public var msg:String;
        
        /**
         * log的时间 
         */        
        public var time:Number;
        
        /**
         * LogType枚举的值 
         */        
        public var type:String
        
        
        /**
         * 一条Log数据
         * 
         * @param msg log内容
         * @param type log类型
         * @param time log时间
         * 
         */    
        public function LogEntity(msg:String, time:Number, type:String)
        {
            this.msg = msg;
            this.time = time;
            this.type = type;
        }
        
        
        
        public function clone():LogEntity
        {
            return new LogEntity(msg, time, type);
        }
        
        
        public function toString():String
        {
            return "<p class='t'>" + timeString() + 
                   ":</p><p class='m'>" + 
                   msg.replace(/\</g, "&lt;").replace(/\>/g, "&gt;") + "</p>";
        }
        
        public function toStringWithoutFormat():String
        {
            return time + " : \n" + msg + "\n";
        }
        
        
        private function timeString():String
        {
            if (time < 0)
                return "0";
            var date:Date = new Date(time);
            return date.getHours() + ":" + date.getMinutes() + ":" + 
                   date.getSeconds() + ":" + date.getMilliseconds();
        }
    }
}