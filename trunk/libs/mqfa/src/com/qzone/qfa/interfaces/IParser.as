package com.qzone.qfa.interfaces
{

	/**
	 * qfa底层回包的解析器。
	 * 用户可以根据不同的命令来解析自己的
	 * @author hufan
	 */
	public interface IParser
	{
		/**
		 * 解析失败返回null，这样底层会将这个错误上报到oz!.
		 * **/
		function parser(data:*):*
	}
}
