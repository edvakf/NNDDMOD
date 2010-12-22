package org.mineap.nicovideo4as.loader.api
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	public class ApiGetThreadkeyAccess extends URLLoader
	{
		
		public static const GET_THREADKEY_API_URL:String = "http://flapi.nicovideo.jp/api/getthreadkey";
		
		private var _url:String = GET_THREADKEY_API_URL;
		
		public function ApiGetThreadkeyAccess(request:URLRequest=null)
		{
			super(request);
		}
		
		public function getThreadkey(threadId:String):void
		{
			
			var targetUrl:String = url;
			
			var variables:URLVariables = new URLVariables();
			variables.thread = threadId;
			
			var reqest:URLRequest = new URLRequest(targetUrl);
			reqest.data = variables;
			reqest.method = "GET";
			
			this.load(reqest);
			
		}

		public function get url():String
		{
			return _url;
		}

		public function set url(value:String):void
		{
			_url = value;
		}

		
	}
}