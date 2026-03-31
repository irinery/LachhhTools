package com.giveawaytool.io.youtube {
	import com.giveawaytool.ui.UI_Menu;
	import com.giveawaytool.ui.UI_PopUp;
	import com.lachhh.io.Callback;
	import com.lachhh.lachhhengine.VersionInfoDONTSTREAMTHIS;
	import com.lachhh.utils.Utils;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	/**
	 * @author Codex
	 */
	public class YoutubeConnection {
		static public var instance:YoutubeConnection;
		
		public var onConnect:Callback;
		public var onConnectError:Callback;
		public var connectErrorMsg:String = "";
		
		public var accessToken:String = "";
		public var refreshToken:String = "";
		public var authCode:String = "";
		public var isLoggedIn:Boolean = false;
		
		private var pendingOAuthState:String = "";
		private var channelTitle:String = "";
		
		public function YoutubeConnection() {
		}
		
		public function clear():void {
			accessToken = "";
			refreshToken = "";
			authCode = "";
			pendingOAuthState = "";
			channelTitle = "";
			isLoggedIn = false;
		}
		
		public function connect():void {
			connectStep1FetchAccessCode();
		}
		
		public function connectStep1FetchAccessCode():void {
			UI_PopUp.createOkOnly("A webpage will open, authorize YouTube and come back here!", null);
			UI_Menu.instance.logicNotification.logicSendToWidgetAuth.setModelForYoutube();
			Utils.navigateToURLAndRecord(getConnectURL());
		}
		
		public function getConnectURL():String {
			var redirect:String = VersionInfoDONTSTREAMTHIS.YOUTUBE_REDIRECT_URI;
			pendingOAuthState = getStateRandom();
			var scope:String = encodeURIComponent("https://www.googleapis.com/auth/youtube.readonly");
			var url:String = "https://accounts.google.com/o/oauth2/v2/auth";
			url += "?response_type=code";
			url += "&client_id=" + encodeURIComponent(VersionInfoDONTSTREAMTHIS.YOUTUBE_CLIENT_ID);
			url += "&redirect_uri=" + encodeURIComponent(redirect);
			url += "&scope=" + scope;
			url += "&access_type=offline";
			url += "&include_granted_scopes=true";
			url += "&prompt=consent";
			url += "&state=" + pendingOAuthState;
			return url;
		}
		
		public function setCodeFromWebSocket(code:String, state:String = null):void {
			if(!isValidOAuthCode(code)) {
				connectErrorMsg = "Invalid YouTube authorization code";
				onAuthCodeSendError();
				return;
			}
			if(!isValidStateAndConsume(state)) {
				connectErrorMsg = "Invalid YouTube authorization state";
				onAuthCodeSendError();
				return;
			}
			authCode = code;
			requestAccessToken();
		}
		
		private function requestAccessToken():void {
			var loader:URLLoader = new URLLoader();
			var request:URLRequest = new URLRequest("https://oauth2.googleapis.com/token");
			request.method = URLRequestMethod.POST;
			request.requestHeaders = [new URLRequestHeader("Content-Type", "application/x-www-form-urlencoded")];
			
			var body:URLVariables = new URLVariables();
			body.code = authCode;
			body.client_id = VersionInfoDONTSTREAMTHIS.YOUTUBE_CLIENT_ID;
			body.client_secret = VersionInfoDONTSTREAMTHIS.YOUTUBE_CLIENT_SECRET;
			body.redirect_uri = VersionInfoDONTSTREAMTHIS.YOUTUBE_REDIRECT_URI;
			body.grant_type = "authorization_code";
			request.data = body.toString();
			
			connectErrorMsg = "Problem fetching YouTube access token";
			loader.addEventListener(Event.COMPLETE, onTokenLoaded);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onAuthCodeSendError);
			loader.load(request);
		}
		
		private function onTokenLoaded(event:Event):void {
			var loader:URLLoader = URLLoader(event.target);
			var obj:Object = JSON.parse(loader.data);
			accessToken = safeString(obj["access_token"]);
			refreshToken = safeString(obj["refresh_token"]);
			
			if(!isValidAccessToken(accessToken)) {
				onAuthCodeSendError();
				return;
			}
			connectStep2FetchChannel();
		}
		
		public function connectStep2FetchChannel():void {
			var url:String = "https://www.googleapis.com/youtube/v3/channels?part=snippet&mine=true";
			var loader:URLLoader = new URLLoader();
			var request:URLRequest = new URLRequest(url);
			request.requestHeaders = [new URLRequestHeader("Authorization", "Bearer " + accessToken)];
			request.method = URLRequestMethod.GET;
			
			connectErrorMsg = "Problem fetching YouTube channel";
			loader.addEventListener(Event.COMPLETE, onFetchChannel);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onAuthCodeSendError);
			loader.load(request);
		}
		
		private function onFetchChannel(event:Event):void {
			var rawData:String = event.target.data;
			var obj:Object = JSON.parse(rawData);
			var items:Array = obj["items"] as Array;
			if(items != null && items.length > 0 && items[0] != null) {
				var snippet:Object = items[0]["snippet"];
				channelTitle = safeString(snippet["title"]);
			}
			authCode = "";
			isLoggedIn = true;
			if(onConnect) onConnect.call();
		}
		
		private function onAuthCodeSendError(event:Event = null):void {
			authCode = "";
			accessToken = "";
			isLoggedIn = false;
			pendingOAuthState = "";
			if(onConnectError) onConnectError.call();
		}
		
		public function getNameOfAccount():String {
			if(channelTitle == "") return "YouTube connected";
			return channelTitle;
		}
		
		private function safeString(value:Object):String {
			if(value == null) return "";
			return String(value);
		}
		
		private function isValidOAuthCode(code:String):Boolean {
			if(code == null) return false;
			if(code.length < 8) return false;
			if(code.length > 2048) return false;
			return true;
		}
		
		private function isValidAccessToken(token:String):Boolean {
			if(token == null) return false;
			if(token.length < 8) return false;
			if(token.length > 4096) return false;
			return true;
		}
		
		private function isValidStateAndConsume(state:String):Boolean {
			if(pendingOAuthState == null || pendingOAuthState == "") return false;
			var expected:String = pendingOAuthState;
			pendingOAuthState = "";
			if(state == null) return false;
			return (state == expected);
		}
		
		private function getStateRandom():String {
			return getDigits(8) + "-" + getDigits(8) + "-" + getDigits(8) + "-" + getDigits(8);
		}
		
		private function getDigits(n:int):String {
			var result:String = "";
			for (var i : int = 0; i < n; i++) {
				result += getDigit();
			}
			return result;
		}
		
		private function getDigit():String {
			var i:int = Math.random() * 10;
			return i.toString();
		}
	}
}
