package com.snsapp.mobile.ffc
{
	import com.qzone.qfa.managers.resource.ResourceLoader;
	import com.snsapp.mobile.ffc.Event.FFCAppendFileEvent;
	import com.snsapp.mobile.ffc.Event.FFCCloseEvent;
	import com.snsapp.mobile.ffc.Event.FFCStartupEvent;
	
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	[Event(name="startup_complete", type="com.snsapp.mobile.ffc.Event.FFCStartupEvent")]
	[Event(name="startup_failed", type="com.snsapp.mobile.ffc.Event.FFCStartupEvent")]
	[Event(name="close_complete", type="com.snsapp.mobile.ffc.Event.FFCCloseEvent")]
	[Event(name="close_failed", type="com.snsapp.mobile.ffc.Event.FFCCloseEvent")]
	[Event(name="append_file_complete", type="com.snsapp.mobile.ffc.Event.FFCAppendFileEvent")]
	[Event(name="append_file_error", type="com.snsapp.mobile.ffc.Event.FFCAppendFileEvent")]
	[Event(name="append_filelist_complete", type="com.snsapp.mobile.ffc.Event.FFCAppendFileEvent")]
	public class FlashFastCache extends EventDispatcher
	{
		public static const OPEN:String="open";
		public static const COLSE:String="close";
		public static const OPENING:String="opening"
		public static const COLSEING:String="closeing";

		private var _state:String;

		private var _file:File;
		private var _fs:FileStream;

		private var _indexFile:File;

		private var _vfsIndex:VFSIndexInfo;
		private var _readOnly:Boolean;
		private var _bytesTotal:uint;

		private static const VFSI:Boolean=false;

		public function FlashFastCache(url:String)
		{
			//url合法性的判断
			if (url == null || url.indexOf("vfs") == -1)
				throw new ArgumentError(url + "不是标准的vfs文件");
			try
			{
				_file=new File(url);
			}
			catch (error:Error)
			{
				throw new ArgumentError(url + "不是标准的vfs文件");
			}

			///确定这个VFS是否是只读的
			_readOnly=_file.url.indexOf(File.applicationStorageDirectory.url) != 0;
			_fs=new FileStream();
			_state=COLSE;

			//所有的vfs对象都要监听这个对象.在程序关闭的时候调用dispose方法
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, close);
		}


		/**************************************************************************************************
		 *
		 * 启动逻辑-----------------start
		 *
		 * *************************************************************************************************/

		public function start():void
		{
			if (_state == COLSE)
			{
				var time:uint=getTimer();
				/**如果url代表的文件是只读的，但是这个文件又不存在...会直接抛出启动失败事件**/
				if (_file.exists == false && _readOnly == true)
				{
					setTimeout(startupError, 10);
					return;
				}
				var fileMode:String;
				fileMode=_readOnly ? FileMode.READ : FileMode.UPDATE;
				state=OPENING;
				if (VFSI)
				{
					_indexFile=new File(_file.url + 'i');
					if (_readOnly && _indexFile.exists == false)
					{ //只读的目录，就把索引文件放在appStroage:version
						_indexFile=new File(ResourceLoader.VERSION_DICT + _file.name + 'i');
					}

					if (_indexFile.exists)
					{
						try
						{
							var ifs:FileStream=new FileStream();
							ifs.open(_indexFile, FileMode.READ);
							var ba:ByteArray=new ByteArray;
							ifs.readBytes(ba);
							ifs.close(), ifs=null;
							_vfsIndex=VFSIndexInfo.fromByteArray(ba);
							ba.clear(), ba=null;
						}
						catch (error:Error)
						{
						}

						if (_vfsIndex == null)
						{
							_indexFile.deleteFile();
						}
						else
						{
							_fs.openAsync(_file, fileMode);
							_fs.addEventListener(Event.COMPLETE, openComplete);
							function openComplete(evt:Event):void
							{
								_fs.removeEventListener(Event.COMPLETE, openComplete);
								startupSuccess();
							}
							return;
						}
					}
				}
				_vfsIndex=new VFSIndexInfo(); //索引信息
				_fs.openAsync(_file, fileMode);
				_fs.addEventListener(ProgressEvent.PROGRESS, onReadEvent);
				_fs.addEventListener(Event.COMPLETE, onReadEvent);
				_fs.addEventListener(IOErrorEvent.IO_ERROR, onReadError);
			}
			function onReadError(e:IOErrorEvent):void
			{
				if (_state == OPENING)
				{
					_fs.removeEventListener(Event.COMPLETE, onReadEvent);
					_fs.removeEventListener(ProgressEvent.PROGRESS, onReadEvent);
					_fs.removeEventListener(IOErrorEvent.IO_ERROR, onReadError);
					startupError();
				}
			}

			function onReadEvent(e:Event):void
			{
				//				trace(_file.name, "onReadEvent", e.type, _fs.position, _fs.bytesAvailable);
				fetchVFSIndexInfo(); //填充索引

				if (e.type == Event.COMPLETE) //读取完成
				{
					if (_state == OPENING)
					{
						_fs.removeEventListener(Event.COMPLETE, onReadEvent);
						_fs.removeEventListener(ProgressEvent.PROGRESS, onReadEvent);
						_fs.removeEventListener(IOErrorEvent.IO_ERROR, onReadError);
						saveVfsIndex();
						startupSuccess();
					}
				}
			}

			function startupSuccess():void
			{
				trace(_file.name, "startup success!!耗时:" + (getTimer() - time).toString() + "ms" + "，文件数:" + _vfsIndex.fileCount);
				_fs.position=0; //启动成功后把这个置会最前。。
				state=OPEN;
				dispatchEvent(new FFCStartupEvent(FFCStartupEvent.STARTUP_COMPLETE));
			}

			function startupError():void
			{
				state=COLSE;
				dispatchEvent(new FFCStartupEvent(FFCStartupEvent.STARTUP_FAILED));
			}
		}

		private var nextFileHead:Number=0; //下一个文件头
		private var nameLen:int=0; //文件名长度
		private var fileName:String=null; //文件名

		/**
		 * 从VFS中获取,整个VFS的索引信息
		 */
		protected function fetchVFSIndexInfo():void
		{
			/**
			 * 一次完整的循环体,表示获取了一个文件的索引信息
			 * 但是,循环体可能在任何一步中断.
			 * 所以,需要有下次进入能继续循环的能力~
			 * ***/
			while (true)
			{
				if (nextFileHead == 0) //需要读头
				{
					if (_fs.bytesAvailable >= 4)
						nextFileHead=_fs.readUnsignedInt();
					else
						break;
				}

				if (nameLen == 0) //需要文件名长度
				{
					if (_fs.bytesAvailable >= 2)
						nameLen=_fs.readShort();
					else
						break;
				}

				if (fileName == null) //需要读文件名
				{
					if (_fs.bytesAvailable >= nameLen)
						fileName=_fs.readUTFBytes(nameLen);
					else
						break;
				}

				_vfsIndex.push(fileName, _fs.position, nextFileHead - _fs.position); //索引信息
				//				trace("aaaaaaaaaaaaaaa", fileName);
				_fs.position=nextFileHead; //跳向下一个文件
				_bytesTotal=nextFileHead; //更新bytesTotal属性

				//完成本次循环体
				nextFileHead=0;
				nameLen=0;
				fileName=null;
			}
		}
		/**************************************************************************************************
		 *
		 * 启动逻辑-----------------end
		 *
		 * *************************************************************************************************/


		/**************************************************************************************************
		 *
		 * 读取逻辑-----------------start
		 *
		 * *************************************************************************************************/


		protected var _readingQueue:Vector.<FileInfo>=new Vector.<FileInfo>(); //读取队列
		protected var _callBackMap:Object=new Object(); //回调字典
		protected var _waitingAvailableBytes:Boolean; //等待可用的字节

		/**
		 * 读取vfs中的数据.
		 * @param key 要读取的文件的key
		 * 如果读取成功返回该文件的数据
		 * 读取失败或者key在vfs中不存在就返回null.
		 * @armorhu 2012/6/18修改
		 * 1 vfs的索引文件的key已经替换为url的模式
		 * 2 当这个vfs是可写模式,则当读取本地文件失败时，会直接尝试使用url加载网络素材
		 */
		public function read(key:String, callBack:Function):void
		{
			if (_state != OPEN)
			{
				callBack(null);
				return;
			}
			var info:FileInfo=_vfsIndex.getInfoByName(key);
			//read: res/images/mainscene.texture 2138919 338565
			//read: res/images/mainscene.texture 2138919 5363182
			trace("read:", info.name, info.len, info.pos);
			if (info == null)
			{
//				if (readOnly)
				callBack(null);
//				else
//					loadAssets(key, callBack); //本地找不到并不直接返回.而是尝试网络加载素材
				return;
			}

			if (_callBackMap[info.name] == undefined) //如果是该文件的第一个读请求.则加入读取队列
			{
				_callBackMap[info.name]=[callBack];
				addToReadingQueue(info);
			}
			else
			{
				_callBackMap[info.name].push(callBack); //如果不是该文件的第一个读请求,加入回调队列
				return;
			}
			if (waitingAvailableBytes) //正在等待可用字节..这个过程中,不允许改变_fs.postion的数量
				return;
			readingAvailableBytes();
		}

		/**
		 * 读取当前可用的字节.
		 */
		private function readingAvailableBytes():void
		{
			var info:FileInfo;
			var bytes:ByteArray;
			var index:int;
			while (true)
			{
				if (_readingQueue.length == 0)
					break;
				index=getNearestFile();
				info=_readingQueue[index]; //弹出第一个
				if (info.pos != _fs.position) //泪奔！！加上这个判断会极大提升读写速度..
					_fs.position=info.pos;
				//				trace(_fs.position, _fs.bytesAvailable, info.len);
				if (_fs.bytesAvailable >= info.len)
				{
					bytes=newByteArray(info.len);
					//					trace("+++++++++++++++++++++++++++",_fs.position)
					_fs.readBytes(bytes, 0, info.len); //不能用默认参数。使用默认参数，会使用append模式。导致bytes翻倍
					callBackByName(info.name, bytes);
					_readingQueue.splice(index, 1);
				}
				else
				{
					//					if (_fs.position != info.pos)
					//						_fs.position = info.pos;
					if (_fs.readAhead != info.len)
						_fs.readAhead=info.len;
					break;
				}
			}
			waitingAvailableBytes=_readingQueue.length > 0;
		}

		/**
		 * 添加到读取队列中
		 */
		private function addToReadingQueue(info:FileInfo):void
		{
			//			_readingQueue.push(info);
			const len:int=_readingQueue.length;
			if (len == 0)
				_readingQueue.push(info);
			else
			{
				for (var i:int=0; i < len; i++)
					if (_readingQueue[i].pos > info.pos)
						break;

				if (i == 0)
					_readingQueue.unshift(info);
				else
					_readingQueue.splice(i, 0, info);
			}
		}

		/**
		 * 找到离当前位置最近的文件列表
		 * @return
		 */
		private function getNearestFile():int
		{
			const len:int=_readingQueue.length;
			for (var i:int=0; i < len; i++)
			{
				if (_readingQueue[i].pos >= _fs.position)
					return i;
			}
			return 0;
		}


		private function callBackByName(name:String, bytes:ByteArray):void
		{
			var callBacks:Array=_callBackMap[name] as Array;
			const len:int=callBacks == null ? 0 : callBacks.length;
			if (bytes)
				bytes.position=0;
			for (var i:int=0; i < len; i++)
				callBacks[i](bytes == null ? null : cloneByteArray(bytes));
			if (bytes)
				bytes.clear(), bytes=null;
			delete _callBackMap[name];
		}

		private function cloneByteArray(bytes:ByteArray):ByteArray
		{
			var newBytes:ByteArray=new ByteArray();
			newBytes.writeBytes(bytes);
			newBytes.position=0;
			return newBytes;
		}

		/**
		 * 读取事件.
		 * Progress事件和Complete事件都会抛
		 * @param e
		 */
		protected function readEventHandler(e:Event):void
		{
			//			trace(e.type);
			readingAvailableBytes();
		}

		/**
		 * 读取错误
		 * @param e
		 */
		protected function readErrorHandler(e:Event):void
		{
			for (var key:String in _callBackMap)
				callBackByName(key, null);
			_readingQueue=new Vector.<FileInfo>();
			_waitingAvailableBytes=false;
		}


		protected function set waitingAvailableBytes(value:Boolean):void
		{
			if (_waitingAvailableBytes == value)
				return;
			_waitingAvailableBytes=value;
			if (_waitingAvailableBytes)
			{
				_fs.addEventListener(Event.COMPLETE, readEventHandler);
				_fs.addEventListener(ProgressEvent.PROGRESS, readEventHandler);
				_fs.addEventListener(IOErrorEvent.IO_ERROR, readErrorHandler);
			}
			else
			{
				_fs.removeEventListener(Event.COMPLETE, readEventHandler);
				_fs.removeEventListener(ProgressEvent.PROGRESS, readEventHandler);
				_fs.removeEventListener(IOErrorEvent.IO_ERROR, readErrorHandler);
			}
		}


		protected function get waitingAvailableBytes():Boolean
		{
			return _waitingAvailableBytes;
		}

		/**************************************************************************************************
		 *
		 * 读取逻辑-----------------end
		 *
		 * *************************************************************************************************/


		/**************************************************************************************************
		 *
		 * 关闭逻辑-----------------startup
		 *
		 * *************************************************************************************************/

		/**
		 * 关闭VFS的文件流
		 * 如果要再次使用,需要重新调用startup方法
		 */
		public function close(e:Event=null):void
		{
			if (this._state == OPEN)
			{
				state=COLSEING;
				_fs.close();
				_fs.addEventListener(IOErrorEvent.IO_ERROR, onCloseEvent);
				_fs.addEventListener(Event.CLOSE, onCloseEvent);
			}
			else
			{
				closeFailed();
			}

			function onCloseEvent(e:Event):void
			{
				_fs.removeEventListener(Event.CLOSE, onCloseEvent);
				_fs.removeEventListener(IOErrorEvent.IO_ERROR, onCloseEvent);
				if (e.type == Event.CLOSE)
					closeSuccess();
				else
					closeFailed();
			}

			function closeSuccess():void
			{
				_bytesTotal=0;
				_vfsIndex=null;
				state=COLSE;
				dispatchEvent(new FFCCloseEvent(FFCCloseEvent.CLOSE_COMPLETE));
			}

			function closeFailed():void
			{
				dispatchEvent(new FFCCloseEvent(FFCCloseEvent.CLOSE_FAILED));
			}
		}


		/**************************************************************************************************
		 *
		 * 关闭逻辑-----------------end
		 *
		 * *************************************************************************************************/

		/**************************************************************************************************
		 *
		 * AppendFileList 的逻辑块-----------------start
		 *
		 * *************************************************************************************************/

		/**
		 * 在vfs的末尾拼接字节数组
		 * @param key 拼接的数组的key
		 * @param byteArray 要拼接的字节数组
		 * @param offset    从字节数组的什么位置开始
		 * @param length    拼接多长
		 * 如果key是已经存在的key,则返回false
		 * 注意:这个方法是直接与文件io的,如果瞬间多次调用这个方法,可能会造成程序cpu飙高
		 */
		public function appendByteArray(key:String, byteArray:ByteArray):Boolean
		{
			if (_state == COLSE || _state == COLSEING || _state == OPENING)
				return false;
			if (byteArray == null || byteArray.length == 0) //byteArray为空也返回false
				return false;
			if (!_vfsIndex.hasFile(key))
			{
				//				trace("append:", waitingAvailableBytes, key, byteArray.length);
				//				if (waitingAvailableBytes) //正在读
				//					return false;
				byteArray.position=0;
				_fs.position=_bytesTotal; //指向最后
				var nextHead:uint=byteArray.length + key.length + 6 + _fs.position;
				_fs.writeUnsignedInt(nextHead); //写入文件总长度：4个字节的文件长度+2个字节的文件名长度+文件名+文件内容
				_fs.writeUTF(key); //写入文件名
				_vfsIndex.push(key, _fs.position, byteArray.length); //记录文件位置
				_fs.writeBytes(byteArray); //写入文件内容
				saveVfsIndex();
				_bytesTotal=nextHead;
				return true;
			}
			return false;
		}


		/**************************************************************************************************
		 *
		 * AppendFileList 的逻辑块-----------------end
		 *
		 * *************************************************************************************************/


		/**************************************************************************************************
		 *
		 * 辅助api  ---------------startup
		 *
		 * *************************************************************************************************/

		private function saveVfsIndex():void
		{
			if (VFSI)
			{
				var fs:FileStream=new FileStream();
				var ba:ByteArray=_vfsIndex.toByteArray();
				fs.open(_indexFile, FileMode.WRITE);
				fs.writeBytes(ba);
				ba.clear(), ba=null;
				fs.close();
			}
		}

		protected function set state(value:String):void
		{
			if (value == _state)
				return;

			trace(_file.name, "change " + _state + " to " + value);
			_state=value;
		}

		public function get readOnly():Boolean
		{
			return _readOnly;
		}

		public function get isSetup():Boolean
		{
			return _state == OPEN;
		}

		public function get totalFileCount():uint
		{
			return _vfsIndex == null ? 0 : _vfsIndex.fileCount;
		}

		public function get url():String
		{
			return this._file.url;
		}

		public function get bytesTotal():uint
		{
			return this._bytesTotal;
		}

		public function hasFile(key:String):Boolean
		{
			return this._vfsIndex.hasFile(key);
		}

		/**************************************************************************************************
		 *
		 * 辅助api  ---------------end
		 *
		 * *************************************************************************************************/

		/**************************************************************************************************
		 *
		 * 静态方法---start
		 *
		 * *************************************************************************************************/
		private static var _byteArrayPool:Vector.<ByteArray>=new Vector.<ByteArray>();

		protected static function newByteArray(size:uint):ByteArray
		{
			var ret:ByteArray;
			var target:int=-1;
			const len:int=_byteArrayPool.length;
			if (len == 0)
			{
				ret=new ByteArray();
				ret.length=size;
				return ret;
			}
			/**
			 * _byteArrayPool是按ByteArray的大小，从大到小排列
			 * **/
			for (var i:int=0; i < len; i++)
			{
				if (_byteArrayPool[i].length < size) //找到第一个比size小的数组
				{
					if (i == 0)
						target=0;
					else
						target=Math.abs(size - _byteArrayPool[i].length) < //
							Math.abs(size - _byteArrayPool[i - 1].length) ? i : (i - 1);
					break;
				}
			}

			if (target == -1)
				ret=_byteArrayPool.pop();
			else
			{
				ret=_byteArrayPool[target];
				_byteArrayPool.splice(target, 1);
			}
			ret.position=0;
			ret.length=size;
			//			trace(ret.length,size);
			return ret;
		}

		public static function recycle(byteArray:ByteArray):void
		{
			if (byteArray)
				byteArray.clear();
			byteArray=null;
			return;
			if (byteArray == null)
				return;
			var len:int=_byteArrayPool.length
			if (len == 10)
			{
				if (_byteArrayPool[_byteArrayPool.length - 1].length < byteArray.length)
				{ //和最小的比
					_byteArrayPool.pop().clear();
					len--;
				}
				else
				{
					byteArray.clear();
					byteArray=null;
				}
			}
			if (byteArray)
			{
				if (len == 0)
					_byteArrayPool.push(byteArray);
				else
				{
					for (var i:int=0; i < len; i++)
						if (_byteArrayPool[i].length < byteArray.length)
							break;

					if (i > 0)
						_byteArrayPool.splice(i - 1, 0, byteArray);
					else
						_byteArrayPool.unshift(byteArray);
				}
			}
			byteArray=null;
		}
	/**************************************************************************************************
	 *
	 * 静态方法---end
	 *
	 * *************************************************************************************************/
	}
}
import com.snsapp.mobile.utils.URLUtil;

import flash.utils.ByteArray;



/**
 * 一个虚拟文件系统的索引信息
 * @author armorhu
 */
class VFSIndexInfo
{
	/**文件信息的索引.为用文件名索引文件提供了快速途径**/
	protected var _indexMap:Object;
	/**将一个文件名的路径名部分做一个转换，节约内存。**/
	protected var _pathMap:Object;
	protected var _fileCount:int;
	protected var _pathFlag:int;

	public function VFSIndexInfo()
	{
		_indexMap=new Object();
		_pathMap=new Object();
		_fileCount=0;
		_pathFlag=0;
	}

	public function getInfoByName(name:String):FileInfo
	{
		var key:String=getFastName(name);
		if (_indexMap[key] == undefined)
			return null;
		else
			return new FileInfo(name, _indexMap[key].pos, _indexMap[key].len);
	}

	public function push(name:String, pos:Number, len:Number):void
	{
		if (hasFile(name) == false)
		{
			_fileCount++;
			name=getFastName(name, true);
			_indexMap[name]={pos: pos, len: len}
		}
	}

	public function hasFile(name:String):Boolean
	{
		return _indexMap.hasOwnProperty(getFastName(name));
	}

	private function getFastName(name:String, modify:Boolean=false):String
	{
		var path:String=URLUtil.getPath(name);
		if (path == '')
			return name;
		else
		{

			if (_pathMap[path] == undefined)
			{ //未知的路径，
				if (modify)
				{
					_pathMap[path]=_pathFlag++; //先赋值再加
					return '[' + _pathMap[path] + ']' + URLUtil.getName(name);
				}
				else
					return name; //不允许修改pathMap，直接返回name!;
			}
			else
				return '[' + _pathMap[path] + ']' + URLUtil.getName(name);
		}
	}

	public function get fileCount():int
	{
		return _fileCount;
	}

	public function toByteArray():ByteArray
	{
		var ba:ByteArray=new ByteArray();
		ba.writeInt(_fileCount);
		ba.writeInt(_pathFlag);

		var str:String=JSON.stringify(_pathMap);
		var len:int=str.length;
		ba.writeInt(len);
		ba.writeUTFBytes(str);

		str=JSON.stringify(_indexMap);
		len=str.length;
		ba.writeInt(len);
		ba.writeUTFBytes(str);

		ba.compress();
		ba.position=0;
		return ba;
	}

	public static function fromByteArray(ba:ByteArray):VFSIndexInfo
	{
		ba.uncompress();
		ba.position=0;
		var index:VFSIndexInfo=new VFSIndexInfo();
		if (ba.bytesAvailable >= 4)
			index._fileCount=ba.readInt();
		else
			throw new Error("decode from byteArray error!!");

		if (ba.bytesAvailable >= 4)
			index._pathFlag=ba.readInt();
		else
			throw new Error("decode from byteArray error!!");

		var len:int, str:String;
		if (ba.bytesAvailable >= 4)
			len=ba.readInt();
		else
			throw new Error("decode from byteArray error!!");

		if (ba.bytesAvailable >= len)
			str=ba.readUTFBytes(len);
		else
			throw new Error("decode from byteArray error!!");
		index._pathMap=JSON.parse(str);
		
		if (ba.bytesAvailable >= 4)
			len=ba.readInt();
		else
			throw new Error("decode from byteArray error!!");
		
		if (ba.bytesAvailable >= len)
			str=ba.readUTFBytes(len);
		else
			throw new Error("decode from byteArray error!!");
		index._indexMap=JSON.parse(str);

		return index;
	}
}

/**
 * 虚拟文件系统的中一个文件的信息结构
 * 通过这个信息，可以方便的定位到文件的内容
 * @author armorhu
 */
class FileInfo
{
	public var name:String;
	public var pos:Number;
	public var len:Number;

	public function FileInfo($name:String, $pos:int, $len:int)
	{
		name=$name;
		len=$len;
		pos=$pos;
	}
}

