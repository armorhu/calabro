package com.qzone.qfa.debug
{
    import com.snsapp.mobile.StageInstance;
    import com.snsapp.mobile.utils.MobileScreenUtil;
    
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.text.StyleSheet;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    
    /**
     * 分类显示Log信息的组件。
     *  
     * @author mobiuschen
     * 
     */    
    public class DarkFog extends Sprite implements IConsoleWindow
    {
        /**
         * 整个组件的宽度，除了弹出按钮。
         * for iphone4 
         */        
        static private const W:Number = 960;
		
		static private const H:Number = 400;
        
        /**
         * 显示Log部分的宽度 
         */        
        static private const TEXT_W:Number = 900;

        
        /**
         * 用于显示Log信息 
         */        
        private var _textField:TextField;
        
        /**
         * 摆放各种Tab
         */        
        private var _tabContainer:Sprite;
        
        /**
         * 弹出按钮
         */        
        private var _toggleBtn:Sprite;
        
        /**
         * Log的数据源
         */        
        private var _logBatch:LogBatch;
        
        /**
         * 当前选中的LogType 
         */        
        private var _crtType:String;
        
        
        /**
         *  view层失效，等待在下一个enterFrame更新
         */        
        private var _viewInvalid:Boolean = false;
        
        /**
         * 相对于iPhone4的缩放
         */        
        private var _scaleToIP4:Number = 1.0;
        
        
        public function DarkFog()
        {
            super();
            
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }
        
        protected function onAddedToStage(e:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            initSkin();
        }
        
        protected function initSkin():void
        {
            //960 is the width of ip4.
			var rect:Rectangle = MobileScreenUtil.getScreenRectInLandScape(StageInstance.stage);
            _scaleToIP4 = rect.width / 960;
            this.scaleX = this.scaleY = _scaleToIP4;
            var h:Number = 400;
            
            var txtStyle:StyleSheet = new StyleSheet();
            txtStyle.setStyle("p", {fontFamily: "Lucida Sans Unicode", fontSize: 13, color: "#00FF00"});
            txtStyle.setStyle(".t", {leading: -20});
            txtStyle.setStyle(".m", {marginLeft: 90});
			
            var tf:TextField;
            tf = new TextField();
            tf.height = h - tf.y;
            tf.width = TEXT_W;
            tf.multiline = true;
            tf.wordWrap = true;
            tf.styleSheet = txtStyle;
            /*tf.border = true;
            tf.borderColor = 0xFF0000;*/
            _textField = tf;
            addChild(_textField);
            
            createTabs();
            
            this.graphics.clear();
            this.graphics.beginFill(0, 0.5);
            this.graphics.drawRoundRect(0, 0, W, h, 10, 10);
            this.graphics.endFill();
            
            _toggleBtn = new Sprite();
            _toggleBtn.graphics.clear();
            _toggleBtn.graphics.beginFill(0, 0.5);
            _toggleBtn.graphics.drawRect(0, 0, 100, 60);
            _toggleBtn.graphics.endFill();
            _toggleBtn.x = TEXT_W*.6 + _toggleBtn.width;
            _toggleBtn.y = h;
            addChild(_toggleBtn);
            _toggleBtn.addEventListener(MouseEvent.CLICK, toggle);
            
            this.y = -H * _scaleToIP4;
        }
        
        
        public function setLogBatch(value:LogBatch):void
        {
            _logBatch = value;
        }
        
        
        public function update():void
        {
            setViewInvalid();
        }
        
        public function isHidden():Boolean
        {
            return this.y == -H*_scaleToIP4;
        }
        
        public function hide():void
        {
            if (this.parent)
            {
                this.stage.focus = this.stage
                this.parent.removeChild(this);
            }
        }
        
        public function show():void
        {
            if (this.y == 0)
                this.y += H * _scaleToIP4;
        }
        
        
        private function createTabs():void
        {
            _tabContainer = new Sprite();
            var btn:Sprite;
            var w:Number, h:Number;
            for(var i:int = 0, n:int = LogType.ALL_TYPES.length; i < n; i++)
            {
                btn = createBtn(String(LogType.ALL_TYPES[i]).slice(0, 3).toUpperCase());
                w = btn.width;
                h = btn.height;

                //窗口右侧
                btn.x = TEXT_W;
                btn.y = i * (h + 15) + 10;
                
                btn.name = LogType.ALL_TYPES[i];
                btn.addEventListener(MouseEvent.CLICK, onClickTab);
                _tabContainer.addChild(btn);
            }
            addChild(_tabContainer);
        }
        
        
        
        private function createBtn(txt:String):Sprite
        {
            var btn:Sprite = new Sprite();
            var tf:TextField = new TextField();
            var format:TextFormat = new TextFormat(null, 16, 0xffffff);
            format.align = TextFormatAlign.CENTER;
            tf.defaultTextFormat = format;
            tf.background = true;
            tf.backgroundColor = 0xAAAAAA;
            tf.text = txt;
            tf.width = Math.ceil(tf.textWidth / 50) * 50;
            tf.height = 25;
            btn.addChild(tf);
            btn.mouseChildren = false;
            return btn;
        }
        
        
        /**
         * 标识当前的view无效, 在下一帧里延迟渲染. 
         * 
         */        
        private function setViewInvalid():void
        {
            if(_viewInvalid)
                return;
            
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            _viewInvalid = true;
        }
        
        
        private function onClickTab(evt:MouseEvent):void
        {
            var tabName:String = evt.currentTarget.name;
            _crtType = evt.currentTarget.name;
            Debugger.log("Click log tab", _crtType, LogType.USER_ACTION);
            setViewInvalid();
            
            var btn:Sprite;
            for(var i:int = 0, n:int = _tabContainer.numChildren; i < n; i++)
            {
                btn = _tabContainer.getChildAt(i) as Sprite;
                if(btn == evt.currentTarget)
                    btn.x = W - btn.width - 20;
                else
                    btn.x = W - btn.width;
            }
        }
        
        
        /**
         * 
         * @param e
         * 
         */        
        private function toggle(e:Event):void
        {
            if (this.y == 0)
                this.y -= H * _scaleToIP4;
            else
                this.y += H * _scaleToIP4;
        }
        
        
        /**
         *  
         * @param evt
         * 
         */        
        private function onEnterFrame(evt:Event):void
        {
            if(!_viewInvalid)
                return;
            
            if(_logBatch == null)
                return;
            
            var vec:Vector.<LogEntity>;
            if(_crtType == null || _crtType == "")
                vec = _logBatch.getAllLogs();
            else
                vec = _logBatch.getLogsByType(_crtType);
            
            _textField.htmlText = vec != null ? vec.join("") : "";
            _textField.scrollV = _textField.maxScrollV;
            
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            
            _viewInvalid = false;
        }
        
    }
}
