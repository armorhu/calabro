package com.qzone.qfa.managers
{
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.utils.Dictionary;
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;

    /**
     * 管理弹窗. 主要作用有:<br/>
     * .弹窗.<br/>
     * .监听窗体事件的Event.CLOSE事件, 触发关闭逻辑.<br/>
     * .避免同时弹出多个系统弹窗. 允许同时多个自定义弹窗.(不确定是否要实现)<br/>
     * .系统弹框的队列功能.(不确定是否要实现)<br/>
     * 
     * </p>
     * 区分系统弹窗和自定义弹窗.<br/>
     * 其主要区别是在于系统弹窗可以调用直接方法弹出, 而自定义弹窗需要先生成窗体实例.
     * 
     * @author mobiuschen
     * 
     */    
    public class WindowManager
    {
        /**
         * 所有窗体的容器 
         */        
        private var _container:DisplayObjectContainer;

        /**
         * 系统弹框的类. 
         */        
        private var _sysDialogClass:Class;
        
        /**
         * id -> 正在显示的窗体 
         */        
        private var _dialogDict:Dictionary;
        
        /**
         * 用于分配窗体id. 递增. 
         */        
        private var _nextID:int = 0;
        
        
        public function WindowManager(container:DisplayObjectContainer, sysDialog:DisplayObject)
        {
            if(container == null || sysDialog == null)
            {
                throw new ArgumentError("Arguments Error.");
                return;
            }
            
            _container = container;
            //保证了获取到的类是继承自DisplayObject
            _sysDialogClass = getDefinitionByName(getQualifiedClassName(sysDialog)) as Class;
            
            _dialogDict = new Dictionary();
            //起始值
            _nextID = 1;
        }
       
        
        /**
         * 显示自定义弹窗
         * 
         * @param dialog 窗体实例
         * @param modal
         * @param params
         * 
         * @return 窗体id.
         */        
        public function showCustomDialog(dialog:DisplayObject, 
                                           modal:Boolean = true, 
                                           params:Object = null):int
        {
            if(dialog.hasOwnProperty("setData"))
                dialog["setData"](params);
            dialog.addEventListener(Event.CLOSE, onDialogWantClose);
            _dialogDict[_nextID] = dialog;
            _container.addChild(dialog);
            
            return _nextID++;
        }
        
        
        /**
         * 根据id关闭弹窗. 
         * @param id
         * @return 是否删除成功.
         * 
         */        
        public function closeDialog(id:int):Boolean
        {
            if(_dialogDict[id] == null)
                return false;
            
            var dialog:DisplayObject = _dialogDict[id];
            if(dialog == null || !_container.contains(dialog))
                return false;
            
            delete _dialogDict[id];
            dialog.removeEventListener(Event.CLOSE, onDialogWantClose);
            _container.removeChild(dialog);
            return true;
        }
        
        
        /**
         * 显示系统框
         * @return 返回根据参数构造的系统框对象
         */
        public function showSysDialog(modal:Boolean = true, params:Object = null):int
        {
            var dialog:DisplayObject = new _sysDialogClass() as DisplayObject;
            return showCustomDialog(dialog, modal, params);
        }
        
        
        /**
         * 根据id获取DisplayObject
         * @param id
         * @return 
         * 
         */        
        public function getDialogByID(id:int):DisplayObject
        {
            return _dialogDict[id];
        }
        
        
        /**
         * 获取最上层的窗体 
         * @return 可能为null.
         * 
         */        
        public function getTopDialogID():int
        {
           var topID:int = -1;
           var topIdx:int = -1;
           for(var key:Object in _dialogDict)
           {
               var d:DisplayObject = _dialogDict[key];
               if(topIdx < _container.getChildIndex(d))
               {
                   topID = int(key);
               }
           }
           
           return topID;
        }
        
        
        private function onDialogWantClose(evt:Event):void
        {
            var crtTarget:DisplayObject = evt.currentTarget as DisplayObject;
            for(var key:Object in _dialogDict)
            {
                if(crtTarget == _dialogDict[key])
                    closeDialog(int(key));
            }
        }
    }
}

