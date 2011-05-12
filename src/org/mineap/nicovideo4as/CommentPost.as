package org.mineap.nicovideo4as
{
	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	
	import org.mineap.nicovideo4as.loader.api.ApiGetFlvAccess;
	
	[Event(name="commentPostSuccess", type="CommentPost")]
	[Event(name="commentPostFail", type="CommentPost")]
	[Event(name="httpResponseStatus", type="HTTPStatusEvent")]
	
	/**
	 * ニコニコ動画の指定された動画に対してコメントの投稿を行います。
	 * コメント投稿の手順
	 * 1. ログイン
	 * 2. getflvにアクセスして[メッセージサーバのURL]と[スレッドID]と[ユーザーID]を取得
	 * 3. [メッセージサーバ]に[スレッドID]と[ユーザーID]をPOSTして[現在のレス数]と[ticket]を取得
	 * 4. getpostkeyに[現在のレス数]割る100（ブロックナンバー）と[スレッドID]をPOSTして[postkey]を取得
	 * 5. [メッセージサーバ]に[スレッドID]と[ticket]と[ユーザーID]と[postkey]とコメント等々をPOSTして[no]（レス番号）を取得
	 *  
	 * @author shiraminekeisuke
	 * 
	 */
	public class CommentPost extends EventDispatcher
	{
		private var _commentLoader:CommentLoader;
		private var _postLoader:URLLoader;
		private var _login:Login;
		private var _getflvAccess:ApiGetFlvAccess;
		
		private var _videoId:String;
		private var _comment:String;
		private var _vpos:int;
		private var _no:String;
		private var _user_id:String;
		private var _premium:String;
		private var _ticket:String;
		private var _mail:String;
		private var _thread:String;
		
		private var _chat:XML;
		
		private static const GETPOSTKEY_URL:String = "http://flapi.nicovideo.jp/api/getpostkey";
		
		public static const COMMENT_POST_SUCCESS:String = "CommentPostSuccess";
		public static const COMMENT_POST_FAIL:String = "CommentPostFail";
		
		/**
		 * コンストラクタです。
		 * 
		 */
		public function CommentPost()
		{
			this._commentLoader = new CommentLoader();
			this._postLoader = new URLLoader();
			this._login = new Login();
			this._getflvAccess = new ApiGetFlvAccess();
			this._chat = null;
		}
		
		/**
		 * ログインし、指定された動画にコメントを投稿します。<br>
		 * 
		 * @param mailAddress ログイン用メールアドレス
		 * @param password ログイン用パスワード
		 * @param videoId 投稿する動画
		 * @param mail コメントのコマンド
		 * @param comment 投稿するコメント
		 * @param vpos 動画を投稿するvpos
		 * @return 
		 * 
		 */
		public function postCommentWithLogin(
									mailAddress:String,
									password:String,
									videoId:String, 
									mail:String, 
									comment:String, 
									vpos:int):void{
			
			this._videoId = videoId;
			this._comment = comment;
			this._mail = mail;
			this._vpos = vpos;
			
			this._login.addEventListener(Login.LOGIN_SUCCESS, loginSuccessHandler);
			this._login.addEventListener(Login.LOGIN_FAIL, networkErrorHandler);
			this._login.login(mailAddress, password);
		}
		
		/**
		 * ログイン完了後に呼ばれます。
		 */
		public function loginSuccessHandler(event:Event):void{
			this._getflvAccess.addEventListener(IOErrorEvent.IO_ERROR, networkErrorHandler);
			this._getflvAccess.addEventListener(Event.COMPLETE, getflvLoadedHandler);
			// alwaysEconomy フラグを false にしていますが、動画 URL を取得するわけではないので関係ないはず。
			this._getflvAccess.getAPIResult(this._videoId, false);
		}
		
		/**
		 * getflv の API アクセス完了後に呼ばれます。
		 */
		public function getflvLoadedHandler(event:Event):void{
			this.postComment(this._videoId, this._mail, this._comment, this._vpos, this._getflvAccess);
		}
		
		/**
		 * 指定された動画にコメントを投稿します。<br>
		 * 
		 * @param videoId 投稿する動画
		 * @param mail コメントのコマンド
		 * @param comment 投稿するコメント
		 * @param vpos 動画を投稿するvpos
		 * @return 
		 * 
		 */
		public function postComment(videoId:String, 
									mail:String, 
									comment:String, 
									vpos:int, 
									apiAccess:ApiGetFlvAccess):void{
			
			this._comment = comment;
			this._mail = mail;
			this._vpos = vpos;
			
			this._commentLoader.addEventListener(CommentLoader.COMMENT_GET_SUCCESS, commentGetSuccess);
			this._commentLoader.addEventListener(CommentLoader.COMMENT_GET_FAIL, networkErrorHandler);
			this._commentLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseStatusEventHandler);
			//TODO コメントローダーにAPIアクセサを渡さないと行けない。
			this._commentLoader.getComment(videoId, 1, false, apiAccess);
			
		}
		
		/**
		 * コメントの取得が完了したら呼ばれます。
		 * 
		 * @param event
		 * 
		 */
		private function commentGetSuccess(event:Event):void{
			var xml:XML = (event.target as CommentLoader).xml;
			var xmlList:XMLList = xml.thread;
			var ticket:String = xmlList[0].@ticket;
			var thread:String = xmlList[0].@thread;
			var commentCount:int = xmlList[0].@last_res;
			this._thread = thread;
			this._ticket = ticket;
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR, networkErrorHandler);
			loader.addEventListener(Event.COMPLETE, getPostKeySuccess);
			loader.load(new URLRequest(GETPOSTKEY_URL + "?thread=" + thread + "&block_no=" + int((commentCount+1)/100)));
		}
		
		/**
		 * APIからPostkeyを取得したときに呼ばれます。
		 * @param event
		 * 
		 */
		private function getPostKeySuccess(event:Event):void{
			var postKey:String = (event.target.data as String).substring(event.target.data.indexOf("=")+1);
			post(postKey, this._commentLoader.userID, this._ticket, this._mail, this._comment, this._vpos, this._thread, this._commentLoader.isPremium, this._commentLoader.messageServerUrl);
		}
		
		/**
		 * コメントを投稿します。
		 * 
		 * @param postKey ポストキーです。コメントXMLのスレッドIDを元にAPIから取得します。
		 * @param user_id ユーザーIDです。コメントXMLから取得します。
		 * @param ticket チケットです。コメントXMLから取得します。
		 * @param mail コマンドです。
		 * @param comment コメント本体です。
		 * @param vpos 動画のどの時間に投稿したかを表すミリ秒です。
		 * @param thread スレッドIDです。コメントXMLから取得します。
		 * @param isPremium プレミアムかどうかを表すフラグです。1のときにプレミアムです。APIから取得します。
		 * @param messageServerUrl メッセージサーバーのURLです。コメントXMLから取得します。
		 * 
		 */
		public function post(postKey:String, 
							 user_id:String, 
							 ticket:String, 
							 mail:String, 
							 comment:String, 
							 vpos:int, 
							 thread:String, 
							 isPremium:Boolean, 
							 messageServerUrl:String):void{
				
			var getComment:URLRequest = new URLRequest(unescape(messageServerUrl));
			getComment.method = "POST";
			getComment.requestHeaders = new Array(new URLRequestHeader("Content-Type", "text/html"));
			
			//<chat thread="" vpos="" mail="184 " ticket="" user_id="" postkey="" premium="">test</chat>
			var chat = <chat />;
			chat.@thread = thread;
			chat.@vpos = String(vpos);
			chat.@mail = "184 " + mail;
			chat.@ticket = ticket;
			chat.@user_id = user_id;
			chat.@postkey = postKey;
			chat.@premium = isPremium ? '0' : '1';
			chat.appendChild(comment);
			
			getComment.data = chat;
			
			this._thread = thread;
			this._vpos = chat.@vpos;
			this._mail = mail;
			this._user_id = user_id;
			this._premium = chat.@premium;
			this._comment = comment;
			
			this._postLoader.addEventListener(Event.COMPLETE, commentPostCompleteHandler);
			this._postLoader.addEventListener(IOErrorEvent.IO_ERROR, networkErrorHandler);
			this._postLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseStatusEventHandler);
			this._postLoader.dataFormat=URLLoaderDataFormat.TEXT;
			this._postLoader.load(getComment);
			
		}
		
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function httpResponseStatusEventHandler(event:HTTPStatusEvent):void{
			trace(event + ":" + event.status);
			dispatchEvent(event);
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function commentPostCompleteHandler(event:Event):void{
			trace(event);
			try{
				var resXml:XML = new XML((event.target as URLLoader).data);
				if(resXml.chat_result.@no){
					this._no = resXml.chat_result.@no;
				}else{
					throw new Error("コメントの投稿に失敗");
				}
			}catch(error:Error){
				dispatchEvent(new IOErrorEvent(COMMENT_POST_FAIL, false, false, error.getStackTrace()));
				return;
			}
			dispatchEvent(new Event(COMMENT_POST_SUCCESS));
		}
		
		/**
		 * ログイン・スレッド ID 取得・コメント取得・ポストキー取得のいずれかでエラーが起こると IOErrorEvent を発行します。
		 * @param event
		 * 
		 */
		private function networkErrorHandler(event:ErrorEvent):void{
			trace(event);
			dispatchEvent(new IOErrorEvent(COMMENT_POST_FAIL, false, false, event.text));
		}
		
		/**
		 * コメントの結果を返します。
		 * 
		 */
		public function getPostComment() {
			// 送信前の chat とほとんど同じですが、いくつか属性が消え、"no" 属性がつきます。
			var chat = <chat />;
			chat.@thread = this._thread;
			chat.@no = this._no;
			chat.@vpos = this._vpos;
			chat.@date = Math.floor((new Date()).getTime() / 1000);
			chat.@mail = "184 " + this._mail;
			chat.@user_id = this._user_id;
			chat.@premium = this._premium;
			chat.@anonymity = '1';
			chat.appendChild(this._comment);
			return chat;
		}
		
		/**
		 * 
		 * 
		 */
		public function close():void{
			try{
				this._login.close();
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
			try{
				this._getflvAccess.close();
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
			try{
				this._commentLoader.close();
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
//			this._commentLoader = null;
			try{
				this._postLoader.close();
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
//			this._postLoader = null;
		}

	}
}