package org.mineap.nicovideo4as
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import org.mineap.nicovideo4as.analyzer.GetFlvResultAnalyzer;
	import org.mineap.nicovideo4as.loader.api.ApiGetFlvAccess;
	import org.mineap.nicovideo4as.model.VideoType;
	
	/**
	 * ニコニコ動画から動画をダウンロードします。
	 * 取得結果は、addVideoLoaderListener()で登録したリスナから取得します。
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class VideoLoader extends EventDispatcher
	{
		
		private var _videoLoader:URLLoader;
		
		private var _apiAccess:ApiGetFlvAccess;
		
		private var _analyzer:GetFlvResultAnalyzer;
		
		private var _videoType:VideoType;
		
		private var _isStreamingPlay:Boolean;
		
		private var _videoUrl:String;
		
		public static const VIDEO_URL_GET_SUCCESS:String = "VideoUrlGetSuccess";
		
		public static const VIDEO_URL_GET_FAIL:String = "VideoUrlGetFail";
		
		/**
		 * コンストラクタ
		 * 
		 */
		public function VideoLoader()
		{
			this._videoLoader = new URLLoader();
			this._apiAccess = new ApiGetFlvAccess();
		}
		
		/**
		 * ニコニコ動画から動画を取得します。
		 * 
		 * @param isStreamingPlay ストリーミング再生かどうかです。
		 * 	trueに設定すると、URL取得完了時にEvent(VIDEO_URL_GET_SUCCESS)が発行され、その後ダウンロード処理を行いません。
		 * @param getflvAccess
		 */
		public function getVideo(isStreamingPlay:Boolean, getflvAccess:ApiGetFlvAccess):void{
			
			this._isStreamingPlay = isStreamingPlay;
			this._apiAccess = getflvAccess;
			
			this._getVideo();
		}
		
		/**
		 * APIから取得したURLを使って動画をダウンロードします。
		 * @param url 
		 * 
		 */
		public function getVideoForApiResult(url:String):void{
			
			this._videoUrl = url;
			
			if(this._videoUrl.indexOf("smile?m=")!=-1){
				this._videoType = VideoType.VIDEO_TYPE_MP4;
			}else if(this._videoUrl.indexOf("smile?v=")!=-1){
				this._videoType = VideoType.VIDEO_TYPE_FLV;
			}else if(this._videoUrl.indexOf("smile?s=")!=-1){
				this._videoType = VideoType.VIDEO_TYPE_SWF;
			}else{
				dispatchEvent(new IOErrorEvent(VIDEO_URL_GET_FAIL, false, false, "UnknownUrl:" + url));
				return;
			}
			
			//通常のダウンロード処理
			var getVideo:URLRequest;
			getVideo = new URLRequest(this._videoUrl);
			this._videoLoader.dataFormat=URLLoaderDataFormat.BINARY;
			this._videoLoader.load(getVideo);
		}
		
		/**
		 * APIのアクセスが成功したら呼ばれます。
		 * @param event
		 * 
		 */
		private function _getVideo():void{
//			trace(unescape(decodeURIComponent(_apiAccess.data)));
			
			this._analyzer = new GetFlvResultAnalyzer();
			this._analyzer.analyze(this._apiAccess.data);
			
			this._videoUrl = this._analyzer.url;
			
			if(this._videoUrl != null){
				if(this._videoUrl.indexOf("smile?m=")!=-1){
					this._videoType = VideoType.VIDEO_TYPE_MP4;
				}else if(this._videoUrl.indexOf("smile?v=")!=-1){
					this._videoType = VideoType.VIDEO_TYPE_FLV;
				}else if(this._videoUrl.indexOf("smile?s=")!=-1){
					this._videoType = VideoType.VIDEO_TYPE_SWF;
				}
			}else{
				dispatchEvent(new IOErrorEvent(VIDEO_URL_GET_FAIL, false, false, "UnknownUrl:" + unescape(decodeURIComponent(_apiAccess.data))));
				close();
				return;
			}
			
			if(this._isStreamingPlay){
				//ストリーミング再生なのでFLVをダウンロードする必要は無い。
				dispatchEvent(new Event(VideoLoader.VIDEO_URL_GET_SUCCESS));
			}else{
				//通常のダウンロード処理
				var getVideo:URLRequest;
				getVideo = new URLRequest(this._videoUrl);
				this._videoLoader.dataFormat=URLLoaderDataFormat.BINARY;
				this._videoLoader.load(getVideo);
			}
			
		}
		
		/**
		 * 動画ロード用のURLLoaderにリスナを追加します。
		 * @param event
		 * @param listener
		 * 
		 */
		public function addVideoLoaderListener(event:String, listener:Function):void{
			this._videoLoader.addEventListener(event, listener);
		}
		
		/**
		 * APIアクセスの結果から取得した動画のURLを返します。
		 * @return 
		 * 
		 */
		public function get videoUrl():String{
			return this._videoUrl;
		}
		
		/**
		 * APIアクセスの結果から取得した動画の種類を返します。
		 * @return 
		 * 
		 */
		public function get videoType():VideoType{
			return this._videoType;
		}
		
		/**
		 * APIアクセスの結果から取得した動画がエコノミーモードかどうか返します。
		 * @return 
		 * 
		 */
		public function get economyMode():Boolean{
			return this._analyzer.economyMode;
		}
		
		/**
		 * 
		 * 
		 */
		public function close():void{
			try{
				this._videoLoader.close();
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
//			this._videoLoader = null;
		}
		
	}
}