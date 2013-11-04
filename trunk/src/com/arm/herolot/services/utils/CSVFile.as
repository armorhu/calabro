package com.arm.herolot.services.utils
{
	import com.adobe.utils.StringUtil;
	
	import flash.utils.Dictionary;
	
	/**
	 *csv的reader
	 * @author hufan
	 *
	 */
	public class CSVFile
	{
		public var keys:Array;
		public var types:Array;
		public var valueTables:Vector.<Vector.<String>>;
		
		private var _data:String;
		private var _idDict:Dictionary;
		private var _nameDict:Dictionary;
		
		public function CSVFile()
		{
		}
		
		/**
		 * 解析文件
		 */		
		public function parse():void
		{
			_idDict = new Dictionary();
			_nameDict = new Dictionary();
			
			var linesArr:Array = _data.split("\r\n");
			trace(linesArr.length);
			keys = String(linesArr[0]).split(",");
			if(!(keys[0] == 'ID' && keys[1] == 'Name'))
			{
				throw new Error('非法的csv文件');
			}
			
			types = String(linesArr[1]).split(",");
			
			var indexOfID:int = 0;
			var indexOfName:int = 1;
			
			const keyLen:int = keys.length;
			const lineNums:int = linesArr.length;
			for (i = 0; i < keyLen; i++)
			{
				keys[i] = tirmStr(keys[i]);
				types[i] = formatTypeString(tirmStr(types[i]));
			}
			
			//值的表
			valueTables = new Vector.<Vector.<String>>();
			//			valueTables.length = lineNums - 2;
			
			var valueLineArr:Array;
			var valueLineStr:String;
			for (var i:int = 2; i < lineNums; i++)
			{
				//从第二行开始。
				valueLineStr = linesArr[i];
				if (valueLineStr == '')
					break;
				valueLineArr = String(valueLineStr).split(',');
				
				var valueTable:Vector.<String> = new Vector.<String>();
				for (var j:int = 0; j < keyLen; j++) valueTable[j] = valueLineArr[j];
				
				//索引操作-----ID 列
				var indexValue:String = valueLineArr[0];
				if(indexValue && indexValue.length > 0 && !(indexValue in _idDict))
				{
//					trace(indexOfIndexName,indexValue,i-2);
					_idDict[indexValue] = i - 2;
				}
				
				//索引操作-----Name 列
				indexValue = valueLineArr[1];
				if(indexValue && indexValue.length > 0 && !(indexValue in _nameDict))
				{
					//					trace(indexOfIndexName,indexValue,i-2);
					_nameDict[indexValue] = i - 2;
				}
				
				valueTable.fixed = true;
				valueTables[i - 2] = valueTable;
				
			}
			valueTables.fixed = true;
			
			_data = null;
		}
		
		public function nameToID(name:String):int
		{
			var row:int = _nameDict[name];
			return int(valueTables[row][0]);
		}
		
		/**
		 * 读进来，不解析 
		 * @param data
		 * 
		 */		
		public function read(data:String):CSVFile
		{
			_data = data;
			return this;
		}
		
		private function tirmStr(str:String):String
		{
			str = StringUtil.trim(str);
			str = str.replace('"', '');
			str = str.replace('"', '');
			return str;
		}
		
		/**
		 * 通过key获取索引的目标行数 
		 * @param key
		 * @return 
		 * 
		 */		
		public function getRowIndexByIndexKey(key:String):int
		{
			if(!key || key.length <= 0) return -1;
			
			if(!(key in _idDict)) return -1;
			
			return _idDict[key];
		}
		
		public function getValue(row:int, col:int, startRow:int):*
		{
			var resultStr:String = '';
			for (var i:int = row; i >= startRow; i--)
			{
				resultStr = valueTables[i][col];
				if (resultStr != '')
					break;
			}
			
			if(resultStr=='')
				return '';
			
			if(types[col] == 'Boolean')
				return resultStr.toLocaleLowerCase() == 'true';
			else if(types[col] == 'Array')
				return resultStr.split('|');
			else
				return resultStr;
		}
		
		public function dispose():void
		{
			keys = null;
			types = null;
			valueTables = null;
			_idDict = null;
		}
		public static const TYPES:Array = ['int', 'Number', 'String', 'Array', 'Boolean'];
		
		public function formatTypeString(type:String):String
		{
			const len:int = TYPES.length;
			for (var i:int = 0; i < len; i++)
			{
				if (type.toLocaleLowerCase() == TYPES[i].toLocaleLowerCase())
				{
					type = TYPES[i];
					break;
				}
			}
			return type;
		}
	}
}
