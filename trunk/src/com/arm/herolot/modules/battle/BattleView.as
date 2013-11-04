package com.arm.herolot.modules.battle
{
	import com.arm.herolot.Consts;
	import com.arm.herolot.Vars;
	import com.arm.herolot.modules.battle.battle.hero.HeroModel;
	import com.arm.herolot.modules.battle.battle.monster.Monster;
	import com.arm.herolot.modules.battle.map.MapData;
	import com.arm.herolot.modules.battle.view.layer.HeroLayer;
	import com.arm.herolot.modules.battle.view.layer.ObjectLayer;
	import com.arm.herolot.modules.battle.view.layer.TileLayer;
	import com.arm.herolot.modules.battle.view.render.MonsterRender;
	import com.arm.herolot.modules.battle.view.texture.BattleTexture;
	import com.snsapp.mobile.utils.MobileSystemUtil;
	import com.snsapp.starling.texture.ClientTextureParams;

	import flash.geom.Point;

	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class BattleView extends Sprite
	{
		public static const REQUEST_DATA:String = 'request_data';
		public static const TILE_TOUCHED:String = 'tile_touched';
		public static const GAME_OVER:String = 'game_over';

		public static const LAYER_TYPE_GROUND:int = 1;
		public static const LAYER_TYPE_OBJECT:int = 2;
		public static const LAYER_TYPE_BLOCK:int = 3;

		private var _controller:BattleController;
		private var _groundLayer:TileLayer; //地板
		private var _blockLayer:TileLayer; //墙
		private var _objectLayer:ObjectLayer; //对象层，在墙和底板之间。
		private var _heroLayer:HeroLayer; //英雄信息&物品栏。
		private var _texture:BattleTexture;

		public function BattleView(controller:BattleController)
		{
			super();
			_controller = controller;
		}

		public function show(complete:Function):void
		{
			var clientParams:ClientTextureParams = new ClientTextureParams();
			clientParams.deviceDefalutLevelConfig = new XML;
			clientParams.clientVersion = Consts.VERSION;
			clientParams.deviceName = _controller.module.app.deviceInfo.deviceName;
			clientParams.os = MobileSystemUtil.os;
			clientParams.screenScale = Vars.starlingScreenScale;
			clientParams.textureVersion = "1";
			clientParams.resouceSwf = Consts.RES_BATTLE;
			_texture = new BattleTexture(_controller.module.app);
			_texture.setup(clientParams, onComplete);

			/**材质启动成功。**/
			function onComplete(suc:Boolean):void
			{
				if (suc == false)
				{
					_texture.dispose();
					_texture = null;
					complete(false);
				}
				else
				{
					buildLayers(); //初始化层级
					complete(true);
				}
			}
		}

		private function buildLayers():void
		{
			_groundLayer = new TileLayer(LAYER_TYPE_GROUND, _texture.mainTexture); //地面层
			_objectLayer = new ObjectLayer(LAYER_TYPE_OBJECT, _texture.mainTexture); //对象层
			_blockLayer = new TileLayer(LAYER_TYPE_BLOCK, _texture.mainTexture); //地块层
			_heroLayer = new HeroLayer(_texture.mainTexture); //英雄信息面板&物品栏视图
			_heroLayer.y = Consts.TILE_SIZE * Consts.MAP_ROWS;

			_groundLayer.addEventListener(TouchEvent.TOUCH, onTouch);
			_objectLayer.addEventListener(TouchEvent.TOUCH, onTouch);
			_blockLayer.addEventListener(TouchEvent.TOUCH, onTouch);

			addChild(_groundLayer);
			addChild(_objectLayer);
			addChild(_blockLayer);
			addChild(_heroLayer);
		}

		private function onTouch(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(event.currentTarget as DisplayObject);
			if (touch && touch.phase == TouchPhase.ENDED)
			{
				if (event.currentTarget == _blockLayer || event.currentTarget == _objectLayer)
				{
					var d:DisplayObject = DisplayObject(event.target).parent;
					dispatchEventWith(TILE_TOUCHED, false, new Point(d.y / d.height, d.x / d.width));
				}
			}
		}

		/**
		 * 数据层的数据注入。。。
		 * 为了不使接口爆炸，使用type来标识数据的类型。
		 * @param type
		 * @param data
		 */
		public function setData(type:String, data:Object):void
		{
			if (type == BattleModel.DATA_MAP)
				setMapData(data as MapData);
			_heroLayer.setData(type, data);
		}

		public function displayInteraction(type:String, result:Object):void
		{
			if (type == BattleModel.INTERACTION_BLOCK)
				displayOpenBlock(result);
			else if (type == BattleModel.INTERACTION_MONSTER)
				displayFight(result);
			else if (type == BattleModel.INTERACTION_ITEM_PICK)
				displayItemPick(result);
			else if (type == BattleModel.INTERACTION_ITEM_USE)
				displayItemEffect(result);
		}

		private function setMapData(data:MapData):void
		{
			_groundLayer.setData(data.groundData);
			_blockLayer.setData(data.blockData);
			_objectLayer.setData({monsters: data.monsterData, items: data.itemData});
		}

		private function displayOpenBlock(result:Object):void
		{
			if (result.openBlock != undefined)
			{
				_blockLayer.setTileVisibilityAt(result.openBlock.x, result.openBlock.y, false);
				if (result.disableList != undefined)
				{
					for each (var pt:Point in result.disableList as Vector.<Point>)
						_blockLayer.showDisableMark(pt.x, pt.y, true);
				}
				if (result.availableList != undefined)
				{
					for each (pt in result.availableList as Vector.<Point>)
						_blockLayer.showAbleMark(pt.x, pt.y, true);
				}
			}
			else
			{
				if (result.availableList != undefined)
				{
					for each (pt in result.availableList as Vector.<Point>)
						_blockLayer.showAbleMark(pt.x, pt.y, true);
				}

				if (result.resetList != undefined)
				{
					for each (pt in result.resetList as Vector.<Point>)
						_blockLayer.resetMark(pt.x, pt.y);
				}
			}
		}

		private function displayFight(data:Object):void
		{
			var pos:Point = data.position as Point;
			fight(data.firstHandResult);
			fight(data.secondHandResult);

			function fight(result:Object):void
			{
				if (!result)
					return;
				if (result.owner is HeroModel)
				{
					/**人打怪**/
					//updatehero数据
					_heroLayer.setData(BattleModel.DATA_HERO, result.owner);
					//更新怪物数据
					MonsterRender(_objectLayer.getTileAt(pos.x, pos.y, ObjectLayer.OBJECT_TAG_MONSTER)).update(result.target as Monster);
					if (result.die)
					{
						_objectLayer.setTileVisibilityAt(pos.x, pos.y, false, ObjectLayer.OBJECT_TAG_MONSTER);
						_objectLayer.setTileVisibilityAt(pos.x, pos.y, true, ObjectLayer.OBJECT_TAG_ITEM);
					}
				}
				else
				{
					/**怪打人**/
					//updatehero数据
					_heroLayer.setData(BattleModel.DATA_HERO, result.target);
					//更新怪物数据
					MonsterRender(_objectLayer.getTileAt(pos.x, pos.y, ObjectLayer.OBJECT_TAG_MONSTER)).update(result.owner as Monster);
					//hero 挂了
					if (result.die)
					{
						//处理 game over
//						dispatchEventWith(GAME_OVER);
					}
				}
			}
		}

		private function displayItemEffect(data:Object):void
		{
		}

		private function displayItemPick(data:Object):void
		{
			_objectLayer.setTileVisibilityAt(data.itemPos.x, data.itemPos.y, false, ObjectLayer.OBJECT_TAG_ITEM);
		}
	}
}
