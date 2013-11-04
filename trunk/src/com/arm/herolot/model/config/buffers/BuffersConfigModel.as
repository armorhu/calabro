package com.arm.herolot.model.config.buffers
{
	import com.arm.herolot.model.config.IConfigModel;
	import com.arm.herolot.services.utils.CSVFile;
	
	import flash.utils.Dictionary;

	public class BuffersConfigModel implements IConfigModel
	{
		private var _file:CSVFile;
		
		private var _idCache:Dictionary;
		
		public function BuffersConfigModel()
		{
			_idCache = new Dictionary();
		}

		public function init(data:*):void
		{
			_file = new CSVFile();
			_file.read(data).parse();
			return;
		}
		
		private function generateConfigListOfID(id:int):Boolean
		{
			var startLine:int = _file.getRowIndexByIndexKey(id.toString());
			if(startLine < 0) return false;
			
			var line:int = startLine;
			var configNameIndex:int = _file.keys.indexOf('Name');
			var configName:String = _file.valueTables[line][configNameIndex];
			const keyLen:int = _file.keys.length;
			const lineNum:int = _file.valueTables.length;
			
			var newConfigs:Vector.<BuffersConfig> = new Vector.<BuffersConfig>();
			_idCache[id] = newConfigs;
			
			while(line < lineNum)
			{
				var currentConfigName:String = _file.valueTables[line][configNameIndex];
				
				if (currentConfigName != null && currentConfigName != '' && currentConfigName != configName)
				{
					break;
				}
				
				var newConfig:BuffersConfig = new BuffersConfig();
				newConfigs.push(newConfig);
				
				for (var j:int = 0 ; j < keyLen ; j++)
				{
					var key:String = _file.keys[j];
					if (newConfig.hasOwnProperty(key))
					{
						newConfig[key] = _file.getValue(line , j , startLine);
					}
				}
				
				
				line++;
			}
			
			return true;
		}

		/**
		 * 根据配置ID和等级查找配置。
		 * @param id
		 * @param level 从1开始
		 * @return
		 */
		public function getBuffersConfigByID(id:int , level:int = 1):BuffersConfig
		{
			var configList:Vector.<BuffersConfig> = getBuffersConfigListByID(id);

			if (level < 1)
				level = 1;
			var line:int = level - 1;

			if (configList && configList.length > line)
				return configList[line];
			else
				return null;
		}

		/**
		 * 根据配置Name和等级查找配置。
		 * @param name
		 * @param level 从1开始
		 * @return
		 *
		 */
		public function getBuffersConfigByName(name:String , level:int = 1):BuffersConfig
		{
			var configList:Vector.<BuffersConfig> = getBuffersConfigListByName(name);

			if (level < 1)
				level = 1;
			var line:int = level - 1;

			if (configList && configList.length > line)
				return configList[line];
			else
				return null;
		}

		public function getBuffersConfigListByID(id:int):Vector.<BuffersConfig>
		{
			if(!(id in _idCache))
			{
				if(!generateConfigListOfID(id))
				{
					return null;
				}
			}
			
			return _idCache[id];
		}


		public function getBuffersConfigListByName(name:String):Vector.<BuffersConfig>
		{
			//name to id
			var id:int = _file.nameToID(name);
			return getBuffersConfigListByID(id);
		}

		public function getMaxLevelByID(id:int):int
		{
			var configsList:Vector.<BuffersConfig> = getBuffersConfigListByID(id);
			if(configsList)
			{
				return configsList.length;
			}
			
			return 0;
		}

		public function getMaxLevelByName(name:String):int
		{
			var id:int = _file.nameToID(name);
			return getMaxLevelByID(id);
		}
	}
}
