package com.arm.herolot.model.config.entities
{
	import com.arm.herolot.model.config.IConfigModel;
	import com.arm.herolot.services.utils.CSVFile;
	

	public class EntitiesConfigModel implements IConfigModel
	{
		public var entities:Vector.<EntitiesConfig>;

		public function EntitiesConfigModel()
		{
		}

		public function init(data:*):void
		{
			var csvFile:CSVFile = new CSVFile();
			csvFile.read(data).parse();
			const keyLen:int = csvFile.keys.length;
			const lineNum:int = csvFile.valueTables.length;

			entities = new Vector.<EntitiesConfig>();
			entities.length = lineNum;

			for (var i:int = 0; i < lineNum; i++)
			{
				entities[i] = new EntitiesConfig();

				for (var j:int = 0; j < keyLen; j++)
					entities[i][csvFile.keys[j]] = csvFile.getValue(i,j,i);
			}
			entities.fixed = true;
			csvFile.dispose();
			csvFile = null;
		}

		/**
		 * 根据配置ID和等级查找配置。
		 * @param id
		 * @param level 从1开始
		 * @return
		 */
		public function getEntitiesConfigByID(id:int):EntitiesConfig
		{
			const len:int = entities.length;

			for (var i:int = 0; i < len; i++)
			{
				if (entities[i].ID == id)
					return entities[i];
			}
			return null;
		}
	}
}
