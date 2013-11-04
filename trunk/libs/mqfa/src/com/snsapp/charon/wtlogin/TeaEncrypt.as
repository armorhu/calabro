package com.snsapp.charon.wtlogin{
	import flash.utils.ByteArray;
	public class TeaEncrypt{
		public function TeaEncrypt(){
			throw new Error("XXTEA class is static container only");
		}
		
		private static var pOutBuf:Array;
		private static var SALT_LEN:int = 2;
		private static var ZERO_LEN:int = 7;
		
		public static function encrypt(pInBuf:Array, pKey:Array,test:Boolean = false):ByteArray
		{
			var nInBufLen:int = pInBuf.length;
			var nPadSaltBodyZeroLen:int;/*PadLen(1byte)+Salt+Body+Zero的长度*/;
			var nPadlen:int;
			var src_buf:Array=new Array(8);
			var iv_plain:Array = new Array(8);
			var iv_crypt:Array;
			var src_i:int, i:int, j:int;
			var k:int;
			/*根据Body长度计算PadLen,最小必需长度必需为8byte的整数倍*/
			nPadSaltBodyZeroLen = nInBufLen/*Body长度*/+10/*PadLen(1byte)+Salt(2byte)+Zero(7byte)*/;
			if((nPadlen=nPadSaltBodyZeroLen%8)) /*len=nSaltBodyZeroLen%8*/
			{
				/*模8余0需补0,余1补7,余2补6,...,余7补1*/
				nPadlen=8-nPadlen;
			}
			/*srand( (unsigned)time( NULL ) ); 初始化随机数*/
			/*加密第一块数据(8byte),取前面10byte*/
			src_buf[0] = ((32 & 0x0f8) | nPadlen);/*最低三位存PadLen,清零*/
			
			src_i = 1; /*src_i指向src_buf下一个位置*/
			while(nPadlen--)
				src_buf[src_i++]= rand(); /*Padding*/
			if(test){
				src_buf[1] = 0xbe;
				src_buf[2] = 0x84;
				src_buf[3] = 0xe1;
				src_i = 4;
			}
			/*come here, src_i must <= 8*/
			for ( i=0; i<8; i++){
				iv_plain[i] = 0;
			}
			for ( i=0; i<pInBuf.length; i++){
				pInBuf[i] = (typeof pInBuf[i])=="string"?pInBuf[i].toString().charCodeAt(0):pInBuf[i];
				
			}
			iv_crypt = iv_plain; /*make zero iv*/
			var pOutBufLen:int = 0; /*init OutBufLen*/
			pOutBuf = [];
			for (i=1;i<=SALT_LEN;) /*Salt(2byte)*/
			{
				if (src_i<8)
				{
					if(!test)
					src_buf[src_i++]=rand();
					i++; /*i inc in here*/
				}
				if (src_i==8){
					/*src_i==8*/
					
					for (j=0;j<8;j++) /*加密前异或前8个byte的密文(iv_crypt指向的)*/
						src_buf[j]^=iv_crypt[j];
					/*pOutBuffer、pInBuffer均为8byte, pKey为16byte*/
					/*加密*/
					TeaEncryptECB(src_buf, pKey);
					
					for (j=0;j<8;j++) /*加密后异或前8个byte的明文(iv_plain指向的)*/
						pOutBuf[j]^=iv_plain[j];
					
					/*保存当前的iv_plain*/
					for (j=0;j<8;j++)
						iv_plain[j]=src_buf[j];
					
					/*更新iv_crypt*/
					src_i=0;
					iv_crypt = [];
					for(k=0;k<8;k++){
						iv_crypt[k]=pOutBuf[pOutBufLen+k];
					}
					pOutBufLen+=8;
				}
			}
			/*src_i指向src_buf下一个位置*/
			var iInBuf:int = 0;
			while(nInBufLen)
			{
				if (src_i<8)
				{
					
					src_buf[src_i++]=pInBuf[iInBuf++];
					nInBufLen--;
				}
				
				if (src_i==8)
				{
					var o:String = "";
					var o2:String = "";
					/*src_i==8*/
					for (j=0;j<8;j++){ /*加密前异或前8个byte的密文(iv_crypt指向的)*/
						
						
						o+=(src_buf[j]).toString(16)+" ";
						src_buf[j]^=iv_crypt[j];
						
						o2+=(iv_crypt[j]).toString(16)+" ";
					}
					/*pOutBuffer、pInBuffer均为8byte, pKey为16byte*/
					TeaEncryptECB(src_buf, pKey);
					
					for (j=0;j<8;j++){
						/*加密后异或前8个byte的明文(iv_plain指向的)*/
						pOutBuf[pOutBufLen+j]^=iv_plain[j];
					}			
					
					/*保存当前的iv_plain*/
					for (j=0;j<8;j++)
						iv_plain[j]=src_buf[j];
					
					src_i=0;
					iv_crypt = [];
					for(k=0;k<8;k++){
						iv_crypt[k]=pOutBuf[pOutBufLen+k];
					}
					//trace("pOutBuf:",o);
					//trace("iv_cryp:",o2);
					pOutBufLen+=8;
				}
			}
			/*src_i指向src_buf下一个位置*/
			for (i=1;i<=ZERO_LEN;)
			{
				if (src_i<8)
				{
					src_buf[src_i++]=0;
					i++; /*i inc in here*/
				}
				
				if (src_i==8)
				{
					/*src_i==8*/
					
					for (j=0;j<8;j++) /*加密前异或前8个byte的密文(iv_crypt指向的)*/
						src_buf[j]^=iv_crypt[j];
					/*pOutBuffer、pInBuffer均为8byte, pKey为16byte*/
					TeaEncryptECB(src_buf, pKey);
					
					for (j=0;j<8;j++) /*加密后异或前8个byte的明文(iv_plain指向的)*/
						pOutBuf[pOutBufLen+j]^=iv_plain[j];
					
					/*保存当前的iv_plain*/
					for (j=0;j<8;j++)
						iv_plain[j]=src_buf[j];
					
					src_i=0;
					iv_crypt = [];
					for( k=0;k<8;k++){
						iv_crypt[k]=pOutBuf[pOutBufLen+k];
					}
					pOutBufLen+=8;
				}
			}
			var byte:ByteArray = new ByteArray;
			
			for(i=0;i<pOutBuf.length;i++){
				byte.writeByte(pOutBuf[i]);
			}
			byte.position = 0;
			
			
			return byte;
		}
		private static var DELTA:uint = 0x9e3779b9;
		private static var ROUNDS:int = 16;
		private static var LOG_ROUNDS:int = 4;
		
		
		private static var dest_buf:Array = new Array(8);
		public static function decrypt(pInBuf:Array, pKey:Array):ByteArray
		{
			var nPadLen:int;
			var nPlainLen:int;
			var zero_buf:Array = new Array(8);
			var iv_pre_crypt:Array;
			var iv_cur_crypt:Array;
			var dest_i:int;
			var i:int;
			var j:int;
			var k:int
			//var pInBufBoundary:Array;
			var nBufPos:int;
			var nInBuf:int=0;
			nBufPos = 0;
			var nInBufLen:int = pInBuf.length;
			pOutBuf = [];
			TeaDecryptECB(pInBuf, pKey);
			nPadLen = dest_buf[0] & 0x7/*只要最低三位*/;
			/*密文格式:PadLen(1byte)+Padding(var,0-7byte)+Salt(2byte)+Body(var byte)+Zero(7byte)*/
			i = nInBufLen-1/*PadLen(1byte)*/-nPadLen-SALT_LEN-ZERO_LEN; /*明文长度*/
			var pOutBufLen:int = i;
			//pInBufBoundary = pInBuf + nInBufLen; /*输入缓冲区的边界，下面不能pInBuf>=pInBufBoundary*/
			for ( i=0; i<8; i++)
				zero_buf[i] = 0;
			
			iv_pre_crypt = zero_buf;
			iv_cur_crypt = pInBuf; /*init iv*/
			
			nInBuf += 8;
			nBufPos += 8;
			
			dest_i=1; /*dest_i指向dest_buf下一个位置*/
			
			
			/*把Padding滤掉*/
			dest_i+=nPadLen;
			/*dest_i must <=8*/
			
			/*把Salt滤掉*/
			for (i=1; i<=SALT_LEN;)
			{
				if (dest_i<8)
				{
					dest_i++;
					i++;
				}
				else if (dest_i==8)
				{
					/*解开一个新的加密块*/
					
					/*改变前一个加密块的指针*/
					iv_pre_crypt = iv_cur_crypt.concat([]);
					iv_cur_crypt = [];
					for(k=0;k<8;k++){
						iv_cur_crypt[k] = pInBuf[nInBuf+k]; 
					}
					/*异或前一块明文(在dest_buf[]中)*/
					for (j=0; j<8; j++)
					{
						//if( (nBufPos + j) >= nInBufLen)
						//return FALSE;
						dest_buf[j]^=pInBuf[nInBuf+j];
					}
					/*dest_i==8*/
					TeaDecryptECB(dest_buf, pKey);
					/*在取出的时候才异或前一块密文(iv_pre_crypt)*/
					nInBuf += 8;
					nBufPos += 8;
					dest_i=0; /*dest_i指向dest_buf下一个位置*/
				}
			}
			/*还原明文*/
			nPlainLen=pOutBufLen;
			//trace("pOutBufLen:",pOutBufLen);
			while (nPlainLen)
			{
				if (dest_i<8)
				{
					pOutBuf.push(dest_buf[dest_i]^iv_pre_crypt[dest_i]);
					dest_i++;
					nPlainLen--;
				}
				else if (dest_i==8)
				{
					/*dest_i==8*/
					/*改变前一个加密块的指针*/
					iv_pre_crypt = iv_cur_crypt.concat([]);
					iv_cur_crypt = [];
					for(k=0;k<8;k++){
						iv_cur_crypt[k] = pInBuf[nInBuf+k]; 
						//trace("pInBuf:",pInBuf[nInBuf+k]);
					}
					
					
					/*解开一个新的加密块*/
					
					/*异或前一块明文(在dest_buf[]中)*/
					for (j=0; j<8; j++)
					{
						//if( (nBufPos + j) >= nInBufLen)
						//	return FALSE;
						dest_buf[j]^=pInBuf[nInBuf+j];
						//trace(nInBuf+j,pInBuf[nInBuf+j]);
					}
					//trace("************")
					TeaDecryptECB(dest_buf, pKey);
					
					/*在取出的时候才异或前一块密文(iv_pre_crypt)*/
					
					
					nInBuf += 8;
					nBufPos += 8;
					
					dest_i=0; /*dest_i指向dest_buf下一个位置*/
				}
			}
			
			/*校验Zero*/
			for (i=1;i<=ZERO_LEN;)
			{
				if (dest_i<8)
				{
					//if(dest_buf[dest_i]^iv_pre_crypt[dest_i]) return FALSE;
					dest_i++;
					i++;
				}
				else if (dest_i==8)
				{
					/*改变前一个加密块的指针*/
					iv_pre_crypt = iv_cur_crypt;
					iv_cur_crypt = [];
					for(k=0;k<8;k++){
						iv_cur_crypt[k] = pInBuf[nInBuf+k]; 
					}
					
					/*解开一个新的加密块*/
					
					/*异或前一块明文(在dest_buf[]中)*/
					for (j=0; j<8; j++)
					{
						//if( (nBufPos + j) >= nInBufLen)
						//	return FALSE;
						dest_buf[j]^=pInBuf[nInBuf+j];
					}
					//trace("************")
					TeaDecryptECB(dest_buf, pKey);
					
					/*在取出的时候才异或前一块密文(iv_pre_crypt)*/
					
					
					nInBuf += 8;
					nBufPos += 8;
					dest_i=0; /*dest_i指向dest_buf下一个位置*/
				}
				
			}
			var output:ByteArray = new ByteArray;
			for(i=0;i<pOutBuf.length;i++){
				output.writeByte(pOutBuf[i]);
			}
			output.position = 0;
			return output;//.readMultiByte(output.length,"utf-8");
			//return TRUE;
		}
		/*pOutBuffer、pInBuffer均为8byte, pKey为16byte*/
		private static function TeaEncryptECB(pInBuf:Array, pKey:Array):void
		{
			//trace(pInBuf,pKey);
			var sum:uint;
			var k:Array = new Array(4);
			var i:int;
			
			/*plain-text is TCP/IP-endian;*/
			
			/*GetBlockBigEndian(in, y, z);*/
			var str:String = "";
			for(i=0;i<pInBuf.length;i++){
				//str+=(pKey[i]).toString(16)+" ";
				//trace(pInBuf[i].toString(16))
			}
			//trace(str);
			var v:Array = str2long(pInBuf, false);
			k = str2long(pKey, false);
			var n:uint = v.length - 1;
			var y:int = v[0];
			var z:int = v[n];
			sum = 0;
			for (i=0; i<ROUNDS; i++)
			{   
				sum += DELTA;
				y += ((z << 4) + k[0]) ^( z + sum) ^( (z >>> 5) + k[1]);
				z += ((y << 4) + k[2] )^( y + sum) ^ ((y >>> 5) + k[3]);
				
			}
			//trace(htonl(y),htonl(z));
			var byte:ByteArray = new ByteArray;
			byte.writeInt(htonl(z));
			byte.writeInt(htonl(y));
			byte.position = 0;
			var temp:Array = [];
			//trace(byte.length);
			for(i=0;i<8;i++){
				temp.push(byte.readUnsignedByte());
			}
			for(i=0;i<8;i++){
				pOutBuf.push(temp[7-i]);
			}
			//
			/*now encrypted buf is TCP/IP-endian;*/
		}
		private static function TeaDecryptECB(pInBuf:Array, pKey:Array):void
		{
			var sum:uint;
			var k:Array = new Array(4);
			var i:int;
			
			/*plain-text is TCP/IP-endian;*/
			
			/*GetBlockBigEndian(in, y, z);*/
			var str:String = "";
			for(i=0;i<pInBuf.length;i++){
				str+=String.fromCharCode(pInBuf[i]);
			}
			var v:Array = str2long(pInBuf, false);
			k = str2long(pKey, false);
			
			var n:uint = v.length - 1;
			var y:int = v[0];
			var z:int = v[1];
			
			sum = DELTA << 4;
			for (i=0; i<ROUNDS; i++)
			{
				z -= ((y << 4) + k[2]) ^ (y + sum )^( (y >>> 5) + k[3]); 
				y -= ((z << 4) + k[0]) ^ (z + sum )^ ((z >>> 5) + k[1]);
				sum -= DELTA;
			}
			//trace(htonl(y),htonl(z));
			var byte:ByteArray = new ByteArray;
			byte.writeInt(htonl(z));
			byte.writeInt(htonl(y));
			
			byte.position = 0;
			var temp:Array = [];
			
			for(i=0;i<8;i++){
				temp.push(byte.readUnsignedByte());
			}
			for(i=0;i<8;i++){
				dest_buf[i]=(temp[7-i]);
			}
			
			/*now plain-text is TCP/IP-endian;*/
		}
		private static function str2long(s:Array,w:Boolean):Array {
			
			var len:uint = s.length;
			
			var v:Array = new Array();
			for (var i:uint = 0; i < len; i += 4){
				v[i >> 2] = s[i+3]
					| (s[i + 2] << 8)
					| (s[i + 1] << 16)
					| (s[i] << 24);
			}
			if (w) {
				v[v.length] = len;
			}
			return v;
		}
		private static function long2str(v:Array,w:Boolean):String {
			var vl:uint = v.length;
			var sl:uint = v[vl - 1] & 0xffffffff;
			for (var i:uint = 0; i < vl; i++){
				v[i] = String.fromCharCode(v[i] & 0xff,
					v[i] >>> 8 & 0xff,
					v[i] >>> 16 & 0xff,
					v[i] >>> 24 & 0xff);
			}
			if(w){
				return v.join('').substring(0, sl);
			}else {
				return v.join('');
			}
		}
		public static function htonl(v:int):int{
			return (((v & 0xff000000) >>> 24) | ((v & 0x00ff0000) >>> 8) | ((v & 0x0000ff00) << 8) |((v & 0x000000ff) << 24))
		}
		public static function htons(v:int):int{
			return ((v & 0xff00) >>> 8) | ((v & 0x00ff) << 8);
		}
		public static function rand():uint{
			return Math.floor(50+Math.random()*78);
		}
		public static function swap_word(v:int):int{
			return (((v) & 0xff00000000000000) >> 56) | (((v) & 0x00ff000000000000) >> 40) | (((v) & 0x0000ff0000000000) >> 24) | (((v) & 0x0000ff0000000000) >> 24) | (((v) & 0x000000ff00000000) >> 8) | 	(((v) & 0x00000000ff000000) << 8) | (((v) & 0x0000000000ff0000) << 24) | ((v & 0x000000000000ff00) << 40) | ((v & 0x00000000000000ff) << 56) ;
		}
	}
}

