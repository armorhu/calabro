package com.arm.herolot.model.config
{
	import com.arm.herolot.HerolotApplication;
	import com.arm.herolot.works.HerolotWorker;
	import com.qzone.qfa.debug.Debugger;
	import com.qzone.qfa.debug.LogType;
	import com.qzone.qfa.managers.resource.Resource;
	
	import flash.utils.getTimer;

	//==========================不要动我!!!!!!!========================//
	/**自动生成的import代码--start**/
	import com.arm.herolot.model.config.skills.SkillsConfigModel;
	import com.arm.herolot.model.config.buffers.BuffersConfigModel;
	import com.arm.herolot.model.config.heros.HerosConfigModel;
	import com.arm.herolot.model.config.entities.EntitiesConfigModel;
	/**自动生成的import代码--end**/
	//==========================不要动我!!!!!!!========================//
	/**
	 * 程序配置模型，在此可以获得所有与配置相关的信息
	 * @author wesleysong
	 *
	 */
	public class AppConfigModel extends HerolotWorker
	{
		//==========================不要动我!!!!!!!========================//
		/**自动生成的属性代码--start**/
		public var skillsConfigModel:SkillsConfigModel;
		public var buffersConfigModel:BuffersConfigModel;
		public var herosConfigModel:HerosConfigModel;
		public var entitiesConfigModel:EntitiesConfigModel;
		/**自动生成的属性代码--end**/
		//==========================不要动我!!!!!!!========================//
		public var flashvars:Object;

		private var _urls:Vector.<String>;
		private var _iConfigs:Vector.<IConfigModel>;

		public function AppConfigModel(app:HerolotApplication)
		{
			super(app);
			init()
		}

		public function init():void
		{
			_urls = new Vector.<String>();
			_iConfigs = new Vector.<IConfigModel>();
			
			
			//==========================不要动我!!!!!!!========================//
			/**自动生产的logic代码--start**/
			skillsConfigModel = new SkillsConfigModel;
			bindle("config/skills.csv",skillsConfigModel);
			buffersConfigModel = new BuffersConfigModel;
			bindle("config/buffers.csv",buffersConfigModel);
			herosConfigModel = new HerosConfigModel;
			bindle("config/heros.csv",herosConfigModel);
			entitiesConfigModel = new EntitiesConfigModel;
			bindle("config/entities.csv",entitiesConfigModel);
		/**自动生产的logic代码--end**/
			//==========================不要动我!!!!!!!========================//
		}

		private function bindle(url:String, iConfig:IConfigModel):void
		{
			_urls.push(url);
			_iConfigs.push(iConfig);
		}

		override public function start():void
		{
//			const len:int = _urls.length;
//			for (var i:int = 0; i < len; i++)
//				app.loadResource(_urls[i], loadConfigComplete);
			
			app.loadResource(_urls[0],loadConfigComplete);
		}

		private function loadConfigComplete(res:Resource):void
		{
			trace(res.url);
			var idx:int = _urls.indexOf(res.url);
			if (idx == -1)
				return;

			var time:int = getTimer();
			_iConfigs[idx].init(res.data);
			Debugger.log('init:'+res.url,'cost:'+(getTimer()-time)+'ms',LogType.ASSERT);
			_iConfigs.splice(idx, 1);
			_urls.splice(idx, 1);
			trace(_urls.length);
			if (_urls.length == 0)
			{
				workComplete();
			}else{
				app.loadResource(_urls[0],loadConfigComplete);
			}
		}
	}
}
