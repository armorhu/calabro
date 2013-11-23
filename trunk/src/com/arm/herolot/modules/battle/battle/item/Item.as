package com.arm.herolot.modules.battle.battle.item
{
	import com.arm.herolot.model.config.AppConfig;
	import com.arm.herolot.model.config.mapEntities.MapEntitiesConfig;

	public class Item
	{
		public var config:MapEntitiesConfig;

		public function Item(id:int)
		{
			config = AppConfig.mapEntitiesConfigModel.getMapEntitiesConfigByID(id);
		}
	}
}
