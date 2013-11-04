package com.adobe.nativeExtensions
{
	public class Transaction
	{
		private var _error:String;
		private var _productIdentifier:String;
		private var _productQuantity:int;
		private var _date:Date;
		private var _transactionIdentifier:String;
		private var _receipt:String;
		private var _state:int;
		private var _originalTransaction:Transaction;
		
		public static const TRANSACTION_STATE_PUCHASING:int = 0;
		public static const TRANSACTION_STATE_PUCHASED:int = 1;
		public static const TRANSACTION_STATE_FAILED:int = 2;
		public static const TRANSACTION_STATE_RESTORED:int = 3;
		
		public function Transaction(e:String,pi:String,q:int,dt:Date,ti:String,r:String,st:int,og:Transaction)
		{
			_error = e;
			_productIdentifier = pi;
			_productQuantity = q;
			_date = dt;
			_transactionIdentifier = ti;
			_receipt = r;
			_state = st;
			_originalTransaction = og;
		}
		
		public function get error():String{
			return _error;
		}
		
		public function get productIdentifier():String{
			return _productIdentifier;
		}
		
		public function get productQuantity():int{
			return _productQuantity;
		}
		
		public function get date():Date{
			return _date;
		}
		
		public function get transactionIdentifier():String{
			return _transactionIdentifier;
		}
		
		public function get receipt():String{
			return _receipt;
		}
		
		public function get state():int{
			return _state;
		}
		
		public function get originalTransaction():Transaction{
			return _originalTransaction;
		}
	}
}