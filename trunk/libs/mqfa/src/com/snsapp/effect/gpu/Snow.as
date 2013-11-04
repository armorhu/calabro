package com.snsapp.effect.gpu
{
	import starling.display.Quad;
	import starling.extensions.PDParticleSystem;
	import starling.textures.Texture;

	/**
	 * 下雪效果
	 */
	public class Snow extends PDParticleSystem
	{
		private const config:XML = <particleEmitterConfig>
				<texture name="drugs_particle.png"/>
				<sourcePosition x="0" y="0"/>
				<sourcePositionVariance x="0" y="10"/>
				<speed value="0"/>
				<speedVariance value="19.74"/>
				<particleLifeSpan value="4.934"/>
				<particleLifespanVariance value="0"/>
				<angle value="0"/>
				<angleVariance value="300"/>
				<gravity x="10" y="150"/>
				<radialAcceleration value="-50"/>
				<tangentialAcceleration value="50"/>
				<radialAccelVariance value="100"/>
				<tangentialAccelVariance value="0.00"/>
				<startColor red="1.00" green="1" blue="1" alpha="1"/>
				<startColorVariance red="0.00" green="0.00" blue="0.00" alpha="0.00"/>
				<finishColor red="1.00" green="1" blue="1" alpha="1"/>
				<finishColorVariance red="0.00" green="0.00" blue="0.00" alpha="0.00"/>
				<maxParticles value="40"/>
				<startParticleSize value="40.00"/>
				<startParticleSizeVariance value="10"/>
				<finishParticleSize value="40.00"/>
				<FinishParticleSizeVariance value="10.00"/>
				<duration value="-1.00"/>
				<emitterType value="0"/>
				<maxRadius value="100.00"/>
				<maxRadiusVariance value="0.00"/>
				<minRadius value="0.00"/>
				<rotatePerSecond value="0.00"/>
				<rotatePerSecondVariance value="0.00"/>
				<blendFuncSource value="770"/>
				<blendFuncDestination value="1"/>
				<rotationStart value="0.00"/>
				<rotationStartVariance value="0.00"/>
				<rotationEnd value="0.00"/>
				<rotationEndVariance value="0.00"/>
			</particleEmitterConfig>

		public function Snow(width:Number, height:Number, texture:Texture)
		{
			config.sourcePositionVariance.@x = width / 2;
			super(config, texture);
			emitterX = width / 2;
		}
	}
}
