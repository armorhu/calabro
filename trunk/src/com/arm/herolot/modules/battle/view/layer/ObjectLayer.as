package com.arm.herolot.modules.battle.view.layer
{
	import com.arm.herolot.Consts;
	import com.arm.herolot.modules.battle.battle.item.Item;
	import com.arm.herolot.modules.battle.battle.monster.Monster;
	import com.arm.herolot.modules.battle.view.render.MonsterRender;
	import com.snsapp.starling.texture.implement.BatchTexture;
	
	import starling.display.Quad;
	import com.arm.herolot.modules.battle.view.render.ItemRender;

	public class ObjectLayer extends BaseLayer
	{
		public static const OBJECT_TAG_MONSTER:String = "monster";
		public static const OBJECT_TAG_ITEM:String = "item";
		
		public function ObjectLayer(layerType:int, batch:BatchTexture)
		{
			super(layerType, batch);
		}

		override public function setData(data:*):void
		{
			if(this.numChildren > 0)
				removeChildren(0, this.numChildren - 1, true);
			
			var ms:Vector.<Monster> = data.monsters as Vector.<Monster>;
			var items:Vector.<Item> = data.items as Vector.<Item>;
			
			var i:int = 0;
			var msRender:MonsterRender;
			var itemRender:ItemRender;
			
			for (var ir:int = 0; ir < Consts.MAP_ROWS; ir++)
			{
				for (var ic:int = 0; ic < Consts.MAP_COLS; ic++)
				{
					if(items[i])
					{
						//trace('add item:', ir, ic, items[id].id, items[id].name);
						itemRender = new ItemRender(items[i]);
						addTileAt(itemRender, ir, ic, OBJECT_TAG_ITEM);
						if(items[i].name == 'key')
							itemRender.visible = false;
					}
					
					if (ms[i])
					{
						//trace('add monster:', ir, ic, ms[id].id, ms[id].name);
						msRender = new MonsterRender(ms[i]);
						addTileAt(msRender, ir, ic, OBJECT_TAG_MONSTER);
					}
					i++;
				}
			}
			
		}
	}
}
