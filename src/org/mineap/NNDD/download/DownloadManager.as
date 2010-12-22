package org.mineap.NNDD.download
{
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.events.CloseEvent;
	import mx.formatters.NumberFormatter;
	
	import org.mineap.NNDD.FileIO;
	import org.mineap.NNDD.LogManager;
	import org.mineap.NNDD.Message;
	import org.mineap.NNDD.NNDDDownloader;
	import org.mineap.NNDD.DownloadedListManager;
	import org.mineap.NNDD.library.ILibraryManager;
	import org.mineap.NNDD.library.LibraryManagerBuilder;
	import org.mineap.NNDD.library.LocalVideoInfoLoader;
	import org.mineap.NNDD.model.DownloadQueueItem;
	import org.mineap.NNDD.model.NNDDVideo;
	import org.mineap.NNDD.util.LibraryUtil;
	import org.mineap.NNDD.util.PathMaker;

	/**
	 * DownloadManager.as
	 * 
	 * Copyright (c) 2009 MAP - MineApplicationProject. All Rights Reserved.
	 *  
	 * @author shiraminekeisuke
	 * 
	 */	
	public class DownloadManager extends EventDispatcher
	{
		
		public var downloadProvider:ArrayCollection;
		public var myListProvider:ArrayCollection;
		public var searchProvider:ArrayCollection;
		public var downloadedListManager:DownloadedListManager;
		public var rankingProvider:ArrayCollection;
		public var libraryManager:ILibraryManager;
		private var logManager:LogManager;
		private var _nnddDownloader:NNDDDownloader;
		private var mailaddress:String;
		private var password:String;
		
		private var isCancel:Boolean;
		private var queueId:String;
		private var queueVideoName:String;
		
		private var isDownloading:Boolean = false;
		
		private var isRetry:Boolean = false;
		private var retryCount:int = 0;
		
		private var timer:Timer = null;
		
		private var canvasQueue:Canvas = null;
		
		private var downloadItemMap:Object = new Object();
		
		public var isContactTheUser:Boolean = false;
		
		public var isAlwaysEconomy:Boolean = false;
		
		public var isAppendComment:Boolean = false;
		
		private var lastStatusUpdateTime:Date = new Date();
		
		/**
		 * 
		 * @param downloadProvider
		 * @param downloadedListManager
		 * @param mailaddress
		 * @param password
		 * @param canvasQueue
		 * @param rankingProvider
		 * @param searchProvider
		 * @param myListProvider
		 * @param logManager
		 * 
		 */
		public function DownloadManager(downloadProvider:ArrayCollection, 
										downloadedListManager:DownloadedListManager, 
										mailaddress:String, 
										password:String, 
										canvasQueue:Canvas, 
										rankingProvider:ArrayCollection, 
										searchProvider:ArrayCollection, 
										myListProvider:ArrayCollection, 
										logManager:LogManager)
		{
			this.downloadProvider = downloadProvider;
			this.myListProvider = myListProvider;
			this.searchProvider = searchProvider;
			this.downloadedListManager = downloadedListManager;
			this.libraryManager = LibraryManagerBuilder.instance.libraryManager;
			this.mailaddress = mailaddress;
			this.password = password;
			this.canvasQueue = canvasQueue;
			this.rankingProvider = rankingProvider;
			this.logManager = logManager;
			
			this.loadDownloadList();
		}
		
		/**
		 * メールアドレスとパスワードを設定します。
		 * @param mailAddress
		 * @param password
		 * 
		 */
		public function setMailAndPass(mailAddress:String = "", password:String = ""):void{
			this.mailaddress = mailAddress;
			this.password = password;
		}
		
		/**
		 * 動画をキューに追加します。
		 * @param video 動画オブジェクト
		 * @paran isStart ダウンロードを開始するかどうか
		 * @return 
		 * 
		 */
		public function add(video:NNDDVideo, isStart:Boolean):Boolean{
			
			if(downloadProvider.length > 100){
				return false;
			}
			
			var item:DownloadQueueItem = new DownloadQueueItem(video, new Date());
			
			var url:String = "http://www.nicovideo.jp/watch/" + PathMaker.getVideoID(video.getDecodeUrl());
			
			downloadProvider.addItem({
				col_videoName:video.videoName,
				col_videoUrl:url,
				col_status:"待機中",
				col_id:item.getDownloadID()
			});
			
			showCountRest();
			
			if(!isDownloading && isStart){
				//"待機中"のものを探してダウンロード開始
				next();
			}
			
			return true;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get listLength():int{
			return downloadProvider.length;
		}
		
		/**
		 * 次のダウンロードを開始します。
		 * キューを上から探索し、ダウンロード済みでないものを見つけたらダウンロードを開始します。
		 * 
		 */
		public function next():void{
			isCancel = false;
			
			if(mailaddress != "" && password != ""){
				if(isDownloading == false){
					for(var i:int = 0; downloadProvider.length > i; i++){
						if(downloadProvider[i].col_status.indexOf("待機中") != -1){
							
							this.queueId = downloadProvider[i].col_id;
							this.queueVideoName = downloadProvider[i].col_videoName;
							
							isDownloading = true;
							
							var timerCount:int = 10;
							if(retryCount > 0){
								timerCount = timerCount*(retryCount*2);
							}
							if(retryCount >= 7){
								stop();
								return;
							}
							
							if(timer != null){
								timer.stop();
							}
							
							var retry:String = "";
							if(isRetry){
								retry = "\nリトライしています";
							}
							
							timer = new Timer(1000, timerCount);
							downloadProvider.setItemAt({
								col_videoName:downloadProvider[i].col_videoName,
								col_videoUrl:downloadProvider[i].col_videoUrl,
								col_status:timerCount+"秒後にDL開始" + retry,
								col_id:downloadProvider[i].col_id,
								col_downloadedPath:downloadProvider[i].col_downloadedPath
							}, i);
							timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void{
								timerCount--;
								var index:int = searchQueueIndexByQueueId(queueId);
								downloadProvider.setItemAt({
									col_videoName:downloadProvider[index].col_videoName,
									col_videoUrl:downloadProvider[index].col_videoUrl,
									col_status:timerCount+"秒後にDL開始" + retry,
									col_id:downloadProvider[index].col_id,
									col_downloadedPath:downloadProvider[index].col_downloadedPath
								}, index);
							});
							timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:TimerEvent):void{
								download(queueId);
								showCountRest();
							});
							timer.start();
							
							showCountRest();
							
							return;
						}
					}
				}
			}
		}
		
		/**
		 * 
		 * @param queueIndex
		 * 
		 */
		private function download(id:String):void{
			
			if(mailaddress != "" && password != ""){
				
				var index:int = searchQueueIndexByQueueId(id);
				
				this.queueVideoName = downloadProvider[index].col_videoName;
				
				isRetry = false;
				var video:NNDDVideo = libraryManager.isExist(LibraryUtil.getVideoKey(downloadProvider[index].col_videoUrl));
				if(video == null){
					video = new NNDDVideo(downloadProvider[index].col_videoUrl, downloadProvider[index].col_videoName);
				}
				this._nnddDownloader = createNNDDDrequestDownload(video);
				
				//失敗系ハンドラ登録
				this._nnddDownloader.addEventListener(NNDDDownloader.COMMENT_GET_FAIL, getFailListener, false, 0, true);
				this._nnddDownloader.addEventListener(NNDDDownloader.GETFLV_API_ACCESS_FAIL, getFailListener, false, 0, true);
				this._nnddDownloader.addEventListener(NNDDDownloader.ICHIBA_INFO_GET_FAIL, getFailListener, false, 0, true);
				this._nnddDownloader.addEventListener(NNDDDownloader.LOGIN_FAIL, getFailListener, false, 0, true);
				this._nnddDownloader.addEventListener(NNDDDownloader.NICOWARI_GET_FAIL, getFailListener, false, 0, true);
				this._nnddDownloader.addEventListener(NNDDDownloader.OWNER_COMMENT_GET_FAIL, getFailListener, false, 0, true);
				this._nnddDownloader.addEventListener(NNDDDownloader.THUMB_IMG_GET_FAIL, getFailListener, false, 0, true);
				this._nnddDownloader.addEventListener(NNDDDownloader.THUMB_INFO_GET_FAIL, getFailListener, false, 0, true);
				this._nnddDownloader.addEventListener(NNDDDownloader.VIDEO_GET_FAIL, getFailListener, false, 0, true);
				this._nnddDownloader.addEventListener(NNDDDownloader.WATCH_FAIL, getFailListener, false, 0, true);
				
				//成功系ハンドラ登録
				this._nnddDownloader.addEventListener(NNDDDownloader.COMMENT_GET_SUCCESS, getSuccessListener, false, 0, true);
				this._nnddDownloader.addEventListener(NNDDDownloader.GETFLV_API_ACCESS_SUCCESS, getSuccessListener, false, 0, true);
				this._nnddDownloader.addEventListener(NNDDDownloader.ICHIBA_INFO_GET_SUCCESS, getSuccessListener, false, 0, true);
				this._nnddDownloader.addEventListener(NNDDDownloader.LOGIN_SUCCESS, getSuccessListener, false, 0, true);
				this._nnddDownloader.addEventListener(NNDDDownloader.NICOWARI_GET_SUCCESS, getSuccessListener, false, 0, true);
				this._nnddDownloader.addEventListener(NNDDDownloader.OWNER_COMMENT_GET_SUCCESS, getSuccessListener, false, 0, true);
				this._nnddDownloader.addEventListener(NNDDDownloader.THUMB_IMG_GET_SUCCESS, getSuccessListener, false, 0, true);
				this._nnddDownloader.addEventListener(NNDDDownloader.THUMB_INFO_GET_SUCCESS, getSuccessListener, false, 0, true);
				this._nnddDownloader.addEventListener(NNDDDownloader.VIDEO_GET_SUCCESS, getSuccessListener, false, 0, true);
				this._nnddDownloader.addEventListener(NNDDDownloader.WATCH_SUCCESS, getSuccessListener, false, 0, true);
				
				//プログレスハンドラ登録
				this._nnddDownloader.addEventListener(NNDDDownloader.VIDEO_DOWNLOAD_PROGRESS, downloadProgressHandler, false, 0, true);
				
				//完了系ハンドラ登録
				this._nnddDownloader.addEventListener(NNDDDownloader.DOWNLOAD_PROCESS_CANCELD, downlaodFailListener);
				this._nnddDownloader.addEventListener(NNDDDownloader.DOWNLOAD_PROCESS_ERROR, downlaodFailListener);
				this._nnddDownloader.addEventListener(NNDDDownloader.DOWNLOAD_PROCESS_COMPLETE, downloadCompleteListener);
				
				logManager.addLog("***ニコニコ動画へ動画取得のリクエスト***");
				
				this._nnddDownloader.requestStart(this.mailaddress, this.password);
			}
			
			
		}
		
		/**
		 * 進行中のニコ動へのアクセスをキャンセルさせます。
		 */
		public function stop():void{
			retryCount = 0;
			if(isDownloading){
				isCancel = true;
				
				var index:int = searchQueueIndexByQueueId(queueId);
				
				if(index != -1){
					if(this._nnddDownloader != null){
						this._nnddDownloader.close(true, false);
						logManager.addLog("ニコニコ動画へのアクセスをキャンセル");
					}
					if(timer != null){
						timer.stop();
					}
					
					setStatus("待機中\nキャンセルされました", false, queueVideoName, index);
					
					isDownloading = false;
					showCountRest();
				}
			}
		}
		
		/**
		 * すべてのダウンロードをキャンセルし、DLリストを空にします。
		 * 
		 */
		public function emptyList():void{
			
			Alert.show(Message.M_DOWNLOAD_PROCESSING, Message.M_MESSAGE, Alert.OK | Alert.CANCEL, null, function(event:CloseEvent):void{
				if(event.detail == Alert.OK){
					stop();
					downloadItemMap = new Object();
					downloadProvider.removeAll();
					showCountRest();
				}
			},null, Alert.CANCEL);
		}
		
		/**
		 * 
		 * 
		 */
		public function removeDownloadedVideo():void{
			Alert.show(Message.M_ALL_DOWNLOADED_VIDEO_DELETE, Message.M_MESSAGE, Alert.OK | Alert.CANCEL, null, function(event:CloseEvent):void{
				if(event.detail == Alert.OK){
					
					var index:int = 0;
					while(true){
						var object:Object = downloadProvider[index];
						if(true == object.col_isDownloaded){
							downloadProvider.removeItemAt(index);
						}else{
							index++;
						}
						if(index >= downloadProvider.length){
							break;
						}
					}
					
					showCountRest();
				}
			},null, Alert.CANCEL);
		}
		
		/**
		 * 渡されたインデックスの項目をリストから削除します。
		 * @param selectedIndices
		 * 
		 */
		public function deleteSelectedItems(selectedIndices:Array):void{
			selectedIndices.sort(Array.NUMERIC);
			for(var i:int=selectedIndices.length-1; i>=0; i--){
				var index:int = selectedIndices[i];
				
				var qIndex:int = searchQueueIndexByQueueId(queueId);
				
				if(index != qIndex || !isDownloading){
					
					delete downloadItemMap[downloadProvider[index].col_id];
					
					downloadProvider.removeItemAt(index);
					
					qIndex = searchQueueIndexByQueueId(queueId);
					if(qIndex != -1){
						queueVideoName = downloadProvider[qIndex].col_videoName;
					}
					showCountRest();
					
				}else{
					Alert.show(Message.M_THIS_ITEM_IS_DOWNLOADING, Message.M_MESSAGE, Alert.OK | Alert.CANCEL, null, function(event:CloseEvent):void{
						if(event.detail == Alert.OK){
							
							delete downloadItemMap[downloadProvider[index].col_id];
							
							downloadProvider.removeItemAt(index);
							if(_nnddDownloader != null){
								_nnddDownloader.close(true, false);
							}
							isDownloading = false;
							if(timer != null){
								timer.stop();
							}
							qIndex = searchQueueIndexByQueueId(queueId);
							if(qIndex != -1){
								queueVideoName = downloadProvider[qIndex].col_videoName;
							}
							showCountRest();
						}
					},null, Alert.CANCEL);
				}
				
			}
		}
		
		/**
		 * "待機中"の項目を数えて、タブに反映します。
		 * 
		 * @return 残りの"待機中"の項目数
		 */
		public function showCountRest():int{
			var count:int = 0;
			if(isDownloading){
				count++;
			}
			for(var i:int = 0; i<downloadProvider.length ;i++ ){
				if(downloadProvider[i].col_status.indexOf("待機中") != -1){
					count++;
				}
			}
			if(canvasQueue != null){
				if(count != 0){
					canvasQueue.label = "DLリスト(" + count + ")";
				}else{
					canvasQueue.label = "DLリスト";
				}
			}
			
			saveDownloadList();
			
			return count;
		}
		
		
		/**
		 * 
		 * @param video
		 * @return 
		 * 
		 */
		public function createNNDDDrequestDownload(video:NNDDVideo):NNDDDownloader{
			
			var nnddDownloader:NNDDDownloader = new NNDDDownloader(logManager);
			var myLibrary:File = libraryManager.libraryDir;
			try{
				if(video.getDecodeUrl() != null){
					myLibrary = new File(video.getDecodeUrl().substr(0, video.getDecodeUrl().lastIndexOf("/")));
					if(!myLibrary.exists){
						myLibrary = libraryManager.libraryDir;
					}
				}
			}catch(error:Error){
				myLibrary = libraryManager.libraryDir;
			}
			nnddDownloader.requestDownload(this.mailaddress, this.password, PathMaker.getVideoID(video.getDecodeUrl()), 
				null, myLibrary, false, isContactTheUser, this.isAlwaysEconomy, this.isAppendComment, Application.application.getSaveCommentMaxCount());
			
			return nnddDownloader;
		}
		
		/**
		 * 引数で渡されたNNDDVideoオブジェクトと同じuriの動画がDLリストに既に追加されていないか調べます。
		 * @param video
		 * @return 
		 * 
		 */
		public function isExists(video:NNDDVideo):Boolean{
			
			for(var i:int = 0; i<downloadProvider.length; i++){
				if(downloadProvider[i].col_videoUrl == video.getDecodeUrl()){
					return true;
				}
				if(PathMaker.getVideoID(downloadProvider[i].col_videoUrl) == PathMaker.getVideoID(video.getDecodeUrl())){
					return true;
				}
			}
			
			return false;
		}
		
		/**
		 * 取得成功系リスナー
		 * @param event
		 * 
		 */
		public function getSuccessListener(event:Event):void{
			var status:String = "";
			if(event.type == NNDDDownloader.LOGIN_SUCCESS){
				status = "ログイン成功";
			}else if(event.type == NNDDDownloader.WATCH_SUCCESS){
				status = "動画ページアクセス成功";
			}else if(event.type == NNDDDownloader.GETFLV_API_ACCESS_SUCCESS){
				status = "APIアクセス成功";
			}else if(event.type == NNDDDownloader.COMMENT_GET_SUCCESS){
				status = "コメント取得成功";
			}else if(event.type == NNDDDownloader.OWNER_COMMENT_GET_SUCCESS){
				status = "投稿者コメント取得成功";
			}else if(event.type == NNDDDownloader.NICOWARI_GET_SUCCESS){
				status = "ニコ割取得成功";
			}else if(event.type == NNDDDownloader.THUMB_INFO_GET_SUCCESS){
				status = "サムネイル情報取得成功";
			}else if(event.type == NNDDDownloader.THUMB_IMG_GET_SUCCESS){
				status = "サムネイル画像取得成功";
			}else if(event.type == NNDDDownloader.ICHIBA_INFO_GET_SUCCESS){
				status = "市場情報取得成功";
			}else if(event.type == NNDDDownloader.VIDEO_GET_SUCCESS){
				status = "動画取得成功";
			} 
			
			var newVideoName:String = null;
			if(NNDDDownloader(event.currentTarget).nicoVideoName != null){
				newVideoName = NNDDDownloader(event.currentTarget).nicoVideoName;
			}
			
			logManager.addLog(status + ":" + event.type);
			
			var index:int = searchQueueIndexByQueueId(queueId);
			
			setStatus("進行中\n" + status, false, queueVideoName, index, "", newVideoName);
			
			if(newVideoName != null){
				queueVideoName = newVideoName;
			}
		}
		
		/**
		 * 取得失敗系リスナー
		 * @param event
		 * 
		 */
		public function getFailListener(event:IOErrorEvent):void{
			var status:String = "";
			if(event.type == NNDDDownloader.LOGIN_FAIL){
				status = "ログイン失敗";
			}else if(event.type == NNDDDownloader.WATCH_FAIL){
				status = "動画ページアクセス失敗";
			}else if(event.type == NNDDDownloader.GETFLV_API_ACCESS_FAIL){
				status = "APIアクセス失敗";
			}else if(event.type == NNDDDownloader.COMMENT_GET_FAIL){
				status = "コメント取得失敗";
			}else if(event.type == NNDDDownloader.OWNER_COMMENT_GET_FAIL){
				status = "投稿者コメント取得失敗";
			}else if(event.type == NNDDDownloader.NICOWARI_GET_FAIL){
				status = "ニコ割取得失敗";
			}else if(event.type == NNDDDownloader.THUMB_INFO_GET_FAIL){
				status = "サムネイル情報取得失敗";
			}else if(event.type == NNDDDownloader.THUMB_IMG_GET_FAIL){
				status = "サムネイル画像取得失敗";
			}else if(event.type == NNDDDownloader.ICHIBA_INFO_GET_FAIL){
				status = "市場情報取得失敗";
			}else if(event.type == NNDDDownloader.VIDEO_GET_FAIL){
				status = "動画取得失敗";
			} 
			
			var newVideoName:String = null;
			if(NNDDDownloader(event.currentTarget).nicoVideoName != null){
				 newVideoName = NNDDDownloader(event.currentTarget).nicoVideoName;
			}
			
			logManager.addLog(status + ":" + event.type + ":" + event.text);
			var index:int = searchQueueIndexByQueueId(queueId);
			setStatus("進行中\n" + status, false, queueVideoName, index, "", newVideoName);
			
			if(newVideoName != null){
				queueVideoName = newVideoName;
			}
		}
		
		/**
		 * プログレスイベント用リスナー
		 * @param event
		 * 
		 */
		public function downloadProgressHandler(event:ProgressEvent):void{
			var date:Date = new Date();
			if(date.time - lastStatusUpdateTime.time > 100){
				if(event.type == NNDDDownloader.VIDEO_DOWNLOAD_PROGRESS){
					
					this.lastStatusUpdateTime = date;
					
					var loadedValue:Number = new Number(event.bytesLoaded/1000000);
					var totalValue:Number = new Number(event.bytesTotal/1000000);
					var formatter:NumberFormatter = new NumberFormatter();
					formatter.precision = 1;
					
					var index:int = searchQueueIndexByQueueId(queueId);
					setStatus("動画をDL中\n" + new int((event.bytesLoaded/event.bytesTotal)*100) + "%\n" + 
							formatter.format(loadedValue)+"MB/"+formatter.format(totalValue)+"MB", false, queueVideoName, index);
				}
			}
		}
		
		/**
		 * ダウンロード完了リスナー
		 * @param event
		 * 
		 */
		public function downloadCompleteListener(event:Event):void{
			
			/** ここから今までのAccess2Nicoの処理 **/
			
			var nnddVideo:NNDDVideo = (event.target as NNDDDownloader).downloadedVideo;
			nnddVideo.modificationDate = new Date();
			//ライブラリに同じ物があれば削除
			var videoId:String = LibraryUtil.getVideoKey(nnddVideo.getDecodeUrl());
			if(videoId != null){
				var oldVideo:NNDDVideo = libraryManager.remove(videoId, false);
				if(oldVideo != null && nnddVideo.getDecodeUrl() != oldVideo.getDecodeUrl()){
					nnddVideo.creationDate = oldVideo.creationDate;
					if(nnddVideo.creationDate != null){
						nnddVideo.creationDate = nnddVideo.modificationDate;
					}
					
					try{
						//既にDL済のファイルが存在するが、エコノミーモードだった等の理由でファイル名（拡張子）が違う。ファイルが２個できるのを防ぐため、古い方を削除。
						var oldFile:File = new File(oldVideo.uri);
						if(oldFile.exists){
							oldFile.deleteFile();
						}
					}catch(error:Error){
						logManager.addLog("ダウンロード済みの古いファイルを削除しようとしましたが、失敗しました。:" + oldVideo.getDecodeUrl() + "\nError:" + error.getStackTrace());
					}
				}else{
					nnddVideo.creationDate = new Date();
				}
			}else{
				nnddVideo.creationDate = nnddVideo.modificationDate;
			}
			
			//タグ情報を読み込んでライブラリに反映
			var video:NNDDVideo = new LocalVideoInfoLoader().loadInfo(nnddVideo.getDecodeUrl());
			var localThumbImgPath:String = PathMaker.createThumbImgFilePath(nnddVideo.getDecodeUrl(), true);
			video.thumbUrl = localThumbImgPath;
			video.creationDate = nnddVideo.creationDate;
			video.modificationDate = nnddVideo.modificationDate;
			video.isEconomy = nnddVideo.isEconomy;
			video.playCount = nnddVideo.playCount;
			
//			libraryManager.update(video, true);
			libraryManager.add(video, false, true);
			
			logManager.addLog("動画のダウンロード完了:" + video.getDecodeUrl());
			var index:int = searchQueueIndexByQueueId(queueId);
			setStatus("動画保存済\n右クリックから再生できます。", true, queueVideoName, index, video.getDecodeUrl());
			
			logManager.addLog("***動画取得完了***");
				
			this.downloadedListManager.refresh();
			
			/** ここまで今までのAccess2Nicoの処理 **/
			/** ここから今までのDownloadManagerの処理 **/
			
			removeHandler();
			isDownloading = false;
			showCountRest();
			retryCount = 0;
			
			this._nnddDownloader = null;
			
			/** **/
			if(!isCancel && isDownloading == false){
				next();
			}
			
		}
		
		/**
		 * ダウンロード失敗リスナー
		 * @param event
		 * 
		 */
		public function downlaodFailListener(event:Event):void{
			var status:String = "";
			removeHandler();
			if(event.type == NNDDDownloader.DOWNLOAD_PROCESS_CANCELD){
				status = "キャンセル";
				logManager.addLog("エラー:" + (event.target as NNDDDownloader).saveVideoName);
				logManager.addLog("***動画取得キャンセル***");
				if(isDownloading){
					isCancel = true;
					retryCount = 0;
					if(timer != null){
						timer.stop();
					}
					isDownloading = false;
					var index:int = searchQueueIndexByQueueId(queueId);
					setStatus("待機中\n" + status, false, queueVideoName, index);
					showCountRest();
				}
			}else if(event.type == NNDDDownloader.DOWNLOAD_PROCESS_ERROR){
				status = "失敗(エラー)";
				logManager.addLog("エラー:" + (event.target as NNDDDownloader).saveVideoName);
				logManager.addLog("***動画取得エラー終了***");
				if(isDownloading){
					isRetry = true;
					retryCount++;
					if(timer != null){
						timer.stop();
					}
					isDownloading = false;
					showCountRest();
					var index:int = searchQueueIndexByQueueId(queueId);
					setStatus("待機中\n" + status, false, queueVideoName, index);
					next();
				}
			}
			this._nnddDownloader = null;
			
		}
		
		/**
		 * 
		 * @param status
		 * @param index
		 * @param path 省略可能
		 * @param newVideoName
		 * 
		 */
		public function setStatus(status:String, isDownloaded:Boolean, videoName:String, qIndex:int, path:String = "", newVideoName:String = null):void{
			
			if(qIndex == -1){
				return;
			}
			
			var downloadingVideoName:String = videoName;
			if(newVideoName != null){
				downloadingVideoName = newVideoName;
			}
			
			if(downloadProvider != null){
				if(downloadProvider.length > qIndex && downloadProvider[qIndex] != undefined && downloadProvider[qIndex].col_videoName.indexOf(videoName) != -1){
					downloadProvider.setItemAt({
						col_videoName:downloadingVideoName,
						col_videoUrl:downloadProvider[qIndex].col_videoUrl,
						col_status:status,
						col_id:downloadProvider[qIndex].col_id,
						col_downloadedPath: path,
						col_isDownloaded: isDownloaded
					}, qIndex);
				}
			}
			
			var lastIndex:int = videoName.lastIndexOf("- [");
			if(lastIndex != -1){
				lastIndex -= 1;
			}
			if(lastIndex == -1){
				lastIndex = videoName.indexOf("\n");
			}
			if(lastIndex == -1){
				lastIndex = videoName.length;
			}
			videoName = videoName.substring(0, lastIndex);
			
			//ランキングリストを更新
			var rankingVideoIndex:int = -1;
			if(rankingProvider != null){
				for(var index:int = 0; index<rankingProvider.length; index++){
					if(rankingProvider[index].dataGridColumn_videoName.indexOf(videoName) != -1){
						rankingVideoIndex = index;
						break;
					}
				}
			}
			
			if(rankingProvider != null && rankingVideoIndex != -1 && rankingProvider.length > rankingVideoIndex){
				if(videoName != null && rankingProvider[rankingVideoIndex].dataGridColumn_videoName.indexOf(videoName) != -1){
					this.rankingProvider.setItemAt({
						dataGridColumn_ranking: rankingProvider[rankingVideoIndex].dataGridColumn_ranking,
						dataGridColumn_preview: rankingProvider[rankingVideoIndex].dataGridColumn_preview,
						dataGridColumn_videoName: rankingProvider[rankingVideoIndex].dataGridColumn_videoName,
						dataGridColumn_Info: rankingProvider[rankingVideoIndex].dataGridColumn_Info,
						dataGridColumn_videoInfo: rankingProvider[rankingVideoIndex].dataGridColumn_videoInfo,
						dataGridColumn_condition: status,
						dataGridColumn_videoPath: path,
						dataGridColumn_date: rankingProvider[rankingVideoIndex].dataGridColumn_date,
						dataGridColumn_nicoVideoUrl: rankingProvider[rankingVideoIndex].dataGridColumn_nicoVideoUrl
					},rankingVideoIndex);
				}
			}
			
			//検索結果の値を更新
			var searchVideoIndex:int = -1;
			if(searchProvider != null){
				for(index = 0; index<searchProvider.length; index++){
					if(searchProvider[index].dataGridColumn_videoName.indexOf(videoName) != -1){
						searchVideoIndex = index;
						break;
					}
				}
			}
			
			if(searchProvider != null && searchVideoIndex != -1 && searchProvider.length > searchVideoIndex){
				if(videoName != null && searchProvider[searchVideoIndex].dataGridColumn_videoName.indexOf(videoName) != -1){
					this.searchProvider.setItemAt({
						dataGridColumn_ranking: searchProvider[searchVideoIndex].dataGridColumn_ranking,
						dataGridColumn_preview: searchProvider[searchVideoIndex].dataGridColumn_preview,
						dataGridColumn_videoName: searchProvider[searchVideoIndex].dataGridColumn_videoName,
						dataGridColumn_Info: searchProvider[searchVideoIndex].dataGridColumn_Info,
						dataGridColumn_videoInfo: searchProvider[searchVideoIndex].dataGridColumn_videoInfo,
						dataGridColumn_condition: status,
						dataGridColumn_videoPath: path,
						dataGridColumn_date: searchProvider[searchVideoIndex].dataGridColumn_date,
						dataGridColumn_nicoVideoUrl: searchProvider[searchVideoIndex].dataGridColumn_nicoVideoUrl
					},searchVideoIndex);
				}
			}
			
			//マイリストの値を更新
			var myListVideoIndex:int = -1;
			if(myListProvider != null){
				for(index = 0; index<myListProvider.length; index++){
					if(myListProvider[index].dataGridColumn_videoName.indexOf(videoName) != -1){
						myListVideoIndex = index;
						break;
					}
				}
			}
			
			if(myListProvider != null && myListVideoIndex != -1 && myListProvider.length > myListVideoIndex){
				if(videoName != null && myListProvider[myListVideoIndex].dataGridColumn_videoName.indexOf(videoName) != -1){
					this.myListProvider.setItemAt({
						dataGridColumn_index: myListProvider[myListVideoIndex].dataGridColumn_index,
						dataGridColumn_preview: myListProvider[myListVideoIndex].dataGridColumn_preview,
						dataGridColumn_videoName: myListProvider[myListVideoIndex].dataGridColumn_videoName,
						dataGridColumn_videoInfo: myListProvider[myListVideoIndex].dataGridColumn_videoInfo,
						dataGridColumn_condition: status,
						dataGridColumn_videoUrl: myListProvider[myListVideoIndex].dataGridColumn_videoUrl,
						dataGridColumn_videoLocalPath: path
					},myListVideoIndex);
				}
			}
		}
		
		/**
		 * リスナを解除します。
		 * 
		 */
		public function removeHandler():void{
			this._nnddDownloader.removeEventListener(NNDDDownloader.DOWNLOAD_PROCESS_COMPLETE, downloadCompleteListener);
			this._nnddDownloader.removeEventListener(NNDDDownloader.DOWNLOAD_PROCESS_CANCELD, downlaodFailListener);
			this._nnddDownloader.removeEventListener(NNDDDownloader.DOWNLOAD_PROCESS_ERROR, downlaodFailListener);
		}
		
		/**
		 * ダウンロードリストを保存します。
		 * 
		 */
		public function saveDownloadList():void{
			
			try{
				
				var saveXML:XML = <downloadList/>;
				
				for(var i:int=0; i<downloadProvider.length; i++){
					
					var xml:XML = <downloadItem/>;
					xml.videoName = encodeURIComponent(downloadProvider[i].col_videoName);
					xml.videoUrl = encodeURIComponent(downloadProvider[i].col_videoUrl);
					xml.status = encodeURIComponent(downloadProvider[i].col_status);
					xml.downloadedPath = encodeURIComponent(downloadProvider[i].col_downloadedPath);
					xml.col_id = encodeURIComponent(downloadProvider[i].col_id);
					xml.isDownloaded = encodeURIComponent(downloadProvider[i].col_isDownloaded);
					
					saveXML.appendChild(xml);
					
				}
				
				try{
					var saveFile:File = new File(libraryManager.systemFileDir.url + "/downloadList.xml");
					var fileIO:FileIO = new FileIO(logManager);
					fileIO.saveXMLSync(saveFile, saveXML);
					
					var oldSaveFile:File = new File(libraryManager.libraryDir.url + "/downloadList.xml");
					if(oldSaveFile.exists){
						oldSaveFile.moveToTrash();
					}
					
					logManager.addLog("ダウンロードリストを保存:" + saveFile.nativePath);
					
				}catch(error:IOError){
					Alert.show("ダウンロードリストの保存に失敗しました。\n" + error);
					logManager.addLog("ダウンロードリストの保存に失敗:" + saveFile.nativePath + "\n" + error + ":" + error.getStackTrace());
				}
			
			}catch(error:Error){
				Alert.show("ダウンロードリストの保存に失敗しました。\n" + error);
				logManager.addLog("ダウンロードリストの保存に失敗:" + saveFile.nativePath + "\n" + error + ":" + error.getStackTrace());
			}
			
		}
		
		/**
		 * ダウンロードリストをロードします。
		 * 
		 */
		public function loadDownloadList():void{
			
			try{
				downloadItemMap = new Object();
				downloadProvider.removeAll();
				
				var loadFile:File = new File(libraryManager.systemFileDir.url + "/downloadList.xml");
				if(!loadFile.exists){
					loadFile = new File(libraryManager.libraryDir.url + "/downloadList.xml");
				}
				
				if(loadFile.exists){
					
					try{
						var fileIO:FileIO = new FileIO(logManager);
						var loadXML:XML = fileIO.loadXMLSync(loadFile.url, true);
					}catch(error:IOError){
						Alert.show("ダウンロードリストの読み込みに失敗しました。\n" + loadFile.url + "/downloadList.xml", Message.M_ERROR);
						logManager.addLog("ダウンロードリストの読み込みに失敗:" + loadFile.url + "/downloadList.xml\n" + error + ":" + error.getStackTrace());
					}
					var xmlList:XMLList = loadXML.children();
					for(var i:int=0; i<xmlList.length(); i++){
						
						var name:String = decodeURIComponent(xmlList[i].videoName);
						
						var id:String = new Date().time + "-" + i;
						if(xmlList[i].colId != null && xmlList[i].colId != undefined && xmlList[i].colId != ""){
							id = decodeURIComponent(xmlList[i].col_id);
						}
						
						var status:String = decodeURIComponent(xmlList[i].status);
						var isDownloaded:Boolean = false;
						
						if(status.indexOf("動画保存済") == -1){
							isDownloaded = true;
						}
						if("true" == xmlList[i].isDownloaded){
							isDownloaded = true;
						}
							
						downloadProvider.addItem({
							col_videoName:name,
							col_videoUrl:decodeURIComponent(xmlList[i].videoUrl),
							col_status:status,
							col_id:id,
							col_downloadedPath: decodeURIComponent(xmlList[i].downloadedPath),
							col_isDownloaded:isDownloaded
						});
					}
					
					logManager.addLog("ダウンロードリストを読み込み:" + loadFile.nativePath);
					this.showCountRest();
				}else{
					logManager.addLog("ダウンロードリストは存在しません:" + loadFile.nativePath);
				}
			
			}catch(error:Error){
				Alert.show("ダウンロードリストの読み込みに失敗しました。\n" + libraryManager.libraryDir.url + "/downloadList.xml", Message.M_ERROR);
				logManager.addLog("ダウンロードリストの読み込みに失敗:" + libraryManager.libraryDir.url + "/downloadList.xml\n" + error + ":" + error.getStackTrace());
			}
			
		}
		
		/**
		 * 
		 * @param queueId
		 * @return 
		 * 
		 */
		private function searchQueueIndexByQueueId(queueId:String):int{
			for(var index:int = 0; downloadProvider.length > index; index++){
				if(downloadProvider[index].col_id == queueId){
					return index;
				}
			}
			return -1;
		}
		
		
	}
}