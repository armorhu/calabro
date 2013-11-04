package com.snsapp.mobile.vfs.Event
{
	import flash.events.Event;
	import flash.filesystem.File;

	public class VFSAppendFileEvent extends Event
	{

		public static const APPEND_FILE_COMPLETE:String = "append_file_complete";

		public static const APPEND_FILE_ERROR:String = "append_file_error";

		public static const APPEND_FILELIST_COMPLETE:String = "append_filelist_complete";

		public var totalCount:int;
		public var currentCount:int;
		public var faildCount:int;
		public var file:File;

		public function VFSAppendFileEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
