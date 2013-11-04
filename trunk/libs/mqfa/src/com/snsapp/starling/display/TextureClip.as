package com.snsapp.starling.display
{
	import com.snsapp.starling.texture.implement.SingleTexture;
	
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;
	import starling.textures.Texture;

	/**
	 * GPU加速的动画。
	 * @author hufan
	 */
	public class TextureClip extends Image implements IAnimatable
	{
		private var _textures:Vector.<SingleTexture>;
		private var _currentFrame:int;
		private var _timeDelay:Number;
		private var _fps:int;
		private var _timePast:Number;
		private var _script:Vector.<Function>;

		public function TextureClip(textures:Vector.<SingleTexture>, $fps:int = 12)
		{
			if (textures && textures.length > 0)
				var temp:Texture = textures[0].texture;
			super(temp);
			_textures = textures;
			_currentFrame = 0;
			_script = new Vector.<Function>();
			_script.length = textures.length;
			_script.fixed = true;
			fps = $fps;
			_timePast = 0;
			updateImage();
			play();
		}

		public function set fps(value:int):void
		{
			_fps = value;
			_timeDelay = 1 / _fps;
		}

		public function get fps():int
		{
			return _fps;
		}

		public function advanceTime(time:Number):void
		{
			_timePast += time;
			if (_timePast >= _timeDelay)
			{
				if (_currentFrame == totalframes - 1)
				{
					dispatchEventWith(Event.COMPLETE);
					_currentFrame = 0;
				}
				else
					_currentFrame++;

				if (this.stage != null)
					updateImage();
			}
		}

		private function updateImage():void
		{
			if (!_textures)
				return;

			_timePast = 0;
			this.texture = _textures[_currentFrame].texture;
			this.width = this.texture.width * _textures[_currentFrame].scaleX;
			this.height = this.texture.height * _textures[_currentFrame].scaleY;
			/**
			 * 非常重要,_image在实际渲染时会将注册点与scale参数相乘。
			 * 所以，为了实际的设置，需要这边先除一次
			 * **/
			this.pivotX = _textures[_currentFrame].pivotX * _textures[_currentFrame].scaleX / this.scaleX;
			this.pivotY = _textures[_currentFrame].pivotY * _textures[_currentFrame].scaleY / this.scaleY;
			if (_script[_currentFrame] != null)
				_script[_currentFrame]();
		}

		public function get totalframes():int
		{
			return _textures.length;
		}

		public function addFrameScript(frame:int, script:Function):void
		{
			if (frame < 0 || frame >= _textures.length)
				return;
			_script[frame - 1] = script;
		}

		public function gotoAndPlay(frame:int):void
		{
			if (frame < 1)
				frame = 1;
			else if (frame > totalframes)
				frame = totalframes;
			_currentFrame = frame - 1;
			updateImage();
			play();
		}

		public function gotoAndStop(frame:int):void
		{
			if (frame < 1)
				frame = 1;
			else if (frame > totalframes)
				frame = totalframes;
			_currentFrame = frame - 1;
			updateImage();
			stop();
		}

		public function get currentframe():int
		{
			return _currentFrame + 1;
		}

		public function play():void
		{
			Starling.juggler.add(this);
		}

		public function stop():void
		{
			Starling.juggler.remove(this);
		}

		public override function dispose():void
		{
			stop();
			_textures = null;
			_script = null;
			super.dispose();
		}

		public function get textures():Vector.<SingleTexture>
		{
			return _textures;
		}
	}
}
