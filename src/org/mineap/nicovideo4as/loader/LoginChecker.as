package org.mineap.nicovideo4as.loader
{
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	import org.mineap.nicovideo4as.Login;

	/**
	 * 
	 * ニコニコ動画に対して、ログイン済みかどうかをチェックするためのURLLoaderです。
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class LoginChecker extends URLLoader
	{
		
		private var x_niconico_authflag_value:String = null;
		
		public static const TOP_PAGE_URL:String = Login.TOP_PAGE_URL;
		
		public function LoginChecker(request:URLRequest = null)
		{
			super(request);
		}
		
		/**
		 * ログイン済みかどうかチェックを行います。
		 * チェック結果は、 Event.COMPLETE が発行されたあと、 isAlreadyLogin プロパティで確認できます。
		 * 
		 * @param url 
		 * 
		 */
		public function check(url:String = TOP_PAGE_URL):void{
			
			var request:URLRequest = new URLRequest(url);
			request.method = URLRequestMethod.HEAD;
			
			super.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseStatusListener);
			super.load(request);
			
		}
		
		protected function httpResponseStatusListener(event:HTTPStatusEvent):void
		{
			checkResponseHeader(event);
		}
		
		protected function checkResponseHeader(event:HTTPStatusEvent):String{
			var value:String;
			for each(var header:Object in event.responseHeaders) {
				if (header.name != null && header.name is String &&
						(header.name as String).toLowerCase() == "x-niconico-authflag") {
					this.x_niconico_authflag_value = value = header.value;
					break;
				}
			}
			trace("x-niconico-authflag:" + value);
			return value;
		}
		
		/**
		 * ニコニコ動画にログイン済みかどうかを返します。
		 * この関数は、check(url:String)の呼び出しが完了し、Event.COMPLETEイベントのディスパッチが完了してから呼び出してください。
		 * @return ログイン済みかどうか。trueの時はログイン済み、falseの場合は未ログイン。
		 * 
		 */
		public function get isAlreadyLogin():Boolean{
			if (this.x_niconico_authflag_value == null) {
				return false;
			}
			
			if (this.x_niconico_authflag_value == "0") {
				return false;
			} else if(this.x_niconico_authflag_value == "1") {
				return true;
			} else if(this.x_niconico_authflag_value == "3") {
				return true;
			}
			return false;
		}
		
	}
}