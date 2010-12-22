package org.mineap.nicovideo4as.model
{
	/**
	 * 検索によって取得された、１動画の情報を表現します
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class SearchResultItem
	{
		
		/**
		 * タイトル
		 */
		public var title:String;
		
		/**
		 * 投稿日
		 */
		public var contribute:String;
		
		/**
		 * 動画のurl
		 */
		public var url:String;
		
		/**
		 * 再生回数
		 */
		public var playCount:int;
		
		/**
		 * マイリスト数
		 */
		public var myListCount:int;
		
		/**
		 * コメント数
		 */
		public var commentCount:int;
		
		/**
		 * 動画の長さ
		 */
		public var videoLength:String;
		
		/**
		 * 
		 * @param title 動画のタイトル
		 * @param url 動画のurl
		 * @param contribute 投稿日時
		 * @param playCount 再生回数
		 * @param myListCount マイリスト数
		 * @param commentCount コメント数
		 * @param videoLength 動画の長さ
		 * 
		 */
		public function SearchResultItem(title:String, url:String, contribute:String = null, playCount:int = 0, myListCount:int = 0, commentCount:int = 0, videoLength:String = null)
		{
			this.title = title;
			this.url = url;
			this.contribute = contribute;
			this.playCount = playCount;
			this.myListCount = myListCount;
			this.commentCount = commentCount;
			this.videoLength = videoLength;
		}
	}
}