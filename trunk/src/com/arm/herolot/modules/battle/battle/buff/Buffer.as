package com.arm.herolot.modules.battle.battle.buff
{
	import com.arm.herolot.modules.battle.battle.BattleEntity;
	import com.arm.herolot.modules.battle.battle.buff.implement.AddAttackToDeath;
	import com.arm.herolot.modules.battle.battle.buff.implement.AddAttackWhenSkillDeath;
	import com.arm.herolot.modules.battle.battle.buff.implement.CapblityBuffer;
	import com.arm.herolot.modules.battle.battle.buff.implement.Relife;
	import com.arm.herolot.modules.battle.battle.round.BattleRound;

	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	public class Buffer implements IBuffer
	{
		private var _owner:BattleEntity;
		protected var _params:Object;

		public function Buffer()
		{
		}

		public function before_attack(result:BattleRound):void
		{
		}

		public function after_attack(result:BattleRound):void
		{
		}

		public function before_injured(result:BattleRound):void
		{
		}

		public function after_injured(result:BattleRound):void
		{
		}

		public function get owner():BattleEntity
		{
			return _owner;
		}

		public function set owner(target:BattleEntity):void
		{
			if (target == _owner)
				return;
			if (_owner) //之前已经有主人了。。。执行一下移除方法
				removedFromOwner();
			_owner = target;
			if (_owner) //新的主人，执行添加命令。
				addedToOwner();
		}

		protected function addedToOwner():void
		{
		}

		protected function removedFromOwner():void
		{
		}

		public function setParams(params:Object):void
		{
			_params = params;
		}

		public function reset():void
		{
		}

		/**
		 * 注册具体的buffer实现类。
		 * 使得buffer类被编译进程序域
		 */
		private static function compleMe():void
		{
			var buff1:CapblityBuffer;
			var buff2:Relife;
			var b3:AddAttackToDeath;
			var b4:AddAttackWhenSkillDeath;
		}

		private static var BufferPackageName:String = '';

		public static function createBuffer(bufferType:String, params:Object):IBuffer
		{
			trace('------------------------create buffer', bufferType, params);
			if (BufferPackageName == '')
			{
				BufferPackageName = getQualifiedClassName(Buffer);
				BufferPackageName = BufferPackageName.substr(0, BufferPackageName.indexOf('::'));
				BufferPackageName = BufferPackageName + '.implement.';
			}
			var bClass:Class = getDefinitionByName(BufferPackageName + bufferType) as Class;
			var buffer:IBuffer;
			if (bClass)
				buffer = new bClass() as IBuffer;

			if (buffer == null)
				throw new Error('can not create buffer:' + bufferType);
			buffer.setParams(params);
			return buffer;
		}
	}
}
