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
	import flash.net.URLVariables;
	
	/**
	 * 市場情報を取得するクラスです。
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class IchibaInfoLoader extends URLLoader
	{
		
		public static const NICO_ICHIBA_URL:String = "http://ichiba.nicovideo.jp/embed/";
		
		/**
		 * 
		 * @param urlRequest
		 * 
		 */
		public function IchibaInfoLoader(urlRequest:URLRequest = null)
		{
			if(urlRequest != null){
				this.load(urlRequest);
			}
		}
		
		/**
		 * 市場情報を取得します。
		 * 
		 * @param videoId
		 * 
		 */
		public function getIchibaInfo(videoId:String):void{
			
			var request:URLRequest = new URLRequest(NICO_ICHIBA_URL);
			
			var variables:URLVariables = new URLVariables();
			variables.action = "showMain";
			variables.rev = "20100805";
			variables.v = videoId;
			
			request.data = variables;
			
			this.load(request);
			
		}

	}
}