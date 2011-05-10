package org.mineap.nicovideo4as.analyzer
{
	/**
	 * マイリストグループ取得APIの応答を解析するクラスです。
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class MyListGroupAnalyzer
	{
		
		public static const MY_LIST_GROUP:String = "mylistgroup";
		
		public static const OK:String = "ok";
		
		public static const ERROR:String = "error";
		
		private var _idPattern:RegExp = new RegExp("\"id\":\"([\\d]+)\"", "ig");
		
		private var _statusPattern:RegExp = new RegExp("\"status\":\"([^\"]*)\"", "ig");
		
		private var _result:String = null;
		
		private var _myListIds:Vector.<String> = new Vector.<String>();
		
		/**
		 * 
		 * 
		 */
		public function MyListGroupAnalyzer()
		{
		}
		
		/**
		 * 渡されたMyListGroup取得APIの実行結果を解析します。
		 * 
		 * @param data
		 * 
		 */
		public function analyzer(data:String):void{
			
			if (data == null) {
				this._result = ERROR;
				return;
			}
			
			var result:Array = this._statusPattern.exec(data);
			
			if (result != null && result.length > 1 ) {
				var status:String = result[1];
				if (status == OK) {
					result = data.match(this._idPattern);
					if(result != null){
						for each(var str:String in result){
							this._idPattern.lastIndex = 0;
							var obj:Array = this._idPattern.exec(str);
							if(obj != null && obj.length > 1){
								var id:String = obj[1];
								this._myListIds.splice(0, 0, id);
							}
						}
						this._result = OK;
					}else{
						this._result = ERROR;
					}
				} else {
					this._result = ERROR;
				}
			}
			
			return;
			
		}
		
		/**
		 * MyListGroupを解析した結果得られたマイリストIDの一覧
		 * 
		 * @return 
		 * 
		 */
		public function get myListIds():Vector.<String>{
			return this._myListIds;
		}
		
		/**
		 * MyListGroup取得APIへのアクセス結果
		 * 
		 * @return 
		 * 
		 */
		public function get result():String{
			return this._result;
		}
		
	}
}