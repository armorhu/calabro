package com.snsapp.mobile.mananger.cachepool
{
	import com.snsapp.mobile.mananger.factory.IFactory;

	public interface ICachePool extends IFactory
	{
		function set object(obj:*):void;
		function clear():void;
	}
}
