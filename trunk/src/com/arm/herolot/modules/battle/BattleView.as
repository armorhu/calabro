package com.arm.herolot.modules.battle
{
	import com.arm.herolot.Consts;
	import com.arm.herolot.modules.battle.battle.hero.HeroModel;
	import com.arm.herolot.modules.battle.battle.round.BattleRound;
	import com.arm.herolot.modules.battle.model.battleui.BattleuiModel;
	import com.arm.herolot.modules.battle.model.map.MapGridModel;
	import com.arm.herolot.modules.battle.texture.BattleTexture;
	import com.arm.herolot.modules.battle.view.DamagePlayer;
	import com.arm.herolot.modules.battle.view.battleui.BattleuiView;
	import com.arm.herolot.modules.battle.view.map.MapGridView;
	import com.arm.herolot.modules.battle.view.map.MapView;

	import flash.geom.Point;

	import starling.display.DisplayObject;
	import starling.display.Sprite;

	public class BattleView extends Sprite
	{
		public static const TILE_TOUCHED:String = 'tile_touched';

		private var _map:MapView;
		private var _battleui:BattleuiView; //英雄信息&物品栏。
		private var _texture:BattleTexture;
		private var _effectLayer:Sprite;

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

			_battleui = new BattleuiView(_texture.mainTexture); //英雄信息面板&物品栏视图
			_battleui.y = Consts.TILE_SIZE * Consts.MAP_ROWS;
			addChild(_battleui);

			_effectLayer = new Sprite();
			addChild(_effectLayer);
		}

		public function setMapdata(grids:Vector.<MapGridModel>):void
		{
			_map.setMapData(grids);
		}

		public function setBattleuiModel(battleuiModel:BattleuiModel):void
		{
			_battleui.setBattleuiModel(battleuiModel);
		}

		public function setFloor(floor:int):void
		{
			_battleui.setLevel(floor);
		}

		public function displayBattleResult(data:Object):void
		{
			var attacker:Object = data.a;
			var defenser:Object = data.d;
			var result:BattleRound = data.result as BattleRound;
			var attackerView:DisplayObject = getViewOf(attacker);
			var defenserView:DisplayObject = getViewOf(defenser);

			if (result.ar.damage > 0)
			{
				playDamage(result.ar.damage, result.ar.crit, attackerView);
			}

			if (result.dr.damage > 0)
			{
				playDamage(result.dr.damage, result.dr.crit, defenserView);
			}
		}

		private function playDamage(damage:int, crit:Boolean, targetView:DisplayObject):void
		{
			var point:Point = targetView.localToGlobal(new Point(targetView.width / 2, targetView.height / 2));
			DamagePlayer.play(damage, crit, point, _effectLayer);
		}


		private function getViewOf(data:Object):DisplayObject
		{
			if (data is MapGridModel)
				return _map.getEntityViewByModel(data as MapGridModel);
			else if (data is HeroModel)
				return _battleui.heroView;
			else
				return null;
		}
	}
}
