package org.mineap.NNDD.library.sqlite
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.filesystem.File;
	
	import org.mineap.NNDD.model.NNDDVideo;

	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class DbAccessHelper
	{
		private static const dbAccessHelper:DbAccessHelper = new DbAccessHelper();
		
		private static const CREATE_TABLE_NNDDVIDEO:String = "CREATE TABLE IF NOT EXISTS nnddvideo (" +
			" id INTEGER PRIMARY KEY," +
			" key TEXT," +
			" uri TEXT," +
			" videoName TEXT," +
			" isEconomy INTEGER," +
			" modificationDate INTEGER," +
			" creationDate INTEGER," +
			" thumbUrl TEXT," +
			" playCount REAL," +
			" time REAL," +
			" lastPlayDate INTEGER," +
			" yetReading INTEGER," +
			" UNIQUE(key))";
		
		private static const CREATE_TABLE_TAG:String = "CREATE TABLE IF NOT EXISTS tagstring (" +
			" id INTEGER PRIMARY KEY," +
			" tag TEXT," +
			" UNIQUE(tag))";
		
		private static const CREATE_TABLE_NNDDVIDEO_TAG = "CREATE TABLE IF NOT EXISTS nnddvideo_tag (" +
			" id INTEGER PRIMARY KEY," +
			" nnddvideo_id INTEGER," +
			" tag_id INTEGER," +
			" UNIQUE(nnddvideo_id, tag_id));"
		
		private var _connection:SQLConnection;
		private var _stmt:SQLStatement;
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public static function get instance():DbAccessHelper{
			return dbAccessHelper;
		}
		
		/**
		 * 
		 * 
		 */
		public function DbAccessHelper()
		{
			if(dbAccessHelper != null){
				throw new ArgumentError("DbAccessHelperはインスタンス化できません。");
			}
		}
		
		/**
		 * 指定されたデータベースへのコネクションを確立します。(同期モード)
		 * @param dbFile
		 * 
		 */
		public function connect(dbFile:File):Boolean{
			
			try{
			
				var firstTime:Boolean = false;
				if(!dbFile.exists){
					firstTime = true;
				}
				
				this._connection = new SQLConnection();
				this._connection.open(dbFile);
				
				if(firstTime){
					createTable();
				}
				
				return true;
			
			}catch(error:Error){
				return false;
			}
			
		}
		
		/**
		 * テーブルを作成します
		 * 
		 */
		private function createTable():void{
			this._stmt = new SQLStatement();
			this._stmt.sqlConnection = this._connection;
			this._stmt.text = DbAccessHelper.CREATE_TABLE_NNDDVIDEO;
			this._stmt.text += DbAccessHelper.CREATE_TABLE_TAG;
			this._stmt.text += DbAccessHelper.CREATE_TABLE_NNDDVIDEO_TAG;
			
			this._stmt.execute();
		}
		
		/**
		 * 
		 * @param nnddVideo
		 * @return 
		 * 
		 */
		public function insertNNDDVideo(nnddVideo:NNDDVideo):Boolean{
			return false;
		}
		
		/**
		 * 
		 * @param nnddVideo
		 * @return 
		 * 
		 */
		public function updateNNDDVideo(nnddVideo:NNDDVideo):Boolean{
			return false;
		}
		
		/**
		 * 
		 * @param id
		 * @return 
		 * 
		 */
		public function deleteNNDDVideoById(id:int):Boolean{
			return false;
		}
		
		/**
		 * 
		 * @param key
		 * @return 
		 * 
		 */
		public function deleteNNDDVideoByKey(key:String):Boolean{
			return false;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function selectAllNNDDVideo():Vector.<NNDDVideo>{
			return null;
		}
		
		/**
		 * 
		 * @param id
		 * @return 
		 * 
		 */
		public function selectNNDDVideoById(id:int):NNDDVideo{
			return null;
		}
		
		/**
		 * 
		 * @param key
		 * @return 
		 * 
		 */
		public function selectNNDDVideoByKey(key:String):NNDDVideo{
			return null;
		}
	}
}