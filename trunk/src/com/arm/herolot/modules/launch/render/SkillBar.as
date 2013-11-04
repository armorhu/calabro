package com.arm.herolot.modules.launch.render
{
	import com.arm.herolot.modules.battle.battle.skill.SkillModel;
	import com.snsapp.starling.texture.implement.BatchTexture;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	/**
	 * 管理4个技能槽的交互与展现。
	 */
	public class SkillBar extends Sprite
	{
		public static const UPGRADE_SKILL:String = 'upgrade_skill';

		private var _renders:Vector.<SkillRender>;
		private var _scale:Number;
		private var _batch:BatchTexture;
		private var _detailPanel:SkillDetailRender;

		private var _skills:Vector.<SkillModel>;
		private var _selectedIndex:int;

		public function SkillBar(batch:BatchTexture, scale:Number)
		{
			super();
			_scale = scale;
			_batch = batch;
			_renders = new Vector.<SkillRender>(4, true);
			const FACTOR:Number = 50 * _scale;
			const DIST:Number = (Starling.current.stage.stageWidth - 2 * FACTOR) / _renders.length;
			for (var i:int = 0; i < _renders.length; i++)
			{
				_renders[i] = new SkillRender();
				_renders[i].scaleX = _renders[i].scaleY = _scale;
				_renders[i].x = FACTOR + i * DIST;
				_renders[i].addEventListener(Event.TRIGGERED, triggerHandler);
				addChild(_renders[i]);
			}

			_detailPanel = new SkillDetailRender(batch, scale);
			_detailPanel.x = (Starling.current.stage.stageWidth - _detailPanel.width) / 2;
			_detailPanel.y = (SkillRender.SIZE + 50) * _scale;
			addChild(_detailPanel);

			selectedIndex = -1;
			Starling.current.stage.addEventListener(TouchEvent.TOUCH, touchEvent);
		}

		private function touchEvent(e:TouchEvent):void
		{
			if (_selectedIndex == -1)
				return;
			if (e.getTouch(this, TouchPhase.BEGAN) == null && e.getTouch(Starling.current.stage, TouchPhase.BEGAN) != null)
				selectedIndex = -1;
		}

		public function setData(skills:Vector.<SkillModel>):void
		{
			_skills = skills;
			for (var i:int = 0; i < _renders.length; i++)
				_renders[i].setData(skills[i]);
			if (_selectedIndex != -1)
				_detailPanel.setData(_skills[_selectedIndex]);
		}

		private function triggerHandler(e:Event):void
		{
			var render:SkillRender = e.target as SkillRender;
			if (render)
				selectedIndex = _renders.indexOf(render);
		}

		public function get selectedIndex():int
		{
			return _selectedIndex;
		}

		public function set selectedIndex(index:int):void
		{
			if (_selectedIndex == index)
				return;

			if (_selectedIndex != -1)
				_renders[_selectedIndex].selected = false;
			_selectedIndex = index;
			if (_selectedIndex != -1)
			{
				_renders[_selectedIndex].selected = true;
				_detailPanel.setData(_skills[_selectedIndex]);
			}
			else
			{
				_detailPanel.setData(null);
			}
		}

		/**
		 * 展示技能的细节。
		 */
		public function showSkillDetial(skill:SkillModel):void
		{
			_detailPanel.visible = true;
			_detailPanel.setData(skill);
		}


	}
}
