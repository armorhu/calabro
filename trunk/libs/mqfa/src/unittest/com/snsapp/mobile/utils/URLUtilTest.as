package unittest.com.snsapp.mobile.utils
{
	import asunit.framework.TestCase;

	import com.snsapp.mobile.utils.URLUtil;

	public class URLUtilTest extends TestCase
	{
		public function URLUtilTest()
		{
			super();
		}

		public function testGetName():void
		{
			//纯路径名，没有文件名
			var url:String = 'http://farm.xiaoyou.pengyou.com/cgi-bin/';
			assertEquals('', URLUtil.getName(url, true));
			assertEquals('', URLUtil.getName(url, false));
			assertEquals('http://farm.xiaoyou.pengyou.com/cgi-bin', URLUtil.getPath(url));

			//路劲+文件名，没有后缀。
			url = 'farm.xiao/you';
			assertEquals('you', URLUtil.getName(url, true));
			assertEquals('you', URLUtil.getName(url, false));
			assertEquals('farm.xiao', URLUtil.getPath(url));

			//文件名，没有路径
			url = 'farm.xiao.you';
			assertEquals('farm.xiao.you', URLUtil.getName(url, true));
			assertEquals('farm.xiao', URLUtil.getName(url, false));
			assertEquals('', URLUtil.getPath(url));

			//路径+后缀
			url = 'farm.xiao/.you';
			assertEquals('.you', URLUtil.getName(url, true));
			assertEquals('', URLUtil.getName(url, false));
			assertEquals('farm.xiao', URLUtil.getPath(url));

			//文件名，无路径，无后缀
			url = 'farm';
			assertEquals('farm', URLUtil.getName(url, true));
			assertEquals('farm', URLUtil.getName(url, false));
			assertEquals('', URLUtil.getPath(url));

			url = '';
			assertEquals('', URLUtil.getName(url, true));
			assertEquals('', URLUtil.getName(url, false));
			assertEquals('', URLUtil.getPath(url));

			url = '.';
//			trace(URLUtil.getName(url, true));
//			trace(URLUtil.getName(url, false));
//			trace(URLUtil.getPath(url));
			assertEquals('.', URLUtil.getName(url, true));
			assertEquals('', URLUtil.getName(url, false));
			assertEquals('', URLUtil.getPath(url));

			url = '..';
			assertEquals('..', URLUtil.getName(url, true));
			assertEquals('.', URLUtil.getName(url, false));
			assertEquals('', URLUtil.getPath(url));

			url = './.';
			assertEquals('.', URLUtil.getName(url, true));
			assertEquals('', URLUtil.getName(url, false));
			assertEquals('.', URLUtil.getPath(url));

			url = './..';
			assertEquals('..', URLUtil.getName(url, true));
			assertEquals('.', URLUtil.getName(url, false));
			assertEquals('.', URLUtil.getPath(url));
		}
	}
}
