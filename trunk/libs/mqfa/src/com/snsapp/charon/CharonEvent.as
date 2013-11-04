package com.snsapp.charon
{
    import flash.events.Event;
    
    public class CharonEvent extends Event
    {
        static public const LOGIN_PROGRESS:String = "loginProgress";
        
        
        public function CharonEvent(type:String, progress:LoginProgress)
        {
            super(type, bubbles, cancelable);
            
            this.progress = progress;
        }
        
        public var progress:LoginProgress;
        
        
    }
}