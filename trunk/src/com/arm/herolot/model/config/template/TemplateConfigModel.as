package com.arm.herolot.model.config.template
{
	import com.arm.herolot.model.config.IConfigModel;
	import com.arm.herolot.services.utils.CSVFile;
	

	public class TemplateConfigModel implements IConfigModel
	{
		public var template:Vector.<TemplateConfig>;

		public function TemplateConfigModel()
		{
		}

		public function init(data:*):void
		{
			var csvFile:CSVFile = new CSVFile();
			csvFile.read(data).parse();
			const keyLen:int = csvFile.keys.length;
			const lineNum:int = csvFile.valueTables.length;

			template = new Vector.<TemplateConfig>();
			template.length = lineNum;

			for (var i:int = 0; i < lineNum; i++)
			{
				template[i] = new TemplateConfig();

				for (var j:int = 0; j < keyLen; j++)
					template[i][csvFile.keys[j]] = csvFile.getValue(i,j,i);
			}
			template.fixed = true;
			csvFile.dispose();
			csvFile = null;
		}

		/**
		 * 根据配置ID和等级查找配置。
		 * @param id
		 * @param level 从1开始
		 * @return
		 */
		public function getTemplateConfigByID(id:int):TemplateConfig
		{
			const len:int = template.length;

			for (var i:int = 0; i < len; i++)
			{
				if (template[i].ID == id)
					return template[i];
			}
			return null;
		}
	}
}
