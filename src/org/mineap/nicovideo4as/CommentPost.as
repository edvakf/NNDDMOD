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
	[Event(name="apiGetPostkeyError", type="CommentPost")]
	[Event(name="commentGetError", type="CommentPost")]
	[Event(name="xmlParseError", type="CommentPost")]
	[Event(name="httpResponseStatus", type="HTTPStatusEvent")]
	
	/**
	 * ニコニコ動画の指定された動画に対してコメントの投稿を行います。
	 *  
	 * @author shiraminekeisuke
	 * 
	 */
	public class CommentPost extends EventDispatcher
	{
		
		private var _commentLoader:CommentLoader;
		private var _postLoader:URLLoader;
		private var _comment:String;
		private var _vpos:int;
		
		private var _postKey:String;
		private var _ticket:String;
		private var _mail:String;
		private var _threadID:String;
		private var _isPremium:String;
		
		public static const COMMENT_POST_SUCCESS:String = "CommentPostSuccess";
		public static const COMMENT_POST_FAIL:String = "CommentPostFail";
		public static const COMMENT_GET_ERROR:String = "CommentGetError";
		public static const XML_PARSE_ERROR:String = "XmlParseError";
		public static const API_GET_POST_KEY_ACCESS_ERROR:String = "ApiGetPostkeyError";
		
		/**
		 * コンストラクタです。
		 * 
		 */
		public function CommentPost()
		{
			this._commentLoader = new CommentLoader();
			this._postLoader = new URLLoader();
		}
		
		/**
		 * 指定された動画にコメントを投稿します。<br>
		 * 
		 * @param videoId 投稿する動画
		 * @param mail コメントのコマンド
		 * @param comment 投稿するコメント
		 * @param vpos 動画を投稿するvpos
		 * @param isPremium プレミアムかどうか
		 * @return 
		 * 
		 */
		public function postComment(videoId:String, 
									mail:String, 
									comment:String, 
									vpos:int, 
									isPremium:String, 
									apiAccess:ApiGetFlvAccess):void{
			
			this._comment = comment;
			this._mail = mail;
			this._vpos = vpos;
			this._isPremium = isPremium;
			
			this._commentLoader.addEventListener(CommentLoader.COMMENT_GET_SUCCESS, commentGetSuccess);
			this._commentLoader.addEventListener(CommentLoader.COMMENT_GET_FAIL, commentLoaderErrorHandler);
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
			try{
				var xml:XML = new XML((event.target as URLLoader).data);
				var xmlList:XMLList = xml.thread;
				var ticket:String = xmlList[0].@ticket;
				var threadID:String = xmlList[0].@thread;
				var commentCount:int = xmlList[0].@last_res;
				
				var loader:URLLoader = new URLLoader();
				loader.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
					trace(event + ":" + event.text);
					dispatchEvent(new IOErrorEvent(API_GET_POST_KEY_ACCESS_ERROR, false, false, event.text));
				});
				loader.addEventListener(Event.COMPLETE, getPostKeySuccess);
				loader.load(new URLRequest("http://www.nicovideo.jp/api/getpostkey?thread=" + threadID + "&block_no=" + int((commentCount+1)/100)));
				
			}catch(error:Error){
				trace(error.getStackTrace());
				dispatchEvent(new IOErrorEvent(XML_PARSE_ERROR, false, false, error.getStackTrace()));
			}
		}
		
		/**
		 * APIからPostkeyを取得したときに呼ばれます。
		 * @param event
		 * 
		 */
		private function getPostKeySuccess(event:Event):void{
			var postKey:String = (event.target.data as String).substring(event.target.data.indexOf("=")+1);
			post(this._postKey, this._commentLoader.userID, this._ticket, this._mail, this._comment, String(this._vpos), this._threadID, this._isPremium, this._commentLoader.messageServerUrl);
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
							 vpos:String, 
							 thread:String, 
							 isPremium:String, 
							 messageServerUrl:String):void{
				
			var getComment:URLRequest = new URLRequest(unescape(messageServerUrl));
			getComment.method = "POST";
			getComment.requestHeaders = new Array(new URLRequestHeader("Content-Type", "text/html"));
			
			//<chat thread="" vpos="" mail="184 " ticket="" user_id="" postkey="" premium="">test</chat>
			var chat:XML = <chat />;
			chat.@thread = thread;
			chat.@vpos = vpos;
			chat.@mail = "184 " + mail;
			chat.@ticket = ticket;
			chat.@user_id = user_id;
			chat.@postkey = postKey;
			chat.@premium = isPremium;
			chat.appendChild(comment);
			
			getComment.data = chat;
			
			this._postLoader.addEventListener(Event.COMPLETE, commentPostCompleteHandler);
			this._postLoader.addEventListener(IOErrorEvent.IO_ERROR, commentPostErrorHandler);
			this._postLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseStatusEventHandler);
			this._postLoader.dataFormat=URLLoaderDataFormat.TEXT;
			this._postLoader.load(getComment);
			
		}
		
		/**
		 * コメントの取得に失敗した場合、IOErrorEventを発行します。
		 * @param event
		 */
		private function commentLoaderErrorHandler(event:ErrorEvent):void{
			trace(event + ":" + event.text);
			dispatchEvent(new IOErrorEvent(COMMENT_GET_ERROR, false, false, event.text));
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
			dispatchEvent(new Event(COMMENT_POST_SUCCESS));
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function commentPostErrorHandler(event:IOErrorEvent):void{
			trace(event);
			dispatchEvent(new IOErrorEvent(COMMENT_POST_FAIL, false, false, event.text));
		}
		
		
		/**
		 * 
		 * 
		 */
		public function close():void{
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