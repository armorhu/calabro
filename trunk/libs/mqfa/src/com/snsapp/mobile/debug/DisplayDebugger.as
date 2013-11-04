package com.snsapp.mobile.debug
{
	import com.qzone.qfa.debug.Debugger;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.system.ApplicationDomain;

	/**
	 * 显示列表的调试工具
	 * @author armorhu
	 */
	public class DisplayDebugger
	{
		private var _root:DisplayObjectContainer;

		private var _target:DisplayObject;

		public function DisplayDebugger(root:DisplayObjectContainer, target:DisplayObject = null)
		{
			_root = root;
			_target = target;
		}

		public function showUnVisible():void
		{

		}

		public function remove():DisplayObject
		{
			if (_root == _target)
				return null;

			var child:DisplayObjectContainer = _target as DisplayObjectContainer;
			while (child != null && child.parent != _root)
			{
				child = child.parent;
			}
			if (child == null)
				return null;

			if (_root.numChildren == 1)
			{
				_root = child;
				return remove();
			}
			else
			{
				var index:int = _root.getChildIndex(child);
				if (index == 0)
					return _root.removeChildAt(1);
				else
					return _root.removeChildAt(0);
			}
		}
	}
}
