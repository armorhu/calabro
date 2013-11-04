package com.arm.herolot.modules.launch.render
{
	import com.arm.herolot.HerolotApplication;
	import com.arm.herolot.modules.battle.battle.skill.SkillModel;
	import com.snsapp.starling.display.Button;
	import com.snsapp.starling.texture.TextureLoadEvent;
	import com.snsapp.starling.texture.implement.SingleTexture;
	
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;

	/**
	 * 技能渲染器。
	 * @author hufan
	 */
	public class SkillRender extends Sprite
	{
		public static const SIZE:int = 100;

		private var _levelTf:TextField;
		private var _iconTexture:SingleTexture;
		private var _icon:Button;

		public function SkillRender()
		{
			super();
		}

//		private function touchMeBaby(evt:TouchEvent):void
//		{
//			var touch:Touch = evt.getTouch(this);
//			if (touch.phase == TouchPhase.BEGAN)
//			{
//				this.scaleX *= 0.9;
//				_hold = true;
//			}
//			else if (touch.phase == TouchPhase.MOVED)
//			{
//
//			}
//			else if (touch.phase == TouchPhase.ENDED)
//			{
//				if (_hold)
//				{
//					this.scaleX /= 0.9;
//					_hold = false;
//				}
//			}
//		}

		private static var _badTf:TextField;

		public function setData(skill:SkillModel):void
		{
			this.visible = false;
			var assets:String = skill.configs[0].SWF;
			var waitURL:String = HerolotApplication.instance.textureLoader.getCacheURL(assets);
			if (_iconTexture && _iconTexture.name == waitURL)
			{
				_levelTf.text = skill.data.level.toString();
				this.visible = true;
				return;
			}

			HerolotApplication.instance.textureLoader.addEventListener(TextureLoadEvent.COMPLETE, //
				function loadTexture(e:TextureLoadEvent):void
				{
					if (e.texture.name == waitURL)
					{
						HerolotApplication.instance.textureLoader.removeEventListener(TextureLoadEvent.COMPLETE, loadTexture);
						if (_iconTexture)
							_iconTexture.useCount--;
						_iconTexture = e.texture as SingleTexture;
						_iconTexture.useCount++;
						if (_icon)
						{
							_icon.upState = _iconTexture;
							_icon.width = SIZE;
							_icon.height = SIZE;
							_levelTf.text = skill.data.level.toString();
						}
						else
						{
							_icon = new Button(_iconTexture);
							_icon.width = SIZE;
							_icon.height = SIZE;
							_icon.addEventListener(Event.TRIGGERED, trigerIcon);
							addChild(_icon);

							/**蛋疼的Starling的bug。**/
							if (_badTf == null)
							{
								_badTf = new TextField(SIZE / 4, SIZE / 4, skill.data.level.toString(), 'Verdana', 20, 0xFFFFFF, true);
								addChild(_badTf);
								_badTf.x = -100;
								_badTf.y = 0;
							}
							_levelTf = new TextField(SIZE / 4, SIZE / 4, '', 'Verdana', 20, 0xFFFFFF, true);
							_levelTf.x = _icon.width - _levelTf.width;
							_levelTf.y = _icon.height - _levelTf.height;
							addChild(_levelTf);
							_levelTf.text = skill.data.level.toString();
						}

						visible = true;
					}
				});
			HerolotApplication.instance.textureLoader.requestTexture(assets, false);
		}

		private function trigerIcon(e:Event):void
		{
			dispatchEventWith(Event.TRIGGERED);
		}

		override public function get width():Number
		{
			return SIZE * scaleX;
		}

		private var _selected:Boolean;

		public function set selected(bool:Boolean):void
		{
			if (_selected == bool)
				return;
			_selected = bool;
			if (_selected)
			{
				this.y += 10;

			}
			else
			{
				this.y -= 10;
			}
		}
	}
}
