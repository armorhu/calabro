package com.arm.herolot.modules.battle.view.map
{
	import com.arm.herolot.HerolotApplication;
	import com.arm.herolot.model.config.AppConfig;
	import com.arm.herolot.modules.battle.map.MapGridData;
	import com.arm.herolot.modules.battle.model.MapGridModel;
	import com.arm.herolot.modules.battle.view.texture.BattleTexture;
	import com.greensock.TweenLite;
	import com.qzone.utils.DisplayUtil;
	import com.snsapp.starling.StarlingFactory;
	import com.snsapp.starling.texture.TextureLoadEvent;
	import com.snsapp.starling.texture.implement.BatchTexture;
	import com.snsapp.starling.texture.implement.SingleTexture;
	import com.snsapp.starling.texture.implement.TextureBase;

	import flash.utils.getDefinitionByName;

	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.TextureAtlas;


	/**
	 * 地图上的一个格子
	 * @author hufan
	 *
	 */
	public class MapGridView extends Sprite
	{
		private var _texture:BatchTexture;

		protected var _groundLayer:Sprite;
		protected var _enetityLayer:Sprite;
		protected var _blockLayer:Sprite;
		protected var _stateLayer:Sprite;
		protected var _entity:Sprite;

		protected var _model:MapGridModel;
		private var _debugText:TextField;

		public function set model(value:MapGridModel):void
		{
			var eventList:Vector.<String>;
			if (_model)
			{
				eventList = _model.eventsTypeList;
				for (var i:int = 0; i < eventList.length; i++)
					_model.removeEventListener(eventList[i], modelEventHandler);
			}

			_model = value;

			if (_model)
			{
				eventList = _model.eventsTypeList;
				if (eventList)
				{
					for (i = 0; i < eventList.length; i++)
						_model.addEventListener(eventList[i], modelEventHandler);
				}
			}
		}

		public function MapGridView()
		{
			super();
		}

		protected function initliaze():void
		{
			_groundLayer = new Sprite();
			addChild(_groundLayer);
			_enetityLayer = new Sprite();
			addChild(_enetityLayer);
			_blockLayer = new Sprite();
			addChild(_blockLayer);
			_stateLayer = new Sprite();
			addChild(_stateLayer);

			var data:MapGridData = _model.gridData;
			if (data.groundType >= 0)
			{
				var groundTexture:SingleTexture = _texture.getTexture(BattleTexture.GROUND + data.groundType);
				var ground:Image = StarlingFactory.newImage(groundTexture);
				_groundLayer.addChild(ground);
			}

			if (data.entity.id > 0)
			{
				_entity = new Sprite();
				_enetityLayer.addChild(_entity);
				createEntityView();
			}

			if (data.blockType >= 0)
			{
				var blockTexture:SingleTexture = _texture.getTexture(BattleTexture.BLOCK + data.blockType);
				var block:Image = StarlingFactory.newImage(blockTexture);
				_blockLayer.addChild(block);
			}
			this.scaleX = 4;
			this.scaleY = 4;

			//默认将所有的蒙版蒙上
			var flagInstance:DisplayObject = StarlingFactory.newImage(_texture.getTexture(BattleTexture.UNREACHABLE_FLAG));
			_stateLayer.addChild(flagInstance);
			flagInstance.name = BattleTexture.UNREACHABLE_FLAG;

			validate();
			_debugText = new TextField(128, 128, '', 'Verdana', 24, 0xffffff);
			var entityId:int = _model.gridData.entity.id;
			if (entityId > 0)
				_debugText.text = AppConfig.mapEntitiesConfigModel.getMapEntitiesConfigByID(entityId).DisplayName;
			var dropId:int = _model.gridData.entity.dropID;
			if (dropId > 0)
				_debugText.text = _debugText.text + '\n' + AppConfig.mapEntitiesConfigModel.getMapEntitiesConfigByID(dropId).DisplayName;
			_debugText.scaleX = 0.25, _debugText.scaleY = 0.25;
			addChild(_debugText);


			addEventListener(TouchEvent.TOUCH, touchMeBaby);
		}


		private var _beign:Boolean;

		private function touchMeBaby(evt:TouchEvent):void
		{
			var touch:Touch = evt.getTouch(this, TouchPhase.ENDED);
			if (touch)
			{
				_model.touchHandler();
//				dispatchEventWith(MapView.TOUCH_GRID, true, _model);
			}
		}

		protected function validate():void
		{
			flagHandler(BattleTexture.UNREACHABLE_FLAG, !_model.reachable, _stateLayer);
			flagHandler(BattleTexture.LOCK_FLAG, _model.lock, _stateLayer);

			_blockLayer.visible = !_model.open;
		}

		private function flagHandler(flagName:String, flagVisible:Boolean, p:Sprite):void
		{
			var flagInstance:DisplayObject = DisplayUtil.getChildByName(p, flagName) as DisplayObject;

			if (flagInstance)
				TweenLite.killTweensOf(flagInstance, true);

			if (flagVisible)
			{
				if (flagInstance == null)
				{
					flagInstance = StarlingFactory.newImage(_texture.getTexture(flagName));
					p.addChild(flagInstance);
					flagInstance.name = flagName;
					flagInstance.alpha = 0;
				}

				if (flagInstance && flagInstance.alpha < 1)
					TweenLite.to(flagInstance, 0.5, {alpha: 1});
			}
			else
			{
				if (flagInstance && flagInstance.alpha > 0)
					TweenLite.to(flagInstance, 0.5, {alpha: 0});
			}
		}

		protected function modelEventHandler(evt:Event):void
		{
			if (evt.type == Event.CHANGE)
				validate();
		}


		private function createEntityView():void
		{
			var id:int = _model.gridData.entity.id;
			if (id > 0)
			{
				var entitySwf:String = AppConfig.mapEntitiesConfigModel.getMapEntitiesConfigByID(id).SWF;
				var textureName:String = HerolotApplication.instance.textureLoader.getCacheURL(entitySwf);
				HerolotApplication.instance.textureLoader.addEventListener(TextureLoadEvent.COMPLETE, onloadTexture);
				HerolotApplication.instance.textureLoader.requestTexture(entitySwf, false);
			}
			function onloadTexture(evt:TextureLoadEvent):void
			{
				if (evt.texture.name == textureName)
				{
					HerolotApplication.instance.textureLoader.removeEventListener(TextureLoadEvent.COMPLETE, onloadTexture);
					evt.texture.useCount++;
					onloadEntityTexture(evt.texture);
				}
			}
		}

		protected function onloadEntityTexture(texture:TextureBase):void
		{
			if (texture.texture.width == 128)
			{
				var atlas:TextureAtlas = new TextureAtlas(texture.texture, <TextureAtlas imagePath='atlas.png'>
						<SubTexture name='texture_1' x='0'  y='0' width='32' height='32'/>
						<SubTexture name='texture_2' x='32' y='0' width='32' height='32'/>
						<SubTexture name='texture_3' x='64'  y='0' width='32' height='32'/>
						<SubTexture name='texture_4' x='96' y='0' width='32' height='32'/>
					</TextureAtlas>);

				var mc:MovieClip = new MovieClip(atlas.getTextures('texture'), 6);
				Starling.juggler.add(mc);
				_entity.addChild(mc);
			}
			else
			{
				var img:Image = StarlingFactory.newImage(texture as SingleTexture);
				img.scaleX = img.scaleY = 0.5;
				_entity.addChild(img);
			}
		}

		public static function createMapGridView(model:MapGridModel, texture:BatchTexture):MapGridView
		{
			if (model.entityId > 0)
			{
				var renderClassName:String = 'com.arm.herolot.modules.battle.view.map.entities.' + AppConfig.mapEntitiesConfigModel.getMapEntitiesConfigByID(model.entityId).RenderClassName;
				var renderClass:Class;
				try
				{
					renderClass = getDefinitionByName(renderClassName) as Class;
				}
				catch (error:Error)
				{
				}
			}

			if (renderClass == null)
				renderClass = MapGridView;

			var view:MapGridView = new renderClass();
			view._texture = texture;
			view.model = model;
			view.initliaze();
			return view;
		}
	}
}
