package com.snsapp.mobile.utils
{
	import com.qzone.qfa.interfaces.IApplication;
	import com.snsapp.mobile.StageInstance;
	import com.snsapp.mobile.view.ScreenAdaptiveUtil;
	import com.snsapp.mobile.view.bmpLib.BitmapSprite;
	import com.snsapp.mobile.view.bmpLib.EmbedTextField;
	import com.snsapp.mobile.view.bmpLib.Scale9GridSprite;
	
	import flash.display.Sprite;
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
		private var _tipUI:Class;
		private var _dialogUI:Class;
		private var _fontName:String;
//		private var _stageWidth:Number;
//		private var _stageHeight:Number;



		public function MessageBoxHelper(app:IApplication, //app
			fontName:String, //字体
			stageWidth:Number, //舞台宽
			stageHeight:Number, //舞台高
			tipUI:Class, //ui
			dialogUI:Class)
		{
			_app=app;
			_fontName=fontName;
//			_stageWidth=stageWidth;
//			_stageHeight=stageHeight;
			_tipUI=tipUI;
			_dialogUI=dialogUI;
		}

		private var _tipMC:Scale9GridSprite;

		public function showAlert(msg:String, delay:int=1000, textWidth:uint=0):void
		{
			if (msg == null || msg == "")
				return;
			_screenScale=ScreenAdaptiveUtil.SCALE_COMPARED_TO_IP4.maxScale;
			if (_tipMC == null)
			{
				var layer:Sprite=_app.appStage.getChildByName("tipLayer") as Sprite;
				layer.mouseChildren=layer.mouseEnabled=false;

				var tipView:Sprite=new _tipUI;
				_tipMC=new Scale9GridSprite(tipView, 24, 24);
				var msgTF:EmbedTextField=new EmbedTextField(_fontName, _screenScale, 24, 0x591806, "CC");
				msgTF.multiline=true;
				msgTF.htmlText=msg;

				_tipMC.width=msgTF.width + 180 * _screenScale;
				_tipMC.height=msgTF.height + 80 * _screenScale;
				_tipMC.createSprite();

				msgTF.x=(_tipMC.width - msgTF.width) * .5;
				msgTF.y=(_tipMC.height - msgTF.height) * .5;
				_tipMC.addChild(msgTF);

				_tipMC.x=(StageInstance.stage.stageWidth - _tipMC.width) * .5;
				_tipMC.y=(StageInstance.stage.stageHeight - _tipMC.height) * .5;


				layer.addChild(_tipMC);
				setTimeout(removeAlert, delay);
			}
		}

		private function removeAlert():void
		{
			if (_tipMC != null)
			{
				var layer:Sprite=_app.appStage.getChildByName("tipLayer") as Sprite;
				layer.removeChild(_tipMC);
				_tipMC=null;
			}
		}

		private var _dialogs:Vector.<DialogItem>=new Vector.<DialogItem>();

		public function showDialog(msg:String, okCall:Function, okParam:Object=null, single:Boolean=false, cancelCall:Function=null, cancelParam:Object=null):void
		{
			if (msg == null || msg == "")
				return;
			
			var stageWidth:Number = _app.appStage.stage.stageWidth;
			var stageHeight:Number = _app.appStage.stage.stageHeight;
			
			var _msgTF:EmbedTextField;
			var _okBtn:BitmapSprite;
			var _cancelBtn:BitmapSprite;
			_screenScale=ScreenAdaptiveUtil.SCALE_COMPARED_TO_IP4.maxScale;
			var hasCancelCall:Boolean;
			var _dialogMC:Sprite;
			var dialogView:Sprite=new _dialogUI;
			_dialogMC=new Scale9GridSprite(dialogView.getChildByName('bgMC'), 24, 24);
			var msgTF:EmbedTextField=new EmbedTextField(_fontName, _screenScale, 24, 0x813401, "CC");
			msgTF.htmlText=msg;

			//当信息文本框过小（当embed字体不存在时）时，取消embed。
//			if (msgTF.width <= 5.0 || msgTF.height <= 5.0)
//				msgTF.embedFonts = false;

			_dialogMC.width=msgTF.width + 150 * _screenScale;
			_dialogMC.height=msgTF.height + 180 * _screenScale;
			Scale9GridSprite(_dialogMC).createSprite();

			msgTF.x=(_dialogMC.width - msgTF.width) * .5;
			msgTF.y=(_dialogMC.height - msgTF.height) * .3;

			_dialogMC.addChild(msgTF);

			_okBtn=new BitmapSprite(dialogView.getChildByName('okBtn'), _screenScale);
			_okBtn.name='btnOK';
			_okBtn.y=_dialogMC.height * .65;

			_cancelBtn=new BitmapSprite(dialogView.getChildByName('cancelBtn'), _screenScale);
			_cancelBtn.name='btnCancel';

			_dialogMC.x=(stageWidth - _dialogMC.width) >> 1;
			_dialogMC.y=(stageHeight - _dialogMC.height) >> 1;

			if (single)
			{
				_okBtn.x=_dialogMC.width * .5 - _okBtn.width * .5;
			}
			else
			{
				_okBtn.x=_dialogMC.width * .5 - _okBtn.width * 1.5;

				_cancelBtn.x=_dialogMC.width * .5 + _cancelBtn.width * .5;
				_cancelBtn.y=_dialogMC.height * .65;
				_dialogMC.addChild(_cancelBtn);
				if (cancelCall != null)
					hasCancelCall=true;
			}
			_dialogMC.addChild(_okBtn);
			addDialog(_dialogMC, okCall, cancelCall);
		}

		private function clickDialog(evt:MouseEvent):void
		{
			//只有最上面的面板能触发事件。 
			var targetName:String=evt.target['name'];
			var item:DialogItem=_dialogs[_dialogs.length - 1];
			if (item.clickHandler != null)
				item.clickHandler(targetName);
			if (targetName == 'btnOK' || targetName == 'btnCancel' || targetName == 'btnClose')
			{
				if (targetName == 'btnOK')
				{
					if (item.okCall != null)
						item.okCall();
				}
				else
				{
					if (item.cancelCall != null)
						item.cancelCall();
				}
				removeDialog(item);
			}
		}


		private function addDialog(_dialogMC:Sprite, okCall:Function, cancelCall:Function=null, clickHandler:Function=null, modal:Boolean=true):void
		{
			var stageWidth:Number = _app.appStage.stage.stageWidth;
			var stageHeight:Number = _app.appStage.stage.stageHeight;
			//添加之前把这个框移除先。
			removeCustomDialog(_dialogMC);
			var item:DialogItem=new DialogItem();
			item.dialog=_dialogMC;
			item.okCall=okCall;
			item.cancelCall=cancelCall;
			item.clickHandler=clickHandler;
			var layer:Sprite=_app.appStage.getChildByName("dialogLayer") as Sprite;
			layer.mouseChildren=layer.mouseEnabled=true;
			if (modal)
			{
				var maskMC:Sprite=GraphicsUtil.createMaskSprite(0, 0, stageWidth * 2, stageHeight * 2); //在手机端stage.stageWidth是不准的。//StageInstance.stage.stageWidth, StageInstance.stage.stageHeight);
				item.mask=maskMC;
				maskMC.x=-stageWidth, maskMC.y=-stageHeight;
				_dialogMC.addChildAt(maskMC, 0);
			}
			_dialogs.push(item);
			_dialogMC.addEventListener(MouseEvent.CLICK, clickDialog);
			layer.addChild(_dialogMC);
		}

		private function removeDialog(item:DialogItem):void
		{
			if (item)
			{
				var index:int=_dialogs.indexOf(item);
				if(index == -1)return;
				var layer:Sprite=_app.appStage.getChildByName("dialogLayer") as Sprite;
				layer.removeChild(item.dialog);
				if (item.mask)
					item.dialog.removeChild(item.mask);
				item.dialog.removeEventListener(MouseEvent.CLICK, clickDialog);
				_dialogs.splice(index, 1);
			}
		}

		private function hasDialog(dialog:Sprite):Boolean
		{
			return getDialogItem(dialog) != null;
		}

		private function getDialogItem(dialog:Sprite):DialogItem
		{
			const len:int=_dialogs.length;
			for (var i:int=0; i < len; i++)
				if (dialog == _dialogs[i].dialog)
					return _dialogs[i];
			return null;
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
		public function showCustomDialog(dialog:Sprite, clickHandler:Function=null, modal:Boolean=true, okCall:Function=null, cancelCall:Function=null):Sprite
		{
			var stageWidth:Number = _app.appStage.stage.stageWidth;
			var stageHeight:Number = _app.appStage.stage.stageHeight;
			
			_screenScale=ScreenAdaptiveUtil.SCALE_COMPARED_TO_IP4.maxScale;
			_screenScale=1;
			var layer:Sprite=_app.appStage.getChildByName("dialogLayer") as Sprite;
			dialog.scaleX*=_screenScale;
			dialog.scaleY*=_screenScale;
			var bounds:Rectangle=dialog.getBounds(dialog);
			bounds.x*=_screenScale, bounds.y*=_screenScale;
			dialog.x=stageWidth >> 1
			dialog.y=stageHeight >> 1;
			addDialog(dialog, okCall, cancelCall, clickHandler, modal);

			return dialog;
		}

		/**
		 * 移除自定义对话框
		 */
		public function removeCustomDialog(dialog:Sprite):void
		{
			var item:DialogItem=getDialogItem(dialog);
			removeDialog(item);
		}
		
		
		public function removeAllDialog():void
		{
			while(_dialogs.length)
				removeDialog(_dialogs[0]);
		}
	}
}
import flash.display.Sprite;

class DialogItem
{
	public var dialog:Sprite;
	public var okCall:Function;
	public var cancelCall:Function;
	public var clickHandler:Function;
	public var mask:Sprite;

	public function DialogItem()
	{

	}
}
