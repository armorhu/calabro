package com.adobe.nativeExtensions
{
	public class Product
	{
		private var _title:String = null;
		private var _desc:String = null;
		private var _id:String = null;
		private var _priceLocale:String = null;
		private var _price:Number = 0;
		
		public function Product(t:String,d:String,i:String,pl:String,p:Number)
		{
			_title = t;
			_desc = d;
			_id = i;
			_priceLocale = pl;
			_price = p; 
		}
		
		public function get title():String{
			return _title;
		}
		
		public function get description():String{
			return _desc;
		}
		
		public function get identifier():String{
			return _id;
		}
		
		public function get priceLocale():String{
			return _priceLocale;
		}
		
		public function get price():Number{
			return _price;
		}
	}
}