package com.arm.herolot.modules.battle.view.map.entities
{
	import com.arm.herolot.HerolotApplication;
	import com.arm.herolot.model.config.AppConfig;
	import com.arm.herolot.model.config.mapEntities.MapEntitiesConfig;
	import com.arm.herolot.modules.battle.model.MapGridModel;
	import com.arm.herolot.modules.battle.view.texture.BattleTexture;
	import com.snsapp.starling.texture.TextureLoadEvent;
	import com.snsapp.starling.texture.implement.TextureBase;
	
	import starling.display.Sprite;

	public class EntityRender extends Sprite
	{
		private var _texture:BattleTexture;
		public function EntityRender()
		{
		}
		
		public function validate(id:int):void
		{
			var entitySwf:String = AppConfig.mapEntitiesConfigModel.getMapEntitiesConfigByID(id).SWF;
			var textureName:String = HerolotApplication.instance.textureLoader.getCacheURL(entitySwf);
			HerolotApplication.instance.textureLoader.addEventListener(TextureLoadEvent.COMPLETE, onloadTexture);
			HerolotApplication.instance.textureLoader.requestTexture(entitySwf, false);
			
			function onloadTexture(evt:TextureLoadEvent):void
			{
				if(evt.texture.name == textureName)
				{
					HerolotApplication.instance.textureLoader.removeEventListener(TextureLoadEvent.COMPLETE, onloadTexture);
					onLoadTexture(evt.texture);
				}
			}
		}
		
		protected function onLoadTexture(texture:TextureBase):void
		{
		}
	}
}