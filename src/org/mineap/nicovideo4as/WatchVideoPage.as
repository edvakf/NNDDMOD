package org.mineap.nicovideo4as
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.unescapeMultiByte;
	
	import mx.messaging.SubscriptionInfo;
	
	import org.mineap.nicovideo4as.util.HtmlUtil;
	
	[Event(name="watchSuccess", type="org.mineap.nicovideo4as.WatchVideoPage")]
	[Event(name="watchFail", type="org.mineap.nicovideo4as.WatchVideoPage")]
	[Event(name="httpResponseStatus", type="HTTPStatusEvent")]
	
	/**
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class WatchVideoPage extends EventDispatcher
	{
		
		private var _watchLoader:URLLoader;
		
		//so.addVariable("videoId", "so8174126");
		private static const videoIdPattern:RegExp = new RegExp("addVariable.\"videoId\", \"([^\"]+)\".");
		
		/*
		<tr>
		<td style="background:#CCCFCF;"><img src="http://res.nimg.jp/img/watch/ftit_description.png" alt="動画の説明文"></td>
		<td width="100%" class="font12" style="background:#FFF;">
			(.*</p>)
		</td>
		</tr>
		*/
		/**
		 * 
		 */
		private var descriptionPattern:RegExp = new RegExp("description:[^']*'(.*)'");
		
		//"<img src=\"http://res.nimg.jp/img/_.gif\" alt=\"動画の説明文\" class=\"video_des_tit\"></td>[^<]*<td width=\"100%\" style=\"background:#F9F9F9;\">(.*</p>)</td>[^<]*</tr>[^<]*</table>"
		
		/**
		 * 
		 */
		private static const fontSizePattern:RegExp = new RegExp("size=\"([1-7])\"", "ig");
		
		/**
		 * 
		 */
		private static const prefix:String = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">" +
			"<html>" +
			"<head>" +
			"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">" +
			"</head>" +
			"<body>";
		
		/**
		 * 
		 */
		private static const suffix:String = "</body>" +
			"</html>";
		
		/**
		 * 投稿者が普通のユーザの時
		 */
		private static const pubUser:String = "<a href=\"user/([^\"]+)\"><img src=\"([^\"]+)\" alt=\"([^\"]+)\" class=\".+\"></a>";
		
		/**
		 * 投稿者がチャンネルの時
		 * <a href="http://ch.nicovideo.jp/channel/ch639"><img src="http://icon.nimg.jp/channel/ch639.jpg?1303983084" alt="「俺の妹がこんなに可愛いわけがない」動画配信チャンネル" class="img_sq48"></a>
		 */
		private static const channel:String = "<a href=\"http://ch.nicovideo.jp/channel/([^\"]+)\"><img src=\"([^\"]+)\" alt=\"([^\"]+)\" class=\".+\"></a>";
		
		/**
		 * "http://www.nicovideo.jp/watch/"を表す定数です
		 */
		public static const WATCH_VIDEO_PAGE_URL:String = "http://www.nicovideo.jp/watch/";
		
		/**
		 * 
		 */
		public static const WATCH_SUCCESS:String = "WatchSuccess";
		
		/**
		 * 
		 */
		public static const WATCH_FAIL:String = "WatchFail";
		
		/**
		 * 
		 */
		private var _videoId:String = "";
		
		/**
		 * 
		 */
		private var _data:Object = "";
		
		/**
		 * 
		 * 
		 */
		public function WatchVideoPage()
		{
			this._watchLoader = new URLLoader();
		}
		
		/**
		 * 
		 * @param videoId
		 * @param isEconomyMode
		 * 
		 */
		public function watchVideo(videoId:String):void{
			
			this._videoId = videoId;
			
			var mUrl:String = WATCH_VIDEO_PAGE_URL + videoId;
			
			var watchURL:URLRequest = new URLRequest(mUrl);
			watchURL.method = "GET";
			watchURL.followRedirects = true;
			
			this._watchLoader.addEventListener(Event.COMPLETE, completeEventHandler);
			this._watchLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			this._watchLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			this._watchLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseHandler);
			this._watchLoader.load(watchURL);
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function getVideoId():String{
			
			if(this._watchLoader.data != null){
				
				var result:Array = videoIdPattern.exec(this._watchLoader.data);
				if(result != null && result.length > 1){
					return result[1];
				}else{
					return this._videoId;
				}
				
			}else{
				return this._videoId;
			}
			
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function getDescription():String{
			
			if (this._watchLoader.data != null) {
				
				var result:Array = descriptionPattern.exec(this._watchLoader.data);
				if(result != null && result.length > 1){
					var html:String = prefix + HtmlUtil.convertCharacterCodeToCharacter(result[1]) + suffix;
					
					html = html.replace(fontSizePattern, replFN);
					
					function replFN():String{
						var value:int = new int(arguments[1]);
						if(arguments[1] != ""){
							value = value-3;
							if(value > 0){
								return (arguments[0] as String).replace(arguments[1], "+" + value);
							}
							return (arguments[0] as String).replace(arguments[1], value);
							
						}
						return arguments[0];
					}
					
					trace(html);
					return html;
				}else{
					return "";
				}
				
			} else {
				return "";
			}
			
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function getPubUserId():String{
			if(this._watchLoader != null && this._watchLoader.data != null){
				var pubUserPattern:RegExp = new RegExp(pubUser);
				var result:Array = pubUserPattern.exec(this._watchLoader.data);
				if(result != null && result.length > 1){
					return result[1];
				}else{
					return null;
				}
			}else{
				return null;
			}
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function getPubUserIconUrl():String{
			if(this._watchLoader != null && this._watchLoader.data != null){
				var pubUserPattern:RegExp = new RegExp(pubUser);
				var result:Array = pubUserPattern.exec(this._watchLoader.data);
				if(result != null && result.length > 1){
					return result[2];
				}else{
					return null;
				}
			}else{
				return null;
			}
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function getPubUserName():String{
			if(this._watchLoader != null && this._watchLoader.data != null){
				var pubUserPattern:RegExp = new RegExp(pubUser);
				var result:Array = pubUserPattern.exec(this._watchLoader.data);
				if(result != null && result.length > 1){
					return result[3];
				}else{
					return null;
				}
			}else{
				return null;
			}
		}
		
		/**
		 * チャンネルを返す。
		 * @return "ch639"など
		 * 
		 */
		public function getChannel():String{
			if (this._watchLoader != null && this._watchLoader.data != null)
			{
				var channelPattern:RegExp = new RegExp(channel);
				var result:Array = channelPattern.exec(this._watchLoader.data);
				if (result != null && result.length > 1)
				{
					return result[1];
				}
			}
			return null;
		}
		
		/**
		 * チャンネルのアイコンURLを返す
		 * @return 
		 * 
		 */
		public function getChannelIconUrl():String{
			if (this._watchLoader != null && this._watchLoader.data != null)
			{
				var channelPattern:RegExp = new RegExp(channel);
				var result:Array = channelPattern.exec(this._watchLoader.data);
				if (result != null && result.length > 1)
				{
					return result[2];
				}
			}
			return null;
		}
		
		/**
		 * チャンネルの名前を返す
		 * @return 
		 * 
		 */
		public function getChannelName():String{
			if (this._watchLoader != null && this._watchLoader.data != null)
			{
				var channelPattern:RegExp = new RegExp(channel);
				var result:Array = channelPattern.exec(this._watchLoader.data);
				if (result != null && result.length > 1)
				{
					return result[3];
				}
			}
			return null;
		}
		
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function completeEventHandler(event:Event):void{
			
			// TODO テスト
//			trace(this.getDescription());
			
			this._data = this._watchLoader.data;
			dispatchEvent(new Event(WATCH_SUCCESS));
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get data():Object{
			return this._data;
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function errorHandler(event:ErrorEvent):void{
			dispatchEvent(new ErrorEvent(WATCH_FAIL, false, false, event.text));
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function httpResponseHandler(event:HTTPStatusEvent):void{
			dispatchEvent(event);
		}
		
		/**
		 * 
		 * 
		 */
		public function close():void{
			try{
				this._watchLoader.close();
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
//			this._watchLoader = null;
			
		}

	}
}