package com.snsapp.charon
{
    
    /**
     * 登录描述.<br/>
     * 用于在登录过程中, 登录完成时, 保存真个登录过程的信息.<br/>
     *  
     * @author mobiuschen
     * 
     */    
    public class LoginDesc
    {
        public var uin:String;
        
        public var nickName:String;
        
        public var skey:String;
        
        public var cookies:String;
        
        public var g_tk:String;
        
        public var errCode:int = 0;
        
        public var errMsg:String = "";
        
        
        public function LoginDesc()
        {
        }
        
        
        public function toString():String
        {
            var s:String =
                [
                    "[LoginResult]:(", 
                    "uin=", uin,
                    ", nickName=", nickName, 
                    ", skey=", skey, 
                    ", cookies=", cookies, 
                    ", g_tk=", g_tk, 
                    ", errCode=", errCode, 
                    ", errMsg=", errMsg, 
                    ")"
                ].join("");
            return s;
        }
    }
}