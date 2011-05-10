package org.mineap.nicovideo4as.model
{
	public class RelationResultItem
	{
		
		/**
		 * 動画のURL
		 */
		public var url:String = null;
		
		/**
		 * サムネイル画像へのURL
		 */
		public var thumbnail:String = null;
		
		/**
		 * 動画のタイトル
		 */
		public var title:String = null;
		
		/**
		 * 再生回数
		 */
		public var view:int = 0;
		
		/**
		 * コメント総数
		 */
		public var comment:int = 0;
		
		/**
		 * マイリスト登録数
		 */
		public var mylist:int = 0;
		
		/**
		 * 動画の長さ
		 */
		public var length:int = 0;
		
		/**
		 * 投稿日時
		 */
		public var time:Number = 0;
		
		/**
		 * 
		 * @param url
		 * @param thumbnail
		 * @param title
		 * @param view
		 * @param comment
		 * @param mylist
		 * @param length
		 * @param time
		 * 
		 */
		public function RelationResultItem(url:String, 
										   thumbnail:String, 
										   title:String, 
										   view:int, 
										   comment:int, 
										   mylist:int, 
										   length:int, 
										   time:Number)
		{
			this.url = url;
			this.thumbnail = thumbnail;
			this.title = title;
			this.view = view;
			this.comment = comment;
			this.mylist = mylist;
			this.length = length;
			this.time = time;
		}
	}
}