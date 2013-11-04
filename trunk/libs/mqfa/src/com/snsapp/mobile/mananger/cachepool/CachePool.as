package com.snsapp.mobile.mananger.cachepool
{


	public class CachePool
	{
		private var max_size:int;
		private var _pool:Object;
		private var _size:int;

		public function CachePool(size:int)
		{
			max_size = size;
			_size = 0;
			_pool = new Object();
		}

		public function pop(key:String, remove:Boolean = false):Object
		{
			if (_pool[key] != undefined)
			{
				var a:Object = _pool[key]['a'];
				var b:int = _pool[key]['b'];
				if (remove)
				{
					_size -= b;
					_pool[key] = null;
				}
				return a;
			}
			return null;
		}

		public function push(obj:Object, key:String, size:int = 1):Object
		{
			if (_pool[key] == undefined)
			{
				if (size + _size > max_size)
					return obj;
				else
				{
					_pool[key] = {a: obj, b: size};
					_size += size;
				}
			}
			else
			{
				if (_pool[key] == obj)
					return null;
				else
					return obj;
			}
		}
	}
}
