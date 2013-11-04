package com.arm.herolot.modules.battle.battle.skill
{
	import com.arm.herolot.model.config.AppConfig;
	import com.arm.herolot.model.config.skills.SkillsConfig;
	import com.arm.herolot.model.data.database.SkillData;
	import com.arm.herolot.modules.battle.battle.BattleEntity;
	import com.arm.herolot.modules.battle.battle.buff.Buffer;
	import com.arm.herolot.modules.battle.battle.buff.IBuffer;

	/**
	 * 技能
	 * @author hufan
	 */
	public class SkillModel
	{
		public var configs:Vector.<SkillsConfig>;
		public var data:SkillData;
		
		private var _owner:BattleEntity;
		/**由本技能添加给宿主的buffers**/
		private var _buffers:Vector.<IBuffer>;

		public function SkillModel($data:SkillData)
		{
			super();
			this.data = $data;

			configs = AppConfig.skillsConfigModel.getSkillsConfigListByID(data.id);
			_buffers = new Vector.<IBuffer>();
		}


		/**
		 * 升级技能。
		 */
		public function upgrade():void
		{
		}
		
		public function get level():int
		{
			if(data)
				return data.level;
			else
				return 0;
		}

		/**
		 * 更新本技能给宿主施加的被动buffer。
		 */
		protected function updatePassiveBufferToOnwer():void
		{
			/**清除该技能之前添加在宿主身上的buff。**/
			for (var i:int = 0; i < _buffers.length; i++)
				if (_buffers[i].owner == _owner)
					_owner.removeBuffer(_buffers[i]);
			_buffers = new Vector.<IBuffer>();

			//添加配置中的buffer。
			var levelConfig:SkillsConfig = configs[level];
			var buffer:IBuffer = Buffer.createBuffer(levelConfig.BufferName,levelConfig.BufferData);
			_buffers.push(buffer);
			_owner.addBuffer(buffer);
		}

		/**
		 * 该技能的宿主。
		 */
		public function get onwer():BattleEntity
		{
			return _owner;
		}

		public function set onwer(target:BattleEntity):void
		{
			if (target == onwer)
				return;
			_owner = target;
			updatePassiveBufferToOnwer();
		}
	}
}
