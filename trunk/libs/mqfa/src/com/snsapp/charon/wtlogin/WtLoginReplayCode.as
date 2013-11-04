package com.snsapp.charon.wtlogin
{

	public class WtLoginReplayCode
	{

		public static const LOGIN_SUCCESS:int = 0; //登陆成功
		public static const ERROR_PSW:int = 1; //密码错误
		public static const ERROR_PICCODE:int = 2; //验证码错误
		
		public static const ERROR_USERNAME:int = 90; //用户名不存在
		public static const ERROR_IOERROR:int = 91; //通信失败
		public static const ERROR_INPUT:int = 92; //输入错误
		public static const A2_LOGIN_ERROR:int = 93; //a2登陆错误。
	}
}
