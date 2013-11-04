package com.qzone.corelib.controls.scrollviews
{	
	import com.qzone.corelib.controls.interfaces.IRenderer;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	/**
	 * 列表渲染器包装器
	 * @author Larry H.
	 */
	public class RendererWrapper extends Sprite
	{
		public static var scrolling:Boolean = false;
		
		////////////////////////////////////////////////////////////////////
		// members
		private var _data:Object = null;
		
		private var _index:int = 0;
		private var _dataIndex:int = 0;
		
		private var _renderer:IRenderer = null;
		
		/**
		 * 构造函数
		 * create a [RendererWrapper] object 
		 * @param	RenderClass		渲染器类
		 */
		public function RendererWrapper(RenderClass:Class)
		{
			_renderer = new RenderClass() as IRenderer;
			if (_renderer is DisplayObject)
			{
				addChild(_renderer as DisplayObject);
			}
			else
			{
				throw new ArgumentError(RenderClass + "必须实现IRenderer接口，并且继承显示对象类！");
			}
		}
		
		/**
		 * 数据，如果必要，需要将data转换成特定类型
		 */
		public function get data():Object { return _data; }
		public function set data(value:Object):void
		{
			_data = value;
			_renderer.data = value;
		}
		
		/**
		 * 视图索引
		 */
		public function get index():int { return _index; }
		public function set index(value:int):void 
		{
			_index = value;
		}
		
		/**
		 * 数据索引
		 */
		public function get dataIndex():int { return _dataIndex; }
		public function set dataIndex(value:int):void 
		{
			_dataIndex = value;
		}
		
		/**
		 * 优先使用Renderer的高度
		 */
		override public function get height():Number { return DisplayObject(_renderer).height; }
		
		/**
		 * 优先使用Renderer的宽度
		 */
		override public function get width():Number { return DisplayObject(_renderer).width; }
		
		/**
		 * 渲染器实例对象
		 */
		public function get renderer():IRenderer { return _renderer; }
	}

}