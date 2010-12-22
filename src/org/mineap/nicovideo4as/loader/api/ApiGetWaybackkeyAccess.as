package org.mineap.nicovideo4as.loader.api
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	import mx.messaging.SubscriptionInfo;

	/**
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class ApiGetWaybackkeyAccess extends URLLoader
	{
		
		public static const NICO_API_GET_WAYBACKKEY_URL:String = "http://flapi.nicovideo.jp/api/getwaybackkey";
		
		private var _url:String = NICO_API_GET_WAYBACKKEY_URL;
		
		/**
		 * 
		 * @param request
		 * 
		 */
		public function ApiGetWaybackkeyAccess(request:URLRequest = null)
		{
			super(request);
		}
		
		/**
		 * 
		 * @param threadId
		 * 
		 */
		public function getAPIResult(threadId:String):void{
			
			var variables:URLVariables = new URLVariables();
			variables.thread = threadId;
			
			var request:URLRequest = new URLRequest(_url);
			request.data = variables;
			request.method = "GET";
			
			this.load(request);
			
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