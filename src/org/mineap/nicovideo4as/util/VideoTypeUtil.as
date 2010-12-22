package org.mineap.nicovideo4as.util
{
	public class VideoTypeUtil
	{
		
		/**
		 * 動画IDを探すためのパターン文字列です。
		 */
		public static const VIDEO_ID_SEARCH_PATTERN_STRING:String = "(((sm)|(nm)|(am)|(fz)|(ut)|(ax)|(ca)|(cd)|(cw)|(fx)|(ig)|(na)|(nl)|(om)|(sd)|(sk)|(yk)|(yo)|(za)|(zb)|(zc)|(zd)|(ze)|(so)|(\\d\\d))\\d+)";
		
		/**
		 * 数字のみの動画ID以外の動画IDを探すためのパターン文字列です。
		 */
		public static const VIDEO_ID_WITHOUT_NUMONLY_SEARCH_PATTERN_STRING:String = "(((sm)|(nm)|(am)|(fz)|(ut)|(ax)|(ca)|(cd)|(cw)|(fx)|(ig)|(na)|(nl)|(om)|(sd)|(sk)|(yk)|(yo)|(za)|(zb)|(zc)|(zd)|(ze)|(so))\\d+)";
		
		
		public function VideoTypeUtil()
		{
		}
	}
}