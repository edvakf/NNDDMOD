package org.mineap.nicovideo4as
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestDefaults;
	import flash.net.URLVariables;
	import flash.utils.Timer;

	[Event(name="login_success", type="org.mineap.nicovideo4as.Login")]
	[Event(name="login_fail", type="org.mineap.nicovideo4as.Login")]
	[Event(name="logout_complete", type="org.mineap.nicovideo4as.Login")]
	
	/**
	 * ニコニコ動画へのログインリクエストを格納するクラスです。
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class Login extends EventDispatcher
	{
		
		private var _loginLoader:URLLoader;
		private var _loginRequest:URLRequest;
		private var _logoutLoader:URLLoader;
		private var _isRetry:Boolean = false;
		
		/**
		 * ニコニコ動画のログインURLです。
		 */
		public static const LOGIN_URL:String = "https://secure.nicovideo.jp/secure/login?site=niconico";
		
		/**
		 * ニコニコ動画のログアウトURLです。
		 */
		public static const LOGOUT_URL:String = "https://secure.nicovideo.jp/secure/logout";
		
		/**
		 * ニコニコ動画へのログインに失敗した際に返されるメッセージです。
		 */
		public static const LOGIN_FAIL_MESSAGE:String = "cant_login";
		
		/**
		 * ニコニコ動画のトップページURLです。
		 */
		public static const TOP_PAGE_URL:String = "http://www.nicovideo.jp/";
		
		/**
		 * ニコニコ動画のドメインです。
		 */
		public static const HOST_URL:String = "http://nicovideo.jp/";
		
		/**
		 * 
		 */
		public static const LOGIN_SUCCESS:String = "LoginSuccess";
		
		/**
		 * 
		 */
		public static const LOGIN_FAIL:String = "LoginFail";
		
		/**
		 * 
		 */
		public static const LOGOUT_COMPLETE:String = "LogoutComplete";
		
		/**
		 * コンストラクタ<br>
		 * 
		 */
		public function Login()
		{
			
		}
		
		/**
		 * ニコニコ動画にログインします。
		 * 
		 * @param user ログイン名です。
		 * @param password ログインパスワードです。
		 * @param url ログインに使うURLです。
		 * @param isDefault 今回設定したログインをデフォルトに設定するかどうかです
		 * @param topPageUrl デフォルトのログイン設定を有効にするURLです。
		 * @param isRetry このフラグがtrueで、かつIOエラーが発生したときに、ログアウト→ログインの順で一度だけ再試行します。
		 * @return 
		 * 
		 */
		public function login(user:String, password:String, url:String=LOGIN_URL, isDefault:Boolean=true, topPageUrl:String=TOP_PAGE_URL, isRetry:Boolean = true):void{
			if(isDefault){
				setURLRequestDefaults(user, password, HOST_URL);
			}
			
			this._isRetry = isRetry;
			
			this._loginLoader = new URLLoader();
			
			var variables:URLVariables = new URLVariables();
			variables.mail = user;
			variables.password = password;
			
			this._loginRequest = new URLRequest(url);
			this._loginRequest.method = "POST";
			this._loginRequest.data = variables;
			
			if (isRetry) {
				checkLogin();
				return;
			}
			
			this._loginLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpCompleteHandler);
			this._loginLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			this._loginLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			this._loginLoader.load(this._loginRequest);
		}
		
		/**
		 * とりあえずトップページに HEAD リクエストを送ってみて、ログインしてるかどうかを確認します。
		 *
		 */
		private function checkLogin(topPageUrl:String=TOP_PAGE_URL):void{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, checkLoginCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			var request:URLRequest = new URLRequest(topPageUrl);
			request.method = "HEAD";
			loader.load(request);
		}
		
		/**
		 * HEAD リクエストのレスポンスヘッダーを処理します。
		 * x-niconico-authflag が0ならログインしてない、1ならノーマルユーザーとしてログイン中、3ならプレミアムユーザーとしてログイン中です。
		 * @param event
		 * 
		 */
		private function checkLoginCompleteHandler(event:HTTPStatusEvent):void{
			trace(event);
			
			var responseHeaders:Array = event.responseHeaders;
			for (var index in responseHeaders) {
				if (responseHeaders[index].name === 'x-niconico-authflag') {
					if (responseHeaders[index].value === '0') {
						reallyLogin();
						return;
					} else { // 1 = normal user, 2 = premium user
						dispatchEvent(new Event(LOGIN_SUCCESS));
						return;
					}
				}
			}
			reallyLogin(); // this should not occur
			return;
		}
		
		private function reallyLogin():void{
			login(String(this._loginRequest.data.mail), String(this._loginRequest.data.password), LOGIN_URL, true, TOP_PAGE_URL, false);
		}
		
		/**
		 * ニコニコ動画からログアウトします。
		 * 
		 */
		public function logout():void{
			
			this._logoutLoader = new URLLoader();
			
			this._logoutLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, logoutCompleteHandler);
			this._logoutLoader.addEventListener(IOErrorEvent.IO_ERROR, logoutCompleteHandler);
			
			this._logoutLoader.load(new URLRequest(LOGOUT_URL));
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function logoutCompleteHandler(event:Event):void{
			trace(event);
			if(this._isRetry){
				trace("ログインリトライ");
				if(_loginRequest != null){
					var timer:Timer = new Timer(1000, 1);
					timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerEventHandler);
					timer.start();
				}else{
					dispatchEvent(new ErrorEvent(LOGIN_FAIL));
				}
			}else{
				dispatchEvent(new Event(LOGOUT_COMPLETE));
			}
		}
		
		private function timerEventHandler(event:Event):void{
			login(String(this._loginRequest.data.mail), String(this._loginRequest.data.password), LOGIN_URL, true, TOP_PAGE_URL, false);
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function errorHandler(event:ErrorEvent):void{
			trace(event);
			if(this._isRetry){
				trace("ログアウト");
				logout();
			}else{
				dispatchEvent(new ErrorEvent(LOGIN_FAIL, false, false, event.toString()));
			}
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function httpCompleteHandler(event:HTTPStatusEvent):void{
			trace(event);
			
			dispatchEvent(event);
			
			if (event.status != 200) {
				dispatchEvent(new ErrorEvent(LOGIN_FAIL, false, false, "status:" + event.status));
				
				return;
			}
			
			if (event.responseURL.indexOf(LOGIN_FAIL_MESSAGE) != -1){
				dispatchEvent(new ErrorEvent(LOGIN_FAIL, false, false, LOGIN_FAIL_MESSAGE + ",status:" + event.status));
				
				return;
			}
			
			dispatchEvent(new Event(LOGIN_SUCCESS));
		}
		
		/**
		 * 指定されたURL下のページにアクセスする際のデフォルトユーザー名およびパスワードに、
		 * 引数で指定された値を設定します。
		 * @param user
		 * @param password
		 * @param url
		 * @return 
		 * 
		 */
		public function setURLRequestDefaults(user:String, password:String, url:String):void{
			URLRequestDefaults.setLoginCredentialsForHost(url, user, password);
		}
		
		
		/**
		 * 
		 * 
		 */
		public function close():void{
			try{
				if(this._loginLoader != null){
					this._loginLoader.close();
				}
			}catch(error:Error){
				trace(error.getStackTrace());
			}
			try{
				if(this._logoutLoader != null){
					this._logoutLoader.close();
				}
			}catch(error:Error){
				trace(error.getStackTrace());
			}
			this._loginLoader = null;
//			this._loginRequest = null;
		}
		
	}
}