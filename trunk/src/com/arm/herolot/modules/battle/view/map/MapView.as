package com.arm.herolot.modules.battle.view.map
{
	import com.arm.herolot.Consts;
	import com.arm.herolot.modules.battle.model.MapGridModel;
	import com.snsapp.mobile.view.interactive.align.setting.VerticalAlign;
	import com.snsapp.starling.texture.implement.BatchTexture;
	
	import flash.geom.Point;
	
	import starling.display.Sprite;


	/**
	 * 地图
	 * @author hufan
	 *
	 */
	public class MapView extends Sprite
	{
		private var _grids:Vector.<MapGridView>;

		private var _texture:BatchTexture;

		private var _alignSetting:VerticalAlign;


		public function MapView(texture:BatchTexture)
		{
			super();
			_texture = texture;
			initialize();
		}

		private function initialize():void
		{
			_grids = new Vector.<MapGridView>();
			_grids.length = Consts.MAP_COLS * Consts.MAP_ROWS;
			_grids.fixed = true;

			var len:int = _grids.length;
			_alignSetting = new VerticalAlign(Consts.MAP_COLS);
			_alignSetting.cellHeight = Consts.TILE_SIZE;
			_alignSetting.cellWidth = Consts.TILE_SIZE;
		}

		public function setMapData(grids:Vector.<MapGridModel>):void
		{
			var len:int = _grids.length;
			var point:Point;
			for (var i:int = 0; i < len; i++)
			{
				if (_grids[i])
				{
					_grids[i].dispose();
					removeChild(_grids[i]);
					_grids[i] = null;
				}

				_grids[i] = MapGridView.createMapGridView(grids[i], _texture);
				addChild(_grids[i]);
				point = _alignSetting.getPostionOf(i);
				_grids[i].x = point.x, _grids[i].y = point.y;
			}
		}
	}
}
