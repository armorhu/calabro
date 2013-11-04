package com.snsapp.mobile.view.bmpLib
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	/**################################
	 * 
	 * @author sevencchen
	 * @2012-9-9
	 * ###################################
	 */
	
	public class BitmapMC extends Sprite
	{
		private var _mc:MovieClip;
		private var _scale:Number;
		private var _bmp:Bitmap;
		private var _bmd:Vector.<BitmapData>=new Vector.<BitmapData>;
		private var _currentFrame:int;
		private var _loop:Boolean;
		
		public function BitmapMC(mc:MovieClip,scale:Number=1)
		{
			_mc = mc;
			_scale = scale;
			
			var rect:Rectangle = _mc.getBounds(_mc.parent);
			this.name =  mc.name;
			this.x = rect.x*_scale;
			this.y = rect.y*_scale;
			
			_bmp = new Bitmap();
			_bmp.smoothing = true;
			addChild(_bmp);
			
			for (var i:int,len:int=_mc.totalFrames;i<len;i++)
			{
				_mc.gotoAndStop(i+1);
				var mcRect:Rectangle = _mc.getBounds(_mc);
				var maxt:Matrix = new Matrix;
				maxt.scale(_scale,_scale);
				maxt.translate(-mcRect.x*_scale,-mcRect.y*_scale);
				var bmd:BitmapData = new BitmapData(mcRect.width*_scale,mcRect.height*_scale,true,0);
				bmd.drawWithQuality(_mc,maxt,null,null,null,true,StageQuality.HIGH);
				_bmd.push(bmd);
			}
			gotoAndStop(1);
		}
		public function gotoAndStop(frameId:uint):void
		{
			if(frameId>_mc.totalFrames)
				return;
			_bmp.bitmapData = _bmd[frameId-1];
			_currentFrame = frameId;
		}
		public function play(loop:Boolean=true):void
		{
			_loop = loop;
			_currentFrame = 1;
			this.addEventListener(Event.ENTER_FRAME,loopHandler);
		}
		private function loopHandler(e:Event):void{
			_bmp.bitmapData = _bmd[_currentFrame-1];
			
			if(_currentFrame == _bmd.length){
				_currentFrame=0;
				if(!_loop)
					stop();
			}
			_currentFrame++;
		}
		public function stop():void
		{
			if(this.hasEventListener(Event.ENTER_FRAME))
				this.removeEventListener(Event.ENTER_FRAME,loopHandler);
			gotoAndStop(1);
		}
		public function destory():void
		{
			if(_bmd)
				_bmd = null;
			if(this.parent)
				this.parent.removeChild(this);
		}

		public function get currentFrame():int
		{
			return _currentFrame;
		}

	}
}