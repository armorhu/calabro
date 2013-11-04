package com.snsapp.mobile.utils
{

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	/**################################
	 * @SoundHelper
	 * @author sevencchen
	 * @2012-9-6
	 * ###################################
	 */

	public class SoundHelper
	{
		public static const LOGIN:int = 1;
		public static const MAIN:int = 2;
		private var _musicList:Dictionary = new Dictionary;
		private var _musicPlayer:Sound;
		private var _musicCL:SoundChannel;
		private var _postion:Number;
		private var _currentMusic:String;


		public static const FLEX:int = 1;
		public static const OP:int = 1;
		private var _soundList:Dictionary = new Dictionary;
		private var _soundPlayer:Sound;
		private var _soundCL:SoundChannel;

		public function SoundHelper()
		{
			_musicCL = new SoundChannel;
			_soundCL = new SoundChannel;
		}

		public function startPlayMusic(fileName:String):void
		{
			var musicOn:Boolean = Cookies.getObject("musicOn");
			if (musicOn)
			{
				stopPlayMusic();
				if(fileName != "") _currentMusic = fileName;
				playMusic(0);
			}
		}

		public function stopPlayMusic():void
		{
			_musicCL.stop();
			if (_musicPlayer != null)
			{
				try
				{
					_musicPlayer.close();
				} 
				catch(error:Error) 
				{
					
				}
				_musicPlayer = null;
			}
		}

		public function pauseMusic():void
		{
			_postion = _musicCL.position;
			stopPlayMusic();
		}

		public function continueMusic():void
		{
			if (_musicPlayer == null && Cookies.getObject("musicOn"))
			{
				playMusic(_postion);
			}
		}

		private function playMusic(postion:Number):void
		{
			if (_musicPlayer == null && _currentMusic != null && _currentMusic != '')
			{
				_musicPlayer = new Sound;
				_musicPlayer.addEventListener(Event.COMPLETE, loadMusicComplete);
				_musicPlayer.addEventListener(IOErrorEvent.IO_ERROR, loadMusicError);
				_musicPlayer.addEventListener(IOErrorEvent.DISK_ERROR, loadMusicError);
				_musicPlayer.load(new URLRequest(_currentMusic));
			}
			function loadMusicComplete(e:Event):void
			{
				if (_musicPlayer)
				{
					_musicCL.stop();
					_musicCL = _musicPlayer.play(postion, int.MAX_VALUE);
					_postion = 0;
				}
			}

			function loadMusicError(e:IOErrorEvent):void
			{
				trace(e);
			}
		}


		public function setMusic(onOff:Boolean, fileName:String):void
		{
			Cookies.setObject("musicOn", onOff);
			if (onOff)
				startPlayMusic(fileName);
			else
				stopPlayMusic();
		}


		public function playSound(fileName:String):void
		{
			var soundOn:Boolean = Cookies.getObject("soundOn");
			if (soundOn)
			{
				var soundPlayer:Sound = new Sound;
				soundPlayer.addEventListener(Event.COMPLETE, loadSoundComplete);
				soundPlayer.addEventListener(IOErrorEvent.IO_ERROR, loadSoundError);
				soundPlayer.addEventListener(IOErrorEvent.DISK_ERROR, loadSoundError);
				soundPlayer.load(new URLRequest(fileName));
				function loadSoundComplete(e:Event):void
				{
					_soundCL = soundPlayer.play();
				}
				function loadSoundError(e:IOErrorEvent):void
				{
					trace(e);
				}
			}
		}

		public function setSound(onOff:Boolean):void
		{
			Cookies.setObject("soundOn", onOff);
		}

		public function destory():void
		{
			_musicCL.stop();
			_musicPlayer = null;
			_soundCL.stop();
			_soundPlayer = null;
		}
	}
}
