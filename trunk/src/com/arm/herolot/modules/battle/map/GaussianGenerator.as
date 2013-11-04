package com.arm.herolot.modules.battle.map
{
	public class GaussianGenerator
	{
		private var numbers:Vector.<int>;
		private var cachedRate:Vector.<Number>;
		private var cachedIndex:int;
		private var delta:Number;
		private var originalTop:int;
		private var targetTop:int;
		
		public function GaussianGenerator(min:int, max:int, oriTop:int, tarTop:int, totalGapsCount:int)
		{
			reset(min, max, oriTop, tarTop, totalGapsCount);
		}
		
		public function reset(min:int, max:int, oriTop:int, tarTop:int, totalGapsCount:int):void
		{
			originalTop = oriTop;
			targetTop = tarTop;
			
			numbers = new Vector.<int>();
			delta = Number(targetTop - originalTop) / totalGapsCount;
			cachedIndex = -1;
			
			for(var i:int = 0; i < max - min + 1; i++)
				numbers.push(min + i);
			
			cachedRate = new Vector.<Number>();
			cachedRate.length = numbers.length;
		}
		
		public function getRandom(gapsCount:int):int
		{
			/*we get same random model from every 10 floors in order to decrease calculation*/
			var index:int = gapsCount / 10;
			if(cachedIndex != index)
			{
				cachedIndex = index;
				
				var u:Number = originalTop + gapsCount * delta;
				var v:Number = 0;
				const count:int = numbers.length;
				for(var i:int = 0; i < count; i++)
					v += Math.pow((u - numbers[i]), 2);
				v = Math.pow(v / count, 0.5);
				
				/*normalization*/
				var total:Number = 0;
				for(i = 0; i < count; i++)
				{
					cachedRate[i] = calculateGaussian(u, v, numbers[i]);
					total += cachedRate[i];
				}
				
				for(i = 0; i < count; i++)
					cachedRate[i] /= total;
				
//				trace(cachedRate);
			}
			
			var r:Number = Math.random();
			var sum:Number = 0;
			var ret:int = -1;
			for(var l:int = 0; l < cachedRate.length; l++)
			{
				sum += cachedRate[l];
				if(r <= sum)
				{
					ret = numbers[l];
					break;
				}
			}
			return ret;
			
			function calculateGaussian(u:Number, v:Number, x:Number):Number
			{
				var param1:Number = 1/((Math.pow(2 * Math.PI, 0.5) * v));
				var param2:Number = Math.pow(Math.E, -((x - u) * (x - u)/(2 * v * v)));
				return param1 * param2;
			}
		}
	}
}