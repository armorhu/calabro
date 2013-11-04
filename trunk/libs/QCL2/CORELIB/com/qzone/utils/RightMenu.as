package com.qzone.utils
{

	import flash.display.InteractiveObject;
	import flash.events.ContextMenuEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;

	/**
	 * 右键菜单配置
	 * @author cbm
	 *
	 */
	public class RightMenu
	{
		/**
		 * 添加一个右键菜单项 
		 * @param obj 菜单对应的交互对象
		 * @param caption 显示文字
		 * @param func 当选择时函数
		 * @param separatorBefore 是否有分隔线，默认为false。
		 * @param enabled 启用状态，默认为true。
		 * @param visible 可见模式，默认为true。
		 * @param hideBuiltIns 隐藏内建的菜单项，默认为true。
		 * 
		 */

		public static function addMenuItem(obj:InteractiveObject, caption:String, func:Function = null, separatorBefore:Boolean=false, enabled:Boolean=true, visible:Boolean=true, hideBuiltIns:Boolean=true):void
		{
			var contextMenu:ContextMenu

			if (obj.contextMenu == null)
			{
				contextMenu=new ContextMenu();

			}
			else
			{
				contextMenu=obj.contextMenu as ContextMenu

			}

			if (hideBuiltIns)
				contextMenu.hideBuiltInItems();

			var item:ContextMenuItem=new ContextMenuItem(caption, separatorBefore, enabled, visible);
			
			if(func != null)item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, func);

			contextMenu.customItems.push(item);

			obj.contextMenu=contextMenu
		}
		public static function hideBuiltInItems(obj:InteractiveObject):void{
			
			var contextMenu:ContextMenu

			if (obj.contextMenu == null)
			{
				contextMenu=new ContextMenu();

			}
			else
			{
				contextMenu=obj.contextMenu as ContextMenu

			}
			
			contextMenu.hideBuiltInItems();
			
			obj.contextMenu=contextMenu
		}
	}

}
