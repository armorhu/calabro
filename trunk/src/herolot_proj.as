package
{
	import com.arm.herolot.HerolotApplication;
	import com.arm.herolot.services.utils.Csv2asCommand;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageOrientation;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.StageOrientationEvent;
	import flash.filesystem.File;

	[SWF(backgroundColor = "0x000000", frameRate = '60')]
	public class herolot_proj extends Sprite
	{
		private var _app:HerolotApplication;
		
		public function herolot_proj()
		{
			super();
			trace(File.applicationStorageDirectory.nativePath);
			
			// 支持 autoOrient
			if (this.stage)
				initlaize(null);
			else
				addEventListener(Event.ADDED_TO_STAGE, initlaize);
		}
		
		private function initlaize(e:Event):void
		{
			if (e)
				removeEventListener(Event.ADDED_TO_STAGE, initlaize);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			_app = new HerolotApplication("cala_brother");
			_app.startup(this);
			stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGING, onOrientationChanging);
		}
		
		/**only support landscape mode*/
		private function onOrientationChanging(event:StageOrientationEvent):void
		{
			// If the stage is about to move to an orientation we don't support, lets prevent it 
			// from changing to that stage orientation. 
			if (event.afterOrientation == StageOrientation.ROTATED_LEFT || event.afterOrientation == StageOrientation.ROTATED_RIGHT)
				event.preventDefault();
		}
	}
}
