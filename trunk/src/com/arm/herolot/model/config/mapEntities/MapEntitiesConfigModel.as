package com.arm.herolot.model.config.mapEntities
{
	import com.arm.herolot.model.config.IConfigModel;
	import com.arm.herolot.services.utils.CSVFile;
	

	public class MapEntitiesConfigModel implements IConfigModel
	{
		public var mapEntities:Vector.<MapEntitiesConfig>;

		public function MapEntitiesConfigModel()
		{
		}

		public function init(data:*):void
		{
			var csvFile:CSVFile = new CSVFile();
			csvFile.read(data).parse();
			const keyLen:int = csvFile.keys.length;
			const lineNum:int = csvFile.valueTables.length;

			mapEntities = new Vector.<MapEntitiesConfig>();
			mapEntities.length = lineNum;

			for (var i:int = 0; i < lineNum; i++)
			{
				mapEntities[i] = new MapEntitiesConfig();

				for (var j:int = 0; j < keyLen; j++)
					mapEntities[i][csvFile.keys[j]] = csvFile.getValue(i,j,i);
			}
			mapEntities.fixed = true;
			csvFile.dispose();
			csvFile = null;
		}

		/**
		 * 根据配置ID和等级查找配置。
		 * @param id
		 * @param level 从1开始
		 * @return
		 */
		public function getMapEntitiesConfigByID(id:int):MapEntitiesConfig
		{
			const len:int = mapEntities.length;

			for (var i:int = 0; i < len; i++)
			{
				if (mapEntities[i].ID == id)
					return mapEntities[i];
			}
			return null;
		}
	}
}
