package org.mineap.NNDD.playList
{
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.DataGrid;
	import mx.events.CloseEvent;
	
	import org.mineap.NNDD.FileIO;
	import org.mineap.NNDD.LogManager;
	import org.mineap.NNDD.library.ILibraryManager;
	import org.mineap.NNDD.library.namedarray.LibraryManager;
	import org.mineap.NNDD.library.LibraryManagerBuilder;
	import org.mineap.NNDD.model.NNDDVideo;
	import org.mineap.NNDD.util.DateUtil;
	import org.mineap.NNDD.util.LibraryUtil;
	import org.mineap.NNDD.util.PathMaker;

	/**
	 * プレイリストの管理を行うクラスです。
	 * 
	 * Copyright (c) 2008 MAP - MineApplicationProject. All Rights Reserved.
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class PlayListManager extends EventDispatcher
	{
		private var playListProvider:Array = null;
		public var downLoadedProvider:ArrayCollection = null;
		private var playListArray:Array = new Array();
		private var logManager:LogManager = null;
		private var libraryManager:ILibraryManager = null;
		
		private var fileIO:FileIO = new FileIO(logManager);
		
		public static const PLAYLIST_UPDATE:String = "PlaylistUpdate";
		
		private var isPlayListSaveError:Boolean = false;
		
		public var isSelectedPlayList:Boolean = false;
		public var selectedPlayListIndex:int = -1;
		
		private var downLoadedDataGrid:DataGrid;
		
		/**
		 * コンストラクタです。
		 * プレイリストを管理するplayListProvierとプレイリストの内容を表示するdownLoadedProviderで変数を初期化します。
		 * 
		 * @param playListProvider プレイリストを管理するプロバイダです
		 * @param downLoadedProvider 各プレイリストの項目を表示するためのプロバイダです
		 * 
		 */
		public function PlayListManager(playListProvider:Array, downLoadedProvider:ArrayCollection, logManager:LogManager, dataGrid:DataGrid)
		{
			this.libraryManager = LibraryManagerBuilder.instance.libraryManager;
			this.playListProvider = playListProvider;
			this.downLoadedProvider = downLoadedProvider;
			this.downLoadedDataGrid = dataGrid;
			
			this.logManager = logManager;
			
			//TODO プレイリスト一覧の読み込み開始
			var dir:File = new File(libraryManager.playListDir.url);
			if(dir.exists){
				readPlayListSummary(dir);
			}else{
				dir = new File(libraryManager.libraryDir.url + "/playList/");
				try{
					dir.moveTo(libraryManager.playListDir);
				}catch(error:Error){
					trace(error);
				}
				readPlayListSummary(libraryManager.playListDir);
				saveAllPlayList();
			}
		}
		
		/**
		 * プレイリストの一覧を読み込みます。
		 * 読み込むファイルは拡張子がm3uのファイルです。
		 * 
		 * @param path プレイリストが保存されているディレクトリへのパス
		 * @return 
		 */
		public function readPlayListSummary(dir:File):Array{
			var myPlayListArray:Array = new Array();
			
			if(!dir.exists){
				if(playListProvider != null){
					playListProvider.splice(0, playListProvider.length);
				}
				return this.playListProvider;
			}
			
			try{
				
				myPlayListArray = dir.getDirectoryListing();
				
				if(playListProvider != null && playListProvider.length >= 0){
					playListProvider.splice(0, playListProvider.length);
					playListArray.splice(0, playListArray.length);
					//ディレクトリの項目一覧をプレイリストに追加
					var myIndex:int = 0;
					for(var index:int = 0; index < myPlayListArray.length; index++){
						if((myPlayListArray[index] as File).url.indexOf(".m3u") != -1 
							|| (myPlayListArray[index] as File).url.indexOf(".M3U") != -1){
							var url:String = myPlayListArray[index].url;
							playListProvider.push(unescape(decodeURIComponent(url.substring(url.lastIndexOf("/")+1))));
							readPlayList(url, myIndex++);
							
						}
					}
				}
				
			}catch(error:Error){
				Alert.show("プレイリスト一覧の生成に失敗しました。\nパス:" + dir.nativePath + "\n"+error, "エラー");
				logManager.addLog("プレイリスト一覧の生成に失敗\nパス:" + dir.nativePath + "\n"+error);
			}
			
			
			return this.playListProvider;
		}
		
		/**
		 * 指定されたpathのファイルをプレイリストとして読み込みます。
		 * 読み込んだ結果はplayListArray[pIndex]に代入されます。pIndexが指定されていない場合(-1の場合)、
		 * 読み込み結果はplayListArrayにpushされます。
		 * 
		 * @param path
		 * @param pIndex 
		 * 
		 */
		public function readPlayList(path:String, pIndex:int = -1):void{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, function(event:Event):void{
				var pattern1:RegExp = new RegExp("[^\\n]+", "ig");
				var pattern2:RegExp = new RegExp("#EXTINF:([\\d]*),(.*)");
				var playItems:Array = (loader.data as String).match(pattern1);
				
				var videoArray:Array = new Array();
				
				for(var i:int = 0; i<playItems.length ; i++){
					try{
						if(playItems[i].indexOf("#") != 0){
							//コメントアウト部分ではない
							var filePath:String = String(playItems[i]);
							var video:NNDDVideo = new NNDDVideo(filePath);
							
							if(filePath.indexOf("http") != -1){
								var videoId:String = PathMaker.getVideoID(filePath);
								if(videoId != null){
									var thumbImgUrl:String = PathMaker.getThumbImgUrl(videoId);
									if(thumbImgUrl != null){
										video.thumbUrl = thumbImgUrl;
									}
								}
							}
							
							if((i+1)<playItems.length && playItems[i+1].indexOf("#EXTINF:") != -1){
								//ファイルパスの次が付加情報
								var array:Array = pattern2.exec(playItems[i+1]);
								if(array != null){
									video.time = array[1];//曲の長さ
									video.videoName = array[2];//タイトル
								}
								i++;
							}else{
								//違ったら次の行へ
							}
							
							videoArray.push(video);
							
						}
					}catch(error:Error){
						//読み込みエラー。スキップ。
						logManager.addLog("プレイリストが不正:Path=[" + path + "] + Line=[" + i + "]");
						trace(error.getStackTrace());
					}
				}
				
				if(pIndex == -1){
					playListArray.push(videoArray);
				}else{
					playListArray[pIndex] = videoArray;
				}
				
			});
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
				Alert.show("プレイリストの読み込みに失敗しました。\nパス:" + path + "\n"+event, "エラー");
				logManager.addLog("プレイリストの読み込みに失敗\nパス:" + path + "\n"+event);
			});
			
			loader.load(new URLRequest(path));
		}
		
		/**
		 * 指定されたindex番目にあるプレイリストでdownLoadedProviderを更新します。
		 *  
		 * @param index
		 * 
		 */
		public function showPlayList(index:int, isSave:Boolean = true):void{
			
			if(index >= playListArray.length){
				return;
			}
			
			//今あるプレイリストを保存
			if(isSave){
				this.saveAllPlayList();
			}
			
			downLoadedProvider.removeAll();
			downLoadedProvider.sort = null;
			
			for(var i:int=0; i < playListArray[index].length; i++){
				var video:NNDDVideo = playListArray[index][i];
				var thumbUrl:String = "";
				var creationDate:String = "-";
				var playCount:Number = 0;
				var status:String = "";
				var tempVideo:NNDDVideo = libraryManager.isExist(PathMaker.getVideoID(video.getDecodeUrl()));
				
				if(tempVideo != null){
					video = tempVideo;
				}
				
				if(video.uri.indexOf("http://") != -1){
					status = "未ダウンロード";
				}
				
				thumbUrl = video.thumbUrl;
				creationDate = DateUtil.getDateString(video.creationDate);
				playCount = video.playCount;
				if(thumbUrl == ""){
					thumbUrl = PathMaker.createThumbImgFilePath(video.getDecodeUrl(), true);
				}
				
				downLoadedProvider.addItem({
					dataGridColumn_thumbImage: thumbUrl,
					dataGridColumn_videoName: video.getVideoNameWithVideoID(),
					dataGridColumn_date: creationDate,
					dataGridColumn_count: playCount,
					dataGridColumn_condition: status,
					dataGridColumn_videoPath: video.getDecodeUrl()
				});
			}
			
			logManager.addLog("プレイリスト表示:" + playListProvider[index]);
			
		}
		
		/**
		 * 指定されたインデックスのプレイリストに項目を追加します。
		 * 
		 * @param pIndex プレイリストのインデックス
		 * @param nnddVideoArray 追加したいアイテムのURL
		 * @param index プレイリストの何番目にURLを追加するかを指定するIndex
		 * 
		 */
		public function addNNDDVideos(pIndex:int, nnddVideoArray:Array, index:int = -1):void{
			if(playListArray[pIndex] != null){
				if(index == -1){
					index = nnddVideoArray.length;
				}
				nnddVideoArray = nnddVideoArray.concat((playListArray[pIndex] as Array).slice(index));
				playListArray[pIndex] = ((playListArray[pIndex] as Array).slice(0, index)).concat(nnddVideoArray);
				trace(playListArray[pIndex]);
			}
		}
		
		/**
		 * 新しいプレイリストを追加します。
		 * @param newName プレイリストの名前を指定します。指定しない場合は"新規プレイリスト"になります。
		 * @return 追加したプレイリストのファイル名を返します。
		 */
		public function addPlayList(newName:String = null):String{
			
			if(newName == null){
				newName = "新規プレイリスト"
			}
			var tempFileName:String = newName;
			for(var j:int=0;;j++){
				var exists:Boolean = false;
				for(var i:int=0; i<playListProvider.length; i++){
					if((playListProvider[i] == (tempFileName + ".m3u")) || (playListProvider[i] == (tempFileName + ".M3U"))){
						exists = true;
					}
				}
				if(exists){
					tempFileName = newName + (j+1);
				}else{
					break;
				}
			}

			
			var fileName:String = tempFileName + ".m3u";
			
			playListProvider.push(fileName);
			playListArray.push(new Array());
			dispatchEvent(new Event(PlayListManager.PLAYLIST_UPDATE));
//			this.savePlayListByIndex(playListProvider.length-1);

			return fileName;
		}
		
		/**
		 * 指定されたプレイリストのitemIndex番目の項目をプレイリストから取り除きます。
		 * 
		 * @param pIndex
		 * @param itemIndex
		 * @return 
		 * 
		 */
		public function removePlayListItemByIndex(pIndex:int, itemIndices:Array):void{
			itemIndices.sort();
			for(var i:int = itemIndices.length-1; i>-1; i--){
				downLoadedProvider.removeItemAt(itemIndices[i]);
				playListArray[pIndex].splice(itemIndices[i], 1);
	//			this.savePlayListByIndex(pIndex);
			}
		}
		
		
		/**
		 * 指定されたプレイリストの名前を変更します。
		 * @param pIndex
		 * @param newName
		 * @return 
		 * 
		 */
		public function reNamePlayList(pIndex:int, newName:String):void{
			playListProvider[pIndex] = newName;
			dispatchEvent(new Event(PlayListManager.PLAYLIST_UPDATE));
		}
		
		/**
		 * playListProviderのインデックスに該当するプレイリストをProviderから削除します。
		 * 同時に、ローカルディレクトリに存在するプレイリストファイルを削除します。
		 * 
		 * @param index
		 * 
		 */
		public function removePlayListByIndex(index:int):void{
			
			var url:String = libraryManager.playListDir.url + "/" + this.playListProvider[index];
			
			if(url.length > 0){
				Alert.show("プレイリストを削除してもよろしいですか？\n\n" + url.substring(url.lastIndexOf("/")+1), "確認", (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
					if(event.detail == Alert.YES){
						try{
							var file:File = new File(url);
							if(file.exists){
								file.moveToTrash();
								playListProvider.splice(index, 1);
								playListArray.splice(index, 1);
								downLoadedProvider.removeAll();
								logManager.addLog("ファイルを削除:" + decodeURIComponent(file.url));
							}else{
								playListProvider.splice(index, 1);
								playListArray.splice(index, 1);
								downLoadedProvider.removeAll();
							}
						}catch (error:IOError){
							Alert.show("削除できませんでした。\nファイルが開かれていない状態で再度実行してください。\n"+error, "エラー");
						}
						dispatchEvent(new Event(PlayListManager.PLAYLIST_UPDATE));
					}
				}, null, Alert.NO);
			}
		}
		
		/**
		 * playListProviderのインデックスに該当するプレイリストの配列を返します。
		 * 
		 * @param index
		 * @return 
		 * 
		 */
		public function getUrlListByIndex(index:int):Array{
			
			var urlArray:Array = new Array();
			for each(var video:NNDDVideo in playListArray[index]){
				urlArray.push(video.getDecodeUrl());
			}
			
			return urlArray;
		}
		
		/**
		 * playListProviderのインデックスに該当するプレイリストの動画の一覧を返します。
		 * 
		 * @param index
		 * @return 
		 * 
		 */
		public function getNNDDVideoListByIndex(index:int):Vector.<NNDDVideo>{
			
			var nnddVideoArray:Vector.<NNDDVideo> = new Vector.<NNDDVideo>();
			for each(var video:NNDDVideo in playListArray[index]){
				nnddVideoArray.splice(0, 0, video);
			}
			
			return nnddVideoArray;
		}
		
		/**
		 * playListProviderのインデックスに対応する動画の一覧を返します
		 * @param index
		 * @return 
		 * 
		 */
		public function getPlayListVideoListByIndex(index:int):Array{
			return playListArray[index];
		}
		
		/**
		 * playListProviderのインデックスに対応する動画名の一覧を返します
		 * @param index
		 * @return 
		 * 
		 */
		public function getPlayListVideoNameList(index:int):Array{
			var array:Array = new Array();
			
			for each(var video:NNDDVideo in playListArray[index]){
				array.push(video.getVideoNameWithVideoID());
			}
			
			return array;
		}
		
		/**
		 * プレイリストの名前を返します。この名前はプレイリストの純粋なファイル名です。
		 * @param index
		 * @return 
		 * 
		 */
		public function getPlayListNameByIndex(index:int):String{
			return playListProvider[index];
		}
		
		/**
		 * 指定された名前のプレイリストが存在するインデックスを返します。
		 * 
		 * @param name
		 * @return 指定された名前のプレイリストが存在する場合は、そのインデックス。存在しない場合は-1。
		 * 
		 */
		public function getPlayListIndexByName(name:String):int{
			for(var index:int=0; index<playListProvider.length; index++){
				if(String(playListProvider[index]) == name){
					return index;
				}
			}
			return -1;
		}
		
		/**
		 * 指定されたインデックスのプレイリストのフルパスを返します。
		 * @param pIndex
		 * @return 
		 * 
		 */
		private function getFullPath(pIndex:int):String{
			var file:File = new File(libraryManager.playListDir.url);
			file.url += "/" + playListProvider[pIndex];
			
			return file.url;
		}
		
		/**
		 * プレイリストを保存します。
		 * @param pIndex
		 * 
		 */
		public function savePlayListByIndex(pIndex:int):Boolean{
			
			for(var i:int=0; i<playListProvider.length; i++){
				if(i!=pIndex && playListProvider[i] == playListProvider[pIndex]){
					Alert.show("同名のプレイリストが存在するため保存できません。\nプレイリストの名前を変えてください。", "エラー");
					return false;
				}
			}
			
			try{
				var filePath:String = getFullPath(pIndex);
				fileIO.savePlayList(filePath, playListArray[pIndex]);
				fileIO.closeFileStream();
				logManager.addLog("プレイリストを保存:" + new File(getFullPath(pIndex)).nativePath);
				return true;
			}catch(error:Error){
				fileIO.closeFileStream();
				if(isPlayListSaveError){
					isPlayListSaveError = true;
					Alert.show("プレイリストの保存に失敗しました。\n" + error, "エラー", 4, null, function():void{isPlayListSaveError = false;});
					logManager.addLog("プレイリストの保存に失敗:" + new File(getFullPath(pIndex)).nativePath + "\n" + error);
				}
			}
			return false;
		}
		
		/**
		 * 指定されたファイル名のプレイリストを、指定された内容で上書きします。
		 *  
		 * @param fileName
		 * @param urlArray
		 * @return 
		 * 
		 */
		public function updatePlayList(fileName:String, urlArray:Array):Boolean{
			
			var index:int = getPlayListIndexByName(fileName);
			
			var videoArray:Array = new Array();
			
			for each(var url:String in urlArray){
				
				url = decodeURIComponent(url);
				
				var videoId:String = LibraryUtil.getVideoKey(url);
				var video:NNDDVideo = libraryManager.isExist(videoId);
				
				if(video == null){
					video = new NNDDVideo(url);
				}
				
				videoArray.push(video);
				
			}
			
			playListArray[index] = videoArray;
			
			try{
				var filePath:String = libraryManager.playListDir.url  + "/" + fileName;
				fileIO.savePlayList(filePath, urlArray);
				fileIO.closeFileStream();
				logManager.addLog("プレイリストを保存:" + new File(libraryManager.playListDir.url + "/" + fileName).nativePath);
				return true;
			}catch(error:Error){
				fileIO.closeFileStream();
				if(isPlayListSaveError){
					isPlayListSaveError = true;
					Alert.show("プレイリストの保存に失敗しました。\n" + error, "エラー", 4, null, function():void{isPlayListSaveError = false;});
					logManager.addLog("プレイリストの保存に失敗:" + libraryManager.playListDir.url + "/" + fileName + "\n" + error);
				}
			}
			return false;
		}
		
		
		/**
		 * すべてのプレイリストを保存します。
		 * 
		 */
		public function saveAllPlayList():Boolean{
			logManager.addLog("***すべてのプレイリストを保存***")
			var isSuccess:Boolean = true;
			for(var i:int=0; i<playListProvider.length; i++){
				if(!savePlayListByIndex(i)){
					isSuccess = false;
				}
			}
			logManager.addLog("***プレイリストを保存終了***")
			return isSuccess;
		}
		
	}
}