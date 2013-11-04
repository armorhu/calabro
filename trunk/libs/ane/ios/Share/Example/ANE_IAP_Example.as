package
{
	import com.adobe.nativeExtensions.*;
	import com.jamesli.ghostbride.BlueButton;
	import com.jamesli.ghostbride.InfoPanel;
	import com.jamesli.ghostbride.Preloader;
	import com.jamesli.ghostbride.ProductsList;
	import com.jamesli.ghostbride.ReceiptVerifier;
	
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.text.TextField;
	
	public class ANE_IAP_Example extends Sprite
	{
		private var pdList:ProductsList;
		private var rfrshBtn:BlueButton;
		private var preloader:Preloader;
		private var panel:InfoPanel;
		private var bubble:SimpleButton;
		private var info:String = "";
		
		public function ANE_IAP_Example()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(pEvent:Event):void{
			initApplication();
			refreshProducts();
			restoreTransactions();
		}
		private function initApplication():void{
			initProductsList();
			initRefreshButton();
			initInfoPanel();
			initAppPurchaseExtension();
		}
		
		private function initProductsList():void{
			pdList = getChildByName("productsList") as ProductsList;
			if(pdList){
				pdList.visible = false;
			}
		}
		private function initRefreshButton():void{
			rfrshBtn = getChildByName("refreshButton") as BlueButton;
			if(rfrshBtn){
				rfrshBtn.addEventListener(MouseEvent.CLICK,onRefreshButtonClick);
			}
		}
		private function initInfoPanel():void{
			panel = getChildByName("infoPanel") as InfoPanel;
			if(panel){
				panel.init();
			}
			
			bubble = getChildByName("bubbleButton") as SimpleButton;
			//bubble.visible = false;
			bubble.alpha = .2;
			bubble.addEventListener(MouseEvent.CLICK,bubbleClickHandler);
		}
		private function bubbleClickHandler(pEvent:MouseEvent):void{
			//bubble.visible = false;
			bubble.alpha = .2;
			panel.open();
		}
		
		private function newMsg(pNewMsg:String):void{
			info += pNewMsg +"\n";
			if(panel.visible){
				bubble.alpha = .2;
			}else{
				bubble.alpha = 1;
			}
			panel.update(info);
		}
		
		private function onRefreshButtonClick(pEvent:MouseEvent):void{
			refreshProducts();
		}
		
		private function initAppPurchaseExtension():void{
			AppPurchase.manager.addEventListener(AppPurchaseEvent.UPDATED_TRANSACTIONS, onUpdatedTransactions);
			AppPurchase.manager.addEventListener(AppPurchaseEvent.RESTORE_FAILED, onRestoreFailed);
			AppPurchase.manager.addEventListener(AppPurchaseEvent.RESTORE_COMPLETE, onRestoreComplete);
			AppPurchase.manager.addEventListener(AppPurchaseEvent.REMOVED_TRANSACTIONS, onRemovedTransactions);
			AppPurchase.manager.addEventListener(AppPurchaseEvent.PRODUCTS_RECEIVED,onProducts);
		}
		
		private function createPreloader(pMsg:String=""):void{
			removePreloader();
			preloader = new Preloader();
			preloader.x = stage.stageWidth/2;
			preloader.y = stage.stageHeight/2;
			addChild(preloader);
			(preloader.getChildByName("msgField") as TextField).text = pMsg;
		}
		private function removePreloader():void{
			if(preloader){
				removeChild(preloader);
				preloader = null;
			}
		}
		
		private function restoreTransactions():void{
			AppPurchase.manager.restoreTransactions();
		}
		private function refreshProducts():void{
			createPreloader("Getting Products...");
			rfrshBtn.disable();
			pdList.hide();
			AppPurchase.manager.getProducts(["bottle","key","plane","diary"]);
		}

		private function onProducts(pEvent:AppPurchaseEvent):void{
			removePreloader();
			rfrshBtn.enable();
			pdList.show(pEvent.products);
		}
		
		private function onUpdatedTransactions(pEvent:AppPurchaseEvent):void{
			var output:String = "----------------------------UPDATE TRANSACTION-----------------------------------\n\n";
			//info = "";
			
			for each(var t:Transaction in pEvent.transactions){
				if(t.state == Transaction.TRANSACTION_STATE_FAILED){
					output+="Failed<font color='#ff0000'>";
				}else if(t.state == Transaction.TRANSACTION_STATE_PUCHASED){
					output +="Purchased<font color='#00ff00'>";
				}else if(t.state == Transaction.TRANSACTION_STATE_PUCHASING){
					output +="Purchasing<font color='#ffff00'>";
				}else if(t.state == Transaction.TRANSACTION_STATE_RESTORED){
					output +="Restored<font color='#0000ff'>";
				}
				output += "  -----------------------------\nAPP - Printing Transaction" +"\n";
				output += "Date: " + t.date +"\n";
				output += "Error: " + t.error+"\n"; 
				if(t.state == Transaction.TRANSACTION_STATE_RESTORED){
					output += "Original Product Id: " + t.originalTransaction.productIdentifier+"\n";
				}else{
					output += "Product Id: " + t.productIdentifier+"\n";
				}
				//output += "Product Quantity: " + t.productQuantity+"\n";
				//output += "Receipt: " + t.receipt+"\n";
				output += "State: " + t.state+"\n";
				output += "transaction Identifier: " + t.transactionIdentifier+"\n";
				if(t.state == Transaction.TRANSACTION_STATE_RESTORED){
					output += "Original transaction Identifier: " + t.originalTransaction.transactionIdentifier+"\n";
				}
				output+="</font>";
				
				newMsg(output);
				output = "";
				
				if(t.state == Transaction.TRANSACTION_STATE_PUCHASED){
					var req:URLRequest = new URLRequest("https://sandbox.itunes.apple.com/verifyReceipt");
					req.method = URLRequestMethod.POST;
					req.data = "{\"receipt-data\" : \""+ t.receipt +"\"}";
					var verifier:ReceiptVerifier = new ReceiptVerifier(req,t);
					//var ldr:URLLoader = new URLLoader(req);
					//ldr.load(req);
					verifier.addEventListener(Event.COMPLETE,function(e:Event):void{
						var target:ReceiptVerifier = e.target as ReceiptVerifier;
						newMsg("<font color='#cccccc'>LOAD RECEIPT COMPLETE for " + target.transaction.transactionIdentifier+"\n</font>");
						provideContent(target.transaction.productIdentifier);
						AppPurchase.manager.finishTransaction(target.transaction.transactionIdentifier); 
					});
					
					//trace("Called Finish on " + t.transactionIdentifier); 
				}else if(t.state == Transaction.TRANSACTION_STATE_RESTORED){
					if(t.originalTransaction.state == Transaction.TRANSACTION_STATE_FAILED 
						|| t.originalTransaction.state == Transaction.TRANSACTION_STATE_PUCHASED){
						newMsg("<font color='#666666'>RESTORED TRANSACTION FINISH " + t.transactionIdentifier+"\n</font>");
						//AppPurchase.manager.finishTransaction(t.originalTransaction.transactionIdentifier);
						provideContent(t.productIdentifier);
						AppPurchase.manager.finishTransaction(t.transactionIdentifier);
					}
				}else if(t.state == Transaction.TRANSACTION_STATE_FAILED){
					newMsg("<font color='#666666'>FAILED TRANSACTION FINISH " + t.transactionIdentifier+"\n</font>");
					AppPurchase.manager.finishTransaction(t.transactionIdentifier);
				}
				
			}
		}
		private function onRestoreFailed(pEvent:AppPurchaseEvent):void{
			newMsg("<font color='#666666'>RESTORE TRANSACTION FAILED\n</font>");
			/*for each(var t:Transaction in pEvent.transactions){
				newMsg("<font color='#ff0000'>Restored Transaction Failed "+t.transactionIdentifier+"\n</font>");
			}*/
		}
		private function onRestoreComplete(pEvent:AppPurchaseEvent):void{
			newMsg("<font color='#ffffff'>RESTORE TRANSACTION COMPLETED\n</font>");
			/*for each(var t:Transaction in pEvent.transactions){
				newMsg("<font color='#0000ff'>Restored Completed "+t.transactionIdentifier+"\n</font>");
			}*/
		}
		private function onRemovedTransactions(pEvent:AppPurchaseEvent):void{
			newMsg("<font color='#666666'>TRANSACTION REMOVED\n</font>");
			/*for each(var t:Transaction in pEvent.transactions){
			}*/
			
		}
		
		
		private function provideContent(pProductId:String):void{
			
		}
			
	}
}