package com.snsapp.mobile.mananger.cachepool
{
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.ProgressEvent;
import flash.utils.Dictionary;
import flash.utils.clearTimeout;
import flash.utils.describeType;
import flash.utils.getQualifiedClassName;
import flash.utils.setTimeout;
    
/**
 * 
 *  
 * @author mobiuschen
 * 
 */    
public class CacheStreamline extends EventDispatcher
{
    static public const CACHE_COMPLETE:String = "cacheComplete";
    
    static public const OVERTIME:int = 5000;
    
    public function CacheStreamline()
    {
        super(null);
        insDict = new Dictionary();
    }
    
    
    private var insDict:Dictionary;
    
    public function registerClassAndCache(classes:Vector.<Class>, keys:Vector.<String>):void
    {
        if(classes == null || classes.length == 0)
        {
            throw new ArgumentError("ArgumentError");
        }
        
        startCache(register(classes, keys));
    }
    
    
    public function getIns(key:String):ICacheable
    {
        return insDict[key];
    }
        
    
    
    private function register(classes:Vector.<Class>, keys:Vector.<String>):Dictionary
    {
        var C:Class;
        var descripetion:XML;
        var dict:Dictionary = new Dictionary();
        
        //方便编译时检查
        var interfaceName:String = getQualifiedClassName(ICacheable);
        
        var xmllist:XMLList
        for(var i:int, n:int = classes.length; i < n; i++)
        {
            C = classes[i];
            if(C == null)
                continue;
            
            descripetion = describeType(C);
            xmllist = descripetion.factory.implementsInterface.(@type == interfaceName);
            
            //是否implements 指定接口
            if(xmllist.length() > 0)
            {
                dict[keys[i]] = C;
            }
        }
        return dict;
    }
    
    
    private function startCache(dict:Dictionary):void
    {
        if(dict == null || insDict == null)
        {
            throw new ArgumentError("ArgumentError");
            return;
        }
        cacheNext(dict);
    }
    
    
    private function cacheNext(classDict:Dictionary):void
    {
        var key:String;
        for(key in classDict)
            break;
        
        if(key == null || key == "")
        {
            dispatchEvent(new Event(Event.COMPLETE));
            return;
        }
        
        var C:Class = classDict[key];
        var cacheTarget:ICacheable = new C();
        cacheTarget.initForCache();            
        cacheTarget.addEventListener(CACHE_COMPLETE, onCacheComplete);
        cacheTarget.cache();
        
        var overTimeID:int = -1; 
        //overTimeID = setTimeout(overtime, OVERTIME);
        
        function onCacheComplete(evt:Event):void
        {
            cacheTarget.removeEventListener(CACHE_COMPLETE, onCacheComplete);
            overTimeID > -1 ? clearTimeout(overTimeID) : null;
            insDict[key] = cacheTarget;
            delete classDict[key];
            
            setTimeout(cacheNext, 10, classDict);
        }
        
        function overtime():void
        {
            cacheTarget.removeEventListener(CACHE_COMPLETE, onCacheComplete);
            overTimeID > -1 ? clearTimeout(overTimeID) : null;
            delete classDict[key];
            
            setTimeout(cacheNext, 10, classDict);
        }
    }
    
    
    
    
    
    
    
    
}
}