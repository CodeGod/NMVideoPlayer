package
{
	
	import com.greensock.*;
	import com.greensock.easing.*;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.*;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.media.Video;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFieldAutoSize;
	
	import utils.NMPostroll;
	
	public class NMPlayerObjects extends Sprite
	{
		
		public static var videoPlayer:NMVideoPlayer;
		public static var videoFullscreen:NMVideoFullscreen;
		public static var videoConstructor:NMVideoConstructor;
		
		private var _stage:Stage;
		private var videoPanel:String;
		private var alignBottom:int;
		private var i:int;
		
		private var loaderInterface:LoaderMax;
		private var folderPath:String;
		
		private var CONT_CONTROLLERS:Sprite;
		private var CONT_PANEL:Sprite;
		private var CONT_VIDEO:Sprite;
		private var CONT_IMAGE:Sprite;
		private var CONT_MORE:Sprite;
		private var CONT_LOADER:Sprite;
		private var CONT_POSTROLL:Sprite;
		private var CONT_FADE:Sprite;
		
		private var panelBg:Sprite;
		private var videoTime:VideoTime;
		private var buttonPlayBig:Sprite;
		private var buttonPlayBigIcon:Sprite;
		private var buttonPlayBigBg:Sprite;
		private var buttonPlayBigState:String;
		private var buttonPlay:Sprite;
		private var buttonPause:Sprite;
		private var buttonFull:Sprite;
		private var buttonShare:Sprite;
		private var buttonSound:Sprite;
		private var buttonSoundState:String;
		private var oldSound:Number;
		private var barSound:Sprite;
		private var barSoundTrack:Sprite;
		private var bgSound:Sprite;
		private var contSound:Sprite;
		private var itemTime:BarTime;
		private var barTime:Sprite;
		private var barProgress:Sprite;
		private var barLoad:Sprite;
		private var lifeBut:LifeBut;
		private var news_link:String;
		private var buttonState:Sprite;
		private var stateIcon:Sprite;
		private var stateIconPressed:Sprite;
		private var statePlayer:Boolean;
		private var videoID:String;
		private var videoLoaded:Boolean;
		
		private var videoObj:Video;
		private var videoCont:Sprite;
		private var imageObj:Sprite;
		private var imageCont:Sprite;
		private var imageBg:Sprite;
		private var postrollBg:Sprite;
		
		private var relatedImageLoader:LoaderMax;
		private var relatedItemsArr:Array;
		private var relatedDataArr:Array;
		
		public function NMPlayerObjects(_st:Stage)
		{
			
			this._stage = _st;
			
			NMVideoConstructor.playerObjects = this;
			NMVideoFullscreen.playerObjects = this;
			utils.VIADController.playerObjects = this;
			utils.NMPostroll.playerObjects = this;
			
			buttonPlayBigState = "PAUSED";
			buttonSoundState = "UNMUTE";
			videoLoaded = false;
			alignBottom = 0;
			oldSound = 0.5;
			videoPanel = videoPlayer.getShowPanel();
			news_link = videoPlayer.getVideoLink();
			statePlayer = false;
			videoID = videoPlayer.getVideoID();
			folderPath = "http://front.lifenews.ru/flash/pl_v1";
			//folderPath = ".";//"." local path
			
			createContainers();
			
		}
		
		private function createContainers():void
		{
			
			// глобальные контейнеры
			CONT_CONTROLLERS = new Sprite();
			CONT_PANEL = new Sprite();
			CONT_VIDEO = new Sprite();
			CONT_IMAGE = new Sprite();
			CONT_LOADER = new Sprite();
			CONT_POSTROLL = new Sprite();
			CONT_MORE = new Sprite();
			CONT_FADE = new Sprite();
			
			CONT_CONTROLLERS.visible = false;
			
			CONT_MORE.visible = false;
			
			_stage.addChild(CONT_VIDEO);
			_stage.addChild(CONT_IMAGE);
			_stage.addChild(CONT_MORE);
			_stage.addChild(CONT_CONTROLLERS);
			_stage.addChild(CONT_LOADER);
			_stage.addChild(CONT_POSTROLL);
			_stage.addChild(CONT_FADE);
			
			postrollBg = new Sprite();
			postrollBg.graphics.beginFill(0x000000, 1);
			postrollBg.graphics.drawRect(0, 0, 100, 100);
			postrollBg.graphics.endFill();
			CONT_POSTROLL.addChild(postrollBg);
			
			CONT_FADE.graphics.beginFill(0x000000, 1);
			CONT_FADE.graphics.drawRect(0, 0, _stage.stageWidth, _stage.stageHeight);
			CONT_FADE.graphics.endFill();
			
			// элементы управления
			panelBg = new Sprite();
			videoTime = new VideoTime();
			buttonPlay = new Sprite();
			buttonPause = new Sprite();
			buttonFull = new Sprite();
			buttonShare = new Sprite();
			buttonSound = new Sprite();
			barSound = new Sprite();
			barSoundTrack = new Sprite();
			bgSound = new Sprite();
			contSound = new Sprite();
			barProgress = new Sprite();
			barLoad = new Sprite();
			barTime = new Sprite();
			itemTime = new BarTime();
			buttonPlayBig = new Sprite();
			buttonPlayBigIcon = new Sprite();
			buttonPlayBigBg = new Sprite();
			lifeBut = new LifeBut();
			buttonState = new Sprite();
			stateIcon = new Sprite();
			stateIconPressed = new Sprite();
			
			stateIconPressed.visible = false;
			buttonState.addChild(stateIcon);
			buttonState.addChild(stateIconPressed);
			
			buttonPlayBigBg.graphics.beginFill(0x000000, 0.2);
			buttonPlayBigBg.graphics.drawRect(0, 0, 10, 10);
			buttonPlayBigBg.graphics.endFill();
			
			videoTime.x = 90;
			videoTime.y = 12;
			videoTime.time.text = "00:00 / 00:00";
			
			barTime.graphics.beginFill(0xFF00FA, 0);
			barTime.graphics.drawRect(0, 0, 1, 9);
			barTime.graphics.endFill();
			
			buttonSound.x = 4;
			buttonSound.y = 2;
			
			bgSound.x = 4;
			bgSound.y = -130;
			bgSound.visible = false;
			bgSound.alpha = 0;
			
			contSound.x = 58;
			
			barSound.x = 19;
			barSound.y = -19;
			barSound.rotation = 180;
			barSound.visible = false;
			barSound.alpha = 0;
			
			barSoundTrack.graphics.beginFill(0xFFFFFF, 0);
			barSoundTrack.graphics.drawRect(0, 0, 12, 104);
			barSoundTrack.graphics.endFill();
			barSoundTrack.x = 22;
			barSoundTrack.y = -19;
			barSoundTrack.rotation = 180;
			barSoundTrack.visible = false;
			
			itemTime.visible = false;
			itemTime.alpha = 0;
			
			CONT_CONTROLLERS.addChild(buttonPlayBig);
			_stage.addChild(itemTime);
			CONT_PANEL.addChild(panelBg);
			CONT_PANEL.addChild(videoTime);
			CONT_PANEL.addChild(buttonPlay);
			CONT_PANEL.addChild(buttonPause);
			CONT_PANEL.addChild(buttonFull);
			CONT_PANEL.addChild(contSound);
			CONT_PANEL.addChild(barLoad);
			CONT_PANEL.addChild(barProgress);
			CONT_PANEL.addChild(barTime);
			CONT_PANEL.addChild(lifeBut);
			CONT_PANEL.addChild(buttonShare);
			CONT_PANEL.addChild(buttonState);
			
			barTime.visible = false;
			
			var emb:Boolean = videoPlayer.getEmbed();
			if (emb == false) {
				lifeBut.visible = false;
				buttonShare.visible = true;
				buttonState.visible = true;
			} else {
				lifeBut.visible = true;
				buttonShare.visible = false;
				buttonState.visible = false;
			}
			
			CONT_CONTROLLERS.addChild(CONT_PANEL);
			
			contSound.addChild(bgSound);
			contSound.addChild(buttonSound);
			contSound.addChild(barSound);
			contSound.addChild(barSoundTrack);
			
			buttonPlayBig.addChild(buttonPlayBigBg);
			buttonPlayBig.addChild(buttonPlayBigIcon);
			
			// видео
			videoCont = new Sprite();
			videoObj = new Video();
			
			videoCont.addChild(videoObj);
			CONT_VIDEO.addChild(videoCont);
			
			// картинка
			imageCont = new Sprite();
			imageBg = new Sprite();
			imageObj = new Sprite();
			
			imageBg.graphics.beginFill(0x000000, 1);
			imageBg.graphics.drawRect(0, 0, 10, 10);
			imageBg.graphics.endFill();
			
			imageCont.addChild(imageBg);
			imageCont.addChild(imageObj);
			CONT_IMAGE.addChild(imageCont);
			
			if (NMVideoPlayer.DEBUG_MODE) {
				trace("[INFO] Create containers & objects\n");
			}
			
			loadInterfaces();
			
		}
		
		private function loadInterfaces():void
		{
			
			loaderInterface = new LoaderMax({name:"mainLoader", onProgress:progressHandler, onComplete:completeHandler, onError:errorHandler});
			
			loaderInterface.append(new ImageLoader(folderPath + "/skin/bg.png", {container:panelBg, scaleMode:"proportionalInside"}));
			loaderInterface.append(new ImageLoader(folderPath + "/skin/buttonPlay.png", {container:buttonPlay, scaleMode:"proportionalInside"}));
			loaderInterface.append(new ImageLoader(folderPath + "/skin/buttonPause.png", {container:buttonPause, scaleMode:"proportionalInside"}));
			loaderInterface.append(new ImageLoader(folderPath + "/skin/buttonFullscreen.png", {container:buttonFull, scaleMode:"proportionalInside"}));
			loaderInterface.append(new ImageLoader(folderPath + "/skin/bgSound.png", {container:bgSound, scaleMode:"proportionalInside"}));
			loaderInterface.append(new ImageLoader(folderPath + "/skin/buttonSound.png", {container:buttonSound, scaleMode:"proportionalInside"}));
			loaderInterface.append(new ImageLoader(folderPath + "/skin/barSound.png", {container:barSound, scaleMode:"proportionalInside"}));
			loaderInterface.append(new ImageLoader(folderPath + "/skin/barProgress.png", {container:barProgress, scaleMode:"proportionalInside"}));
			loaderInterface.append(new ImageLoader(folderPath + "/skin/barLoad.png", {container:barLoad, scaleMode:"proportionalInside"}));
			loaderInterface.append(new ImageLoader(folderPath + "/skin/buttonPlayBig.png", {container:buttonPlayBigIcon, scaleMode:"proportionalInside"}));
			loaderInterface.append(new ImageLoader(folderPath + "/skin/buttonShare.png", {container:buttonShare, scaleMode:"proportionalInside"}));
			loaderInterface.append(new ImageLoader(folderPath + "/skin/buttonState.png", {container:stateIcon, scaleMode:"proportionalInside"}));
			loaderInterface.append(new ImageLoader(folderPath + "/skin/buttonStatePressed.png", {container:stateIconPressed, scaleMode:"proportionalInside"}));
			
			loaderInterface.load();
			
			if (NMVideoPlayer.DEBUG_MODE) {
				trace("[INFO] Load interface: START\n");
			}
			
		}
		
		private function progressHandler(event:LoaderEvent):void
		{
			
			
			
		}
		
		private function completeHandler(event:LoaderEvent):void
		{
			
			buttonPause.visible = false;
			
			barSound.height = 52;
			barLoad.width = barProgress.width = barTime.width = _stage.stageWidth;
			
			CONT_CONTROLLERS.visible = true;
			
			addListeners();
			
			if (videoPlayer.getEmbed() == true) {
				initRelated();
			}
			
			if (NMVideoPlayer.DEBUG_MODE) {
				trace("[INFO] Load interface: COMPLETE\n");
			}
			
		}
		
		private function errorHandler(event:LoaderEvent):void
		{
			
			if (NMVideoPlayer.DEBUG_MODE) {
				trace("[ERROR] Load interface: ERROR (LoaderEvent - " + event + ")\n");
			}
			
		}
		
		private function addListeners():void
		{
			
			buttonPlay.addEventListener(MouseEvent.CLICK, clickPlay);
			buttonPlay.addEventListener(MouseEvent.MOUSE_OVER, overPlay);
			buttonPlay.buttonMode = true;
			buttonPlayBig.addEventListener(MouseEvent.CLICK, clickPlayBig);
			buttonPause.addEventListener(MouseEvent.CLICK, clickPause);
			buttonPause.addEventListener(MouseEvent.MOUSE_OVER, overPause);
			buttonPause.buttonMode = true;
			buttonFull.addEventListener(MouseEvent.CLICK, clickFull);
			buttonFull.buttonMode = true;
			buttonShare.addEventListener(MouseEvent.CLICK, clickShare);
			buttonShare.buttonMode = true;
			barTime.addEventListener(MouseEvent.MOUSE_OVER, overBarTime);
			barTime.addEventListener(MouseEvent.MOUSE_OUT, outBarTime);
			barTime.addEventListener(MouseEvent.MOUSE_DOWN, clickBarTime);
			buttonSound.addEventListener(MouseEvent.CLICK, clickSound);
			buttonSound.addEventListener(MouseEvent.MOUSE_OVER, overSound);
			buttonSound.buttonMode = true;
			barSoundTrack.addEventListener(MouseEvent.MOUSE_DOWN, downBarSound);
			barSoundTrack.buttonMode = true;
			lifeBut.addEventListener(MouseEvent.CLICK, clickLifeBut);
			lifeBut.buttonMode = true;
			buttonState.addEventListener(MouseEvent.CLICK, clickState);
			buttonState.buttonMode = true;
			
			videoConstructor = new NMVideoConstructor(videoObj, CONT_POSTROLL, imageObj, barProgress, barLoad, barTime, videoTime, _stage, postrollBg, CONT_MORE);
			videoFullscreen = new NMVideoFullscreen(_stage);
			
			_stage.addEventListener(Event.RESIZE, resizeStage);
			
			if (videoPanel == "HIDE") {
				
				_stage.addEventListener(Event.MOUSE_LEAVE, autoHidePanel);
				_stage.addEventListener(MouseEvent.MOUSE_MOVE, autoShowPanel);
				
			}
			
			TweenMax.to(CONT_FADE, 0.4, {autoAlpha:0, delay:0.2});
			
		}
		
		private function clickState(event:MouseEvent):void
		{
			
			if (statePlayer == false) {
				
				statePlayer = true;
				
				stateIcon.visible = false;
				stateIconPressed.visible = true;
				
				replaceState();
				detectFullScreen();
				
			} else {
				
				statePlayer = false;
				
				stateIcon.visible = true;
				stateIconPressed.visible = false;
				
				replaceState();
				detectFullScreen();
				
			}
			
		}
		
		private function detectFullScreen():void
		{
			
			if (videoFullscreen.fullState == "FULL") {
				
				videoFullscreen.gotoFullScreen();
				
			}
			
		}
		
		private function replaceState():void
		{
			
			try {
				
				ExternalInterface.call("$.life.videoPlayerMediumSizeToggle", videoID);
				
			} catch (err:Error) {
				
				if (NMVideoPlayer.DEBUG_MODE) {
					trace("[ERROR] Error replace state player\n");
				}
				
			}
			
		}
		
		private function clickLifeBut(event:MouseEvent):void
		{
			
			navigateToURL(new URLRequest("" + news_link), "_blank");
			
		}
		
		private function autoHidePanel(event:Event):void
		{
			
			if (buttonPlayBigState != "PAUSED") {
				
				TweenMax.killTweensOf(CONT_PANEL);
				TweenMax.to(CONT_PANEL, 0.3, {y:_stage.stageHeight - barProgress.height, delay:0.2});
				
			}
			
		}
		
		private function autoShowPanel(event:MouseEvent):void
		{
			
			showPanel();
			
		}
		private function showPanel():void
		{
			
			TweenMax.killTweensOf(CONT_PANEL);
			TweenMax.to(CONT_PANEL, 0.3, {y:_stage.stageHeight - CONT_PANEL.height + 123});
			
		}
		
		private function overBarTime(event:MouseEvent):void
		{
			
			_stage.addEventListener(Event.ENTER_FRAME, detectBarTime);
			
			TweenMax.killTweensOf(itemTime);
			TweenMax.to(itemTime, 0.2, {autoAlpha:1, delay:0.1, ease:Expo.easeOut});
			
		}
		private function outBarTime(event:MouseEvent):void
		{
			
			TweenMax.killTweensOf(itemTime);
			TweenMax.to(itemTime, 0.3, {autoAlpha:0, ease:Expo.easeOut});
			
			_stage.removeEventListener(Event.ENTER_FRAME, detectBarTime);
			
		}
		private function clickBarTime(event:MouseEvent):void
		{
			
			videoConstructor.replaseVideoStatus();
			
			if (buttonPlayBigState == "PAUSED") {
				
				buttonPlayBigState = "PLAYING";
				videoPlay();
				
			}
			
			if (NMVideoPlayer.DEBUG_MODE) {
				trace("[CLICK] Replace Video Status\n");
			}
			
		}
		private function detectBarTime(event:Event):void
		{
			
			itemTime.time.text = videoConstructor.getVideoTime();
			
			setPositionBarTime();
			
		}
		private function setPositionBarTime():void
		{
			
			itemTime.x = _stage.mouseX - 25;
			itemTime.y = _stage.stageHeight - CONT_PANEL.height + 122;
			
			if (itemTime.x < 0) {
				
				itemTime.x = 0;
				
			} else if (itemTime.x > _stage.stageWidth - itemTime.width) {
				
				itemTime.x = _stage.stageWidth - itemTime.width;
				
			}
			
		}
		
		private function clickFull(event:MouseEvent):void
		{
			
			videoFullscreen.gotoFullScreen();
			
			if (NMVideoPlayer.DEBUG_MODE) {
				trace("[CLICK] FULLSCREEN\n");
			}
			
		}
		
		private function overPlay(event:MouseEvent):void
		{
			hideVol();
		}
		private function overPause(event:MouseEvent):void
		{
			hideVol();
		}
		
		private function clickPlay(event:MouseEvent):void
		{
			
			buttonPlayBigState = "PLAYING";
			videoPlay();
			
		}
		private function clickPlayBig(event:MouseEvent):void
		{
			
			if (buttonPlayBigState == "PAUSED") {
				
				buttonPlayBigState = "PLAYING";
				videoPlay();
				
			} else {
				
				videoPause();
				
			}
			
		}
		private function videoPlay():void
		{
			
			if (videoLoaded == false) {
				videoLoaded = true;
				barTime.visible = true;
			}
			
			videoConstructor.videoPlay();
			playStateObjects();
			
			if (NMVideoPlayer.DEBUG_MODE) {
				trace("[CLICK] PLAY\n");
			}
			
		}
		private function playStateObjects():void
		{
			
			buttonPlayBig.alpha = 0;
			buttonPlay.visible = false;
			buttonPause.visible = true;
			
			CONT_MORE.visible = false;
			showBigPlay();
			
		}
		
		public function hideBigPlay():void
		{
			buttonPlayBig.visible = false;
		}
		public function showBigPlay():void
		{
			buttonPlayBig.visible = true;
		}
		
		private function clickPause(event:MouseEvent):void
		{
			
			videoPause();
			
		}
		private function videoPause():void
		{
			
			videoConstructor.videoPause();
			
			pauseStateObjects();
			
			if (NMVideoPlayer.DEBUG_MODE) {
				trace("[CLICK] PAUSE\n");
			}
			
		}
		public function pauseStateObjects():void
		{
			
			buttonPlayBig.alpha = 1;
			buttonPlay.visible = true;
			buttonPause.visible = false;
			
			buttonPlayBigState = "PAUSED";
			
			showPanel();
			
		}
		
		private function clickShare(event:MouseEvent):void
		{
			
			videoPause();
			
			var bg:Sprite = new Sprite();
			bg.graphics.beginFill(0x000000, 0.7);
			bg.graphics.drawRect(0, 0, _stage.stageWidth, _stage.stageHeight);
			bg.graphics.endFill();
			_stage.addChild(bg);
			
			var iconVk:IconVk = new IconVk();
			iconVk.name = "vk";
			iconVk.x = _stage.stageWidth/2 - iconVk.width/2;
			iconVk.y = 20;
			iconVk.addEventListener(MouseEvent.CLICK, clickSocial);
			iconVk.buttonMode = true;
			_stage.addChild(iconVk);
			
			var iconTw:IconTw = new IconTw();
			iconTw.name = "tw";
			iconTw.x = _stage.stageWidth/2 - iconTw.width/2;
			iconTw.y = iconVk.y + 40;
			iconTw.addEventListener(MouseEvent.CLICK, clickSocial);
			iconTw.buttonMode = true;
			_stage.addChild(iconTw);
			
			var iconFb:IconFb = new IconFb();
			iconFb.name = "fb";
			iconFb.x = _stage.stageWidth/2 - iconFb.width/2;
			iconFb.y = iconTw.y + 40;
			iconFb.addEventListener(MouseEvent.CLICK, clickSocial);
			iconFb.buttonMode = true;
			_stage.addChild(iconFb);
			
			var iconClose:IconClose = new IconClose();
			iconClose.x = _stage.stageWidth - iconClose.width;
			iconClose.y = 0;
			iconClose.addEventListener(MouseEvent.CLICK, closeShare);
			iconClose.buttonMode = true;
			_stage.addChild(iconClose);
			
			function closeShare(event:MouseEvent):void
			{
				iconVk.removeEventListener(MouseEvent.CLICK, clickSocial);
				iconTw.removeEventListener(MouseEvent.CLICK, clickSocial);
				iconFb.removeEventListener(MouseEvent.CLICK, clickSocial);
				iconClose.removeEventListener(MouseEvent.CLICK, closeShare);
				_stage.removeChild(bg);
				_stage.removeChild(iconVk);
				_stage.removeChild(iconTw);
				_stage.removeChild(iconFb);
				_stage.removeChild(iconClose);
				bg = null;
				iconVk = null;
				iconTw = null;
				iconFb = null;
				iconClose = null;
			}
			
			if (NMVideoPlayer.DEBUG_MODE) {
				trace("[CLICK] SHARE\n");
			}
			
		}
		
		private function clickSocial(event:MouseEvent):void
		{
			
			try {
				
				ExternalInterface.call("$.life.socialShareVideo", event.currentTarget.name, NMVideoPlayer.paramVideoPath);
				
			} catch (err:Error) {
				
				if (NMVideoPlayer.DEBUG_MODE) {
					trace("\nError External: " + err);
				}
				
			}
			
		}
		
		private function initRelated():void
		{
			
			relatedImageLoader = new LoaderMax({name:"imageLoader", onComplete:completeRelatedLoadImg});
			
			relatedItemsArr = new Array();
			relatedDataArr = new Array();
			
			for (i = 0; i < 4; i++) {
				
				var item:Sprite = new Sprite();
				item.graphics.beginFill(0x000000, 1);
				item.graphics.drawRect(0, 0, 490, 280);
				item.graphics.endFill();
				item.name = "" + i;
				
				var hit:Sprite = new Sprite();
				hit.graphics.beginFill(0x000000, 0);
				hit.graphics.drawRect(0, 0, 490, 280);
				hit.graphics.endFill();
				hit.addEventListener(MouseEvent.CLICK, clickRelatedItem);
				hit.addEventListener(MouseEvent.ROLL_OVER, overRelatedItem);
				hit.addEventListener(MouseEvent.ROLL_OUT, outRelatedItem);
				
				var itemTitle:ItemTitle = new ItemTitle();
				itemTitle.textTitle.text = NMVideoPlayer.related[i]["title"];
				itemTitle.textTitle.autoSize = TextFieldAutoSize.LEFT;
				itemTitle.x = itemTitle.y = 5;
				
				var bgTitle:Sprite = new Sprite();
				bgTitle.graphics.beginFill(0x000000, 0.7);
				bgTitle.graphics.drawRect(5, 5, 480, itemTitle.textTitle.height + 5);
				bgTitle.graphics.endFill();
				
				var playIcon:Sprite = new Sprite();
				playIcon.x = 203;
				playIcon.y = 90;
				playIcon.alpha = 0;
				playIcon.buttonMode = true;
				playIcon.addEventListener(MouseEvent.CLICK, clickRelatedItem);
				playIcon.addEventListener(MouseEvent.ROLL_OVER, overRelatedItem);
				playIcon.addEventListener(MouseEvent.ROLL_OUT, outRelatedItem);
				
				var iconLoader:LoaderMax = new LoaderMax();
				iconLoader.append(new ImageLoader(folderPath + "/skin/buttonPlayBig.png", {container:playIcon, scaleMode:"proportionalInside"}));
				iconLoader.load();
				
				var itemImg:Sprite = new Sprite();
				itemImg.x = itemImg.y = 5;
				itemImg.alpha = 0.5;
				
				item.addChild(itemImg);
				item.addChild(bgTitle);
				item.addChild(itemTitle);
				item.addChild(hit);
				item.addChild(playIcon);
				
				if (i == 0) {
					item.x = item.y = 0;
				}
				if (i == 1) {
					item.x = 495;
					item.y = 0;
				}
				if (i == 2) {
					item.x = 0;
					item.y = 285;
				}
				if (i == 3) {
					item.x = 495;
					item.y = 285;
				}
				
				CONT_MORE.addChild(item);
				
				var obj:Object = new Object();
				obj.item = item;
				obj.itemImg = itemImg;
				obj.itemTitle = itemTitle;
				obj.bgTitle = bgTitle;
				obj.id = i;
				obj.playIcon = playIcon;
				
				relatedItemsArr.push(obj);
				
			}
			
		}
		
		public function createRelatedVideos():void
		{
			
			//CONT_MORE
			if (videoPlayer.getEmbed() == true) {
				
				relatedImageLoader.unload();
				
				CONT_MORE.visible = true;
				
				hideBigPlay();
				
				relatedDataArr = [];
				
				for (i = 0; i < NMVideoPlayer.related.length; i++) {
					
					var obj:Object = new Object();
					obj.title = NMVideoPlayer.related[i]["title"];
					obj.link = NMVideoPlayer.related[i]["news_link"];
					obj.videoPath = NMVideoPlayer.related[i]["videoPath"];
					obj.videoImage = NMVideoPlayer.related[i]["videoImage"];
					obj.varsJSON = NMVideoPlayer.related[i]["varsJSON"];
					
					relatedDataArr.push(obj);
					
					while(relatedItemsArr[i]["itemImg"].numChildren > 0) {
						relatedItemsArr[i]["itemImg"].removeChildAt(relatedItemsArr[i]["itemImg"].numChildren-1);
					}
					
				}
				
				for (i = 0; i < NMVideoPlayer.related.length; i++) {
					
					relatedItemsArr[i]["itemTitle"].textTitle.text = relatedDataArr[i]["title"];
					relatedItemsArr[i]["bgTitle"].height = relatedItemsArr[i]["itemTitle"].textTitle.height + 5;
					
					relatedImageLoader.append(new ImageLoader(relatedDataArr[i]["videoImage"], {container:relatedItemsArr[i]["itemImg"], width:480, height:270, scaleMode:"proportionalInside"}));
					relatedImageLoader.load();
					
				}
				
			}
			
		}
		
		private function overRelatedItem(event:MouseEvent):void
		{
			
			relatedItemsArr[event.currentTarget.parent.name]["itemTitle"].alpha = 0;
			relatedItemsArr[event.currentTarget.parent.name]["bgTitle"].alpha = 0;
			relatedItemsArr[event.currentTarget.parent.name]["playIcon"].alpha = 1;
			TweenMax.to(relatedItemsArr[event.currentTarget.parent.name]["itemImg"], 0.2, {alpha:1});
			
		}
		
		private function outRelatedItem(event:MouseEvent):void
		{
			
			relatedItemsArr[event.currentTarget.parent.name]["itemTitle"].alpha = 1;
			relatedItemsArr[event.currentTarget.parent.name]["bgTitle"].alpha = 1;
			relatedItemsArr[event.currentTarget.parent.name]["playIcon"].alpha = 0;
			TweenMax.to(relatedItemsArr[event.currentTarget.parent.name]["itemImg"], 0.4, {alpha:0.5});
			
		}
		
		private function clickRelatedItem(event:MouseEvent):void
		{
			
			videoConstructor.videoRelatedPlay(relatedDataArr[event.currentTarget.parent.name]["videoPath"]);
			
			videoPlayer.loadJson(relatedDataArr[event.currentTarget.parent.name]["varsJSON"]);
			
			news_link = relatedDataArr[event.currentTarget.parent.name]["link"];
			
			videoConstructor.reloadImageFile(relatedDataArr[event.currentTarget.parent.name]["videoImage"]);
			
			playStateObjects();
			
		}
		
		private function completeRelatedLoadImg(event:LoaderEvent):void
		{
			
			alignObjects();
			
		}
		
		private function overSound(event:MouseEvent):void
		{
			
			TweenMax.to(barSound, 0.2, {autoAlpha:1});
			TweenMax.to(bgSound, 0.2, {autoAlpha:1, ease:Expo.easeOut});
			barSoundTrack.visible = true;
			
			_stage.addEventListener(Event.ENTER_FRAME, detectShowVol);
			
		}
		
		private function detectShowVol(event:Event):void
		{
			
			if (mouseX > 100 || mouseX < 50 || mouseY < CONT_PANEL.y - 130 || mouseY > _stage.stageHeight - 3) {
				
				hideVol();
				_stage.removeEventListener(Event.ENTER_FRAME, detectShowVol);
				
			}
			
		}
		
		private function hideVol():void
		{
			
			TweenMax.to(barSound, 0.4, {autoAlpha:0, ease:Expo.easeOut});
			TweenMax.to(bgSound, 0.4, {autoAlpha:0, ease:Expo.easeOut});
			barSoundTrack.visible = false;
			
		}
		
		private function clickSound(event:MouseEvent):void
		{
			
			if (buttonSoundState == "UNMUTE") {
				
				buttonSoundState = "MUTE";
				
				TweenMax.to(buttonSound, 0.2, {tint:0x000000});
				TweenMax.to(barSound, 0.2, {height:0});
				
				videoConstructor.setVideoSound(0);
				
			} else {
				
				buttonSoundState = "UNMUTE";
				
				TweenMax.to(buttonSound, 0.2, {tint:null});
				TweenMax.to(barSound, 0.2, {height:oldSound * 104});
				
				videoConstructor.setVideoSound(oldSound);
				
			}
			
		}
		private function downBarSound(event:MouseEvent):void
		{
			
			_stage.addEventListener(Event.ENTER_FRAME, detectSound);
			_stage.addEventListener(MouseEvent.MOUSE_UP, replaceSound);
			
			if (buttonSoundState == "MUTE") {
				
				buttonSoundState = "UNMUTE";
				TweenMax.to(buttonSound, 0.2, {tint:null});
				
			}
			
		}
		private function detectSound(event:Event):void
		{
			
			barSound.height = barSoundTrack.mouseY;
			if (barSound.height > 104) {
				
				barSound.height = 104;
				
			}
			
			oldSound = barSound.height / 104;
			videoConstructor.setVideoSound(oldSound);
			
		}
		private function replaceSound(event:MouseEvent):void
		{
			
			_stage.removeEventListener(Event.ENTER_FRAME, detectSound);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, replaceSound);
			
		}
		
		private function resizeStage(event:Event):void
		{
			
			alignObjects();
			
		}
		
		public function alignObjects():void
		{
			
			CONT_FADE.width = _stage.stageWidth;
			CONT_FADE.height = _stage.stageHeight;
			
			TweenMax.killTweensOf(CONT_PANEL);
			showPanel();
			
			barTime.width = _stage.stageWidth;
			CONT_PANEL.y = _stage.stageHeight - CONT_PANEL.height + 123;
			panelBg.width = buttonPlayBigBg.width = _stage.stageWidth;
			buttonPlayBigBg.height = _stage.stageHeight - panelBg.height;
			buttonPlayBigIcon.x = buttonPlayBigBg.width/2 - buttonPlayBigIcon.width/2;
			buttonPlayBigIcon.y = buttonPlayBigBg.height/2 - buttonPlayBigIcon.height/2;
			buttonPlay.y = buttonPause.y = buttonFull.y = contSound.y = 7;
			buttonFull.x = panelBg.width - buttonFull.width - 4;
			lifeBut.x = buttonFull.x - lifeBut.width - 4;
			lifeBut.y = 9;
			buttonState.x = buttonFull.x - buttonState.width - 2;
			buttonState.y = 7;
			buttonShare.x = buttonState.x - buttonShare.width - 2;
			buttonShare.y = 7;
			
			if (videoPanel == "SHOW") {
				
				alignBottom = CONT_PANEL.height - 123;
				
			} else {
				
				alignBottom = 0;
				
			}
			
			imageBg.width = postrollBg.width = _stage.stageWidth;
			imageBg.height = postrollBg.height = _stage.stageHeight;
			
			videoCont.height = imageObj.height = _stage.stageHeight - alignBottom;
			videoCont.scaleX = videoCont.scaleY;
			imageObj.scaleX = imageObj.scaleY;
			
			if (videoCont.width > _stage.stageWidth || videoCont.width < _stage.stageWidth) {
				videoCont.width = _stage.stageWidth;
				videoCont.scaleY = videoCont.scaleX;
			}
			if (imageObj.width > _stage.stageWidth || imageObj.width < _stage.stageWidth) {
				imageObj.width = _stage.stageWidth;
				imageObj.scaleY = imageObj.scaleX;
			}
			if (videoCont.height > _stage.stageHeight - alignBottom) {
				videoCont.height = _stage.stageHeight - alignBottom;
				videoCont.scaleX = videoCont.scaleY;
			}
			if (imageObj.height > _stage.stageHeight - alignBottom) {
				imageObj.height = _stage.stageHeight - alignBottom;
				imageObj.scaleX = imageObj.scaleY;
			}
			
			videoCont.x = _stage.stageWidth/2 - videoCont.width/2;
			videoCont.y = (_stage.stageHeight - alignBottom)/2 - videoCont.height/2;
			
			imageObj.x = _stage.stageWidth/2 - imageObj.width/2;
			imageObj.y = (_stage.stageHeight - alignBottom)/2 - imageObj.height/2;
			
			CONT_MORE.height = _stage.stageHeight - 50;
			CONT_MORE.scaleX = CONT_MORE.scaleY;
			
			if (CONT_MORE.width > _stage.stageWidth) {
				CONT_MORE.width = _stage.stageWidth - 10;
				CONT_MORE.scaleY = CONT_MORE.scaleX;
			}
			
			CONT_MORE.x = _stage.stageWidth/2 - CONT_MORE.width/2;
			CONT_MORE.y = _stage.stageHeight/2 - CONT_MORE.height/2 - 18;
			
			videoConstructor.resizeBarLoadAndTime();
			setPositionBarTime();
			
		}
		
	}
	
}