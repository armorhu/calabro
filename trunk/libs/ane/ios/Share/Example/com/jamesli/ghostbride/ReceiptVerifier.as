package com.jamesli.ghostbride
{
	import com.adobe.nativeExtensions.Transaction;
	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class ReceiptVerifier extends URLLoader
	{
		public var transaction:Transaction;
		public function ReceiptVerifier(request:URLRequest=null,pTransaction:Transaction=null)
		{
			super(request);
			transaction = pTransaction;
		}
	}

}