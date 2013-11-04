package com.snsapp.starling.display.effect
{
	import com.snsapp.starling.StarlingFactory;
	import com.snsapp.starling.texture.implement.BatchTexture;
	
	import sky.effect.FireFly;
	import sky.effect.NightLight;
	import sky.effect.NightMask;
	import sky.effect.NightMoon;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.extensions.PDParticleSystem;
	import starling.extensions.ParticleSystem;

	/**
	 * 夜晚效果
	 */
	public class NightEffect extends Sprite implements IDynamicEffect
	{
		public static const NAME:String = 'NIGHT';

		public static const NIGHT_COLOR:uint = 0x0;
		public static const NIGHT_MASK:String = 'night_mask';
		public static const MOON:String = 'night_moon';
		public static const LIGHT:String = 'night_light';
		public static const FIREFLY:String = 'night_fire_fly';

		private var _nightSky:Quad;
		private var _bacth:BatchTexture;
		private var _screenScale:Number;
		private var _align:Object;

		private var _nightMask:Image;

		/**萤火虫粒子效果**/
		private var _firefly:ParticleSystem;
		private static const FIRE_FLY_CONFIG:XML = <particleEmitterConfig>
				<texture name="drugs_particle.png"/>
				<sourcePosition x="0" y="0"/>
				<sourcePositionVariance x="0" y="0"/>
				<speed value="15"/>
				<speedVariance value="2"/>
				<particleLifeSpan value="15"/>
				<particleLifespanVariance value="10"/>
				<angle value="0"/>
				<angleVariance value="360"/>
				<gravity x="0" y="0"/>
				<radialAcceleration value="0.00"/>
				<tangentialAcceleration value="0.00"/>
				<radialAccelVariance value="0.00"/>
				<tangentialAccelVariance value="0.00"/>
				<startColor red="0.9" green="1" blue="0" alpha="0"/>
				<startColorVariance red="0.1" green="0" blue="0" alpha="0"/>
				<finishColor red="0" green="0" blue="0" alpha="0"/>
				<finishColorVariance red="0" green="0" blue="0" alpha="0"/>
				<maxParticles value="80"/>
				<startParticleSize value="15"/>
				<startParticleSizeVariance value="5"/>
				<finishParticleSize value="15"/>
				<FinishParticleSizeVariance value="5"/>
				<duration value="-1.00"/>
				<emitterType value="0"/>
				<maxRadius value="100.00"/>
				<maxRadiusVariance value="0.00"/>
				<minRadius value="0.00"/>
				<rotatePerSecond value="0.00"/>
				<rotatePerSecondVariance value="0.00"/>
				<blendFuncSource value="1"/>
				<blendFuncDestination value="1"/>
				<rotationStart value="0.00"/>
				<rotationStartVariance value="0.00"/>
				<rotationEnd value="0.00"/>
				<rotationEndVariance value="0.00"/>
			</particleEmitterConfig>

		public function NightEffect(screenScale:Number, batch:BatchTexture, align:Object)
		{
			super();
			this.touchable = false;
			_bacth = batch;
			_screenScale = screenScale;
			_align = align;
		}

		public function show():void
		{
			if (_align == null)
				return;

			if (_bacth == null)
			{
				_bacth = new BatchTexture(512, 128, false);
				_bacth.insertBmd(NightEffect.LIGHT, new NightLight, _screenScale, _screenScale, .5, .4);
				_bacth.insertBmd(NightEffect.MOON, new NightMoon, _screenScale, _screenScale);
				_bacth.insertDisplayObject(NightEffect.FIREFLY, new FireFly, _screenScale, _screenScale);
				_bacth.insertDisplayObject(NightEffect.NIGHT_MASK, new NightMask, _screenScale / 60, _screenScale / 60);
				_bacth.upload();
			}

			_nightMask = StarlingFactory.newImage(_bacth.getTexture(NIGHT_MASK));
			_nightMask.scaleX *= 60;
			_nightMask.scaleY *= 63;
			_nightMask.y = (_align['sceneHeight'] - _nightMask.height) / 2;
			addChild(_nightMask);

			if (_align['firefly'] != undefined)
			{
				FIRE_FLY_CONFIG.sourcePositionVariance.@x = _align['firefly'].width / 2;
				FIRE_FLY_CONFIG.sourcePositionVariance.@y = _align['firefly'].height / 2;
				_firefly = new PDParticleSystem(FIRE_FLY_CONFIG, _bacth.getTexture(FIREFLY).texture);
				_firefly.emitterX = _align['firefly'].x + _align['firefly'].width / 2;
				_firefly.emitterY = _align['firefly'].y + _align['firefly'].height / 2;
				_firefly.start();
				addChild(_firefly);
				Starling.juggler.add(_firefly);
				delete _align['firefly'];
			}

			delete _align['sceneWidth'];
			delete _align['sceneHeight'];
			var image:Image;
			for (var key:String in _align)
			{
				image = StarlingFactory.newImage(_bacth.getTexture(key));
				image.x = _align[key].x * _screenScale, image.y = _align[key].y * _screenScale;
				addChild(image);
			}
		}

		public function get type():String
		{
			return NAME;
		}

		override public function dispose():void
		{
			if (this.parent)
				this.parent.removeChild(this);
			if (this._nightSky.parent)
				this._nightSky.parent.removeChild(this._nightSky);
			if (_firefly)
			{
				_firefly.stop(true);
				removeChild(_firefly);
				Starling.juggler.remove(_firefly);
			}
			super.dispose();
		}
	}
}
