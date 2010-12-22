package org.mineap.nicovideo4as.analyzer
{
	import org.mineap.nicovideo4as.model.NgUp;
	import org.mineap.nicovideo4as.util.HtmlUtil;

	/**
	 * getFlvの応答を解析するためのクラスです。 
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class GetFlvResultAnalyzer
	{
		
		/**
		 * スレッドIDを抽出するための正規表現です
		 */
		public static const THREAD_ID_PATTERN:RegExp = new RegExp("thread_id=([^&]*)&");
		
		/**
		 * 長さを抽出するための正規表現です。
		 */
		public static const L_PATTERN:RegExp = new RegExp("&l=([^&]*)&");
		
		/**
		 * 動画へのURLを抽出するための正規表現です
		 */
		public static const VIDEO_URL_PATTERN:RegExp = new RegExp("&url=([^&]*)&");
		
		/**
		 * 当該動画のSmileVideoへのリンクを抽出するための正規表現です
		 */
		public static const SMILE_VIDEO_LINK_PATTERN:RegExp = new RegExp("&link=([^&]*)&");
		
		/**
		 * メッセージサーバのURLを抽出するための正規表現です。
		 */
		public static const MESSAGE_SERVER_URL_PATTERN:RegExp = new RegExp("&ms=([^&]*)&");
		
		/**
		 * ユーザーIDを抽出するための正規表現です。
		 */
		public static const USER_ID_PATTERN:RegExp = new RegExp("&user_id=([^&]*)&");
		
		/**
		 * プレミアム会員かどうかを抽出するための正規表現です。
		 */
		public static const IS_PREMIUM_PATTERN:RegExp = new RegExp("&is_premium=([^&]*)&");
		
		/**
		 * ニックネームを抽出するための正規表現です。
		 */
		public static const NICK_NAME_PATTERN:RegExp = new RegExp("&nickname=([^&]*)&");
		
		/**
		 * 時刻を抽出するための正規表現です。
		 */
		public static const TIME_PATTERN:RegExp = new RegExp("&time=([^&]*)&");
		
		/**
		 * 
		 */
		public static const DONE_PATTERN:RegExp = new RegExp("&done=([^&]*)");
		
		/**
		 * needs_key
		 */
		public static const NEEDS_KEY_PATTERN:RegExp = new RegExp("&needs_key=([^&]*)");
		
		/**
		 * optional_thread_id
		 */
		public static const OPTIONAL_THREAD_ID_PATTERN:RegExp = new RegExp("&optional_thread_id=([^&]*)");
		
		/**
		 * feedrev
		 */
		public static const FEED_REV_PATTERN:RegExp = new RegExp("&feedrev=([^&]*)");
		
		/**
		 * ng_up
		 */
		public static const NG_UP_PATTERN:RegExp = new RegExp("&ng_up=([^&]*)");
		
		/**
		 * エコノミーモード(低画質モード)の検出
		 */
		public static const LOW_MODE:String = "low";
		
		private var _threadId:String = null;
		
		private var _l:Number = 0;
		
		private var _url:String = null;
		
		private var _link:String = null;
		
		private var _ms:String = null;
		
		private var _userId:String = null;
		
		private var _isPremium:Boolean = false;
		
		private var _nickName:String = null;
		
		private var _time:Number = 0;
		
		private var _done:Boolean = false;
		
		private var _needs_key:int = 0;
		
		private var _optional_thread_id:String = null;
		
		private var _feedrev:String = null;
		
		private var _ng_ups:Vector.<NgUp> = new Vector.<NgUp>();
		
		private var _economyMode:Boolean = false;
		
		private var _result:String = null;
		
		/**
		 * コンストラクタ
		 * 
		 */
		public function GetFlvResultAnalyzer()
		{
			/* nothing */
		}

		/**
		 * 渡されたString表現をgetflvの応答として解析します。
		 * 
		 * @param result getflvの応答
		 * @return 解析に成功した場合はtrue、失敗した場合はfalse。
		 * 
		 */
		public function analyze(result:String):Boolean{
			
			try{
				
				if(result.indexOf("%") != -1){
					// "%"が含まれていればデコード
					result = decodeURIComponent(unescape(result));
				}
				if(result.indexOf("\\u") != -1){
					result = HtmlUtil.convertCharacterCodeToCharacter(result);
				}
				
				trace(result);
				
				this._result = result;
				
				/*
				thread_id=1173206704
				&l=111
				&url=http://smile-pcm31.nicovideo.jp/smile?v=8702.9279
				&link=http://www.smilevideo.jp/view/8702/573999
				&ms=http://msg.nicovideo.jp/7/api/
				&user_id=*****
				&is_premium=1
				&nickname=*****
				&time=1281958264
				&done=true
				&needs_key=1	//公式の時のみ？
				&optional_thread_id=1254473671	//公式の時のみ？
				&feedrev=b852b	//公式の時のみというわけではない？
				&ng_up=*はー=はあああああああああああああああああああああああああああああ
				&*どー=どおおおおおおおおおおおおおおおおおおおおおおおおおおおおお
				&*らっちー=らっち～☆ミ　らっち～☆ミ
				&*つー=つううううううううううううううううううううううううううううううううううううううううう
				&hms=hiroba04.nicovideo.jp
				&hmsp=2527
				&hmst=1000000063
				&hmstk=1281958324.YAVXxEJhyWLGc5RvDqju57Gtwec
				&rpu={"count":924888,
					"users":["\u30d2\u30c0\u30de\u30eaX",
						"hifumy1",
						"\u30d7\u30b8\u30e7\u30eb",
						"ryu",
						"\uff26\uff41\uff4e\uff54\uff41\uff53\uff49\uff45",
						"\u66b4\u8d70",
						"shutter-speeds72",
						"\u305f\u308d",
						"\u30ea\u30b9\u30c8",
						"\u3086\u3048\u3053",
						"Cocoon",
						"\u59d0\u5fa1",
						"\uff08\u00b0\u2200\uff9f\uff09",
						"\u30ed\u30c3\u30af",
						"\u30ca\u30eb\u30ab\u30ca\u69d8",
						"Ash",
						"\u307e\u308a\u3079\u3047",
						"\u60e3\u6d41\u30a2\u30b9\u30ab",
						"\u3057\u3087\u3046\u305f\u308b",
						"ginzuisyoufox"],
						"extra":13}
				*/
				
				var array:Array = THREAD_ID_PATTERN.exec(result);
				if(array != null && array.length > 1){
					this._threadId = array[array.length-1];
				}
				
				array = L_PATTERN.exec(result);
				if(array != null && array.length > 1){
					this._l = Number(array[array.length-1]);
				}
				
				array = VIDEO_URL_PATTERN.exec(result);
				if(array != null && array.length > 1){
					this._url = array[array.length-1];
					if(this._url.indexOf(LOW_MODE) != -1){
						this._economyMode = true;
					}
				}
				
				array = SMILE_VIDEO_LINK_PATTERN.exec(result);
				if(array != null && array.length > 1){
					this._link = array[array.length-1];
				}
				
				array = MESSAGE_SERVER_URL_PATTERN.exec(result);
				if(array != null && array.length > 1){
					this._ms = array[array.length-1];
				}
				
				array = USER_ID_PATTERN.exec(result);
				if(array != null && array.length > 1){
					this._userId = array[array.length-1];
				}
				
				array = IS_PREMIUM_PATTERN.exec(result);
				if(array != null && array.length > 1){
					this._isPremium = Boolean(array[array.length-1]);
				}
				
				array = NICK_NAME_PATTERN.exec(result);
				if(array != null && array.length > 1){
					this._nickName = array[array.length-1];
				}
				
				array = TIME_PATTERN.exec(result);
				if(array != null && array.length > 1){
					this._time = Number(array[array.length-1]);
				}
				
				array = DONE_PATTERN.exec(result);
				if(array != null && array.length > 1){
					this._done = Boolean(array[array.length-1]);
				}
				
				array = NEEDS_KEY_PATTERN.exec(result);
				if(array != null && array.length > 1){
					this._needs_key = int(array[array.length-1]);
				}
				
				array = OPTIONAL_THREAD_ID_PATTERN.exec(result);
				if(array != null && array.length > 1){
					this._optional_thread_id = array[array.length-1];
				}
				
				array = FEED_REV_PATTERN.exec(result);
				if(array != null && array.length > 1){
					this._feedrev = array[array.length-1];
				}
				
				array = NG_UP_PATTERN.exec(result);
				if(array != null && array.length > 1){
					
					var pattern:RegExp = new RegExp("\\*([^&]*)", "g");
					pattern.lastIndex = array.index;
					
					while(true){
						
						array = pattern.exec(result);
						
						if(array == null || array.length <= 1){
							break;
						}
						
						var str:String = array[array.length-1];
						var index:int = str.indexOf("=");
						
						var ngword:String = str.substring(0, index);
						var changeValue:String = str.substring(index+1);
						
						this._ng_ups.splice(this._ng_ups.length,0,new NgUp(ngword, changeValue));
						
					}
					
				}
				
				return true;
				
			}catch(error:Error){
				trace(error.getStackTrace());
			}
			return false;
		}
		
		public function get done():Boolean
		{
			return _done;
		}

		public function get time():Number
		{
			return _time;
		}

		public function get nickName():String
		{
			return _nickName;
		}

		public function get isPremium():Boolean
		{
			return _isPremium;
		}

		public function get userId():String
		{
			return _userId;
		}

		public function get ms():String
		{
			return _ms;
		}

		public function get link():String
		{
			return _link;
		}

		public function get url():String
		{
			return _url;
		}

		public function get l():Number
		{
			return _l;
		}

		public function get threadId():String
		{
			return _threadId;
		}
		
		public function get result():String
		{
			return _result;
		}

		public function get needs_key():int
		{
			return _needs_key;
		}

		public function get optional_thread_id():String
		{
			return _optional_thread_id;
		}

		public function get feedrev():String
		{
			return _feedrev;
		}
		
		public function get ng_ups():Vector.<NgUp>
		{
			return _ng_ups;
		}
		
		public function get economyMode():Boolean
		{
			return _economyMode;
		}


	}
}