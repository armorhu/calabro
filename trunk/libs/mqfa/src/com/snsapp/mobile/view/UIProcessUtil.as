package com.snsapp.mobile.view
{
    import com.qzone.qfa.debug.Debugger;
    import com.qzone.qfa.debug.LogType;
    
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.geom.Rectangle;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.getQualifiedClassName;
    
    public class UIProcessUtil
    {
        public function UIProcessUtil()
        {
        }
        
        
        /**
         * 递归使用自适应策略
         * @param target
         * @param symbolKey
         * @param scaleList
         * @param screenSize
         * 
         */        
        public static function processUI(target:Sprite):void
        {
            var symbolKey:String = getQualifiedClassName(target).replace("::", "/");
            recursivelyProcess(
                target, 
                symbolKey, 
                ScreenAdaptiveUtil.SCALE_COMPARED_TO_IP4, 
                ScreenAdaptiveUtil.ACTUAL_SCREEN_RECT
            );
        }
        
        
        public static function destroy(target:DisplayObject):void
        {
            recursiveDestroy(target);
            
            function recursiveDestroy(target:DisplayObject):void
            {
                //递归找出所有
                if(target is BmpMC)
                {
                    BmpMC(target).destroy();
                }
                else if(target is DisplayObjectContainer)
                {
                    var c:DisplayObjectContainer = target as DisplayObjectContainer;
                    for(var i:int = 0, n:int = c.numChildren; i < n; i++)
                    {
                        recursiveDestroy(c.getChildAt(i));
                    }
                }
            }//function recursiveDestroy
        }
        
       	private static const debug:Boolean = false;
        private static function recursivelyProcess(target:Sprite,
                                                   symbolKey:String,
                                                   scaleList:Object,
                                                   screenSize:Rectangle):void
        {
            try{
				if(debug)
                Debugger.log("recursivelyProcess 1", target.name, LogType.DEBUG_MOBIUS);
                var child:MovieClip;
                var cName:String;
                var bmpMC:BmpMC;
                var oriBounds:Rectangle;
                var newBounds:Rectangle;
                var cacheDict:Dictionary = new Dictionary();
                var scaleObj:Object = {"sX":1.0, "sY":1.0};
				if(debug)
                Debugger.log("recursivelyProcess 1.1", "numChildren=", target.numChildren, LogType.DEBUG_MOBIUS);
                
                
                for(var i:int = 0, n:int = target.numChildren; i < n; i++)
                {
					if(debug)
                    Debugger.log("recursivelyProcess 1.2", LogType.DEBUG_MOBIUS);
                    child = target.getChildAt(i) as MovieClip;
                    
                    if(child == null)
                        continue;
					if(debug)
                    Debugger.log("recursivelyProcess 1.3", "childName=" + child.name, LogType.DEBUG_MOBIUS);
                    
                    cName = child.name;
                    var adaptAttrs:Array = getAttributesFromMcName(cName, "scale");
                    var posAttrs:Array = getAttributesFromMcName(cName, "pos");
                    var cacheAttrs:Array = getAttributesFromMcName(cName, "cache");
					if(debug)
                    Debugger.log("recursivelyProcess 1.3.1", LogType.DEBUG_MOBIUS);
                    
                    if(adaptAttrs == null && posAttrs == null && cacheAttrs == null && 
                        child is DisplayObjectContainer)
                    {
						if(debug)
                        Debugger.log("recursivelyProcess 1.3.2", LogType.DEBUG_MOBIUS);
                        recursivelyProcess(child, symbolKey, scaleList, screenSize);
                        continue;
                    }
                    
					if(debug)
                    Debugger.log("recursivelyProcess 1.4", target.name, LogType.DEBUG_MOBIUS);
                    
                    //自适应的scale和postion要放到一起搞, 因为需要需要获取scale前的bounds
                    oriBounds = child.getBounds(target);
					if(debug)
                    Debugger.log("recursivelyProcess 1.5", oriBounds, LogType.DEBUG_MOBIUS);
                    
                    scaleObj = getSxSy(adaptAttrs[1], scaleList);
					if(debug)
                    Debugger.log("recursivelyProcess 1.6", scaleObj.sX, scaleObj.sY, LogType.DEBUG_MOBIUS);
                    
                    bmpMC = null;
                    //cache逻辑优先
                    if(cacheAttrs != null)
                    {
						if(debug)
                        Debugger.log("recursivelyProcess 1.7", "cacheAttrs != null", LogType.DEBUG_MOBIUS);
                        bmpMC = cacheSymbol(child, cacheAttrs, symbolKey, scaleObj.sX, scaleObj.sY);
                        if(bmpMC != null)
                        {
							if(debug)
                            Debugger.log("recursivelyProcess 1.8", "bmpMC != null", LogType.DEBUG_MOBIUS);
                            cacheDict[child] = bmpMC;
                        }
                    }
                    //如果cache成功(bmpMC != null), 则不走scale逻辑
                    if(adaptAttrs != null)
                    {
                        child.scaleX = scaleObj.sX;
                        child.scaleY = scaleObj.sY;
                    }
                    
                    posSymbol(child, posAttrs, oriBounds, child.getBounds(target), scaleList, screenSize);
                }//for
				if(debug)
                Debugger.log("recursivelyProcess 2", target.name, LogType.DEBUG_MOBIUS);
                
                //将cache过的mc替换称BmpMC
                for(var key:Object in cacheDict)
                {
                    child = key as MovieClip;
                    bmpMC = cacheDict[child];
                    if(child.parent != null)
                    {
						if(debug)
                        Debugger.log("replace bmpMC", child.name, LogType.DEBUG_MOBIUS);
                        child.parent.addChildAt(bmpMC, child.parent.getChildIndex(child));
                        bmpMC.x += child.getBounds(child.parent).x - bmpMC.getBounds(child.parent).x;
                        bmpMC.y += child.getBounds(child.parent).y - bmpMC.getBounds(child.parent).y;
                        child.parent.removeChild(child);
                        //可以用name索引到bmpMC.
                        bmpMC.name = child.name;
                    }
                }//for
				if(debug)
                Debugger.log("recursivelyProcess 3", target.name, LogType.DEBUG_MOBIUS);
            }catch(err:Error)
            {if(debug)
                Debugger.log("recursivelyProcess 4", err.message, LogType.DEBUG_MOBIUS);
            }
        }
        
        
        
        /**
         * rect2相对rect1的缩放数据. 
         * @param rect1
         * @param rect2
         * @return {vScale, hScale, maxScale, minScale}
         * 
         */    
        private static function getRectScale(rect1:Rectangle, rect2:Rectangle):Object
        {
            var sl:Object = {};
            sl.vScale = rect2.height / rect1.height;
            sl.hScale = rect2.width / rect1.width;
            sl.maxScale = sl.vScale > sl.hScale ? sl.vScale : sl.hScale;
            sl.minScale = sl.vScale < sl.hScale ? sl.vScale : sl.hScale;
            return sl;
        }
        
        
        
        private static function cacheSymbol(target:MovieClip,
                                            cacheAttrs:Array,
                                            symbolKey:String,
                                            sX:Number, sY:Number):BmpMC
        {
            var ret:BmpMC;
            var tName:String = target.name;
            var C:Class;
            
            if(cacheAttrs == null)
                return null;
            else if(cacheAttrs[1] == "mc")
                C = BmpMC;
            else if(cacheAttrs[1] == "toggle")
                C = BmpToggleBtn;
            else if(cacheAttrs[1] == "btn")
                C = BmpBtn;
            
            var ba:ByteArray = null;
            //存本地的文件名过滤掉"$"符号
            var fileName:String = symbolKey + "/" + tName.replace(/\$/g, "");
            var needSave:Boolean = (cacheAttrs.length >= 3 && cacheAttrs[2] == "local");
            //反序列化是否成功
            var deseSuccess:Boolean = false;
            
            if(needSave)
                ba = loadFromLocal(fileName);
            
            if(ba != null)
            {
                ret = new C(null, sX, sY);
                deseSuccess = ret.deserialize(ba, target);
            }
            
            if(!deseSuccess)
            {
                ret = new C(target, sX, sY);
                if(needSave)
                    saveToLocal(fileName, ret.serialize());
            }
            
            return ret;
        }
        
        
        private static function posSymbol(target:DisplayObjectContainer,
                                           posAttrs:Array,
                                           oriBounds:Rectangle,
                                           newBounds:Rectangle,
                                           sacleList:Object,
                                           screenSize:Rectangle):void
        {
            if(posAttrs == null)
                return;
            
            //var newBounds:Rectangle = target.getBounds(target);
			if(debug)
            trace("oriBounds =", oriBounds);
			if(debug)
            trace("newBounds =", newBounds);
            
            var obj:Object = getSxSy(posAttrs[1], sacleList);
            
            var dx:Number;
            var dy:Number;
            var disX:Number = 0;
            var disY:Number = 0;
            var ip4Rect:Rectangle = new Rectangle(0, 0, 960, 640);
            var dict:Object = {
                "1":["left", "top"],
                "2":["right", "top"],
                "3":["left", "bottom"],
                "4":["right", "bottom"]
            };
            var arr:Array = dict[posAttrs[2]];
            disX = ip4Rect[arr[0]] - oriBounds[arr[0]];
            disY = ip4Rect[arr[1]] - oriBounds[arr[1]];
            disX *= obj.sX;
            disY *= obj.sY;
            dx = disX - (screenSize[arr[0]] - newBounds[arr[0]]);
            dy = disY - (screenSize[arr[1]] - newBounds[arr[1]]);
			if(debug)
            trace(disX, disY, dx, dy);
            target.x -= dx;
            target.y -= dy;
			if(debug)
            trace("x=", target.x);
			if(debug)
            trace("y=", target.y);
			if(debug)
            trace("\n");
        }
        
        
        
        private static function getSxSy(attribute:String, scaleList:Object):Object
        {
            var sX:Number = 1.0;
            var sY:Number = 1.0;
            
            switch(attribute)
            {
                case "no":
                    sX = sY = 1.0;
                    break;
                case "h":
                    sX = sY = scaleList.hScale;
                    break;
                case "v":
                    sX = sY = scaleList.vScale;
                    break;
                case "min":
                    sX = sY = scaleList.minScale;
                    break;
                case "max":
                    sX = sY = scaleList.maxScale;
                    break;
                case "u":
                default:
                    sX = scaleList.hScale;
                    sY = scaleList.vScale;
                    break;
            }
            return {"sX":sX, "sY":sY};
        }
        
        
        /**
         * 从MC的name里, 分析出对应的key.
         *  
         * @param mcName e.g. "mc_cache$mc_scale$min_pos$u$1"
         * @param key
         * @return 
         * 
         */        
        private static function getAttributesFromMcName(mcName:String, key:String):Array
        {   
            //Debugger.log("getAttributesFromMcName 1", mcName, key, LogType.DEBUG_MOBIUS);
            var arr:Array = mcName.split("_");
            //Debugger.log("getAttributesFromMcName 2", arr.length, LogType.DEBUG_MOBIUS);
            var arr2:Array = null;
            var flg:Boolean = false;
            for each(var str:String in arr)
            {
                arr2 = str.split("$");
                if(arr2[0] == key)
                {
                    flg = true;
                    break;
                }
            }
			if(debug)
            Debugger.log("getAttributesFromMcName 3", flg, arr2.length, LogType.DEBUG_MOBIUS);
            
            if(!flg || arr2.length < 2)
                return null;
            
            return arr2;
        }
        
        
        private static function saveToLocal(key:String, value:ByteArray):void
        {
            var fs:FileStream = new FileStream();
            var file:File = File.applicationStorageDirectory.resolvePath("cachebmps/"+key + ".cache");
			if(debug)
			trace(file.nativePath);
            fs.open(file, FileMode.WRITE);
            fs.writeBytes(value);
        }
        
        
        private static function loadFromLocal(key:String):ByteArray
        {
            var fs:FileStream = new FileStream();
            var file:File = File.applicationStorageDirectory.resolvePath("cachebmps/"+key + ".cache");
			if(debug)
			trace(file.nativePath);
            if(!file.exists)
                return null;
            fs.open(file, FileMode.READ);
            var ret:ByteArray = new ByteArray();
            fs.readBytes(ret);
            return ret;
        }
    }
}