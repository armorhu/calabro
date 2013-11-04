package com.codeazur.as3swf.swftags.etc
{
	import com.codeazur.as3swf.swftags.ITag;
	import com.codeazur.as3swf.swftags.TagUnknown;
	
	public class TagSWFEncryptActions extends TagUnknown implements ITag
	{
		public static const TYPE:uint = 253;
		
		public function TagSWFEncryptActions(type:uint = 0) {}
		
		override public function get type():uint { return TYPE; }
		override public function get name():String { return "SWFEncryptActions"; }
	}
}
