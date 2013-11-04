package com.arm.herolot.modules.launch.screens
{
	import com.adobe.nativeExtensions.AppPurchase;
	import com.adobe.nativeExtensions.AppPurchaseEvent;
	import com.adobe.nativeExtensions.Product;
	import com.adobe.nativeExtensions.Transaction;
	import com.qzone.qfa.debug.Debugger;
	
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.text.TextField;
	
	import starling.events.Event;

	public class ShopScreen extends BaseScreen
	{
		public function ShopScreen()
		{
			super();
		}

		private var count:int = 0;
		private function triggerBtnStart(e:starling.events.Event):void
		{
			//			dispatchEventWith(Event.COMPLETE);
			if (count == 0)
			{
				/**恢复非消耗商品的状态**/
				Debugger.log('恢复非消耗商品的状态');
				AppPurchase.manager.restoreTransactions();
			}
			else if (count == 1)
			{
				/**获取商品**/
				Debugger.log('请求商品信息');
				AppPurchase.manager.getProducts(['test_money_1000', 'test_scene']);
			}
			else if (count == 2)
			{
				Debugger.log('开始购买：test_money_1000');
				AppPurchase.manager.startPayment('test_money_1000', 1);
			}
			count++;
			if (count == 3)
				count = 0;
		}

		private function initAppPurchaseExtension():void
		{
			Debugger.log('In App Purchase:' + AppPurchase.manager.muted);
			//			AppPurchase.manager.transactions; //交易数组
			//			AppPurchase.manager.finishTransaction(); //结束交易
			//			AppPurchase.manager.getProducts(); //请求商品信息
			//			AppPurchase.manager.onStatus(); //？？？
			//			AppPurchase.manager.restoreTransactions(); //恢复商品信息
			//			AppPurchase.manager.startPayment();   //开始付款
			AppPurchase.manager.addEventListener(AppPurchaseEvent.UPDATED_TRANSACTIONS, onUpdatedTransactions);
			AppPurchase.manager.addEventListener(AppPurchaseEvent.RESTORE_FAILED, onRestoreFailed);
			AppPurchase.manager.addEventListener(AppPurchaseEvent.RESTORE_COMPLETE, onRestoreComplete);
			AppPurchase.manager.addEventListener(AppPurchaseEvent.REMOVED_TRANSACTIONS, onRemovedTransactions);
			AppPurchase.manager.addEventListener(AppPurchaseEvent.PRODUCTS_RECEIVED, onProducts);
		}

		private function onUpdatedTransactions(pEvent:AppPurchaseEvent):void
		{
			var output:String = "----------------------------UPDATE TRANSACTION-----------------------------------\n\n";
			//info = "";

			for each (var t:Transaction in pEvent.transactions)
			{
				if (t.state == Transaction.TRANSACTION_STATE_FAILED) //交易失败
				{
					output += "Failed<font color='#ff0000'>";
				}
				else if (t.state == Transaction.TRANSACTION_STATE_PUCHASED) //付款成功
				{
					output += "Purchased<font color='#00ff00'>";
				}
				else if (t.state == Transaction.TRANSACTION_STATE_PUCHASING) //正在付款
				{
					output += "Purchasing<font color='#ffff00'>";
				}
				else if (t.state == Transaction.TRANSACTION_STATE_RESTORED) //非消耗商品的状态被恢复
				{
					output += "Restored<font color='#0000ff'>";
				}
				output += "  -----------------------------\nAPP - Printing Transaction" + "\n";
				output += "Date: " + t.date + "\n";
				output += "Error: " + t.error + "\n";
				if (t.state == Transaction.TRANSACTION_STATE_RESTORED)
				{
					output += "Original Product Id: " + t.originalTransaction.productIdentifier + "\n"; //被恢复的商品id
				}
				else
				{
					output += "Product Id: " + t.productIdentifier + "\n"; //购买的商品id
				}
				output += "Product Quantity: " + t.productQuantity + "\n"; // 商品数量
				output += "Receipt: " + t.receipt + "\n"; //商品收据
				/**
				 * public static const TRANSACTION_STATE_PUCHASING:int = 0;
				 * public static const TRANSACTION_STATE_PUCHASED:int = 1;
				 * public static const TRANSACTION_STATE_FAILED:int = 2;
				 * public static const TRANSACTION_STATE_RESTORED:int = 3;
				 * */
				output += "State: " + t.state + "\n"; //状态
				output += "transaction Identifier: " + t.transactionIdentifier + "\n"; //交易编号
				if (t.state == Transaction.TRANSACTION_STATE_RESTORED)
				{
					output += "Original transaction Identifier: " + t.originalTransaction.transactionIdentifier + "\n"; //被恢复的商品编号
				}
				output += "</font>";

				newMsg(output);
				output = "";

				//这段代码理论上是由后台来校验的。。。。
				if (t.state == Transaction.TRANSACTION_STATE_PUCHASED)
				{
					var req:URLRequest = new URLRequest("https://sandbox.itunes.apple.com/verifyReceipt");
					req.method = URLRequestMethod.POST;
					req.data = "{\"receipt-data\" : \"" + t.receipt + "\"}";
					var verifier:ReceiptVerifier = new ReceiptVerifier(req, t);
					//var ldr:URLLoader = new URLLoader(req);
					//ldr.load(req);
					verifier.addEventListener(flash.events.Event.COMPLETE, function(e:flash.events.Event):void
					{
						var target:ReceiptVerifier = e.target as ReceiptVerifier;
						newMsg("<font color='#cccccc'>LOAD RECEIPT COMPLETE for " + target.transaction.transactionIdentifier + "\n</font>");
						provideContent(target.transaction.productIdentifier);
						AppPurchase.manager.finishTransaction(target.transaction.transactionIdentifier);
					});

					trace("Called Finish on " + t.transactionIdentifier);
				}
				else if (t.state == Transaction.TRANSACTION_STATE_RESTORED)
				{
					if (t.originalTransaction.state == Transaction.TRANSACTION_STATE_FAILED || t.originalTransaction.state == Transaction.TRANSACTION_STATE_PUCHASED)
					{
						newMsg("<font color='#666666'>RESTORED TRANSACTION FINISH " + t.transactionIdentifier + "\n</font>");
						//AppPurchase.manager.finishTransaction(t.originalTransaction.transactionIdentifier);
						provideContent(t.productIdentifier);
						AppPurchase.manager.finishTransaction(t.transactionIdentifier);
					}
				}
				else if (t.state == Transaction.TRANSACTION_STATE_FAILED)
				{
					newMsg("<font color='#666666'>FAILED TRANSACTION FINISH " + t.transactionIdentifier + "\n</font>");
					AppPurchase.manager.finishTransaction(t.transactionIdentifier);
				}

			}
		}

		private function onRestoreFailed(pEvent:AppPurchaseEvent):void
		{
			//			newMsg("<font color='#666666'>RESTORE TRANSACTION FAILED\n</font>");
			for each (var t:Transaction in pEvent.transactions)
			{
				newMsg("<font color='#ff0000'>Restored Transaction Failed " + t.transactionIdentifier + "\n</font>");
			}
		}

		private function onRestoreComplete(pEvent:AppPurchaseEvent):void
		{
			//			newMsg("<font color='#ffffff'>RESTORE TRANSACTION COMPLETED\n</font>");
			for each (var t:Transaction in pEvent.transactions)
			{
				newMsg("<font color='#0000ff'>Restored Completed " + t.transactionIdentifier + "\n</font>");
			}
		}

		private function onRemovedTransactions(pEvent:AppPurchaseEvent):void
		{
			//			newMsg("<font color='#666666'>TRANSACTION REMOVED\n</font>");
			for each (var t:Transaction in pEvent.transactions)
			{
				newMsg("<font color='#0000ff'>Restored Removed " + t.transactionIdentifier + "\n</font>");
			}
		}

		private function newMsg(pNewMsg:String):void
		{
			var natvie:flash.text.TextField = new flash.text.TextField();
			natvie.htmlText = pNewMsg;
			Debugger.log(natvie.text);
		}

		/**
		 * 拿到商品信息。
		 * @param pEvent
		 */
		private function onProducts(pEvent:AppPurchaseEvent):void
		{
			var pProducts:Array = pEvent.products;
			for each (var p:Product in pProducts)
			{
				var id:String = p.identifier;
				Debugger.log('商品信息:', p.title, p.identifier, p.description, p.price, p.priceLocale);
			}
		}

		private function provideContent(pProductId:String):void
		{
		}
	}
}

import com.adobe.nativeExtensions.Transaction;

import flash.net.URLLoader;
import flash.net.URLRequest;

class ReceiptVerifier extends URLLoader
{
	public var transaction:Transaction;

	public function ReceiptVerifier(request:URLRequest = null, pTransaction:Transaction = null)
	{
		super(request);
		transaction = pTransaction;
	}
}
