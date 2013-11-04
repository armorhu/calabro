package com.snsapp.mobile.mananger.cachepool
{
    import flash.events.IEventDispatcher;

    public interface ICacheable extends IEventDispatcher
    {
        function initForCache():void;
        function cache():void;
        function release():void;
    }
}