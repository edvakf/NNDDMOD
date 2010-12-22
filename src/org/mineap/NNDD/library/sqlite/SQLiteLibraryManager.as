package org.mineap.NNDD.library.sqlite
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	
	import org.mineap.NNDD.LogManager;
	import org.mineap.NNDD.library.ILibraryManager;
	import org.mineap.NNDD.model.NNDDVideo;
	import org.mineap.NNDD.tag.TagManager;
	
	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class SQLiteLibraryManager extends EventDispatcher implements ILibraryManager
	{
		
		private static const sqliteLibraryManager:SQLiteLibraryManager = new SQLiteLibraryManager();
		
		private var _logger:LogManager;
		private var _tagManager:TagManager;
		private var _dbAccessHelper:DbAccessHelper;
		private var _libraryDir:File;
		
		public static const LIBRARY_FILE_NAME = "library.db";
		
		public static function get instance():SQLiteLibraryManager{
			return sqliteLibraryManager;
		}
		
		/**
		 * 
		 * @param target
		 * 
		 */
		public function SQLiteLibraryManager(target:IEventDispatcher=null)
		{
			super(target);
			if(sqliteLibraryManager != null){
				throw new ArgumentError("SQLiteLibraryManagerはインスタンス化できません。");
			}
			
			this._logger = LogManager.instance;
			this._tagManager = TagManager.instance;
			this._libraryDir = this.defaultLibraryDir;
			this._dbAccessHelper = DbAccessHelper.instance;
		}
		
		public function get libraryFile():File
		{
			return new File(this.systemFileDir.url + "/" + SQLiteLibraryManager.LIBRARY_FILE_NAME);
		}
		
		public function get libraryDir():File
		{
			return new File(this._libraryDir.url);;
		}
		
		public function get defaultLibraryDir():File
		{
			return new File(File.documentsDirectory.resolvePath("/NNDD/").url);
		}
		
		public function get systemFileDir():File
		{
			return new File(libraryDir.resolvePath("/system/").url);
		}
		
		public function get tempDir():File
		{
			return new File(systemFileDir.resolvePath("/temp/").url);
		}
		
		public function get playListDir():File
		{
			return new File(systemFileDir.resolvePath("/playList/").url);
		}
		
		/**
		 * ライブラリディレクトリを変更します
		 * @param libraryDir
		 * @param isSave
		 * @return 
		 * 
		 */
		public function changeLibraryDir(libraryDir:File, isSave:Boolean=true):Boolean
		{
			if(libraryDir.isDirectory){
				this._libraryDir = libraryDir;
				if(isSave){
					this.saveLibrary();
				}
				return true;
			}else{
				return false;
			}
		}
		
		/**
		 * ライブラリを保存します。<br />
		 * SQLiteLibraryManagerの実装では、このメソッドを実行しても何もしません。
		 * 常にtrueが返されます。
		 * @param saveDir
		 * @return 
		 * 
		 */
		public function saveLibrary(saveDir:File=null):Boolean
		{
			// なにもしない
			return true;
		}
		
		/**
		 * ライブラリをロードします。<br />
		 * SQLiteLibraryManagerの実装では、このメソッドはDBへのコネクションの確立を行います。
		 * @param libraryDir
		 * @return 
		 * 
		 */
		public function loadLibrary(libraryDir:File=null):Boolean
		{
			return false;
		}
		
		private function connect(libraryDir:File):Boolean{
			
		}
		
		public function renewLibrary(libraryDir:File, renewSubDir:Boolean):void
		{
			//TODO: implement function
		}
		
		public function remove(videoId:String, isSaveLibrary:Boolean):NNDDVideo
		{
			//TODO: implement function
			return null;
		}
		
		public function update(video:NNDDVideo, isSaveLibrary:Boolean):Boolean
		{
			//TODO: implement function
			return false;
		}
		
		public function add(video:NNDDVideo, isSaveLibrary:Boolean, isOverWrite:Boolean=false):Boolean
		{
			//TODO: implement function
			return false;
		}
		
		public function changeDirName(oldDir:File, newDir:File):void
		{
			//TODO: implement function
		}
		
		public function isExistByVideoId(videoId:String):NNDDVideo
		{
			//TODO: implement function
			return null;
		}
		
		public function isExist(key:String):NNDDVideo
		{
			//TODO: implement function
			return null;
		}
		
		public function collectTag(dir:File=null):Array
		{
			//TODO: implement function
			return null;
		}
		
		public function collectTagByVideoName(nameArray:Array):Array
		{
			//TODO: implement function
			return null;
		}
		
		public function searchTagAndShow(word:String):Array
		{
			//TODO: implement function
			return null;
		}
		
		public function getNNDDVideoArray(saveDir:File, isShowAll:Boolean):Vector.<NNDDVideo>
		{
			//TODO: implement function
			return null;
		}
	}
}