package com.snsapp.mobile.mananger.factory
{

	/**
	 * 最简单的工厂.
	 * 直接new
	 * @author armorhu
	 */
	public class SimpleFactory implements IFactory
	{
		protected var _instanceClass:Class

		public function SimpleFactory(theClass:Class)
		{
			if (theClass == null)
				throw new Error("不能传空的类！！");
			_instanceClass = theClass;
		}

		public function getInstance():Object
		{
			return new _instanceClass();
		}
	}
}
