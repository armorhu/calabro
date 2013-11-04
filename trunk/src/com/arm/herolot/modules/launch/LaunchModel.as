package com.arm.herolot.modules.launch
{
	import starling.events.EventDispatcher;

	public class LaunchModel extends EventDispatcher
	{
		public static const PLAYER_DATA:String = 'player_data';
		public static const HERO_DATA:String = 'hero_data';

//		internal static const BEGIN_LOAD_DATA:String = 'begin_load_data';
//		internal static const COMLETE_LOAD_DATA:String = 'complete_load_data';
//		internal static const FAILED_LOAD_DATA:String = 'failed_load_data';
//
//		private var _controller:LaunchController;
//		private var _hero:Vector.<Hero>;
//
//		public function LaunchModel(controller:LaunchController)
//		{
//			super();
//			_controller = controller;
//		}
//
//		public function loadData(type:String):void
//		{
//			dispatchEventWith(BEGIN_LOAD_DATA);
//			var data:Object;
//			/**目前是单机版，玩家数据暂时放在so里面。
//			 * 但是未来拓展成网游的话，这里就会是异步操作。。。
//			 * **/
//			if (type == PLAYER_DATA)
//			{
//				dispatchEventWith(COMLETE_LOAD_DATA, false, {type: PLAYER_DATA, data: player});
////				_controller.module.app.loadPlayerData(function getPlayerData(player:Player):void
////				{
////					dispatchEventWith(COMLETE_LOAD_DATA, false, {type: PLAYER_DATA, data: player});
////				});
//				return;
//			}
//			else if (type == HERO_DATA)
//			{
//				if (_hero == null)
//				{
//					_hero = new Vector.<Hero>();
//					_controller.module.app.loadPlayerData(function getPlayerData(player:Player):void
//					{
//						for (var id:String in Hero.CONFIG)
//						{
//							_hero.push(new Hero(int(id), player.heros[id]));
//						}
//						_hero.sort(function compare(a:Hero, b:Hero):Number
//						{
//							return a.id - b.id;
//						});
//						dispatchEventWith(COMLETE_LOAD_DATA, false, {type: HERO_DATA, data: _hero});
//					});
//				}
//				else
//				{
//					dispatchEventWith(COMLETE_LOAD_DATA, false, {type: HERO_DATA, data: _hero});
//				}
//			}
//		}
//
//		/**
//		 * 升级技能
//		 * @param heroId 第几个英雄
//		 * @param skillId 第几个技能
//		 */
//		public function upgradeSkill(heroId:int, skillId:int):void
//		{
//			var hero:Hero = _hero[heroId];
//			var skill:Skill = hero.skills[skillId];
//			
//			_controller.module.app.loadPlayerData(function getPlayerData(player:Player):void
//			{
//				var left:int = player.money - skill.getCostForUpgrade();
//				if(left >= 0)
//				{
//					player.money = left;
//					skill.upgrade();
//					dispatchEventWith(COMLETE_LOAD_DATA, false, {type: HERO_DATA, data: _hero});
//				}
//			});
//		}
//
//		public function get heros():Vector.<Hero>
//		{
//			return _hero;
//		}
	}
}
