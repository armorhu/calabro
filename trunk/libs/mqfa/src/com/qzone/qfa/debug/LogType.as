package com.qzone.qfa.debug
{


public class LogType
{
    /**
     * 警告 
     */		
    public static const WARNING:String = "warning"
    
    /**
     * 报错 
     */		
    public static const ERROR:String = "error";
    
    /**
     * 断言 
     */    
    public static const ASSERT:String = "assert";
    
    /**
     * 网络请求 
     */    
    static public const NETWORK:String = "network"
    
    /**
     * 用户操作 
     */    
    static public const USER_ACTION:String = "userAction";
    
    /**
     * 杂项 
     */    
    static public const MISC:String = "misc";
    
    static public const LOGIN:String = "login";
	
    /**
     * 个人debug专用 
     */    
    static public const DEBUG_MOBIUS:String = "debugMobius";
	
	static public const SYSTEM:String ="system";
    
    
    /**
     * 所有类别，包括运行时新注册的类别都会在这里。 
     */    
    static internal const ALL_TYPES:Array = [
        MISC, WARNING, ERROR,ASSERT, LOGIN, 
        NETWORK, USER_ACTION,
		SYSTEM,
    ];
    
    
    /**
     * 可在运行时注册新的LogType。 
     * @param type
     * @return 是否注册成功？不能与现有类型重复.
     * 
     */    
    static public function registerNewType(type:String):Boolean
    {
        if(type == null || type == "" || ALL_TYPES.indexOf(type) > -1)
            return false;
        
        ALL_TYPES.push(type);
        
        return true;
    }
    
    public function LogType()
    {
    }
    
    
}
}