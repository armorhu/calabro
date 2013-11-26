package com.arm.herolot.modules.battle.model.entities
{
	import com.arm.herolot.model.config.AppConfig;
	import com.arm.herolot.model.config.mapEntities.MapEntitiesConfig;
	import com.arm.herolot.modules.battle.battle.BattleEntity;
	import com.arm.herolot.modules.battle.map.MapMath;
	import com.arm.herolot.modules.battle.model.MapGridModel;

	public class MonsterModel extends MapGridModel
	{
		public var battleEntity:BattleEntity;

		public function MonsterModel()
		{
		}


		override protected function initalize():void
		{
			super.initalize();
			var config:MapEntitiesConfig = AppConfig.mapEntitiesConfigModel.getMapEntitiesConfigByID(entityId);
			battleEntity = new BattleEntity();
			//暴击率
			battleEntity.crit_proxy.base = config.Crit / 100;
			//闪避率
			battleEntity.dodge_proxy.base = config.Dudoge / 100;
			//速度
			battleEntity.speed_proxy.base = config.Speed;
			//护甲
			battleEntity.armor_proxy.base = 0;
			//攻击
			battleEntity.ack_proxy.base = MapMath.getAckByFloor(floor);
			//血
			battleEntity.hp_proxy.base = MapMath.getHpByFloor(floor);
		}
	}
}
