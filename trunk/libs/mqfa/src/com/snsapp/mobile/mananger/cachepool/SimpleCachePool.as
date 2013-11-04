package com.snsapp.mobile.mananger.cachepool
{
	import com.snsapp.mobile.mananger.factory.SimpleFactory;

	/**
	 * 最简单的缓存池
	 * @author armorhu
	 */
	public class SimpleCachePool extends SimpleFactory implements ICachePool
	{
		protected var _pool:Array;
		protected var _maxCache:int;

		public function SimpleCachePool(theClass:Class ,maxCache:int = 10)
		{
			super(theClass);
			_pool = new Array();
		}

		override public function getInstance():Object
		{
			if (_pool.length > 0)
				return _pool.pop();
			else
				return super.getInstance();
		}

		public function set object(obj:*):void
		{
			if (_pool.indexOf(obj) == -1 && _pool.length < _maxCache)
				_pool.push(obj);
		}

		public function clear():void
		{
			_pool = null;
		}
	}
}
