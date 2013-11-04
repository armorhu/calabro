package com.arm.herolot.modules.battle.view.layer
{
	import com.arm.herolot.Consts;
	import com.arm.herolot.modules.battle.BattleView;
	import com.arm.herolot.modules.battle.view.render.Tile;
	import com.snsapp.starling.texture.implement.BatchTexture;

	public class TileLayer extends BaseLayer
	{
		public function TileLayer(layerType:int, batch:BatchTexture)
		{
			super(layerType, batch);
			initialize();
		}

		private function initialize():void
		{
		}

		override public function setData(data:*):void
		{
			if(this.numChildren > 0)
				removeChildren(0, this.numChildren - 1, true);
			
			var d:Vector.<int> = data as Vector.<int>;
			var tile:Tile = null;
			const dLen:int = d.length;
			for (var i:int = 0; i < dLen; i++)
			{
				if (_layerType == BattleView.LAYER_TYPE_BLOCK)
					tile = new Tile(Tile.TILE_TYPE_BLOCK, d[i], _batch);
				else if (_layerType == BattleView.LAYER_TYPE_GROUND)
					tile = new Tile(Tile.TILE_TYPE_GROUND, d[i], _batch);

				addTileAt(tile, int(i / Consts.MAP_COLS), int(i % Consts.MAP_COLS));
			}
		}

		public function showDisableMark(row:int, col:int, show:Boolean):void
		{
			Tile(getTileAt(row, col)).showDisableMark(show);
		}

		public function showAbleMark(row:int, col:int, show:Boolean):void
		{
			Tile(getTileAt(row, col)).showAbleMark(show);
		}
		
		public function resetMark(row:int, col:int):void
		{
			Tile(getTileAt(row, col)).reset();
		}
	}
}
