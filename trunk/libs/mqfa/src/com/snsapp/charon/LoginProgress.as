package com.snsapp.charon
{
    public class LoginProgress
    {
        /**
         * 开始登录 
         */        
        static public const START_LOGIN:int = 1;
        
        
        /**
         * 登录结束。不论成功或者失败。
         */        
        static public const LOGIN_COMPLETE:int = 2;
        
        /**
         * 需要输入验证码 
         */        
        static public const NEED_PIC_CODE:int = 3;
        
        
        /**
         * 描述当前登录进度的数据。
         * result只有在当progress＝LOGIN_COMPLETE时，才有意义。
         * 
         * @param progress
         * @param msg
         * @param result
         * 
         */        
        public function LoginProgress(progress:int, msg:String, desc:LoginDesc = null)
        {
            this.progress = progress;
            this.msg = msg;
            this.desc = desc;
        }
        
        
        /**
         * 当前登录属于哪个阶段 
         */        
        public var progress:int;
        
        /**
         * 相关信息 
         */        
        public var msg:String;
        
        
        /**
         * 登录结果 
         */        
        public var desc:LoginDesc;
    }
}