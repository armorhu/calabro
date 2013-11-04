package com.snsapp.mobile.view
{
    import com.snsapp.mobile.view.bitmapclip.BitmapClipData;
    import com.snsapp.mobile.view.bitmapclip.BitmapFrame;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.display.StageQuality;
    import flash.events.Event;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.ByteArray;
    
    /**
     *  
     * @author mobiuschen
     * 
     */    
    public class BmpMC extends Sprite
    {
        static public var IS_TEST:Boolean = false;
        
        static private const VERSION:Number = 1.1;
        
        //----------------------------------------------------------------------
        //
        //  Variables
        //
        //----------------------------------------------------------------------
        
        /**
         * 位图序列 
         */        
        private var _frames:Vector.<BitmapData>;
        
        /**
         * 位图序列对应的位置序列 
         */        
        private var _pos:Vector.<Point>;
        
        /**
         * label -> frame
         */        
        private var _labelDict:Object;
        
        /**
         * 缩放比例 
         */        
        private var _scaleX:Number;
        private var _scaleY:Number;
        
        
        /**
         * 源MC 
         */        
        private var _src:MovieClip;
        
        
        /**
         * 当前帧, 范围时:[1, n] 
         */        
        private var _crtFrame:int = 1;
        
        
        private var _bmp:Bitmap;
        
        
        /**
         * 是否正在播放
         */        
        private var _isPlaying:Boolean = false;
        
        /**
         * 终止帧.<br/>
         * 如果是-1, 则循环播放. 
         */
        private var _endFrame:int = 1;
        
        
        /**
         * 原型: function playEndCallback(targetBmpMC:BmpMC):void
         */        
        private var _playEndCallback:Function = null;
        
        
        //----------------------------------------------------------------------
        //
        //  Constructor
        //
        //----------------------------------------------------------------------

        /**
         *  
         * @param src
         * @param allScaleORSX 当sY == NaN时, scaleX与scaleY都取这个值; 否则标识scaleX.
         * @param sY 当这个值 != NaN时, 表示scaleY. 
         * 
         */        
        public function BmpMC(src:MovieClip, allScaleOrSX:Number = 1, sY:Number = NaN)
        {
            super();
            
            _src = src;
            
            _scaleX = allScaleOrSX;
            _scaleY = isNaN(sY) ?  allScaleOrSX : sY;
            
            cache();
            
            _bmp = new Bitmap();
            addChild(_bmp);
            gotoAndStop(_crtFrame);
        }
        
        
        //----------------------------------------------------------------------
        //
        //  Public methods
        //
        //----------------------------------------------------------------------
        
        
        /**
         * 销毁 
         * 
         */        
        public function destroy():void
        {
            stop();
            _playEndCallback = null;
            clearCache();
        }
        
        
        public function recache():void
        {
            cache();
            gotoAndStop(_crtFrame);
        }
        
        
        /**
         * 
         * @frame Can be frame number or label string. 
         */    
        public function gotoAndStop(frame:Object, clearPlayEnd:Boolean = false):void
        {
            if(_frames == null)
                return;
            
            if(frame is int)
                _crtFrame = int(frame);
            else if(frame is String && _labelDict.hasOwnProperty(frame))
                _crtFrame = _labelDict[frame];
            else
                return;
            
            var idx:int = _crtFrame - 1;
            _bmp.bitmapData = _frames[idx];
            _bmp.x = _pos[idx].x * _scaleX;
            _bmp.y = _pos[idx].y * _scaleY;
            
            if(clearPlayEnd)
                _playEndCallback = null;
        }
        
        
        /**
         *  
         * @param frame 起始帧
         * @param endFrame 到哪一帧停止播放(可以是帧数或者label). 
         * 如果是-1, 则循环播放. 大于或等于totalFrames, 则只播放到最后一帧.
         * @param playEndCallback 原型: function playEndCallback(targetBmpMC:BmpMC):void
         * 
         * 
         */        
        public function gotoAndPlay(frame:Object, endFrame:Object = -1, playEndCallback:Function = null):void
        {
            if(_isPlaying)
                stop();

            if(frame is int)
                _crtFrame = int(frame);
            else if(frame is String && _labelDict.hasOwnProperty(frame))
                _crtFrame = _labelDict[frame];
            else
                return;
            
            gotoAndStop(_crtFrame);
            play(endFrame, playEndCallback);
        }
        
        
        
        /**
         * 循环播放 
         * @param endFrame 到哪一帧停止播放(可以是帧数或者label). 
         * 如果是-1, 则循环播放. 大于或等于totalFrames, 则只播放到最后一帧.
         * @param playEndCallback 原型: function playEndCallback(targetBmpMC:BmpMC):void
         */        
        public function play(endFrame:Object = -1, playEndCallback:Function = null):void
        {
            if(_isPlaying)
                stop();
            
            if(endFrame is String) //endFrame is label.
                _endFrame = _labelDict.hasOwnProperty(endFrame) ? _labelDict[endFrame] : -1;
            else if(endFrame is int) //endFrame is frame number.
                _endFrame = endFrame > _frames.length ? _frames.length : int(endFrame);
            else
                _endFrame = -1;
            
            _isPlaying = true;
            _playEndCallback = playEndCallback;
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        
        /**
         * stop时会清空playEndCallback
         */        
        public function stop():void
        {
            _endFrame = -1;
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            _isPlaying = false;
        }
        
        
        public function getTotalFrames():int
        {
            if(_frames == null)
                return 0;
            return _frames.length;
        }
        
        
        /**
         * To do... 
         * @return 
         * 
         */   
        public function getCrtFrame():int
        {
            return _crtFrame;
        }
        
        
        /**
         * To do... 
         * @return 
         * 
         */        
        public function getCrtLabel():String
        {
            var f:int = 0;
            var selectedLabel:String = null;
            for(var l:String in _labelDict)
            {
                if(_labelDict[l] > _crtFrame || f > _labelDict[l])
                    continue;
                f = _labelDict[l];
                selectedLabel = l;
            }
            
            return selectedLabel;
        }
        
        
        /**
         * 是否正在播放. 
         * @return 
         * 
         */        
        public function isPlaying():Boolean
        {
            return _isPlaying;
        }
        
        
        /**
         * 序列化 
         * @return 
         * 
         */        
        public function serialize():ByteArray 
        {
            var ba:ByteArray = new ByteArray();
            
            ba.writeFloat(VERSION);
            
            //scale
            ba.writeFloat(_scaleX);
            ba.writeFloat(_scaleY);
            
            ba.writeInt(_frames.length);
            
            var rect:Rectangle = new Rectangle();
            var bpdBytes:ByteArray;
            for each(var bpd:BitmapData in _frames)
            {
                rect.width = bpd.width;
                rect.height = bpd.height;
                bpdBytes = bpd.getPixels(rect);
                ba.writeUnsignedInt(bpdBytes.length);
                ba.writeFloat(rect.width);
                ba.writeFloat(rect.height);
                ba.writeBytes(bpdBytes, 0, bpdBytes.length);
                ////trace(bpdBytes.length, rect.width, rect.height);
            }
            
            ba.writeUnsignedInt(_pos.length);
            for each(var p:Point in _pos)
            {
                ba.writeFloat(p.x);
                ba.writeFloat(p.y);
            }
            
            var tempBa:ByteArray = new ByteArray();
            var count:int = 0;
            for(var key:String in _labelDict)
            {
                var f:int = _labelDict[key];
                tempBa.writeUTF(key);
                tempBa.writeInt(f);
                count++;
                //trace(key, f);
            }
            //trace("count", count);
            ba.writeInt(count);
            ba.writeBytes(tempBa);
            
            //trace("serialize end.......");
            
            ba.position = 0;
            return ba;
        }
        
        
        /**
         * 反序列化 
         * @param value
         * @return 
         * 
         */        
        public function deserialize(value:ByteArray, src:MovieClip):Boolean
        {
            _src = src;
            
            var ver:Number = value.readFloat();
            if(ver != VERSION)
                return false;

            value.position = 0;
            _scaleX = value.readFloat();
            _scaleY = value.readFloat();
            
            
            _frames = new Vector.<BitmapData>();
            var framesLen:int = value.readInt();
            var bpdLen:uint;
            var rect:Rectangle = new Rectangle();
            for(var i:int = 0; i < framesLen; i++)
            {
                var bpdData:ByteArray = new ByteArray();
                bpdLen = value.readUnsignedInt();
                rect.width = value.readFloat();
                rect.height = value.readFloat();
                value.readBytes(bpdData, 0, bpdLen);
                var bpd:BitmapData = new BitmapData(rect.width, rect.height, true, 0);
                bpd.setPixels(rect, bpdData);
                _frames.push(bpd);
            }
            
            _pos = new Vector.<Point>();
            var posLen:int = value.readUnsignedInt();
            for(i = 0; i < posLen; i++)
            {
                var p:Point = new Point();
                p.x = value.readFloat();
                p.y = value.readFloat();
                ////trace(p);
                _pos.push(p);
            }
            
            _labelDict = {};
            var labelsNum:int = value.readInt();
            for(i = 0; i < labelsNum; i++)
            {
                var label:String = value.readUTF();
                var frame:int = value.readInt();
                ////trace(label, frame);
                _labelDict[label] = frame;
            }
            
            gotoAndStop(_crtFrame);
            
            return true;
        }
        
        
        
        public function toBitmapFrames():Vector.<BitmapFrame>
        {
            var result:Vector.<BitmapFrame> = new Vector.<BitmapFrame>();
            if(_frames == null || _frames.length == 0)
                return result;
            
            var bf:BitmapFrame;
            var bd:BitmapData;
            for(var i:int = 0, n:int = _frames.length; i < n; i++)
            {
                //1应该才是正确的, 但是在SingleTexture中, 将frameX与privotX搞混了, 因此使用2.
                //1.
                //bf = new BitmapFrame(_frames[i], _pos[i].x, _pos[i].y, 1, 1);
                //2.
                bf = new BitmapFrame(_frames[i], -_pos[i].x, -_pos[i].y, 1, 1);
                result.push(bf);
            }
            
            return result;
        }
        
        
        //----------------------------------------------------------------------
        //
        //  Internal methods 
        //
        //----------------------------------------------------------------------
        
        protected function cache():void
        {
            if(_src == null)
                return;
            
            clearCache();
            
            _frames = new Vector.<BitmapData>();
            _pos = new Vector.<Point>();
            _labelDict = {};
            
            _src.stop();
            var label:String
            var bpd:BitmapData;
            var bounds:Rectangle;
            var mtx:Matrix;
            var n:int = _src.totalFrames;
            for(var i:int = 0; i < n; i++)
            {
                _src.gotoAndStop(i + 1);
                bounds = _src.getBounds(null);
                
                if(bounds.width < 1 || bounds.height < 1)
                {
                    //处理空帧的情况
                    bpd = new BitmapData(1, 1, true, 0);
                }
                else
                {
                    mtx = new Matrix();
                    mtx.translate(-bounds.x, -bounds.y);
                    mtx.scale(_scaleX, _scaleY);
                    bpd = new BitmapData(bounds.width * _scaleX, bounds.height * _scaleY, true, 0xff0000 + (IS_TEST ? 0x33000000 : 0));
                    bpd.drawWithQuality(_src, mtx, null, null, null, false, StageQuality.HIGH);
                }
                _pos.push(new Point(bounds.x, bounds.y));
                _frames.push(bpd);
                if(_src.currentFrameLabel != null)
                    _labelDict[_src.currentFrameLabel] = i + 1;
            }
        }
        
        
        protected function clearCache():void
        {
            stop();
            
            for each(var bpd:BitmapData in _frames)
            {
                bpd.dispose();
            }
                
            _pos = null;
            _frames = null;
        }
        
        
        private function onEnterFrame(evt:Event):void
        {
            if(_crtFrame == _endFrame)
            {
                stop();
                var tempFunc:Function = _playEndCallback;
                _playEndCallback = null;
                if(tempFunc != null)
                    tempFunc(this);
                return;
            }
            
            if(_crtFrame + 1 > _frames.length)
                _crtFrame = 1;
            else
                _crtFrame++;
            gotoAndStop(_crtFrame);
        }
        
    }//class 
}//package 