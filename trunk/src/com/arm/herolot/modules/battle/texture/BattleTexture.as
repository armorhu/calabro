package com.arm.herolot.modules.battle.texture
{
	import com.arm.herolot.Vars;
	import com.qzone.qfa.interfaces.IApplication;
	import com.snsapp.starling.texture.CacheableTexture;

	import flash.geom.Point;

	public class BattleTexture extends CacheableTexture
	{
		private static const TEXTURE_LEVEL:Vector.<Point> = new <Point>[ //
			new Point(1024, 512), //
			new Point(512, 512), //
			new Point(512, 256), //
			new Point(256, 256), //
			];

		public function BattleTexture(app:IApplication)
		{
			super(app, '_battle_');
			this._texture_level_scales = new <Number>[1, 0.53, 0.53, 0.26];
			this._texture_level_sizes = TEXTURE_LEVEL;
			this._exportPNG = true;
		}

		protected override function buildMainTexture():void
		{
			super.buildMainTexture();
			var scale:Number = Vars.starlingScreenScale;
			/**以下素材的linkage在fla/external/battle.fla
			 * 新增一个素材请:
			 * 1 在battle.fla新建一个元件，并定义linkage
			 * 2 编译battle.fla 输出 battle.swf(battle.swf在【assets/res/swf/】目录下)
			 * 3 清理工程。
			 * 4 在下面添加相应的insert代码。
			 * **/

			for (var i:int = 0; i < 5; i++)
			{
				insert(GROUND + i, GROUND + i, scale);
				insert(BLOCK + i, BLOCK + i, scale);
			}
			insert(LOCK_FLAG, LOCK_FLAG, scale);
			insert(UNREACHABLE_FLAG, UNREACHABLE_FLAG, scale);
			insert(TF_BG, TF_BG, scale);
			insert(EQUIP_BOX, EQUIP_BOX, scale);
		}


		public static const GROUND:String = 'ground_';
		public static const BLOCK:String = 'block_';
		public static const LOCK_FLAG:String = 'lock_flag';
		public static const UNREACHABLE_FLAG:String = 'unReach_flag';
		public static const TF_BG:String = 'tf_bg';
		public static const EQUIP_BOX:String = 'EquipBox';
	}
}
