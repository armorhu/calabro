package com.jamesli.ghostbride
{
	import com.adobe.nativeExtensions.AppPurchase;
	import com.adobe.nativeExtensions.Product;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class ProductItem extends MovieClip
	{
		private var id:String;
		//icon
		private var ic:MovieClip;
		//title text field
		private var tField:TextField;
		//description text field
		private var dField:TextField;
		//owned text field;
		private var oField:TextField;
		//price text field;
		private var pField:TextField;
		//purchase button
		private var pBtn:BlueButton;
		
		public function ProductItem()
		{
			super();
			ic = getChildByName("icon") as MovieClip;
			tField = getChildByName("titleField") as TextField;
			dField = getChildByName("descriptionField") as TextField;
			oField = getChildByName("ownedField") as TextField;
			pField = getChildByName("priceField") as TextField;
			pBtn = getChildByName("purchaseButton") as BlueButton;
		}
		public function update(pProduct:Product):void{
			id = pProduct.identifier;
			ic.gotoAndStop(id);
			tField.text = pProduct.title;
			dField.text = pProduct.description;
			pField.text = "$"+String(pProduct.price);
			pBtn.addEventListener(MouseEvent.CLICK,onPurchase);	
		}
		private function onPurchase(pEvent:MouseEvent):void{
			//pBtn.disable();
			AppPurchase.manager.startPayment(id,1);
		}
	}
}