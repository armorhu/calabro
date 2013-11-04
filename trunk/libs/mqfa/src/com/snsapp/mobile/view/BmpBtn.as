package com.snsapp.mobile.view
{
    import flash.display.MovieClip;
    import flash.events.MouseEvent;
    
    public class BmpBtn extends BmpMC
    {
        static private const UP_STATE:String = "upState";
        
        static private const DOWN_STATE:String = "downState";
        
        public function BmpBtn(src:MovieClip, scale:Number=1)
        {
            super(src, scale);
            
            addEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
            addEventListener(MouseEvent.MOUSE_UP, onMouseEvent);
            addEventListener(MouseEvent.MOUSE_OUT, onMouseEvent);
        }
        
        
        
        override public function destroy():void
        {
            removeEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
            removeEventListener(MouseEvent.MOUSE_UP, onMouseEvent);
            super.destroy();
        }
        
        
        private function onMouseEvent(evt:MouseEvent):void
        {
            switch(evt.type)
            {
                case MouseEvent.MOUSE_DOWN:
                    gotoAndStop(DOWN_STATE);
                    break;
                case MouseEvent.MOUSE_UP:
                case MouseEvent.MOUSE_OUT:
                    gotoAndStop(UP_STATE);
                    break;
            }
        }
    }
}