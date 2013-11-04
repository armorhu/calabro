package com.codeazur.as3swf.factories
{
	import com.codeazur.as3swf.swftags.ITag;

	public interface ISWFTagFactory
	{
		function create(type:uint):ITag;
	}
}