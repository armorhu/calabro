package com.snsapp.starling.display.effect
{
	import com.snsapp.starling.StarlingFactory;
	import com.snsapp.starling.texture.implement.BatchTexture;
	
	import flash.geom.Point;
	
	import sky.effect.Cloud1;
	import sky.effect.Cloud2;
	import sky.effect.Cloud3;
	import sky.effect.CloudShadow;
	
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * 普通的效果。
	 * @author hufan
	 */
	public class CloudEffect extends Sprite implements IDynamicEffect, IAnimatable
	{
		public static const SKY_EFFECT_CLOUD1:String = 'sky_effect_cloud1'; //云
		public static const SKY_EFFECT_CLOUD2:String = 'sky_effect_cloud2'; //云
		public static const SKY_EFFECT_CLOUD3:String = 'sky_effect_cloud3'; //云
		public static const SKY_EFFECT_CLOUD_SHADOW:String = 'sky_effect_cloud_shadow'; //影子
		public static const NAME:String = 'cloud_effect';
		
		private var _batchTexture:BatchTexture;
		private var _clounds:Vector.<Image>; //云们。。
		private var _shadows:Object;
		private var _speed:Point; //云飘的速度，三朵云的速度是统一的
		private var _screenScale:Number;
		
		private var _dragTarget:Image;
		
		private const BORN_POSTIONS:Array = [ //
			6, 7, 8, //
			12, 13, //
			16, 17, 18, //
			21, 22, 23 //
		];
		
		private const RESET:Array = [14, 19, 21, 22, 23, 24];
		
		public function CloudEffect(screenScale:Number, batchTexture:BatchTexture)
		{
			super();
			_batchTexture = batchTexture;
			_screenScale = screenScale;
		}
		
		public function show():void
		{
			if (_batchTexture == null)
			{
				_batchTexture = new BatchTexture(512, 128, false);
				_batchTexture.insertBmd(CloudEffect.SKY_EFFECT_CLOUD1, new Cloud1, _screenScale, _screenScale);
				_batchTexture.insertBmd(CloudEffect.SKY_EFFECT_CLOUD2, new Cloud2, _screenScale, _screenScale);
				_batchTexture.insertBmd(CloudEffect.SKY_EFFECT_CLOUD3, new Cloud3, _screenScale, _screenScale);
				_batchTexture.insertBmd(CloudEffect.SKY_EFFECT_CLOUD_SHADOW, new CloudShadow, _screenScale / 10, _screenScale / 10);
				_batchTexture.upload();
			}
			
			//将屏幕分为16格子，随即从里面选三个格子，生成三朵云
			_clounds = new Vector.<Image>();
			_clounds.length = 3, _clounds.fixed = true;
			_shadows = new Object();
			_clounds[0] = StarlingFactory.newImage(_batchTexture.getTexture(SKY_EFFECT_CLOUD1));
			_clounds[1] = StarlingFactory.newImage(_batchTexture.getTexture(SKY_EFFECT_CLOUD2));
			_clounds[2] = StarlingFactory.newImage(_batchTexture.getTexture(SKY_EFFECT_CLOUD3));
			_clounds[0].addEventListener(TouchEvent.TOUCH, onCloud);
			_clounds[1].addEventListener(TouchEvent.TOUCH, onCloud);
			_clounds[2].addEventListener(TouchEvent.TOUCH, onCloud);
			
			for (var i:int = 0; i < _clounds.length; i++)
			{
				_clounds[i].name = 'cloud' + i;
				_shadows[_clounds[i].name] = StarlingFactory.newImage(_batchTexture.getTexture(SKY_EFFECT_CLOUD_SHADOW));
				_shadows[_clounds[i].name].width = _clounds[i].width * 25 / 18;
				_shadows[_clounds[i].name].scaleY = _shadows[_clounds[i].name].scaleX;
				Image(_shadows[_clounds[i].name]).touchable = false;
			}
			_speed = new Point(-.5 * _screenScale, -.5 * _screenScale);
			placeClounds(BORN_POSTIONS.concat());
			Starling.juggler.add(this);
		}
		
		private function placeClounds(postions:Array, clouds:Array = null):void
		{
			if (clouds == null)
				clouds = [0, 1, 2];
			const cellWidth:Number = Starling.current.stage.stageWidth / 4;
			const cellHeight:Number = Starling.current.stage.stageHeight / 4;
			var random:int, postion:int;
			for (var i:int = 0; i < clouds.length; i++)
			{
				random = Math.random() * postions.length;
				postion = postions[random];
				postions.splice(random, 1);
				var pt:Point = new Point((postion % 5) * cellWidth, (int(postion / 5)) * cellHeight);
				pt = this.globalToLocal(pt);
				_clounds[clouds[i]].x = pt.x, _clounds[clouds[i]].y = pt.y;
			}
		}
		
		private function onCloud(evt:TouchEvent):void
		{
			var currentCloud:Image = evt.currentTarget as Image;
			if (currentCloud)
				var touch:Touch = evt.getTouch(currentCloud);
			if (touch && currentCloud)
			{
				if (touch.phase == TouchPhase.BEGAN)
				{
					evt.stopImmediatePropagation();
					_dragTarget = currentCloud;
				}
				else if (touch.phase == TouchPhase.ENDED)
				{
					evt.stopImmediatePropagation();
					_dragTarget = null;
				}
				else if (touch.phase == TouchPhase.MOVED)
				{
					if (_dragTarget)
					{
						evt.stopImmediatePropagation();
						_dragTarget.x += touch.globalX - touch.previousGlobalX;
						_dragTarget.y += touch.globalY - touch.previousGlobalY;
					}
				}
			}
		}
		
		override public function dispose():void
		{
			if (this.parent)
				this.parent.removeChild(this);
			
			Starling.juggler.remove(this);
			for (var i:int = 0; i < _clounds.length; i++)
			{
				_clounds[i].removeEventListener(TouchEvent.TOUCH, onCloud);
				_shadows[_clounds[i].name].dispose();
				_clounds[i].dispose();
			}
			_clounds = null;
			_shadows = null;
			super.dispose();
		}
		
		private var timeDelay:Number = 0;
		private var testPoint:Point;
		
		public function advanceTime(time:Number):void
		{
			timeDelay += time;
			if (timeDelay >= 1 / 30)
			{
				timeDelay = 0;
				this.removeChildren();
				_clounds.sort(ySort);
				
				//影子
				var shadow:Image;
				for (i = 0; i < _clounds.length; i++)
				{
					shadow = _shadows[_clounds[i].name];
					shadow.x = _clounds[i].x - (shadow.width - _clounds[i].width) / 2;
					shadow.y = _clounds[i].y - shadow.height / 2 + 200 * _screenScale;
					this.addChild(shadow);
				}
				
				//云
				for (var i:int = 0; i < _clounds.length; i++)
				{
					if (_clounds[i] != _dragTarget)
					{
						var cloudid:int = parseInt(_clounds[i].name.charAt(_clounds[i].name.length - 1));
						_clounds[i].x += _speed.x + cloudid * .1 * _screenScale;
						_clounds[i].y += _speed.y + cloudid * .1 * _screenScale;
					}
					
					this.addChild(_clounds[i]);
					if (this.stage)
					{
						testPoint = _clounds[i].bounds.bottomRight; //用云的右下角来做测试;
						if (testPoint.x < 0 || testPoint.y < 0)
						{ //已经出了边界了
							placeClounds(RESET.concat(), [i]);
						}
					}
				}
				
			}
		}
		
		private function ySort(child1:DisplayObject, child2:DisplayObject):Number
		{
			if (child1.y < child2.y)
				return -1;
			else if (child1.y > child2.y)
				return 1;
			else
				return child1.height - child2.height;
		}
		
		public function get type():String
		{
			return NAME;
		}
	}
}
