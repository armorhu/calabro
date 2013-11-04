package com.snsapp.starling.display.tab
{
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;

	/**
	 * 按钮组合。
	 * @author armorhu
	 */
	public class TabBar extends Sprite
	{
		/**
		 * 第一个按钮的偏移量
		 * **/
		private var _firstGap:Number;

		/**
		 * 按钮之间的偏移量
		 * **/
		private var _tabGap:Number;

		/**
		 * 排列位置
		 * **/
		private var _vertial:Boolean;

		/**
		 * 数据源
		 * **/
		private var _dataSource:Array;

		private var _tabFactory:Function;

		private var _selectedIndex:int=-1;

		private var _flagImage:Image;

		public function TabBar(dataSource:Array, tabFactory:Function, tabGap:Number, firstGap:Number=0, flagImage:Image=null)
		{
			super();
			_firstGap=firstGap;
			_tabGap=tabGap;
			_dataSource=dataSource;
			_tabFactory=tabFactory;
			_flagImage=flagImage;
			_vertial=false;
			validate();
//			setTimeout(selectedIndex, 10, 0);
//			selectedIndex=0;
		}

		private function validate():void
		{
			const len:int=_dataSource.length;
			var start:Number=_firstGap;
			var tab:Tab;
			for (var i:int=0; i < len; i++)
			{
				tab=_tabFactory(_dataSource[i]);
				if (_vertial)
					tab.y=start;
				else
					tab.x=start;
				start+=_tabGap;
				addChild(tab);
				tab.addEventListener(Event.TRIGGERED, tabTrigger);
			}
		}

		private function tabTrigger(e:Event):void
		{
			var target:Tab=e.target as Tab;
			if (target)
				selectedIndex=getChildIndex(target);
		}

		public function get selectedIndex():int
		{
			return _selectedIndex;
		}

		public function set selectedIndex(value:int):void
		{
			if (_selectedIndex == value)
				return;

			if (_selectedIndex >= 0 && _selectedIndex < _dataSource.length)
				Tab(getChildAt(_selectedIndex)).selected=false;
			_selectedIndex=value;
			Tab(getChildAt(_selectedIndex)).selected=true;
			if (_flagImage)
			{
				if (_vertial)
					_flagImage.y=getChildAt(_selectedIndex).y //+ getChildAt(_selectedIndex).height / 2;
				else
					_flagImage.x=getChildAt(_selectedIndex).x //+ getChildAt(_selectedIndex).width / 2;
			}

			dispatchEventWith(Event.CHANGE);
		}

		public function get selectedItem():Object
		{
			if (_selectedIndex < 0 || _selectedIndex >= _dataSource.length)
				return null;

			return _dataSource[_selectedIndex];
		}

		override public function set visible(value:Boolean):void
		{
			if (value == visible)
				return;
			super.visible=value;
			if (_flagImage)
				_flagImage.visible=value;
		}
	}
}
