package com.arm.herolot.modules.launch.texture
{
	import com.arm.herolot.Vars;
	import com.qzone.qfa.interfaces.IApplication;
	import com.snsapp.mobile.view.spritesheet.SpriteSheet;
	import com.snsapp.starling.texture.CacheableTexture;

	import flash.geom.Point;

	public class LaunchTexture extends CacheableTexture
	{
		private static const TEXTURE_LEVEL:Vector.<Point> = new <Point>[ //
			new Point(1024, 1024), //
			new Point(1024, 512), //
			new Point(512, 512), //
			new Point(512, 256), //
			];

		public function LaunchTexture(app:IApplication)
		{
			super(app, '_launch_');
			this._texture_level_scales = new <Number>[1, 0.53, 0.53, 0.26];
			this._texture_level_sizes = TEXTURE_LEVEL;
//			this._exportPNG = true;
//			this._computeTextureLevelScales = true;
		}

		protected override function buildMainTexture():void
		{
			super.buildMainTexture();
			var scale:Number = Vars.starlingScreenScale;
			insert(MAIN_BG, MAIN_BG, scale); //主背景
			insert(TF_BG, TF_BG, scale); //文本框底板
			insert(START_BTN, START_BTN, scale); //开始按钮
			insert(PRE_BTN, PRE_BTN, scale);
			insert(OK_BTN, OK_BTN, scale);
			insert(BACK_BTN, BACK_BTN, scale);
			insert(NEXT_BTN, NEXT_BTN, scale);
			insert(BTN_UPGRADE, BTN_UPGRADE, scale);
		}

		public static const TF_BG:String = 'tf_bg';
		public static const MAIN_BG:String = 'main_bg';
		public static const START_BTN:String = 'btnStart';

		public static const OK_BTN:String = 'btnOK';
		public static const BACK_BTN:String = 'btnBack';
		public static const NEXT_BTN:String = 'btnNext';
		public static const PRE_BTN:String = 'btnPre';
		public static const BTN_UPGRADE:String = 'btnUpgrade';
	}
}
