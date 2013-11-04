package com.jamesli.ghostbride
{
	import com.adobe.nativeExtensions.Product;
	
	import flash.display.MovieClip;
	
	public class ProductsList extends MovieClip
	{
		public function ProductsList()
		{
			super();
		}
		public function hide():void{
			visible= false;
		}
		public function show(pProducts:Array):void{
			visible = true;
			for each(var p:Product in pProducts){
				var id:String = p.identifier;
				var productItem:ProductItem = getChildByName("pdct_"+id) as ProductItem;
				if(productItem){
					productItem.update(p);
				}
			}
		}
	}
	
	
}