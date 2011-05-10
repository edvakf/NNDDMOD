package org.mineap.nicovideo4as.model
{
	/**
	 * 動画のタイプを表す列挙型です。
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public final class VideoType
	{
		
		public static const VIDEO_TYPE_SWF:VideoType = new VideoType("VIDEO_TYPE_SWF");
		public static const VIDEO_TYPE_FLV:VideoType = new VideoType("VIDEO_TYPE_FLV");
		public static const VIDEO_TYPE_MP4:VideoType = new VideoType("VIDEO_TYPE_MP4");
		
		private var _type:String;
		
		public function VideoType(type:String){
			this._type = type;
		}
		
		public function toString():String{
			return this._type;
		}
		
	}
}