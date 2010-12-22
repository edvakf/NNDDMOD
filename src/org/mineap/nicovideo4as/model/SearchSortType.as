package org.mineap.nicovideo4as.model
{
	/**
	 * SearchSortType.as<br>
	 * SearchSortTypeクラスは、検索結果のソート順に関する定数を保持するクラスです。<br>
	 * <br>
	 * Copyright (c) 2009 MAP - MineApplicationProject. All Rights Reserved.<br>
	 *  
	 * @author shiraminekeisuke
	 * 
	 */
	public class SearchSortType
	{
		
		/**
		 * 投稿日時
		 */
		public static const CONTRIBUTE:int = 0;
		/**
		 * 再生数
		 */
		public static const PLAY_COUNT:int = 1;
		/**
		 * コメント数
		 */
		public static const COMMENT_COUNT:int = 2;
		/**
		 * コメント日時
		 */
		public static const COMMENT_TIME:int = 3;
		/**
		 * マイリスト
		 */
		public static const MYLIST_COUNT:int = 4;
		/**
		 * 再生時間
		 */
		public static const PLAY_TIME:int = 5;
		
		
		/**
		 * 降順 (descending) 新しい、多い、長い
		 */
		public static const ORDER_D:int = 0;
		/**
		 * 昇順 (ascending) 古い、少ない、短い
		 */
		public static const ORDER_A:int = 1;
		
		/*------- ↓ ココから検索実行時に使う文字 ----------*/
		
		/**
		 * 
		 */
		public static const CONTRIBUTE_STRING:String = "f";
		/**
		 * 
		 */
		public static const PLAY_COUNT_STRING:String = "v";
		/**
		 * 
		 */
		public static const COMMENT_COUNT_STRING:String = "r";
		/**
		 * 
		 */
		public static const COMMENT_TIME_STRING:String = "n";
		/**
		 * 
		 */
		public static const MYLIST_COUNT_STRING:String = "m";
		/**
		 * 
		 */
		public static const PLAY_TIME_STRING:String = "l";
		
		/**
		 * 
		 */
		public static const ORDER_D_STRING:String = "d";
		/**
		 * 
		 */
		public static const ORDER_A_STRING:String = "a"
		
		/**
		 * 指定されたintのソート順序を文字列に変換します
		 * 
		 * @param type
		 * @return 
		 * 
		 */
		public static function convertSortTypeNumToString(type:int):String{
			
			var typeStr:String = CONTRIBUTE_STRING;
			
			switch(type){
				case COMMENT_TIME:
					typeStr = COMMENT_TIME_STRING;
					break;
				case PLAY_COUNT:
					typeStr = PLAY_COUNT_STRING;
					break;
				case COMMENT_COUNT:
					typeStr = COMMENT_COUNT_STRING;
					break;
				case MYLIST_COUNT:
					typeStr = MYLIST_COUNT_STRING;
					break;
				case CONTRIBUTE:
					typeStr = CONTRIBUTE_STRING;
					break;
				case PLAY_TIME:
					typeStr = PLAY_COUNT_STRING;
					break;
			}
			
			return typeStr;
		}
		
		/**
		 * 指定されたオーダーのint表現に対応する文字列表現を返します
		 *  
		 * @param order
		 * @return 
		 * 
		 */
		public static function convertSortOrderTypeNumToString(order:int):String{
			if(order == ORDER_A){
				return ORDER_A_STRING;
			}
			return ORDER_D_STRING;
		}
		
		/**
		 * 
		 */
		public var sort:int = 0;
		
		/**
		 * 
		 */
		public var order:int = 0;
		
		/**
		 * 
		 * @param sort
		 * @param order
		 * 
		 */
		public function SearchSortType(sort:int, order:int)
		{
			this.sort = sort;
			this.order = order
		}
	}
}