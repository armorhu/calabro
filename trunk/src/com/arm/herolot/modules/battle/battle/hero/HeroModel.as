package com.arm.herolot.modules.battle.battle.hero
{
	import com.arm.herolot.model.config.AppConfig;
	import com.arm.herolot.model.config.heros.HerosConfig;
	import com.arm.herolot.model.data.database.HeroData;
	import com.arm.herolot.model.data.database.SkillData;
	import com.arm.herolot.modules.battle.battle.BattleEntity;
	import com.arm.herolot.modules.battle.battle.skill.SkillModel;

	/**
	 * 英雄
	 * @author hufan
	 */
	public class HeroModel extends BattleEntity
	{
		public var config:HerosConfig;
		public var data:HeroData;

		/**各个技能的等级。**/
		public var skills:Vector.<SkillModel>;

		public function HeroModel(data:HeroData)
		{
			super();
			this.data = data;
			config = AppConfig.herosConfigModel.getHerosConfigByID(data.id);
			initialize();
		}


		private function initialize():void
		{

			this.ack_proxy.orignal = config.DamagePoint;
			this.speed_proxy.orignal = config.Speed;
			this.hp_proxy.orignal = config.HitPoint;
			this.armor_proxy.orignal = config.Armor;
			this.crit_proxy.orignal = config.Crit;
			this.dodge_proxy.orignal = config.Doduge;


			skills = new Vector.<SkillModel>();
			skills.length = config.SkillIds.length;
			skills.fixed = true;
			for (var i:int = 0; i < skills.length; i++)
			{
				skills[i] = new SkillModel(getSkillDataByID(config.SkillIds[i]));
				skills[i].onwer = this;
			}
		}


		private function getSkillDataByID(skillID:int):SkillData
		{
			const len:int = data.skills.length;
			for (var i:int = 0; i < len; i++)
			{
				if (data.skills[i].id == skillID)
					return data.skills[i];
			}

			var skillData:SkillData = new SkillData();
			skillData.id = skillID;
			skillData.level = 1;
			data.skills.push(skillData);
			return skillData
		}
	}
}
