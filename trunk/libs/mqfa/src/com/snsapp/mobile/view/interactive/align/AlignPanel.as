package com.snsapp.mobile.view.interactive.align
{
	import com.snsapp.mobile.mananger.cachepool.ICachePool;
	import com.snsapp.mobile.mananger.factory.IFactory;
	import com.snsapp.mobile.view.interactive.align.setting.AlignSetting;
	import com.qzone.qfa.interfaces.IAsynDatabinding;
	import com.qzone.qfa.interfaces.IDatabinding;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	/**
	 * 整齐排列的面板
	 * @author armorhu
	 */
	public class AlignPanel extends Sprite implements IDatabinding
	{
		protected var _itemContainer:Sprite;

		protected var _itemFactory:IFactory;

		protected var _alignSetting:AlignSetting;

		protected var _data:Array;

		protected var _itemCount:int;

		protected var _panelBackgroundSkin:BitmapData;

		protected var _completeCount:int;

//		protected var _loading:DataLoading_mc;

		public function AlignPanel(itemFactory:IFactory, alignSetting:AlignSetting, panelBgSkin:BitmapData = null)
		{
			super();

			_itemFactory = itemFactory;
			_alignSetting = alignSetting;
			_panelBackgroundSkin = panelBgSkin;
			_itemContainer = new Sprite();
			addChild(_itemContainer);
			if (_itemFactory == null)
				throw new Error("itemFactory 不能为空");

			if (_alignSetting == null)
				throw new Error("alignSetting 不能为空");
		}

		public function get data():Object
		{
			return this._data;
		}

		/**
		 * 请传入 数组 或者 Int
		 * 传入数组,使用数组的长度作为对象数量
		 * @param value
		 */
		public function set data(value:Object):void
		{
			if (value is Array)
			{
				_itemCount = value.length;
				_data = value as Array;
			}
			else if (value is int || value == null)
			{
				_itemCount = int(value);
				_data = null;
			}
			else
				throw new Error("请使用数组或者整数作为AlignPanel的数据源");

			this.buildAlign();
		}

		protected function buildAlign():void
		{
			_itemContainer.visible = false;
			while (_itemContainer.numChildren > 0)
			{
				if (_itemFactory is ICachePool)
					(_itemFactory as ICachePool).object = _itemContainer.getChildAt(0);
				_itemContainer.removeChildAt(0);
			}
			redrawBackgournd();
			_completeCount = 0;
			var itemInstance:DisplayObject;
			var pos:Point
			for (var i:int = 0; i < _itemCount; i++)
			{
				itemInstance = _itemFactory.getInstance() as DisplayObject;
				if (itemInstance == null)
					throw new Error("AlignPanel itemFactory 做出来的对象必须是DisplayObject");
				else
					alignAt(itemInstance, i);
			}
		}

		protected function buildComplete():void
		{
			this.dispatchEvent(new Event(Event.COMPLETE));
			_itemContainer.visible = true;
		}

		protected function redrawBackgournd():void
		{
			_itemContainer.graphics.clear();
			if (_panelBackgroundSkin != null && this._itemCount > 0)
			{
				_itemContainer.graphics.beginBitmapFill(_panelBackgroundSkin);
				_itemContainer.graphics.drawRect(0, 0, totalWidth, //
					totalHeight);
				_itemContainer.graphics.endFill();
			}
		}

		public function get factory():IFactory
		{
			return this._itemFactory
		}

		public function get align():AlignSetting
		{
			return this._alignSetting
		}

		/**
		 *将instance 摆在编号为index的单元格上
		 */
		protected function alignAt(instance:DisplayObject, index:int):void
		{
			var pos:Point = _alignSetting.getPostionOf(index);
			instance.x = pos.x;
			instance.y = pos.y;
			if (instance.parent == null)
				_itemContainer.addChild(instance);
			if (_data != null)
			{
				if (instance is IDatabinding)
					IDatabinding(instance).data = _data[index];
				if (instance is IAsynDatabinding && !IAsynDatabinding(instance).isComplete())
					IAsynDatabinding(instance).addEventListener(Event.COMPLETE, dataBindingComplete);
				else
					dataBindingComplete(null);
			}
		}

		protected function dataBindingComplete(e:Event):void
		{
			if (e)
				e.target.addEventListener(Event.COMPLETE, dataBindingComplete);
			_completeCount++;
			if (_completeCount == _itemCount)
				buildComplete();
		}

//		protected function showLoading(bool:Boolean):void
//		{
//			if (_loading == null)
//				_loading = new DataLoading_mc();
//			if (bool)
//			{
//				if (_loading.stage == null)
//					addChild(_loading);
//				_loading.x = totalWidth >> 1;
//				_loading.y = totalHeight >> 1;
//				_loading.play();
//				_itemContainer.visible = false;
//			}
//			else
//			{
//				if (_loading.stage != null)
//					removeChild(_loading);
//				_loading.stop();
//				_itemContainer.visible = true;
//			}
//		}

		protected function get totalWidth():Number
		{
			return _alignSetting.computeAlignWidth(this._itemCount);
		}

		protected function get totalHeight():Number
		{
			return _alignSetting.computeAlignHeight(this._itemCount);
		}
	}
}
