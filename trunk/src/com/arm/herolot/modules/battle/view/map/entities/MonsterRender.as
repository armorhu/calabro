package com.arm.herolot.modules.battle.view.map.entities
{
	import com.arm.herolot.Consts;
	import com.arm.herolot.modules.battle.model.map.entities.MonsterModel;
	import com.arm.herolot.modules.battle.view.map.MapGridView;

	import starling.text.TextField;

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
			_hp = new TextField(128, 16, '', 'Verdana', 12, 0xffffff, true);
			_ack = new TextField(128, 16, '', 'Verdana', 12, 0xffffff, true);
			_enetityLayer.addChild(_hp);
			_enetityLayer.addChild(_ack);
			_ack.y = Consts.TILE_SIZE - _ack.height;
			_hp.y = _ack.y - _hp.height;
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
