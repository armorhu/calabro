package com.arm.herolot.modules.battle
{
	import com.arm.herolot.Consts;
	import com.arm.herolot.modules.battle.map.MapData;
	import com.arm.herolot.modules.battle.model.MapGridModel;
	import com.arm.herolot.modules.battle.view.heroui.HeroUIView;
	import com.arm.herolot.modules.battle.view.map.MapView;
	import com.arm.herolot.modules.battle.view.texture.BattleTexture;
	
	import starling.display.Sprite;

	public class BattleView extends Sprite
	{
		public static const TILE_TOUCHED:String = 'tile_touched';

		private var _map:MapView;
		private var _heroUI:HeroUIView; //英雄信息&物品栏。
		private var _texture:BattleTexture;

		public function BattleView()
		{
			super();
		}

		public function initaliaze(texture:BattleTexture):void
		{
			this._texture = texture;
			buildLayers(); //初始化层级
		}

		private function buildLayers():void
		{
			_map = new MapView(_texture.mainTexture);
			addChild(_map);
			
			_heroUI = new HeroUIView(_texture.mainTexture); //英雄信息面板&物品栏视图
			_heroUI.y = Consts.TILE_SIZE * Consts.MAP_ROWS;
			addChild(_heroUI);
		}
		
		public function setMapdata(grids:Vector.<MapGridModel>):void
		{
			_map.setMapData(grids);
		}
	}
}
