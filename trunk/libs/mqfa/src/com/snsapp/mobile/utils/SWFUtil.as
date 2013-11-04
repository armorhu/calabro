package com.snsapp.mobile.utils
{
	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.SWFSymbol;
	import com.codeazur.as3swf.swftags.ITag;
	import com.codeazur.as3swf.swftags.TagDoABC;
	import com.codeazur.as3swf.swftags.TagDoABCDeprecated;
	import com.codeazur.as3swf.swftags.TagEnd;
	import com.codeazur.as3swf.swftags.TagPlaceObject2;
	import com.codeazur.as3swf.swftags.TagShowFrame;
	import com.codeazur.as3swf.swftags.TagSymbolClass;

	import flash.display.Loader;
	import flash.events.Event;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;

	/**
	 * SWFUtil
	 *
	 * @author Demon.S
	 *
	 */
	public class SWFUtil
	{

		/**
		 * repackByLinkage
		 * @param data , loader content data bytearray.
		 * @param linkageName , full linkages or prefix (will be repacked to multi layered swf).
		 * @param callback repackage done call,callback param is repacked swf.
		 * @usage
		 *
		 * 		urlLoader=new URLLoader();
		 *		urlLoader.dataFormat=URLLoaderDataFormat.BINARY;
		 *
		 * 		SWFUtil.repackByLinkage(URLLoader(event.target).data,"Crop_",handleLoaderReady);
		 */
		public static function repackByLinkage(data:*, linkageName:String, callback:Function):void
		{
			//repackage
			var ld:Loader = new Loader();
			ld.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void
			{
				callback(ld.content)
			})
			var lc:LoaderContext = new LoaderContext();
			lc.allowCodeImport = true;
			ld.loadBytes(repackSwf(data, linkageName), lc);

			//TODO , map linkages to display object
		}


		public static function repackSwf(data:*, linkageName:String):ByteArray
		{
			var swf:SWF = new SWF(data);
			var swfData:SWFData = new SWFData();
			var depth:int = 0;
			var symbol:SWFSymbol;
			var symbols:Vector.<SWFSymbol>;

			//analyze ,find symbols 
			for (var i:int = 0, len:int = swf.tags.length; i < len; i++)
			{
				var tag:ITag = swf.tags[i];
				switch (tag.type)
				{
					case TagPlaceObject2.TYPE:
						swf.tags[i] = null;
						break;
					case TagSymbolClass.TYPE:
						symbols = TagSymbolClass(tag).symbols; //库中的所有元件
						//遍历所有元件，找到linkage满足条件的元件
						for (var i0:int = 0, len0:int = symbols.length; i0 < len0; i0++)
						{
							symbol = TagSymbolClass(tag).symbols[i0];
//								trace("swf-linkage:" + symbol.name);
							if (linkageName == "*" || symbol.name.indexOf(linkageName) == 0)
							{
								var placeObject:TagPlaceObject2 = new TagPlaceObject2();
								if (linkageName == "Animal_")
								{ //对动物做一个特殊处理
									var temp:int = parseInt(symbol.name.charAt(symbol.name.length - 1));
									if (temp > 2)
										temp = temp - 2;
									placeObject.depth = temp - 1;
								}
								else
									placeObject.depth = depth++;
								placeObject.characterId = symbol.tagId;
								placeObject.hasCharacter = true;
								placeObject.hasColorTransform = false;
								placeObject.hasName = true;
								placeObject.instanceName = symbol.name;
								swf.tags.push(placeObject);
							}
						}
					case TagDoABCDeprecated.TYPE:
					case TagDoABC.TYPE:
					case TagShowFrame.TYPE:
					case TagEnd.TYPE:
						swf.tags[i] = null;
						break;
				}

			}
			swf.tags.push(new TagShowFrame());
			swf.tags.push(new TagEnd());
			swf.publish(swfData);

			return swfData;
		}

	}
}
