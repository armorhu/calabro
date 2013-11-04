package com.arm.herolot.modules.launch.screens
{
	import com.arm.herolot.HerolotApplication;
	import com.arm.herolot.model.data.database.GameData;
	import com.arm.herolot.modules.battle.battle.hero.HeroModel;
	import com.arm.herolot.modules.launch.LaunchModel;
	import com.arm.herolot.modules.launch.LaunchView;
	import com.arm.herolot.modules.launch.render.SkillBar;
	import com.arm.herolot.modules.launch.texture.LaunchTexture;
	import com.snsapp.starling.display.Button;
	import com.snsapp.starling.texture.TextureLoadEvent;
	import com.snsapp.starling.texture.implement.TextureBase;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.HAlign;

	/**
	 * 选葫芦娃的界面。
	 * @author hufan
	 */
	public class HeroScreen extends BaseScreen
	{
		private var _moeny:TextField;

		private var _btnBack:Button;
		private var _btnOK:Button;
		private var _btnNext:Button;
		private var _btnPre:Button;

		private var _name:TextField;
		private var _hp:TextField;
		private var _ack:TextField;
		private var _speed:TextField;
		private var _cirt:TextField;

		private var _currentHero:int = -1;
		private var _heroImage:Image;
		private var _heroTexture:TextureBase;
		private var _heroTextureName:String;

		private var _skillBar:SkillBar;


		public function HeroScreen()
		{
			super();
		}

		protected override function screen_addedToStageHandler(event:Event):void
		{
			if (this.isInitialized)
			{
				requestData(LaunchModel.PLAYER_DATA);
			}
		}

		protected override function draw():void
		{
			if (_moeny == null)
			{
				var sWidth:Number = actualWidth / _scale;
				var sHeight:Number = actualHeight / _scale;

				_moeny = addTextWithBg(17, 14);
				_hp = addTextWithBg(120, sHeight - 120);
				_speed = addTextWithBg(342, sHeight - 120);
				_ack = addTextWithBg(120, sHeight - 60);
				_cirt = addTextWithBg(342, sHeight - 60);

				_btnPre = addChildBtn(LaunchTexture.PRE_BTN, btnPreTiggerHandler, 25, 520);
				_btnNext = addChildBtn(LaunchTexture.NEXT_BTN, btnNextTiggerHandler, sWidth - 85, 520);
				_btnBack = addChildBtn(LaunchTexture.BACK_BTN, btnBackTiggerHandler, 25, 0);
				_btnOK = addChildBtn(LaunchTexture.OK_BTN, btnOKTiggerHandler, sWidth - 85, 0);
				_btnBack.y = _btnOK.y = _hp.y;

				_name = addTextField('', 260, 52, 190, 80, 48, 0xcccccc);
				_name.hAlign = HAlign.CENTER;

				_skillBar = new SkillBar(_batch, _scale);
				_skillBar.y = _name.y + _name.height + 15 * _scale;
				addChild(_skillBar);
				_skillBar.addEventListener(SkillBar.UPGRADE_SKILL, function upgradeSkillHandler(e:Event):void
				{
					dispatchEventWith(LaunchView.REQUEST_UPGRADE_SKILL, true, {hero: _currentHero, skill: _skillBar.selectedIndex});
					requestData(LaunchModel.PLAYER_DATA);
				});

				//请求数据
				requestData(LaunchModel.PLAYER_DATA);
				requestHero(0);
			}
		}

		private function btnPreTiggerHandler(e:Event):void
		{
			requestHero(_currentHero - 1);
		}

		private function btnOKTiggerHandler(e:Event):void
		{
			dispatchEventWith(LaunchView.START_BATTLE, false, _currentHero);
		}

		private function btnBackTiggerHandler(e:Event):void
		{
			dispatchEventWith('back');
		}

		private function btnNextTiggerHandler(e:Event):void
		{
			requestHero(_currentHero + 1);
		}

		protected function addTextWithBg(px:Number, py:Number, p:Sprite = null):TextField
		{
			var bg:Image = addChildImage(LaunchTexture.TF_BG, px, py, p);
			var tf:TextField = addTextField('', bg.width - 16, 27, px + 8, py + 3, 22, 0x0);
			return tf;
		}

		public override function setData(type:String, data:*):void
		{
			if (type == LaunchModel.PLAYER_DATA)
			{
				_moeny.text = '金币:' + GameData(data).money.toString();
			}
			else if (type == LaunchModel.HERO_DATA)
			{
				var heros:Vector.<HeroModel> = data as Vector.<HeroModel>;
				if (_currentHero == -1)
					_currentHero = heros.length - 1;
				else if (_currentHero == heros.length)
					_currentHero = 0;
				var hero:HeroModel = heros[_currentHero];
				_name.text = hero.config.Name;
				_hp.text = '生命:' + hero.hp.toString();
				_ack.text = '攻击:' + hero.ack.toString();
				_speed.text = '速度:' + hero.speed.toString();
				_cirt.text = '致命:' + hero.crit.toString();

				_heroTextureName = HerolotApplication.instance.textureLoader.getCacheURL(hero.config.BigPicURL);
				HerolotApplication.instance.textureLoader.addEventListener(TextureLoadEvent.COMPLETE, onloadTexture);
				HerolotApplication.instance.textureLoader.requestTexture(hero.config.BigPicURL, false);
				_skillBar.setData(hero.skills);
			}
		}

		private function onloadTexture(evt:TextureLoadEvent):void
		{
			if (evt.texture.name == _heroTextureName)
			{
				if (_heroTexture)
					_heroTexture.useCount--;
				if (_heroImage == null)
				{
					_heroImage = new Image(evt.texture.texture);
					_heroImage.pivotX = _heroImage.width / 2;
					_heroImage.pivotY = _heroImage.height;
					_heroImage.x = actualWidth / 2;
					_heroImage.y = actualHeight - 160 * _scale;
					addChildAt(_heroImage, 0);
				}
				else
				{
					_heroImage.texture = evt.texture.texture;
				}
				_heroTexture = evt.texture;
				evt.texture.useCount++;
				_heroImage.visible = true;
			}
		}

		private function requestHero(index:int):void
		{
			if (_currentHero == index)
				return;

			if (_heroImage)
				_heroImage.visible = false;
			_currentHero = index;
			requestData(LaunchModel.HERO_DATA);
		}

	}
}
