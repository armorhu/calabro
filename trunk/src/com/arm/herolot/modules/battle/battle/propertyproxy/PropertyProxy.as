package com.arm.herolot.modules.battle.battle.propertyproxy
{

	/**
	 * 属性代理。
	 */
	public class PropertyProxy
	{
		private var _orignal:Number;
		private var _base:Number;
		private var _per:Number = 1;
		private var _addtion:Number = 0;

		public function PropertyProxy()
		{
			_orignal = 0;
			_base = 0;
			_per = 1;
			_addtion = 0;
		}

		public function get value():Number
		{
			return _base * _per + _addtion;
		}

		public function set value(num:Number):void
		{
			_base = (num - _addtion) / _per;
		}

		public function get base():Number
		{
			return _base;
		}

		public function set base(num:Number):void
		{
			_base = num;
		}

		public function get per():Number
		{
			return _per;
		}

		public function set per(num:Number):void
		{
			_per = num;
		}

		public function get add():Number
		{
			return _addtion;
		}

		public function set add(num:Number):void
		{
			_addtion = num;
		}

		public function get orignal():Number
		{
			return _orignal;
		}

		public function set orignal(num:Number):void
		{
			_orignal = num;
			_base = num;
		}
	}
}
