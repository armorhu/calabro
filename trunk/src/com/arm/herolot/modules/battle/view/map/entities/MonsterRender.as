package com.arm.herolot.modules.battle.view.map.entities
{
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
			_hp = new TextField(32, 16, '');
			_ack = new TextField(32, 16, '')
		}

		override protected function validate():void
		{
		}
	}
}
