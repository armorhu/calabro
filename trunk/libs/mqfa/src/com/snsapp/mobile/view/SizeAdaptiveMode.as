package com.snsapp.mobile.view
{
    public class SizeAdaptiveMode
    {
        static public const CUSTOM:int = 0;
        
        /**
         * 表示自适应之后的ui尺寸，取Max(屏幕垂直缩放、屏幕水平缩放比例) 
         */      
        static public const MAX:int = 1;
        
        /**
         * 表示自适应之后的ui尺寸，取Min(屏幕垂直缩放、屏幕水平缩放比例) 
         */        
        static public const MIN:int = 2;
        
        static public const VERTICAL:int = 3;
        
        static public const HORIZONTAL:int = 4;
        
        
        public function SizeAdaptiveMode()
        {
        }
    }
}