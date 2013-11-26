package com.arm.herolot.modules.battle
{
	import com.arm.herolot.modules.battle.battle.hero.HeroModel;
	import com.arm.herolot.modules.battle.battle.round.BattleRound;
	import com.arm.herolot.modules.battle.battle.round.BattleRoundCore;
	import com.arm.herolot.modules.battle.model.battleui.BattleuiModel;
	import com.arm.herolot.modules.battle.model.map.MapDataModel;
	import com.arm.herolot.modules.battle.model.map.entities.MonsterModel;

	import starling.core.Starling;
	import starling.events.Event;
	import starling.events.EventDispatcher;

	public class BattleModel extends EventDispatcher
	{
		/**
		 *更改层级
		 */
		public static const CHANGE_FLOOR:String = 'change_floor';

		/**
		 *英雄攻击.(一个回合)
		 */
		public static const HERO_ATTACK:String = 'hero_attack';

		/**
		 *怪物攻击.(英雄无法反击)
		 */
		public static const MONSTER_ATTACK:String = 'monster_attack';

		/**
		 *战斗结束
		 */
		public static const BATTLE_RESULT:String = 'battle_result';

		public var mapDataModel:MapDataModel;
		public var battleuiModel:BattleuiModel;

		public var floor:int;

		public function BattleModel()
		{
		}

		public function start(hero:HeroModel):void
		{
			addEventListener(HERO_ATTACK, modelEventHandler);
			addEventListener(MONSTER_ATTACK, modelEventHandler);
			mapDataModel = new MapDataModel(this);
			Starling.juggler.add(mapDataModel);

			battleuiModel = new BattleuiModel(this);
			battleuiModel.initialize(hero);
			floor = 0;
		}

		public function nextFloor():void
		{
			mapDataModel.createFloor(++floor);
			dispatchEventWith(CHANGE_FLOOR, false, floor);
		}

		private function modelEventHandler(evt:Event):void
		{
			if (evt.type == HERO_ATTACK)
			{
				var monster:MonsterModel = evt.data as MonsterModel;
				heroAttack(monster);
			}
		}

		public function heroAttack(monster:MonsterModel):void
		{
			//比速度
			var heroSpeed:Number = battleuiModel.hero.speed;
			var monsterSpeed:Number = monster.battleEntity.speed;
			if (Math.random() < heroSpeed / (heroSpeed + monsterSpeed))
			{
				//英雄先出手。
				progressHeroAttack(monster)
				progressMonsterAttack(monster)
			}
			else
			{
				//怪物先出手。
				progressMonsterAttack(monster);
				progressHeroAttack(monster);
			}
		}


		private function progressHeroAttack(monster:MonsterModel):void
		{
			if (battleuiModel.hero.hp <= 0 || monster.battleEntity.hp <= 0)
				return;
			var result:BattleRound = BattleRoundCore.round(battleuiModel.hero, monster.battleEntity);
			battleuiModel.modelChange = true;
			monster.modelChange = true;
			dispatchEventWith(BATTLE_RESULT, false, {'d': monster, 'a': battleuiModel.hero, 'result': result});
		}

		private function progressMonsterAttack(monster:MonsterModel):void
		{
			if (battleuiModel.hero.hp <= 0 || monster.battleEntity.hp <= 0)
				return;
			var result:BattleRound = BattleRoundCore.round(monster.battleEntity, battleuiModel.hero);
			battleuiModel.modelChange = true;
			monster.modelChange = true;
			dispatchEventWith(BATTLE_RESULT, false, {'a': monster, 'd': battleuiModel.hero, 'result': result});
		}

	}
}
