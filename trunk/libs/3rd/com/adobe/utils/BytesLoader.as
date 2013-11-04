package com.adobe.utils {
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;

    public class BytesLoader extends Sprite {

        private var _SECURITY_ERROR:Function;
        private var _PROGRESS:Function;
        private var _urlStream:URLStream;
        private var _COMPLETE:Function;
        private var _IO_ERROR:Function;
        private var _urlRequest:URLRequest;

        public function BytesLoader(result:Function=null, fault:Function=null, progress:Function=null){
            _urlStream = new URLStream();
            _urlRequest = new URLRequest();
            super();
            if ((result is Function)){
                _COMPLETE = result;
            };
            if ((fault is Function)){
                _IO_ERROR = fault;
                _SECURITY_ERROR = fault;
            };
            if ((progress is Function)){
                _PROGRESS = progress;
            };
            configureListeners(_urlStream);
        }
        public function set method(v:String):void{
            _urlRequest.method = v;
        }
        public function send():void{
            sendToURL(_urlRequest);
        }
        public function get target():URLStream{
            return (this._urlStream);
        }
        public function get contentType():String{
            return (_urlRequest.contentType);
        }
        public function set data(v:*):void{
            _urlRequest.data = v;
        }
        public function set url(v:String):void{
            _urlRequest.url = v;
        }
        public function get method():String{
            return (_urlRequest.method);
        }
        public function load(url:String=null):void{
            if (url){
                _urlRequest.url = url;
           		_urlStream.load(_urlRequest);
            }
        }
        public function set contentType(v:String):void{
            _urlRequest.contentType = v;
        }
        public function get url():String{
            return (_urlRequest.url);
        }
        public function sendAndLoad(url:String=null):void{
            this.load(url);
        }
        public function close():void{
            _urlStream.close();
        }
        private function configureListeners(dispatcher : IEventDispatcher):void{
            if (_COMPLETE != null){
                dispatcher.addEventListener(Event.COMPLETE, _COMPLETE);
            }
            if (_IO_ERROR != null){
                dispatcher.addEventListener(IOErrorEvent.IO_ERROR, _IO_ERROR);
            }
            if (_PROGRESS != null){
                dispatcher.addEventListener(ProgressEvent.PROGRESS, _PROGRESS);
            }
            if (_SECURITY_ERROR != null){
                dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _SECURITY_ERROR);
            }
        }

    }
}