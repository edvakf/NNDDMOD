package org.mineap.nicovideo4as.loader.api
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class ApiGetThumbInfoAccess extends URLLoader
	{
		
		public static const GET_THUMB_INFO_API_URL:String = "http://ext.nicovideo.jp/api/getthumbinfo/";
		
		private var _url:String = GET_THUMB_INFO_API_URL;
		
		/**
		 * 
		 * @param request
		 * 
		 */
		public function ApiGetThumbInfoAccess(request:URLRequest = null)
		{
			if (request != null)
			{
				this.load(request);
			}
		}
		
		/**
		 * 
		 * @param videoId
		 * 
		 */
		public function getThumbInfo(videoId:String):void
		{
			
			var targetUrl:String = this._url + videoId;
			
			var request:URLRequest = new URLRequest(targetUrl);
			
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