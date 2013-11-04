package com.arm.herolot.modules.battle.view.layer
{
	import com.arm.herolot.Consts;
	import com.snsapp.starling.texture.implement.BatchTexture;
	
	import starling.display.DisplayObject;
	import starling.display.Sprite;

	public class BaseLayer extends Sprite
	{
		protected var _layerType:int;
		protected var _batch:BatchTexture;

		private var _children:Vector.<Object>;

		public function BaseLayer(layerType:int, batch:BatchTexture)
		{
			super();
			_batch = batch;
			_layerType = layerType;
			_children = new Vector.<Object>(Consts.MAP_ROWS * Consts.MAP_COLS);
		}

		public function setTileVisibilityAt(row:int, col:int, visible:Boolean, tag:String = '0'):void
		{
			var index:int = row * Consts.MAP_COLS + col;
			if (_children[index] && _children[index][tag] != undefined)
				_children[index][tag].visible = visible;
		}
		
		public function setData(data:*):void
		{
		}

		protected function removeTileAt(row:int, col:int, tag:String = '0'):DisplayObject
		{
			return removeTileAtIndex(row * Consts.MAP_COLS + col, tag);
		}

		private function removeTileAtIndex(index:int, tag:String = '0'):DisplayObject
		{
			var tile:DisplayObject = null;
			if (_children[index] && _children[index][tag])
			{
				tile = DisplayObject(_children[index][tag]);
				removeChild(tile);
				_children[index][tag] = null;
			}
			return tile;
		}

		protected function addTileAt(tile:DisplayObject, row:int, col:int, tag:String = '0'):void
		{
			if (tile)
			{
				var index:int = row * Consts.MAP_COLS + col;
				removeTileAtIndex(index, tag);
				if(_children[index] == null)
					_children[index] = new Object();
				_children[index][tag] = tile;
				addChild(tile);
				tile.x = Consts.TILE_SIZE * col;
				tile.y = Consts.TILE_SIZE * row;
			}
		}

		public function getTileAt(row:int, col:int, tag:String = '0'):DisplayObject
		{
			var ret:*;
			if(_children[row * Consts.MAP_COLS + col] != null 
				&& (ret = _children[row * Consts.MAP_COLS + col][tag]) != undefined)
				return DisplayObject(ret);
			return null;
		}

		public function get layerType():int
		{
			return _layerType;
		}
	}
}
