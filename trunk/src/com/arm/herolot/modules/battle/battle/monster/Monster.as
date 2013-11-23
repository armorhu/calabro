package com.arm.herolot.modules.battle.battle.monster
{
	import com.arm.herolot.model.config.AppConfig;
	import com.arm.herolot.model.config.mapEntities.MapEntitiesConfig;
	import com.arm.herolot.modules.battle.battle.BattleEntity;

	import flash.geom.Point;

	public class Monster extends BattleEntity
	{
		public var config:MapEntitiesConfig;

		public function Monster(id:int)
		{
			super();
			config = AppConfig.mapEntitiesConfigModel.getMapEntitiesConfigByID(id);
		}
	}
}
