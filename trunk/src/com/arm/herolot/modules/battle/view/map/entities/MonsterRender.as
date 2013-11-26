package com.arm.herolot.modules.battle.view.map.entities
{
	import com.arm.herolot.Consts;
	import com.arm.herolot.modules.battle.model.map.entities.MonsterModel;
	import com.arm.herolot.modules.battle.view.map.MapGridView;

	import starling.text.TextField;
	import starling.utils.VAlign;

	public class MonsterRender extends MapGridView
	{
		private var _hp:TextField;
		private var _ack:TextField;

		public function MonsterRender()
		{
			super();
		}

		override protected function initliaze():void
		{
			super.initliaze();
			_hp = new TextField(128, 32, '', 'Verdana', 14, 0xffffff, true);
			_hp.vAlign = VAlign.BOTTOM;
			_ack = new TextField(128, 32, '', 'Verdana', 14, 0xffffff, true);
			_ack.vAlign = VAlign.BOTTOM;
			_enetityLayer.addChild(_hp);
			_enetityLayer.addChild(_ack);
			_ack.y = Consts.TILE_SIZE - _ack.height;
			_hp.y = _ack.y - _hp.fontSize;
		}

		override protected function validate():void
		{
			super.validate();

			_hp.text = 'hp:' + monster.battleEntity.hp;
			_ack.text = 'ack:' + monster.battleEntity.ack;
		}


		public function get monster():MonsterModel
		{
			return _model as MonsterModel;
		}
	}
}
