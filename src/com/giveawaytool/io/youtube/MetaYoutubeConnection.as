package com.giveawaytool.io.youtube {
	import flash.utils.Dictionary;
	/**
	 * @author Codex
	 */
	public class MetaYoutubeConnection {
		public var lastAccessToken:String = "";
		public var lastRefreshToken:String = "";
		public var lastAuthCode:String = "";
		public var lastChannelTitle:String = "";
		
		private var saveData:Dictionary = new Dictionary();
		
		public function MetaYoutubeConnection() {
		}
		
		public function clear():void {
			lastAccessToken = "";
			lastRefreshToken = "";
			lastAuthCode = "";
			lastChannelTitle = "";
		}
		
		public function encode():Dictionary {
			saveData["lastAccessToken"] = lastAccessToken;
			saveData["lastRefreshToken"] = lastRefreshToken;
			saveData["lastAuthCode"] = lastAuthCode;
			saveData["lastChannelTitle"] = lastChannelTitle;
			return saveData;
		}
		
		public function decode(loadData:Dictionary):void {
			if(loadData == null) return;
			lastAccessToken = loadData["lastAccessToken"];
			lastRefreshToken = loadData["lastRefreshToken"];
			lastAuthCode = loadData["lastAuthCode"];
			lastChannelTitle = loadData["lastChannelTitle"];
			
			if(lastAccessToken == null) lastAccessToken = "";
			if(lastRefreshToken == null) lastRefreshToken = "";
			if(lastAuthCode == null) lastAuthCode = "";
			if(lastChannelTitle == null) lastChannelTitle = "";
		}
	}
}
