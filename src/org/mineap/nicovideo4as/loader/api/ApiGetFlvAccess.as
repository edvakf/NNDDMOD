package org.mineap.nicovideo4as.loader.api
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
	 * ニコニコ動画のAPI(getflv)へのアクセスを担当するクラスです。
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class ApiGetFlvAccess extends URLLoader
	{
		
		public static const NICO_API_GET_FLV:String = "http://flapi.nicovideo.jp/api/getflv/";
		
		private var _url:String = NICO_API_GET_FLV;
		
		/**
		 * 
		 * @param request
		 * 
		 */
		public function ApiGetFlvAccess(request:URLRequest = null)
		{
			super(request);
		}
		
		/**
		 * FLVのURLを取得する為のAPIへのアクセスを行う
		 * @param videoID 動画ID
		 * @param isEconomy 強制的にエコノミーにするかどうか。swfでは無視される。
		 * 
		 */
		public function getAPIResult(videoID:String, isEconomy:Boolean):void
		{
			var variables:URLVariables = new URLVariables();
			
			//FLVのURLを取得する為にニコニコ動画のAPIにアクセスする
			if(videoID.indexOf("nm") != -1){
				
				//swfのとき。swfにエコノミーモードは存在しない
				variables.as3 = "1";
				
			}else{
				if(isEconomy){
					variables.eco = "1";
				}
			}
			
			var getAPIRequest:URLRequest;
			var url:String = url + videoID;
			
			getAPIRequest = new URLRequest(url);
			getAPIRequest.method = "GET";
			getAPIRequest.data = variables;
			
			this.load(getAPIRequest);
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