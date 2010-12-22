package org.mineap.nicovideo4as.loader
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	
	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class MyListGroupLoader extends URLLoader
	{
		
		public static const NICO_MYLIST_GROUP_API_URL:String = "http://www.nicovideo.jp/api/mylistgroup/list";
		
		/**
		 * 
		 * @param request
		 * 
		 */
		public function MyListGroupLoader(request:URLRequest = null)
		{
			if(request != null){
				this.load(request);
			}
		}
		
		/**
		 * ログイン中のユーザーについて、マイリストグループ（マイリストのIDの一覧）を取得します。
		 * 
		 */
		public function getMyListGroup():void{
			
			var urlRequest:URLRequest = new URLRequest(NICO_MYLIST_GROUP_API_URL);

			this.load(urlRequest);
		}

	}
}