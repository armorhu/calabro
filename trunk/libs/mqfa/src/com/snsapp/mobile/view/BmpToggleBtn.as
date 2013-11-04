package com.snsapp.mobile.view
{
    import flash.display.MovieClip;
    import flash.events.MouseEvent;
    
    /**
     * 
     * @author mobiuschen
     * 
     */
    public class BmpToggleBtn extends BmpMC
    {
        static public const ON_STATE:String = "onState";
        
        static public const OFF_STATE:String = "offState";
        
        
        public function BmpToggleBtn(src:MovieClip, scale:Number = 1.0)
        {
            super(src, scale);
            
            addEventListener(MouseEvent.CLICK, onClick);
        }
        
        
        
        override public function destroy():void
        {
            removeEventListener(MouseEvent.CLICK, onClick);
            super.destroy();
        }
        
        
        private function onClick(evt:MouseEvent):void
        {
            if(getCrtLabel() == ON_STATE)
                gotoAndStop(OFF_STATE);
            else if(getCrtLabel() == OFF_STATE)
                gotoAndStop(ON_STATE);
        }
        
        
        public function toState(state:String):void
        {
            if([ON_STATE, OFF_STATE].indexOf(state) < 0)
                return;
            gotoAndStop(state);
        }
    }
}