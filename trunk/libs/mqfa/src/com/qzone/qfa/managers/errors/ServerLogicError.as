package com.qzone.qfa.managers.errors
{

	/**
	 * 服务器逻辑错误。
	 * @author hufan
	 */
	public class ServerLogicError extends Error
	{
		public function ServerLogicError(message:* = "", id:* = 0)
		{
			super(message, id);
		}
	}
}
