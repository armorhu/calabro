package com.arm.herolot.modules.battle.model.battleui
{
	import com.arm.herolot.modules.battle.battle.hero.HeroModel;

	import starling.animation.IAnimatable;
	import starling.events.Event;
	import starling.events.EventDispatcher;

	/**
	 * BattleUIModel
	 * @author hufan
	 *
	 */
	public class BattleuiModel extends EventDispatcher implements IAnimatable
	{
		private var _msgCenter:EventDispatcher;
		public var hero:HeroModel;
		public var modelChange:Boolean;

		public function BattleuiModel(msgCenter:EventDispatcher)
		{
			super();
			_msgCenter = msgCenter;
		}

		public function initialize(hero:HeroModel):void
		{
			this.hero = hero;
			modelChange = true;
		}

		public function advanceTime(time:Number):void
		{
			if (modelChange)
			{
				modelChange = false;
				dispatchEventWith(Event.CHANGE);
			}
		}
	}
}
