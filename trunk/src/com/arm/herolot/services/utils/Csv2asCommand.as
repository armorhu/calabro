package com.arm.herolot.services.utils
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class Csv2asCommand
	{
		public static const configPackage:String = 'com.arm.herolot.model.config';

		public static const configPath:String = 'src/com/arm/herolot/model/config';

		public static const csvPath:String = 'config/';

		public static const ImportTagStart:String = '	/**自动生成的import代码--start**/';

		public static const ImportTagEnd:String = '	/**自动生成的import代码--end**/';

		public static const PropertyTagStart:String = '		/**自动生成的属性代码--start**/';

		public static const PropertyTagEnd:String = '		/**自动生成的属性代码--end**/';

		public static const ModelLogicTagStart:String = '		/**自动生产的logic代码--start**/';

		public static const ModelLogicTagEnd:String = '		/**自动生产的logic代码--end**/';

		public function Csv2asCommand()
		{
		}

		public var asFolder:File;

		public var fs:FileStream;

		/**
		 *二维配置
		 */
		public var template2ConfigModel:String;

		/**
		 *配置model模版。一维配置。
		 */
		public var templateConfigModel:String;

		/**
		 *配置模版
		 */
		public var templateConfigStr:String;

		/**
		 *管理类
		 */
		public var appConfigModelStr:String;

		public var appConfig_ImportContent:String = '';

		public var appConfig_PropertyContent:String = '';

		public var appConfig_ModelLogicContent:String = '';

		public function csv2as(configName:String, model2:Boolean):void
		{
			var configClass:String = templateConfigStr;
			var modelClass:String = model2 ? template2ConfigModel : templateConfigModel;

			var data:String = readFile(File.applicationDirectory.resolvePath(csvPath + configName).nativePath);
			var csvFile:CSVFile = new CSVFile();
			csvFile.read(data).parse();

			if (model2 && (csvFile.keys.indexOf('ID') == -1 || csvFile.keys.indexOf('Name') == -1))
			{
				trace('csv2as', configName, model2, 'failed!!!!!');
				return;
			}
			trace('csv2as', configName, model2);
			var name:String = configName.replace('.csv', '');
			var className:String = toUperCaseHead(name);
			var propertyName:String = toLowerCaseHead(name);


			var propertys:String = '';
			const len:int = csvFile.keys.length;

			for (var i:int = 0; i < len; i++)
				propertys = propertys + propertyString(csvFile.keys[i], csvFile.types[i]) + '\n';
			configClass = configClass.replace(/template/g, propertyName);
			configClass = configClass.replace(/Template/g, className);
			var insertIndex:int = configClass.indexOf('		public function ');
			configClass = configClass.substr(0, insertIndex) + propertys + configClass.substr(insertIndex);
			writeAsFile(propertyName + '/' + className + 'Config.as', configClass);

			modelClass = modelClass.replace(/template/g, propertyName);

			if (model2)
				modelClass = modelClass.replace(/Template2/g, className);
			modelClass = modelClass.replace(/Template/g, className);
			writeAsFile(propertyName + '/' + className + 'ConfigModel.as', modelClass);

			var importStr:String = '	import ' + configPackage + '.' + propertyName + '.' + className + 'ConfigModel';
//			if (appConfigModelStr.indexOf(importStr) == -1)
			appConfig_ImportContent = appConfig_ImportContent + importStr + ';\n';

			appConfig_PropertyContent = appConfig_PropertyContent + propertyString(propertyName + 'ConfigModel', className + 'ConfigModel') + '\n';
			appConfig_ModelLogicContent = appConfig_ModelLogicContent + //
				'			' + propertyName + 'ConfigModel = new ' + className + 'ConfigModel;\n' + //
				'			bindle("config/' + configName + '",' + propertyName + 'ConfigModel' + ');\n';
		}

		public function propertyString(propertyName:String, propertyClass:String):String
		{
			return '		public var ' + propertyName + ':' + propertyClass + ';';
		}

		public function start():void
		{
			trace('Csv2asCommand start.......')
			fs = new FileStream();
			asFolder = new File(File.applicationDirectory.nativePath.replace(File.applicationDirectory.name, configPath));
			trace(asFolder.nativePath);
//			return;
			templateConfigStr = readFile(asFolder.nativePath + '/template/TemplateConfig.as');
			templateConfigModel = readFile(asFolder.nativePath + '/template/TemplateConfigModel.as');
			template2ConfigModel = readFile(asFolder.nativePath + '/template/Template2ConfigModel.as');
			appConfigModelStr = readFile(asFolder.nativePath + '/AppConfigModel.as');

			var csv2asConfigContent:String = readFile(File.applicationDirectory.nativePath + '/csv2as.txt');
			
			var csv2asList:Array = csv2asConfigContent.split('\n');

			for (var i:int = 0; i < csv2asList.length; i++)
			{
				var csv2asConfig:Array = String(csv2asList[i]).split(',');
				csv2as(csv2asConfig[0], csv2asConfig[1] == 'true');
			}
			appConfigModelStr = insertString( //
				appConfigModelStr, //
				appConfig_ImportContent, //
				ImportTagStart, ImportTagEnd);
			appConfigModelStr = insertString( //
				appConfigModelStr, // 
				appConfig_PropertyContent, //
				PropertyTagStart, PropertyTagEnd //
				);
			appConfigModelStr = insertString(appConfigModelStr, // 
				appConfig_ModelLogicContent, //
				ModelLogicTagStart, ModelLogicTagEnd //
				);
			writeAsFile('AppConfigModel.as', appConfigModelStr);
			trace('Csv2asCommand end.......')
		}

		public function insertString(source:String, target:String, startTag:String, endTag:String):String
		{
			var start:int = source.indexOf(startTag) + startTag.length;
			var end:int = source.indexOf(endTag);
			return source.substring(0, start) + '\n' + target + source.substring(end);
		}

		public function toLowerCaseHead(result:String):String
		{
			return result.substr(0, 1).toLowerCase() + result.substr(1, result.length - 1);
		}

		public function toUperCaseHead(result:String):String
		{
			return result.substr(0, 1).toUpperCase() + result.substr(1, result.length - 1);
		}

		public function readFile(path:String):String
		{
			trace('readFile:',path);
			var file:File = new File(path);
			fs.open(file, FileMode.READ);
			var result:String = fs.readUTFBytes(fs.bytesAvailable);
			fs.close();
			return result;
		}

		public function writeAsFile(resolvePath:String, data:String):void
		{
			trace('writeFile:',resolvePath);
			var file:File = asFolder.resolvePath(resolvePath);
			fs.open(file, FileMode.WRITE);
			fs.writeUTFBytes(data);
			fs.close();
		}
	}
}
