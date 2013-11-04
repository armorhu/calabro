package com.arm.herolot.modules.launch.render
{
	import com.arm.herolot.modules.battle.battle.skill.SkillModel;
	import com.arm.herolot.modules.launch.texture.LaunchTexture;
	import com.arm.herolot.services.utils.EmbedFont;
	import com.snsapp.starling.display.Button;
	import com.snsapp.starling.texture.implement.BatchTexture;

	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	/**
	 * 技能详情面板。
	 */
	public class SkillDetailRender extends Sprite
	{
		private var _batch:BatchTexture;
		private var _scale:Number;
		private var _name:TextField;
		private var _currentDesc:TextField;
		private var _nextDesc:TextField;
		private var _btnUpgrade:Button;

		public function SkillDetailRender(batch:BatchTexture, scale:Number)
		{
			super();
			_batch = batch;
			_scale = scale;
			createView();
		}

		private function createView():void
		{
			var bg:Quad = new Quad(580, 320, 0x0);
			bg.alpha = .75;
			addChild(bg);

			_name = new TextField(180, 40, '', EmbedFont.fontName, 35, 0x00FF00, true);
			_name.vAlign = VAlign.CENTER;
			_name.hAlign = HAlign.CENTER;
			_name.x = (width - _name.width) / 2;
			_name.y = 5;
			addChild(_name);

			_currentDesc = new TextField(160, 150, '', EmbedFont.fontName, 22, 0xffffff);
			_currentDesc.vAlign = VAlign.TOP;
			_currentDesc.hAlign = HAlign.LEFT;
			_currentDesc.border = true;
			_currentDesc.x = 20;
			_currentDesc.y = 70;
			addChild(_currentDesc);

			_nextDesc = new TextField(160, 150, '', EmbedFont.fontName, 22, 0xffffff);
			_nextDesc.vAlign = VAlign.TOP;
			_nextDesc.hAlign = HAlign.LEFT;
			_nextDesc.border = true;
			_nextDesc.x = width - _nextDesc.width - 20;
			_nextDesc.y = 70;
			addChild(_nextDesc);

			_btnUpgrade = new Button(_batch.getTexture(LaunchTexture.BTN_UPGRADE));
			_btnUpgrade.addEventListener(Event.TRIGGERED, triggerHandler);
			_btnUpgrade.x = (width - _btnUpgrade.width) / 2;
			_btnUpgrade.y = height - _btnUpgrade.height - 20;
			addChild(_btnUpgrade);
		}

		private function triggerHandler(evt:Event):void
		{
			dispatchEventWith(SkillBar.UPGRADE_SKILL, true);
		}



		public function setData(skill:SkillModel):void
		{
			if (skill)
			{
				_name.text = skill.configs[0].Name;
				if (skill.data.level == 0)
					_currentDesc.text = '还未学习该技能';
				else
					_currentDesc.text = skill.configs[skill.data.level - 1].Desc;
				if (skill.data.level == skill.configs.length)
					_nextDesc.text = '该技能已经升满';
				else
					_nextDesc.text = skill.configs[skill.data.level].Desc;
				visible = true;
			}
			else
			{
				visible = false;
			}
		}
	}
}
