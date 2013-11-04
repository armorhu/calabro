package com.snsapp.charon
{
    import flash.events.Event;
    
    public class CharonViewEvent extends Event
    {
        public function CharonViewEvent(type:String, data:Object)
        {
            super(type, false, false);
            this.data = data;
        }
        
        public var data:Object;
    }
}