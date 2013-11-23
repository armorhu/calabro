package com.arm.herolot.modules.battle.view.map
{
	import com.arm.herolot.Consts;
	import com.arm.herolot.model.config.AppConfig;
	import com.arm.herolot.modules.battle.map.MapGridData;
	import com.arm.herolot.modules.battle.model.MapGridModel;
	import com.arm.herolot.modules.battle.view.map.entities.EntityRender;
	import com.arm.herolot.modules.battle.view.texture.BattleTexture;
	import com.snsapp.starling.StarlingFactory;
	import com.snsapp.starling.texture.implement.BatchTexture;
	import com.snsapp.starling.texture.implement.SingleTexture;

	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;


	/**
	 * 地图上的一个格子
	 * @author hufan
	 *
	 */
	public class MapGridView extends Sprite
	{
		private var _ground:Image;
		private var _block:Image;
		private var _texture:BatchTexture;


		private var _groundLayer:Sprite;
		private var _enetityLayer:Sprite;
		private var _blockLayer:Sprite;
		private var _stateLayer:Sprite;

		protected var _model:MapGridModel;

		private var _entity:EntityRender;

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
				if (_ground == null)
					_ground = StarlingFactory.newImage(groundTexture);
				else
					StarlingFactory.setTexture(_ground, groundTexture);

				_groundLayer.addChild(_ground);
			}

			if (data.entity.id > 0)
			{
			}

			if (data.blockType >= 0)
			{
				var blockTexture:SingleTexture = _texture.getTexture(BattleTexture.BLOCK + data.blockType);
				if (_block == null)
					_block = StarlingFactory.newImage(blockTexture);
				else
					StarlingFactory.setTexture(_block, blockTexture);
				_blockLayer.addChild(_block);
			}
			this.width = Consts.TILE_SIZE;
			this.height = Consts.TILE_SIZE;
			validate();


			_debugText = new TextField(128, 128, '', 'Verdana', 24, 0xffffff);
			var entityId:int = _model.gridData.entity.id;
			if (entityId > 0)
				_debugText.text = AppConfig.mapEntitiesConfigModel.getMapEntitiesConfigByID(entityId).DisplayName;
			var dropId:int = _model.gridData.entity.dropID;
			if (dropId > 0)
				_debugText.text = _debugText.text + '\n' + AppConfig.mapEntitiesConfigModel.getMapEntitiesConfigByID(dropId).DisplayName;
			_debugText.scaleX = 0.25,_debugText.scaleY = 0.25;
			addChild(_debugText);
		}

		private function validate():void
		{
			_stateLayer.removeChildren(0, -1, true);
			if (!_model.visible)
				_stateLayer.addChild(StarlingFactory.newImage(_texture.getTexture(BattleTexture.TICK)));
			if (_model.lock)
				_stateLayer.addChild(StarlingFactory.newImage(_texture.getTexture(BattleTexture.CROSS)));
		}

		protected function modelEventHandler(evt:Event):void
		{
			if (evt.type == Event.CHANGE)
				validate();
		}

		public static function createMapGridView(model:MapGridModel, texture:BatchTexture):MapGridView
		{
			var view:MapGridView = new MapGridView();
			view._texture = texture;
			view.model = model;
			view.initliaze();
			return view;
		}
	}
}
