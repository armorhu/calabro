package com.qzone.utils
{
	//import com.qzone.qui.styles.Style;

	import com.snsapp.mobile.view.bitmapclip.BitmapFrame;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageQuality;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;


	/**
	 * 显示列表常规操作工具集。
	 * @author cbm
	 *
	 */
	public class DisplayUtil
	{
		public static var stage:Stage;

		public function DisplayUtil()
		{

		}

		/**
		 * 销毁一切
		 *
		 * @param mc
		 * @arthor Demon.S
		 */
		public static function stopAll(mc:DisplayObjectContainer):void
		{
			if (mc == null)
				return;
			var len:int = mc.numChildren
			if (mc is MovieClip)
				mc["stop"]();
			while (len--)
			{
				var child:* = mc.getChildAt(len);
				if (child is DisplayObjectContainer)
					stopAll(child);
			}
		}

		/**
		 * 销毁一切
		 *
		 * @param mc
		 * @arthor Demon.S
		 */
		public static function removeAllChild(mc:DisplayObjectContainer):void
		{
			if (mc is Loader)
				return;
			while (mc.numChildren)
			{
				var child:* = mc.getChildAt(0);
				mc.removeChild(child);
				if (child is Bitmap)
					Bitmap(child).bitmapData.dispose();
				if (child is DisplayObjectContainer)
					removeAllChild(child);
				if (child.loaderInfo && child.loaderInfo.loader)
					child.loaderInfo.loader.unloadAndStop(true);
			}
		}

		/**
		 * 安全移除显示子元素
		 * @param container 子元素所在容器
		 * @param child 欲删除的子元素
		 * @return 删除成功返回子元素，否者返回null。
		 *
		 */
		public static function removeChild(container:DisplayObjectContainer, child:DisplayObject):DisplayObject
		{

			if (child)
			{

				if (child.parent == container)
				{

					return container.removeChild(child);
				}

				return null;
			}
			return null;
		}

		/**
		 * 安全移除子元素按索引深度
		 * @param container 子元素所在容器
		 * @param index 子元素的所在深度
		 * @return 删除成功返回子元素，否者返回null。
		 *
		 */
		public static function removeChildAt(container:DisplayObjectContainer, index:int):DisplayObject
		{

			var child:DisplayObject = container.getChildAt(index);

			return DisplayUtil.removeChild(container, child);
		}

		/**
		 * 安全移除子元素按名称
		 * @param container 子元素所在容器
		 * @param name 子元素的名称
		 * @return 删除成功返回子元素，否者返回null。
		 *
		 */
		public static function removeChildByName(container:DisplayObjectContainer, name:String):DisplayObject
		{

			var child:DisplayObject = container.getChildByName(name);

			return DisplayUtil.removeChild(container, child);
		}

		/**
		 *  禁用鼠标交互
		 * @param arg
		 *
		 */
		public static function disableMouse(arg:InteractiveObject):void
		{
			if (arg is InteractiveObject)
			{
				arg.mouseEnabled = false;
			}
			if (arg is DisplayObjectContainer)
			{
				arg["mouseChildren"] = false;
			}
		}

		/**
		 * 将一个对象的X,Y,W,H设为跟另一个一样
		 * @param source
		 * @param target
		 *
		 */
		public static function copyXYWH(source:DisplayObject, target:DisplayObject):void
		{
			copyProperties(source, target, ['x', 'y', 'width', 'height']);
		}

		/**
		 * 复制显示对象属性
		 * @param source 需要复制的对象
		 * @param target 需要设置的对象
		 * @param properties 需要复制的属性数组列表。如 ['x','y','width','height'];
		 *
		 */
		public static function copyProperties(source:Object, target:Object, properties:Array):void
		{
			if (source && target)
			{
				for each (var i:String in properties)
				{

					if (source.hasOwnProperty(i))
						target[i] = source[i];

				}
			}
		}

		/**
		 * 设置按扭是否可用，并灰掉
		 * @param target
		 * @param enabled
		 *
		 */
		public static function setEnabled(target:InteractiveObject, enabled:Boolean):void
		{
			if (target == null)
				return;

			target.mouseEnabled = enabled;

			if (target.hasOwnProperty("mouseChildren"))
			{
				target["mouseChildren"] = enabled;
			}
			if (target.hasOwnProperty("buttonMode"))
			{
				target["buttonMode"] = enabled;
			}
			if (target.hasOwnProperty("enabled"))
			{
				target["enabled"] = enabled;
			}

			if (enabled)
			{
				target.filters = [];
			}
			else
			{
				/*var matrix:Array =
					[
						0.333, 0.333, 0.333,     0,     0,
						0.333, 0.333, 0.333,     0,     0,
						0.333, 0.333, 0.333,     0,     0,
						0,     0,     0,         1,     0
					];*/
				//0.299*R + 0.587*G + 0.114*B
				var matrix:Array = [0.299, 0.587, 0.114, 0, 0, 0.299, 0.587, 0.114, 0, 0, 0.299, 0.587, 0.114, 0, 0, 0, 0, 0, 1, 0];
				var colorFileter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
				target.filters = [colorFileter];
			}
		}

		/**
		 * 将obj摆在中心点pos上，点pos的参照系是targetCoordinateSpace
		 * */
		public static function centerObjAt(obj:DisplayObject, targetCoordinateSpace:DisplayObject, pos:Point):void
		{
			var rect:Rectangle = obj.getRect(targetCoordinateSpace);

			var currentCenterX:Number = rect.x + rect.width / 2;
			var currentCenterY:Number = rect.y + rect.height / 2;

			obj.x += pos.x - currentCenterX;
			obj.y += pos.y - currentCenterY;
		}

		/**
		 * 自适应全屏的窗口.
		 * 将窗口的宽度缩放至与屏幕宽相同
		 * 然后将高度不够的地方用某种给定的颜色填充
		 */
		public static function autoScaleWindow(window:Sprite, stageWidth:Number, stageHeight:Number, fillColor:uint = 0x666666):void
		{
			smoothingBitmap(window);
			//var scale:Number = Math.min(stageWidth / window.width, stageHeight / window.height);
			var scale:Number = stageWidth / window.width;
			window.scaleY = window.scaleX = scale;
			var unFill:Number = stageHeight - window.height;
			var fillBitmap:Bitmap = new Bitmap(new BitmapData(1, 1, false, fillColor));
			fillBitmap.width = stageWidth / scale;
			fillBitmap.height = stageHeight / scale;
			window.addChildAt(fillBitmap, 0);
		}

		/**
		 * 将target的所有儿子(包括儿子的儿子)名字以cache开头的替换为位图缓存
		 * 缓存位图会考虑到缩放问题.所以如果有必要需要把target的父容器的缩放值传入
		 * @param target
		 * @param parentScaleX
		 */
		public static function replaceAsBitmap(target:DisplayObjectContainer, parentScaleX:Number = 1, parentScaleY:Number = 1):void
		{
			const len:int = target.numChildren;
			var child:DisplayObject;
			var bitmap:Bitmap;
			var vWidth:Number;
			var vHeight:Number;
			for (var i:int = 0; i < len; i++)
			{
				child = target.getChildAt(i);
				if (child.name.indexOf("cache") == 0)
				{ //是以cache开头的
					//draw 
					vWidth = child.width * parentScaleX; //真实在舞台上看见的宽度
					vHeight = child.height * parentScaleY; //真实在舞台上看见的高度
					bitmap = new Bitmap(new BitmapData(vWidth, vHeight, true, 0), "auto", true);
					var matrix:Matrix = new Matrix();
					matrix.scale(parentScaleX, parentScaleY);
					//for air sdk 3.3
					try
					{
						bitmap.bitmapData["drawWithQuality"](child, matrix, null, null, null, true, StageQuality.HIGH);
					}
					catch (err:Error)
					{
						if (stage)
							stage.quality = StageQuality.HIGH;
						bitmap.bitmapData.draw(child, matrix);
						if (stage)
							stage.quality = StageQuality.LOW;
					}
//					bitmap.bitmapData.draw(child,matrix);
					//clone
					bitmap.name = child.name;
					bitmap.x = child.x;
					bitmap.y = child.y;
					bitmap.width = child.width;
					bitmap.height = child.height;

					target.addChildAt(bitmap, target.getChildIndex(child));
					target.removeChild(child);
				}
				else if (child is DisplayObjectContainer)
					replaceAsBitmap(child as DisplayObjectContainer, target.scaleX * parentScaleX, target.scaleY * parentScaleY);
			}
		}



		/**
		 * 1.将SimpleButtun的内容都转化为位图.
		 * 2.以原尺寸的scale倍draw位图，然后位图又以1/scale的缩放放到SimpleButton里.
		 * 这样的目的是让SimpleButton缩放到scale时，不会出现锯齿
		 * 3.upState和overState使用同一个Bitmap，downState使用相同的BitmapData，但往右下10 * scale pixs
		 *
		 * @param btn
		 * @param scale
		 * @transparent 供测试绘制边界用
		 * @return
		 *
		 */
		static public function cacheSimpleButton(btn:SimpleButton, scale:Number = 1.0, transparent:Boolean = true):BitmapData
		{
			btn.downState = btn.upState;
			btn.overState = btn.upState;
			btn.hitTestState = btn.upState;

			var scaleSelfBounds:Rectangle = btn.upState.getBounds(null).clone();
			scaleSelfBounds.x *= scale;
			scaleSelfBounds.y *= scale;
			scaleSelfBounds.width *= scale;
			scaleSelfBounds.height *= scale;
			var parentBounds:Rectangle = btn.upState.getBounds(btn);

			var bpd:BitmapData = new BitmapData(scaleSelfBounds.width, scaleSelfBounds.height, transparent, 0xff0000);
			var mtx:Matrix = new Matrix();
			//注意先scale再translate
			mtx.scale(scale, scale);
			mtx.translate(-scaleSelfBounds.x, -scaleSelfBounds.y);

			try
			{
				bpd["drawWithQuality"](btn.upState, mtx, null, null, null, false, StageQuality.HIGH);
			}
			catch (err:Error)
			{
				stage.quality = StageQuality.HIGH;
				bpd.draw(btn.upState, mtx);
				stage.quality = StageQuality.LOW;
			}


			var bmp:Bitmap = new Bitmap(bpd);
			bmp.width = parentBounds.width;
			bmp.height = parentBounds.height;
			bmp.x = parentBounds.x;
			bmp.y = parentBounds.y;

			btn.upState = btn.overState = btn.hitTestState = bmp;

			//downState一律往右下10 * scale pixs
			bmp = new Bitmap(bpd);
			bmp.width = parentBounds.width;
			bmp.height = parentBounds.height;
			bmp.x = parentBounds.x + 10;
			bmp.y = parentBounds.y + 10;
			btn.downState = bmp;

			return bpd;
		}


		/**
		 *
		 * @param target
		 * @param scale
		 * @param transparent 供测试绘制边界用
		 * @return
		 *
		 */
		public static function cacheSprite(target:Sprite, scale:Number = 1.0, replace:Boolean = true, transparent:Boolean = true):Bitmap
		{
			var oriBounds:Rectangle = target.getBounds(target);
			var bounds:Rectangle = oriBounds.clone();

			var bpd:BitmapData = new BitmapData(bounds.width, bounds.height, transparent, 0xff0000);
			var mtx:Matrix = new Matrix();
			//注意先translate再scale
			mtx.translate(-bounds.x, -bounds.y);
			mtx.scale(scale, scale);

			try
			{
				bpd["drawWithQuality"](target, mtx, null, null, null, false, StageQuality.HIGH);
			}
			catch (err:Error)
			{
				stage.quality = StageQuality.HIGH;
				bpd.draw(target, mtx);
				stage.quality = StageQuality.LOW;
			}

			var bmp:Bitmap = new Bitmap(bpd);
			bmp.x = oriBounds.x;
			bmp.y = oriBounds.y;
			bmp.width = oriBounds.width;
			bmp.height = oriBounds.height;

			if (replace)
			{
				target.removeChildren();
				target.addChild(bmp);
			}

			return bmp;
		}


		/**
		 *
		 * @param target
		 * @framesForCache Identifies which frames would being cached.
		 */
		static public function cacheMCFrames(target:MovieClip, scale:Number, framesForCache:Vector.<int> = null):void
		{
			var n:int = target.totalFrames;
			var bmp:Bitmap;
			for (var i:int = 1; i <= n; i++)
			{
				if (framesForCache != null && framesForCache.indexOf(i) < 0)
					continue;
				target.gotoAndStop(i);
				cacheSprite(target, scale);
			}
		}



		public static function cacheAsBitmap(source:DisplayObject, scaleX:Number, scaleY:Number, transparnt:Boolean = true, gap:int = 0):BitmapFrame
		{
			source.scaleX *= scaleX;
			source.scaleY *= scaleY;
			var rect:Rectangle = source.getBounds(source);
			var mtx:Matrix = source.transform.matrix.clone();
			mtx.tx = -rect.x * source.scaleX + gap;
			mtx.ty = -rect.y * source.scaleY + gap;
			var w:int = source.width + gap * 2;
			var h:int = source.height + gap * 2;
			if (w == 0)
				w = 1;
			if (h == 0)
				h = 1;
			var bitmapdata:BitmapData = new BitmapData(w, h, transparnt, 0);
			bitmapdata.drawWithQuality(source, mtx, null, null, null, true, StageQuality.HIGH);
//			for (var i:int = -3; i < 3; i++)
//				for (var k:int = -3; k < 3; k++)
//					bitmapdata.setPixel(mtx.tx + i, mtx.ty + k, 0xFF0000);
			source.scaleX /= scaleX;
			source.scaleY /= scaleY;
			var frame:BitmapFrame = new BitmapFrame();
			frame.bmd = bitmapdata;
			frame.x = mtx.tx;
			frame.y = mtx.ty;
			frame.scaleX = 1/scaleX;
			frame.scaleY = 1/scaleY;
			return frame;
		}


		public static function smoothingBitmap(target:DisplayObjectContainer):void
		{
			const len:int = target.numChildren;
			var child:DisplayObject;
			for (var i:int = 0; i < len; i++)
			{
				if (child is DisplayObjectContainer)
					smoothingBitmap(child as DisplayObjectContainer);
				else if (child is Bitmap)
					Bitmap(child).smoothing = true;
			}
		}

		/**
		 * 将容器中所有有滤镜的textFiled都替换为位图
		 * @param container
		 */
		public static function replaceFilterTextFiledAsBitmap(container:DisplayObjectContainer):void
		{
			const len:int = container.numChildren;
			var child:DisplayObject;
			var tf:TextField;
			for (var i:int = 0; i < len; i++)
			{
				child = container.getChildAt(i);
				if (child is DisplayObjectContainer)
					replaceFilterTextFiledAsBitmap(child as DisplayObjectContainer);
				else if (child is TextField)
				{
					tf = child as TextField;
					if (tf.filters != null && tf.filters.length > 0)
					{
						/**滤镜一般会超出文本的大小,所以多draw一点**/
						var matrix:Matrix = new Matrix();
						matrix.translate(5, 5);
						var cache:Bitmap = new Bitmap(new BitmapData(tf.textWidth + 10, tf.textHeight + 10, true, 0), "auto", true);
						cache.x = tf.x - 3;
						cache.y = tf.y - 3;
						//cache.bitmapData.drawWithQuality(tf, matrix, null, null, null, true, StageQuality.BEST);
						if (stage)
							stage.quality = StageQuality.HIGH;
						cache.bitmapData.draw(child, matrix);
						if (stage)
							stage.quality = StageQuality.LOW;
						container.addChildAt(cache, container.getChildIndex(tf));
						container.removeChild(tf);
					}
				}
			}
		}

		public static function getRealitySizeOf(tf:TextField):Point
		{
			var w:Number = tf.textWidth, h:Number = tf.textHeight;
			if (tf.filters != null && tf.filters.length > 0)
			{
				const len:int = tf.filters.length;
				for (var i:int = 0; i < len; i++)
				{
					if (tf.filters[i] is GlowFilter)
					{
						w += GlowFilter(tf.filters[i]).blurX;
						h += GlowFilter(tf.filters[i]).blurY;
					}
				}
			}
			return new Point(w, h);
		}

		/**
		 * 获取某个显示对象的注册点
		 * 约定显示对象的包围矩形的左上角为0 0位置
		 * @return
		 */
		public static function getRegPointOf(displayObj:DisplayObject):Point
		{
			var rect:Rectangle = displayObj.getRect(displayObj);
			return new Point(-rect.x, -rect.y);
		}


		public static function delBoldTag(htmlTxt:String):String
		{
			var str:String = htmlTxt;
			str = str.replace(/<b>/g, "");
			str = str.replace(/<\/b>/g, "");
			return str;
		}

		/**
		 * 递归计算无代码素材最大帧数
		 * @param	clip	被计算MovieClip剪辑对象
		 * @param   recursion 递归次数 -1表示无穷
		 * @param	offset	该参数为递归辅助参数，使用时请保持默认
		 * @return
		 */
		public static function caculateTotalFrames(clip:MovieClip, recursion:int = -1, offset:int = 0):int
		{
			var child:DisplayObject;
			var length:int = clip.totalFrames;
			if (recursion == 0)
				return length + offset;
			var position:int, totalFrames:int = 0;
			var currentFrame:int = clip.currentFrame;
			for (var i:int = 1; i <= length; i++)
			{
				clip.gotoAndStop(i);
				var depth:int = clip.numChildren;
				for (var j:int = 0; j < depth; j++) //遍历当前帧的所有原件
				{
					position = offset + i; //position表示这个原件是在第几帧出现的
					child = clip.getChildAt(j);
					if (child is MovieClip)
						position = caculateTotalFrames(child as MovieClip, recursion - 1, position - 1); //这个元件的totalframe
					if (totalFrames < position)
						totalFrames = position;
				}
			}
			clip.gotoAndPlay(currentFrame);
			return totalFrames;
		}

		public static function gotoAndStop0(mc:DisplayObjectContainer):void
		{
			if (mc is MovieClip)
				MovieClip(mc).gotoAndStop(1);
			const len:int = mc.numChildren;
			var child:DisplayObject;
			for (var i:int = 0; i < len; i++)
			{
				child = mc.getChildAt(i);
				if (child is DisplayObjectContainer)
					gotoAndStop0(child as DisplayObjectContainer);
			}
		}
	}
}
