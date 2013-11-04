package com.qzone.qfa.utils
{
	import flash.system.ApplicationDomain;

	public class CommonUtil
	{
		public static function sort_names(a:String, b:String):int
		{
			var a1:Array = a.split('_');
			var b1:Array = b.split('_');
			var na:Number;
			var nb:Number;
			if (a1.length != b1.length)
				return a1.length - b1.length;
			else
			{
				a1.shift();
				b1.shift();
				const len:int = a1.length;
				for (var i:int = 0; i < len; i++)
				{
					na = parseInt(a1[i]);
					nb = parseInt(b1[i]);
					if (isNaN(na) && isNaN(nb))
						continue;
					if (isNaN(na) == false && isNaN(nb) == false)
					{
						if (na != nb)
							return na - nb;
						else
							continue;
					}
					return isNaN(na) ? 1 : -1;
				}

				return 0;
			}
		}

		/**
		 * xx.xx.xx 格式的版本号的比较。
		 * @param v1
		 * @param v2
		 */
		public static function compareVersionLabel(v1:String, v2:String):int
		{
			var n11:Number = parseFloat(v1);
			var n12:Number = parseFloat(v2);
			if (!isNaN(n11) && !isNaN(n11))
			{ //两个都是数字就直接用数字比较
				if (n11 > n12)
					return 1;
				else if (n11 < n12)
					return -1;
				else
					return 0;
			}

			var a1:Array = v1.split(".");
			var a2:Array = v2.split(".");
			var index:int = 0;
			var n1:int;
			var n2:int;
			while (true)
			{
				if (index == a1.length && index == a2.length)
					return 0;
				if (index == a1.length)
					return -1;
				else if (index == a2.length)
					return 1;
				n1 = parseInt(a1[index]);
				n2 = parseInt(a2[index]);
				if (n1 == n2)
					index++;
				else
					return n1 - n2;
			}
			return 0;
		}


		public static function getInstance(classRef:String, appdomian:ApplicationDomain = null):Object
		{
			if (appdomian == null)
				appdomian = ApplicationDomain.currentDomain;

			var c:Class = appdomian.getDefinition(classRef) as Class;
			if (c)
				return new c();
			else
				return null;
		}
		
		
		public static function getSizeStr(bytes:Number):String
		{
			var num:Number = bytes;
			if (num < 1024)
				return num.toFixed() + "byte";
			
			num /= 1024;
			if (num < 1024)
				return num.toFixed() + "KB";
			
			num /= 1024;
			return num.toFixed(2) + "MB";
		}
	}
}
