package org.mineap.nicovideo4as.loader
{
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import org.mineap.nicovideo4as.Login;
	
	/**
	 * マイリスト情報を取得するクラス。
	 * ログインが必要な非公開のマイリストも取得できる。
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class MyListLoader extends PublicMyListLoader
	{
		
		private var _myListId:String = null;
		
		private var _login:Login = null;
		
		public function MyListLoader(request:URLRequest = null)
		{
			if(request != null)
			{
				this.load(request);
			}
		}
		
		/**
		 * 指定されたメールアドレス、パスワードを使って、指定されたマイリストIDのマイリストを取得します。
		 * 
		 * @param myListId マイリストID
		 * @param mailAddr ログインに使うメールアドレス
		 * @param password ログインパスワード
		 * @see org.mineap.nicovideo4as.analyzer.MyListAnalyzer
		 */
		public function getMyListWithLogin(myListId:String, mailAddr:String, password:String):void
		{
			this._myListId = myListId;
			
			this._login = new Login();
			this._login.addEventListener(Login.LOGIN_SUCCESS, loginSuccess);
			this._login.addEventListener(Login.LOGIN_FAIL, loginFail);
			this._login.login(mailAddr, password);
		}
		
		protected function loginSuccess(event:Event):void{
			getMyList(_myListId);
		}
		
		protected function loginFail(event:Event):void{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
	}

}
