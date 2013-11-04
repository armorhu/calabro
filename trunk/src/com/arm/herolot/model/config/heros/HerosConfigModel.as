package com.arm.herolot.model.config.heros
{
	import com.arm.herolot.model.config.IConfigModel;
	import com.arm.herolot.services.utils.CSVFile;
	

	public class HerosConfigModel implements IConfigModel
	{
		public var heros:Vector.<HerosConfig>;

		public function HerosConfigModel()
		{
		}

		public function init(data:*):void
		{
			var csvFile:CSVFile = new CSVFile();
			csvFile.read(data).parse();
			const keyLen:int = csvFile.keys.length;
			const lineNum:int = csvFile.valueTables.length;

			heros = new Vector.<HerosConfig>();
			heros.length = lineNum;

			for (var i:int = 0; i < lineNum; i++)
			{
				heros[i] = new HerosConfig();

				for (var j:int = 0; j < keyLen; j++)
					heros[i][csvFile.keys[j]] = csvFile.getValue(i,j,i);
			}
			heros.fixed = true;
			csvFile.dispose();
			csvFile = null;
		}

		/**
		 * 根据配置ID和等级查找配置。
		 * @param id
		 * @param level 从1开始
		 * @return
		 */
		public function getHerosConfigByID(id:int):HerosConfig
		{
			const len:int = heros.length;

			for (var i:int = 0; i < len; i++)
			{
				if (heros[i].ID == id)
					return heros[i];
			}
			return null;
		}
	}
}
