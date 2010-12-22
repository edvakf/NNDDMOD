package org.mineap.nicovideo4as
{
	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	
	import org.mineap.nicovideo4as.analyzer.CommentAnalyzer;
	import org.mineap.nicovideo4as.analyzer.GetFlvResultAnalyzer;
	import org.mineap.nicovideo4as.analyzer.GetThreadKeyResultAnalyzer;
	import org.mineap.nicovideo4as.loader.api.ApiGetFlvAccess;
	import org.mineap.nicovideo4as.loader.api.ApiGetThreadkeyAccess;
	import org.mineap.nicovideo4as.loader.api.ApiGetWaybackkeyAccess;
	import org.mineap.nicovideo4as.model.NgUp;
	
	[Event(name="commentGetSuccess", type="CommentLoader")]
	[Event(name="commentGetFail", type="CommentLoader")]
	[Event(name="httpResponseStatus", type="HTTPStatusEvent")]
	
	/**
	 * ニコニコ動画からコメントを取得します。<br>
	 *  
	 * @author shiraminekeisuke(MineAP)
	 * @eventType CommentLoader.COMMENT_GET_SUCCESS
	 * @eventType CommentLoader.COMMENT_GET_FAIL
	 * @eventType HTTPStatusEvent.HTTP_RESPONSE_STATUS
	 */
	public class CommentLoader extends EventDispatcher
	{
		
		private var _commentLoader:URLLoader;
		
		private var _messageServerUrl:String;
		
		private var _apiAccess:ApiGetFlvAccess;
		
		private var _apiGetThreadkeyAccess:ApiGetThreadkeyAccess;
		
		private var _getflvAnalyzer:GetFlvResultAnalyzer;
		
		private var _commentAnalyzer:CommentAnalyzer;
		
		private var _isOwnerComment:Boolean
		
		private var _when:Date;
		
		private var _waybackkey:String;
		
		private var _count:int = 0;
		
		private var _xml:XML;
		
		public static const COMMENT_GET_SUCCESS:String = "CommentGetSuccess";
		
		public static const COMMENT_GET_FAIL:String = "CommentGetFail";
		
		/**
		 * コンストラクタ
		 * 
		 */
		public function CommentLoader()
		{
			this._commentLoader = new URLLoader();
			this._apiGetThreadkeyAccess = new ApiGetThreadkeyAccess();
		}
		
		/**
		 * ニコニコ動画にアクセスしてコメントを取得します。
		 * threadIdが指定された場合はapiAccessの結果を使わずに指定されたthreadIdを使用します。
		 * 
		 * @param videoId コメントを取得したい動画の動画ID。
		 * @param count 取得するコメントの数。
		 * @param isOwnerComment 投稿者コメントかどうか
		 * @param apiAccess getFlvにアクセスするApiGetFlvAccessオブジェクト
		 * @param threadId スレッドID
		 * @param when 過去ログを取得する際の取得開始時刻
		 * @param waybackkey 過去ログを取得する際に必要なwaybackkey
		 */
		public function getComment(videoId:String, 
								   count:int, 
								   isOwnerComment:Boolean, 
								   apiAccess:ApiGetFlvAccess, 
								   when:Date = null,
								   waybackkey:String = null):void
		{
			this._count = count;
			
			this._apiAccess = apiAccess;
			
			this._getflvAnalyzer = new GetFlvResultAnalyzer();
			
			this._isOwnerComment = isOwnerComment;
			
			this._when = when;
			
			this._waybackkey = waybackkey;
			
			var isSucess:Boolean = _getflvAnalyzer.analyze(apiAccess.data);
			
			if(!isSucess){
				dispatchEvent(new IOErrorEvent(COMMENT_GET_FAIL, false, false, _getflvAnalyzer.result));
				close();
				return;
			}
			
			//コメントを投稿する際に使う
			this._messageServerUrl = _getflvAnalyzer.ms;
			
			// getthreadkeyにアクセス
			this._apiGetThreadkeyAccess.addEventListener(Event.COMPLETE, _getComment);
			this._apiGetThreadkeyAccess.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
				trace(event);
				dispatchEvent(new IOErrorEvent(COMMENT_GET_FAIL, false, false, _getflvAnalyzer.result));
				close();
			});
			this._apiGetThreadkeyAccess.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(event:HTTPStatusEvent):void{
				trace(event);
			});
			this._apiGetThreadkeyAccess.getThreadkey(this._getflvAnalyzer.threadId);
			
		}
		
		/**
		 * 
		 */
		private function _getComment(event:Event):void{
			
			//POSTリクエストを生成
			var getComment:URLRequest = new URLRequest(unescape(this._getflvAnalyzer.ms));
			getComment.method = "POST";
			getComment.requestHeaders = new Array(new URLRequestHeader("Content-Type", "text/html"));

			_apiGetThreadkeyAccess.close();
			
			//XMLを生成
			//var xml:String = "<thread fork=\"1\" user_id=\"" + user_id + "\" res_from=\"1000\" version=\"20061206\" thread=\"" + threadId + "\" />";
			var xml:XML = null;
			
			if(this._getflvAnalyzer.needs_key == 1 && !this._isOwnerComment ){ // 投コメは取りに行かないよ
				
				var getThreadKeyResultAnalyzer:GetThreadKeyResultAnalyzer = new GetThreadKeyResultAnalyzer();
				getThreadKeyResultAnalyzer.analyze((event.currentTarget as ApiGetThreadkeyAccess).data);
				
				// 公式 
				/*
				  <thread 
				　thread="******" ← getflv で返ってくる thread_id を使用 
				　version="20061206" 
				　res_from="-1000" 
				　user_id="******" ← getflv で返ってくる user_id を使用 
				　threadkey="******" ← これ以降の属性は getthreadkey で返ってくる内容 
				　force_184="1" 
					　/> 
				*/
				xml = new XML("<thread/>");
				xml.@thread = this._getflvAnalyzer.threadId;
				xml.@version = "20061206";
				xml.@res_from = (this._count * -1);
				xml.@user_id = this._getflvAnalyzer.userId;
				
				for each(var key:String in getThreadKeyResultAnalyzer.getKeys()){
					xml.@[key] = getThreadKeyResultAnalyzer.getValue(key);
				}
				
			}else{
				xml = new XML("<thread/>");
				xml.@res_from = (this._count * -1);
				if(this._isOwnerComment){
					xml.@fork = 1;
				}
				xml.@version = "20061206";
				xml.@thread = this._getflvAnalyzer.threadId;
				xml.@user_id = this._getflvAnalyzer.userId;
				if(this._when != null){
					//unix timeで指定
					xml.@when = int(this._when.time / 1000);
				}
				if(this._waybackkey != null){
					xml.@waybackkey = this._waybackkey;
				}
			}
			getComment.data = xml;
			
			this._commentLoader.dataFormat=URLLoaderDataFormat.TEXT;
			
			this._commentLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseStatusEventHandler);
			this._commentLoader.addEventListener(Event.COMPLETE, commentGetSuccess);
			this._commentLoader.addEventListener(IOErrorEvent.IO_ERROR, errorEventHandler);
			this._commentLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorEventHandler);
			
			//読み込み開始
			this._commentLoader.load(getComment);
			
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function httpResponseStatusEventHandler(event:HTTPStatusEvent):void{
			dispatchEvent(event);
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function commentGetSuccess(event:Event):void{
			try{
				this._xml = new XML((event.currentTarget as URLLoader).data);
				
				var analyzer:CommentAnalyzer = new CommentAnalyzer();
				if(analyzer.analyze(xml, this._count)){
					this._commentAnalyzer = analyzer;
					
					dispatchEvent(new Event(COMMENT_GET_SUCCESS));
					return;	
				}
				
			}catch(error:Error){
				trace(error.getStackTrace())
			}
			dispatchEvent(new ErrorEvent(COMMENT_GET_FAIL, false, false, "fail:analyze"));
			
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function errorEventHandler(event:ErrorEvent):void{
			dispatchEvent(new ErrorEvent(COMMENT_GET_FAIL, false, false, event.text));
			close();
		}
		
		/**
		 * APIの結果から取得したメッセージサーバーのURLを返します。
		 * @return 
		 * 
		 */
		public function get messageServerUrl():String{
			return this._messageServerUrl;
		}
		
		/**
		 * APIの結果から取得したuserIDを返します。
		 * @return 
		 * 
		 */
		public function get userID():String{
			return this._getflvAnalyzer.userId;
		}
		
		/**
		 * APIの結果から取得したthreadIdを返します。
		 * @return 
		 * 
		 */
		public function get threadId():String{
			return this._getflvAnalyzer.threadId;
		}
		
		/**
		 * APIアクセスの結果から現在エコノミーモードかどうかを返します。
		 * @return エコノミーモードのときtrue
		 * 
		 */
		public function get economyMode():Boolean{
			return this._getflvAnalyzer.economyMode;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get ngWords():Vector.<NgUp>{
			return this._getflvAnalyzer.ng_ups;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function close():void{
			try{
				this._commentLoader.close();
			}catch(error:Error){
			}
			try{
				this._apiGetThreadkeyAccess.close();
			}catch(error:Error){
			}
			try{
				this._apiAccess.close();
			}catch(error:Error){
				
			}
		}

		public function get commentAnalzyer():CommentAnalyzer
		{
			return _commentAnalyzer;
		}

		public function get xml():XML
		{
			return _xml;
		}
		
		public function set threadKeyAccessApiUrl(url:String):void
		{
			this._apiGetThreadkeyAccess.url = url;
		}

	}
}