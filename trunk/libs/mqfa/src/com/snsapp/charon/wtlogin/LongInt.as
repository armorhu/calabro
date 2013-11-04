package com.snsapp.charon.wtlogin
{
	public class LongInt
	{
		private var hexbin:Array = ["0000","0001","0010","0011",
							"0100","0101","0110","0111",
							"1000","1001","","","","","","","",
							"1010","1011",
							"1100","1101","1110","1111"];
		private var binhex:Array = ["0","1","2","3",
							"4","5","6","7",
							"8","9","A","B",
							"C","D","E","F"];
		public function LongInt()
		{
		}
		public function HextoBin(num:String):String{
			num = num.toLocaleUpperCase();
			var str:String = ""
			for(var i:int=0;i<num.length;i++){
				str += hexbin[num.charCodeAt(i)-48];
			}
			
			return str;
		}
		public function binOperator(bin1:String,bin2:String,mode:String="&"):String{
			var i:int,j:int;
			var limit:int;
			var temp:Array = [];
			limit = Math.min(bin1.length,bin2.length);
			var max:int = Math.max(bin1.length,bin2.length);
			switch(mode){
				case "&":
					for(i=0;i<limit;i++){
						temp.push((int(bin1.charAt(bin1.length-i-1))&int(bin2.charAt(bin2.length-i-1))).toString());
					}
					break;
				case "|":
					if(bin1.length<max){
						for(i=limit;i<max;i++){
							bin1="0"+bin1;
						}
					}
					if(bin2.length<max){
						for(i=limit;i<max;i++){
							bin2="0"+bin2;
						}
					}
					for(i=0;i<max;i++){
						temp.push((int(bin1.charAt(bin1.length-i-1))|int(bin2.charAt(bin2.length-i-1))).toString());
					}
					break;
				case "^":
					for(i=0;i<max;i++){
						temp.push((int(bin1.charAt(bin1.length-i-1))^int(bin2.charAt(bin2.length-i-1))).toString());
					}
					break;
			}
			var output:String="";
			for(i=0;i<max;i++){
				output+=temp[max-i-1];
			}
			return output;
		}
		public function DectoBin(num:*):String{
			var output:String = "";
			while(num>0){
				if(num%2==1){
					num = Math.floor(num/2);
					output="1"+output;
				}else{
					num /=2;
					output="0"+output;
				}
			}
			return output;
		}
		public function BintoHex(num:String):String{
			var i:int,j:int;
			var temp:Array = [];
			var str:String;
			for(i=0;i<num.length%4;i++){
				num="0"+num;
			}
			for(i=0;i<num.length;i=i+4){
				str = num.substr(num.length-4-i,4);
				var n:int=1;
				for(j=0;j<str.length;j++){
					if(str.charAt(j)=="1"){
						n+=Math.pow(2,str.length-1-j);
					}
				}
				temp.push(binhex[n-1]);
			}
			var output:String = "";
			var isZero:Boolean = true;
			for(i=0;i<temp.length;i++){
				if(temp[temp.length-1-i]!="0"){
					isZero = false;
				}
				if(isZero&&temp[temp.length-1-i]=="0"){
					continue;
				}
				output+=temp[temp.length-1-i];
			}
			return output;
		}
		public function binMove(num:String,move:int):String{
			var i:int;
			var temp:Array;
			var output:String = "";
			if(move<0){
				output = "0";
				move = -move;
				temp = num.split("");
				for(i=0;i<temp.length-move;i++){
					output+=temp[i];
				}
				return output;
			}else{
				temp = num.split("");
				for(i=0;i<temp.length+move;i++){
					if(i<temp.length){
						output+=temp[i];
					}else{
						output+="0";
					}
				}
				return output;
			}
		}
	}
}