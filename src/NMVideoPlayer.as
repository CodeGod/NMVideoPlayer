package
{
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.navigateToURL;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.ui.ContextMenu;
	
	import utils.CookieUtil;
	import utils.NMUserEvents;
	import utils.URLEncoding;
	
	[SWF (backgroundColor="0x000000", width="600", height="350", frameRate="40")]
	
	public class NMVideoPlayer extends Sprite
	{
		
		private var jsonLoader:URLLoader;
		private var jsonRequest:URLRequest;
		private var jsonUrl:String;
		private var paramArr:Array;
		
		private var userEvents:NMUserEvents = new NMUserEvents();
		private var cMenu:ContextMenu;
		private var cMenuClass:NMContextMenu; // класс контекстного меню 
		private var embedLoader:URLLoader;
		private var embedData:String;
		private var flashVars:String;
		private var embedText:String; // html-код для вставки загружаемый из файла
		public static var paramVideoEmbedArr:Array; // массив параметров для замены в html-коде для вставки
		public static var paramVideoEmbed:String; // строка параметров для замены в html-коде для вставки разделённая | и ||
		public static var paramVideoLink:String; // адресс страницы с новостью
		public static var paramVideoPath:String; // путь к видеоролику
		public static var paramVideoShare:String; // параметры шаринга соцсетей
		public static var paramImagePath:String; // путь к картинке
		public static var paramAdv:int; // включение рекламы, 1 - есть, 0 - нет
		public static var paramAdvType:int; // тип рекламы, 1 - наша, 0 - сторонняя
		public static var paramVideoPanel:String; // может принимать значения "SHOW" или "HIDE", всегда показывать панель или автоматически скрывать соответственно
		public static var referer:String; // возвращает ссылку на страницу со встроенным плеером
		public static var paramEmbed:Boolean = false;
		public static var paramVideoID:String;
		public static var related:Array;
		private var initVideo:Boolean = false;
		
		private var constructor:NMPlayerObjects;
		private var objectLoaderInfo:Object;
		
		public static const appVersion:String = "4.3.18";
		public static const DEBUG_MODE:Boolean = true;
		
		public function NMVideoPlayer()
		{
			
			this.addEventListener(Event.ADDED_TO_STAGE, initMain);
			
		}
		
		private function initMain(event:Event):void
		{
			
			this.removeEventListener(Event.ADDED_TO_STAGE, initMain);
			
			stage.showDefaultContextMenu = false;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			paramArr = new Array();
			
			NMVideoConstructor.videoPlayer = this;
			NMPlayerObjects.videoPlayer = this;
			NMContextMenu.videoPlayer = this;
			
			Security.loadPolicyFile("http://lifenews.ru/crossdomain.xml");
			Security.allowDomain("vk.com");
			Security.allowDomain("lifenews.ru");
			Security.allowDomain("front.lifenews.ru");
			
			if (DEBUG_MODE) {
				trace("\n--------- DUBUG MODE ---------\n");
			}
			
			loadPlayerData();
			
		}
		
		private function loadPlayerData():void
		{
			
			this.loaderInfo.addEventListener(Event.COMPLETE, loadParameters);
			this.loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadingIOError);
			
		}
		
		private function loadingIOError(event:IOErrorEvent):void
		{
			
			this.loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadingIOError);
			
			errorLoadData("[ERROR] IOError in LoaderInfo");
			
		}
		
		private function loadParameters(event:Event):void
		{
			
			/*
			var loaderSWF:Loader = new Loader();
			var req:URLRequest = new URLRequest("assets.swf");
			loaderSWF.contentLoaderInfo.addEventListener(Event.COMPLETE, compl);
			loaderSWF.load(req);
			
			function compl(event:Event):void
			{
				trace("SWFContent: " + event.currentTarget.content.ButtonPlay);
				
			}
			*/
			this.loaderInfo.removeEventListener(Event.COMPLETE, loadParameters);
			
			try {
				
				referer = this.loaderInfo.parameters.ref ? this.loaderInfo.parameters.ref : ExternalInterface.call( "function() { return window.document.referrer }" );
				
			} catch (err:Error) {
				
				referer = "error";
				
			}
			
			if (DEBUG_MODE) {
				trace("REFERRER: " + referer);
			}
			
			/*
			paramVideoEmbed = "__VIDEO_URL__|VIDEO||__IMG_PATH__|IMAGE||__VIDEO_TITLE__|TITLE";
			paramVideoLink = "http://front.lifenews.ru/static/BannersTest?recache";
			paramVideoPath = "http://ncontent.life.ru/media/2/videos/2010/09/1440/video.mp4";
			paramImagePath = "video_image.jpg";
			paramAdv = 1;
			paramAdvType = 1;
			paramVideoPanel = "HIDE";
			*/
			
			paramVideoEmbed = this.loaderInfo.parameters.videoEmbed;
			paramVideoLink = this.loaderInfo.parameters.videoLink;
			paramVideoPath = this.loaderInfo.parameters.videoPath;
			paramImagePath = this.loaderInfo.parameters.imagePath;
			paramAdv = this.loaderInfo.parameters.adv;
			paramAdvType = this.loaderInfo.parameters.advType;
			paramVideoPanel = this.loaderInfo.parameters.videoPanel;
			paramVideoShare = this.loaderInfo.parameters.videoShare;
			paramVideoID = this.loaderInfo.parameters.videoID;
			
			
			//jsonUrl = "http://front.lifenews.ru/news/96441?v=wioc5y&f";
			jsonUrl = this.loaderInfo.parameters["varsJSON"];
			if (jsonUrl && jsonUrl != "")
			{
				
				loadJson(jsonUrl);
				
			} else {
				
				if (paramVideoPath != null && paramVideoPath != "") {
					
					nowLoadData();
					
				} else {
					
					errorLoadData("[ERROR] Not load vars");
					
				}
				
			}
			
			embedLoader = new URLLoader();
			embedLoader.addEventListener(Event.COMPLETE, completeLoadEmbedText);
			embedLoader.addEventListener(IOErrorEvent.IO_ERROR, errorEmbedText);
			embedLoader.load(new URLRequest("http://lifenews.ru/flash/pl_v1/embed.html"));
			
		}
		
		private function errorEmbedText(event:IOErrorEvent):void
		{
			
			errorLoadData("[ERROR] Not load embed text");
			
		}
		
		
		
		
		//******** JSON ********
		public function loadJson(jsonPath:String):void
		{
			
			jsonRequest = new URLRequest(jsonPath);
			jsonLoader = new URLLoader();
			jsonLoader.addEventListener(Event.COMPLETE, completeJsonLoad);
			jsonLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorJsonLoad);
			jsonLoader.load(jsonRequest);
			
		}
		
		private function ioErrorJsonLoad(event:IOErrorEvent):void
		{
			
			errorLoadData("[ERROR] IOError in JsonLoader");
			
		}
		
		private function completeJsonLoad(event:Event):void
		{
			
			objectLoaderInfo = JSON.parse(event.currentTarget.data);
			
			paramVideoPath = objectLoaderInfo["videoPath"];
			paramImagePath = objectLoaderInfo["videoImage"];
			paramAdv = objectLoaderInfo["adv"];
			paramEmbed = objectLoaderInfo["embed"];
			paramVideoLink = objectLoaderInfo["news_link"];
			related = objectLoaderInfo["related"];
			
			if (initVideo == false) {
				
				nowLoadData();
				
				initVideo = true;
				
			}
			
			if (DEBUG_MODE) {
				trace("\nJSON Obj: " + objectLoaderInfo + "\n");
				trace("\nJSON videoPath: " + objectLoaderInfo["videoPath"] + "\n");
				trace("\nJSON videoImage: " + objectLoaderInfo["videoImage"] + "\n");
				trace("\nJSON news_link: " + objectLoaderInfo["news_link"] + "\n");
				trace("\nJSON related: " + objectLoaderInfo["related"] + "\n");
			}
			
		}
		
		private function nowLoadData():void
		{
			
			if (paramImagePath == null || paramImagePath == "") {
				
				paramImagePath = "NO_IMAGE";
				
			}
			
			if (paramAdv != 1) {
				
				paramAdv = 0;
				
			}
			
			if (paramAdvType > 1) {
				
				paramAdvType = 1;
				
			} else if (paramAdvType < 0) {
				
				paramAdvType = 0;
				
			}
			
			if (paramVideoPanel == null || paramVideoPanel == "") {
				
				paramVideoPanel = "SHOW";
				
			}
			
			if (paramVideoLink == null || paramVideoLink == "") {
				
				paramVideoLink = "NO_LINK";
				
			}
			
			initVideoObjects();
			
		}
		
		private function initVideoObjects():void
		{
			
			constructor = new NMPlayerObjects(stage);
			stage.addChild(constructor);
			
			sendUserEvent(1);
			
			if (DEBUG_MODE) {
				
				trace("[INFO] Init Video Objects\n\n");
				
				trace("********* PARAMETERS *********\n");
				trace("videoPanel: " + paramVideoPanel);
				trace("videoPath: " + paramVideoPath);
				trace("videoLink: " + paramVideoLink);
				trace("imagePath: " + paramImagePath);
				trace("Adv: " + paramAdv);
				trace("AdvType: " + paramAdvType);
				trace("\n******************************\n");
			}
			
		}
		
		private function errorLoadData(message:String):void
		{
			
			var t:TextField = new TextField();
			t.selectable = false;
			t.width = stage.stageWidth;
			t.height = 30;
			t.textColor = 0xffffff;
			t.text = "" + message;
			this.addChild(t);
			
			if (DEBUG_MODE) {
				trace("[ERROR] Error loading data\n");
			}
			
		}
		
		private function completeLoadEmbedText(event:Event):void
		{
			
			embedData = event.target.data;
			
			if (paramVideoEmbed == null || paramVideoEmbed == "") {
				
				embedText = "";
				
			} else {
				
				paramVideoEmbedArr = paramVideoEmbed.split("||");
				
				for (var i:int = 0; i<paramVideoEmbedArr.length; i++) {
					
					var arr:Array = paramVideoEmbedArr[i].split("|");
					var str1:String = arr[0].toString();
					var str2:String = arr[1].toString();
					
					embedData = embedData.split("%" + str1 + "%").join(str2);
					
				}
				
				flashVars = "videoLink=" + URLEncoding.urlEncode(paramVideoLink) + "&videoPath=" + URLEncoding.urlEncode(paramVideoPath) + "&imagePath=" + URLEncoding.urlEncode(paramImagePath) + "&videoPanel=" + URLEncoding.urlEncode(paramVideoPanel);
				
				embedData = embedData.split("%FLASH_VARS%").join(flashVars);
				
				embedText = embedData;
				
			}
			
			cMenu = new ContextMenu();
			contextMenu = cMenu;
			cMenuClass = new NMContextMenu(stage, cMenu, appVersion);
			
			if (DEBUG_MODE) {
				trace("[INFO] Add embed items in ContextMenu\n");
			}
			
		}
		
		public function sendUserEvent(userEvent:int):void
		{
			
			userEvents.detectEvent(userEvent, paramVideoPath, referer);
			
		}
		
		public function getAllParameters():Array
		{
			
			paramArr = [];
			paramArr.push(paramVideoPath, paramImagePath, paramAdv, paramVideoPanel, paramVideoLink, paramAdvType);
			
			return paramArr;
			
		}
		
		public function getVideoShare():String
		{
			
			return paramVideoShare;
			
		}
		
		public function getVideoLink():String
		{
			
			return paramVideoLink;
			
		}
		
		public function getVideoPath():String
		{
			
			return paramVideoPath;
			
		}
		
		public function getImagePath():String
		{
			
			return paramImagePath;
			
		}
		
		public function getAdv():int
		{
			
			return paramAdv;
			
		}
		
		public function getAdvType():int
		{
			
			return paramAdvType;
			
		}
		
		public function getShowPanel():String
		{
			
			return paramVideoPanel;
			
		}
		
		public function getEmbedText():String
		{
			
			return embedText;
			
		}
		
		public function getDebugMode():Boolean
		{
			
			return DEBUG_MODE;
			
		}
		
		public function getReferer():String
		{
			
			return referer;
			
		}
		
		public function getEmbed():Boolean
		{
			
			return paramEmbed;
			
		}
		
		public function getVideoID():String
		{
			
			return paramVideoID;
			
		}
		
	}
}
