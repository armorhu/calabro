package com.arm.herolot.modules.battle.view
{
	import com.arm.herolot.Consts;
	import com.arm.herolot.modules.battle.battle.round.attack.AttackResult;
	import com.greensock.TweenLite;

	import flash.geom.Point;

	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.utils.HAlign;

	public class DamagePlayer extends Sprite implements IAnimatable
	{
		private var _tf:TextField;

		public function DamagePlayer()
		{
		}

		private function init(danmage:int, crit:Boolean):void
		{
			_tf = new TextField(128, 32, danmage.toString());
			_tf.color = 0xff0000;
			_tf.fontSize = 24;
			_tf.hAlign = HAlign.CENTER;
			_tf.pivotX = _tf.width / 2;
			_tf.pivotY = _tf.height;
			addChild(_tf);
			//往上飘一个格子
			TweenLite.to(this, 1, {y: y - Consts.TILE_SIZE, onComplete: removeFromParent, onCompleteParams: [true]});
		}

		public function advanceTime(time:Number):void
		{

		}

		override public function dispose():void
		{
			_tf.removeFromParent(true);
			super.dispose();
		}

		public static function play(danmage:int, crit:Boolean, point:Point, container:Sprite):void
		{
			var player:DamagePlayer = new DamagePlayer();
			player.x = point.x;
			player.y = point.y;
			container.addChild(player);
			player.init(danmage, crit);
		}
	}
}
