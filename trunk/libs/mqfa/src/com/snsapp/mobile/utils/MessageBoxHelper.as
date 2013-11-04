package com.snsapp.mobile.utils
{
	import com.qzone.qfa.interfaces.IApplication;
	import com.snsapp.mobile.StageInstance;
	import com.snsapp.mobile.view.ScreenAdaptiveUtil;
	import com.snsapp.mobile.view.bmpLib.BitmapSprite;
	import com.snsapp.mobile.view.bmpLib.EmbedTextField;
	import com.snsapp.mobile.view.bmpLib.Scale9GridSprite;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;

	/**################################
	 * @MessageBoxHelper
	 * @author sevencchen
	 * @2012-9-1下午4:13:45
	 * ###################################
	 */
	public class MessageBoxHelper extends EventDispatcher
	{
		private var _app:IApplication;
		private var _screenScale:Number;
		private var _msgTF:EmbedTextField;
		private var _okBtn:BitmapSprite;
		private var _cancelBtn:BitmapSprite;
		private var _closeBtn:BitmapSprite;

		private var _tipUI:Class;
		private var _dialogUI:Class;
		private var _fontName:String;
		private var _stageWidth:Number;
		private var _stageHeight:Number;



		public function MessageBoxHelper(app:IApplication, //app
			fontName:String, //字体
			stageWidth:Number, //舞台宽
			stageHeight:Number, //舞台高
			tipUI:Class, //ui
			dialogUI:Class)
		{
			_app = app;
			_fontName = fontName;
			_stageWidth = stageWidth;
			_stageHeight = stageHeight;
			_tipUI = tipUI;
			_dialogUI = dialogUI;
		}

		private var _tipMC:Scale9GridSprite;

		public function showAlert(msg:String, delay:int = 1000, textWidth:uint = 0):void
		{
			if (msg == null || msg == "")
				return;
			_screenScale = ScreenAdaptiveUtil.SCALE_COMPARED_TO_IP4.maxScale;
			if (_tipMC == null)
			{
				var layer:Sprite = _app.appStage.getChildByName("tipLayer") as Sprite;
				layer.mouseChildren = layer.mouseEnabled = false;

				var tipView:Sprite = new _tipUI;
				_tipMC = new Scale9GridSprite(tipView, 24, 24);
				var msgTF:EmbedTextField = new EmbedTextField(_fontName, _screenScale, 24, 0x591806, "CC");
				msgTF.multiline = true;
				msgTF.htmlText = msg;

				_tipMC.width = msgTF.width + 180 * _screenScale;
				_tipMC.height = msgTF.height + 80 * _screenScale;
				_tipMC.createSprite();

				msgTF.x = (_tipMC.width - msgTF.width) * .5;
				msgTF.y = (_tipMC.height - msgTF.height) * .5;
				_tipMC.addChild(msgTF);

				_tipMC.x = (StageInstance.stage.stageWidth - _tipMC.width) * .5;
				_tipMC.y = (StageInstance.stage.stageHeight - _tipMC.height) * .5;


				layer.addChild(_tipMC);
				setTimeout(removeAlert, delay);
			}
		}

		private function removeAlert():void
		{
			if (_tipMC != null)
			{
				var layer:Sprite = _app.appStage.getChildByName("tipLayer") as Sprite;
				layer.removeChild(_tipMC);
				_tipMC = null;
			}
		}

		private var _dialogMC:Sprite;

		public function showDialog(msg:String, okCall:Function, okParam:Object = null, single:Boolean = false, cancelCall:Function = null, cancelParam:Object = null):void
		{
			if (msg == null || msg == "")
				return;
			_screenScale = ScreenAdaptiveUtil.SCALE_COMPARED_TO_IP4.maxScale;
			var hasCancelCall:Boolean;
			if (_dialogMC == null)
			{

				var layer:Sprite = _app.appStage.getChildByName("dialogLayer") as Sprite;
				layer.mouseChildren = layer.mouseEnabled = true;

				var maskMC:Sprite = GraphicsUtil.createMaskSprite(0, 0, _stageWidth, _stageHeight); //在手机端stage.stageWidth是不准的。//StageInstance.stage.stageWidth, StageInstance.stage.stageHeight);
				maskMC.name = "maskMC";
				layer.addChild(maskMC);

				var dialogView:Sprite = new _dialogUI;
				_dialogMC = new Scale9GridSprite(dialogView.getChildByName('bgMC'), 24, 24);

				var msgTF:EmbedTextField = new EmbedTextField(_fontName, _screenScale, 24, 0x813401, "CC");
				msgTF.htmlText = msg;

				_dialogMC.width = msgTF.width + 150 * _screenScale;
				_dialogMC.height = msgTF.height + 180 * _screenScale;
				Scale9GridSprite(_dialogMC).createSprite();

				msgTF.x = (_dialogMC.width - msgTF.width) * .5;
				msgTF.y = (_dialogMC.height - msgTF.height) * .3;

				_dialogMC.addChild(msgTF);

				_okBtn = new BitmapSprite(dialogView.getChildByName('okBtn'), _screenScale);
				_okBtn.y = _dialogMC.height * .65;

				_cancelBtn = new BitmapSprite(dialogView.getChildByName('cancelBtn'), _screenScale);

				_dialogMC.x = (_stageWidth - _dialogMC.width) * .5;
				_dialogMC.y = (StageInstance.stage.stageHeight - _dialogMC.height) * .5;

				layer.addChild(_dialogMC);

				_okBtn.addEventListener(MouseEvent.CLICK, okFunction);

				if (single)
				{
					_okBtn.x = _dialogMC.width * .5 - _okBtn.width * .5;
				}
				else
				{
					_okBtn.x = _dialogMC.width * .5 - _okBtn.width * 1.5;

					_cancelBtn.x = _dialogMC.width * .5 + _cancelBtn.width * .5;
					_cancelBtn.y = _dialogMC.height * .65;
					_cancelBtn.addEventListener(MouseEvent.CLICK, cancelFunction);
					_dialogMC.addChild(_cancelBtn);

					if (cancelCall != null)
						hasCancelCall = true;
				}

				_dialogMC.addChild(_okBtn);

			}
			function okFunction(e:MouseEvent):void
			{
				dispatchEvent(new MouseEvent(MouseEvent.CLICK));
//				_app.playSound(Consts.SOUND_CLICK);
				e.stopPropagation();
				_okBtn.removeEventListener(MouseEvent.CLICK, okFunction);
				removeDialog();
				if (okParam != null)
					okCall(okParam);
				else
				{
					if (okCall != null)
						okCall();
					else
						removeDialog();
				}
			}
			function cancelFunction(e:MouseEvent):void
			{
				dispatchEvent(new MouseEvent(MouseEvent.CLICK));
//				_app.playSound(Consts.SOUND_CLICK);
				e.stopPropagation();
				_cancelBtn.removeEventListener(MouseEvent.CLICK, cancelFunction);
				if (hasCancelCall)
				{
					if (cancelParam != null)
						cancelCall(cancelParam);
					else
						cancelCall();
				}
				removeDialog();
			}
			function closeFunction(e:MouseEvent):void
			{
				dispatchEvent(new MouseEvent(MouseEvent.CLICK));
				removeDialog();
			}
		}

		private function removeDialog():void
		{
			if (_dialogMC != null)
			{
				var layer:Sprite = _app.appStage.getChildByName("dialogLayer") as Sprite;
				var maskMC:Sprite = layer.getChildByName("maskMC") as Sprite;
				if (maskMC)
					layer.removeChild(maskMC);
				layer.removeChild(_dialogMC);
				_dialogMC = null;
			}
		}

		/**
		 * 显示用户自定义的框框.<p/>
         * 如果dialog发出Event.CLOSE事件，会自动关闭。不触发任何handler。<p/>
		 * 当dialog中有名为‘btnOK’,'btnCancel','btnClose'时，点击他们都会关闭这个框框。并触发clickHandler.<bt/>
		 *        function clickHandler(btnName:String):void
		 * 		  {
		 * 			if(btnName == 'btnOK'){
		 * 			}
		 * 			else if(btnName == 'btnCancel'){
		 * 			}
		 * 		  	else if(btnName == 'btnClose'){
		 * 			}
		 * 		  }
         * 
         * 
		 * @param dialog.
		 * @param modal.
		 * @param clickHandler 点击事件的回调函数.
		 */
		public function showCustomDialog(dialog:Sprite, clickHandler:Function = null, modal:Boolean = true):void
		{
			if (_dialogMC == null)
			{
				_screenScale = ScreenAdaptiveUtil.SCALE_COMPARED_TO_IP4.maxScale;
				var layer:Sprite = _app.appStage.getChildByName("dialogLayer") as Sprite;
				if (modal)
				{
					var maskMC:Sprite = GraphicsUtil.createMaskSprite(0, 0, _stageWidth, _stageHeight); //在手机端stage.stageWidth是不准的。//StageInstance.stage.stageWidth, StageInstance.stage.stageHeight);
					maskMC.name = "maskMC";
					layer.addChild(maskMC);
				}
				dialog.scaleX *= _screenScale;
				dialog.scaleY *= _screenScale;
				var bounds:Rectangle = dialog.getBounds(dialog);
				bounds.x *= _screenScale, bounds.y *= _screenScale;
				dialog.x = (_stageWidth - dialog.width) / 2 - bounds.x;
				dialog.y = (_stageHeight - dialog.height) / 2 - bounds.y;
				layer.addChild(dialog);
				_dialogMC = dialog;
                
                dialog.addEventListener(Event.CLOSE, onClose);
				dialog.addEventListener(MouseEvent.CLICK, onClickDialog);
			}

			function onClickDialog(e:MouseEvent):void
			{
				var targetName:String = e.target.name;
				if (targetName == 'btnOK' || targetName == 'btnCancel' || targetName == 'btnClose')
				{
                    dialog.removeEventListener(Event.CLOSE, onClose);
                    dialog.removeEventListener(MouseEvent.CLICK, onClickDialog);
					removeDialog();
					if (clickHandler != null)
						clickHandler(targetName);
				}
			}
            
            function onClose():void
            {
                dialog.removeEventListener(Event.CLOSE, onClose);
                dialog.removeEventListener(MouseEvent.CLICK, onClickDialog);
                removeDialog();
            }
		}
		
		/**
		 * 移除自定义对话框 
		 */	
		public function removeCustomDialog(dialog:Sprite):void
		{
			removeDialog();
			
			//FIXME dialog这里最好能支持多个Dialog并发 
		}
	}
}
