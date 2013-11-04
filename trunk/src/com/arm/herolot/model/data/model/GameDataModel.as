package com.arm.herolot.model.data.model
{
	import com.arm.herolot.model.config.AppConfig;
	import com.arm.herolot.model.data.database.GameData;
	import com.arm.herolot.model.data.database.HeroData;
	import com.arm.herolot.modules.battle.battle.hero.HeroModel;
	
	import starling.events.EventDispatcher;
	
	public class GameDataModel extends EventDispatcher
	{
		public var data:GameData;
		public var heros:Vector.<HeroModel>;
		
		public function GameDataModel()
		{
			super();
		}
		
		public function loadGameData():void
		{
			data = new GameData();
			data.heros = new Vector.<HeroData>();
			data.maxFloor = 0;
			data.money = 0;
			data.kills = 0;
			initialiaze(data);
		}
		
		/**
		 * 根据游戏数据初始化model 
		 * @param data
		 */		
		private function initialiaze(data:GameData):void
		{
			this.data = data;
			heros = new Vector.<HeroModel>();
			heros.length = AppConfig.herosConfigModel.heros.length;
			heros.fixed = true;
			
			var heroID:int;
			for (var i:int = 0; i < heros.length; i++) 
			{
				heroID = AppConfig.herosConfigModel.heros[i].ID;
				heros[i] = new HeroModel(//
					getHeroDataByID(heroID)
				);
			}
		}
		
		protected function getHeroDataByID(heroID:int):HeroData
		{
			const len:int = data.heros.length;
			for (var i:int = 0; i < len; i++) 
			{
				if(data.heros[i].id == heroID)
					return data.heros[i];
			}
			
			var heroData:HeroData = new HeroData();
			heroData.id = heroID;
			return heroData;
		}
	}
}