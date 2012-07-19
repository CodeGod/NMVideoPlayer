package
{
	
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;
	
	import utils.NMPostroll;
	import utils.VIADController;
	
	public class NMVideoConstructor extends Sprite
	{
		//private var userEvents:NMUserEvents = new NMUserEvents();
		public static var videoPlayer:NMVideoPlayer;
		public static var playerObjects:NMPlayerObjects;
		
		private var paramArr:Array;
		private var imagePath:String;
		private var videoPath:String;
		private var adv:int;
		private var advType:int;
		private var videoPanel:String;
		private var loadedVideo:Boolean;
		private var playedVideo:Boolean;
		
		private var _stage:Stage;
		private var videoObj:Video;
		private var imageObj:Sprite;
		private var barProgress:Sprite;
		private var barLoad:Sprite;
		private var barTime:Sprite;
		private var videoTime:VideoTime;
		private var contMore:Sprite;
		
		private var nc:NetConnection;
		private var ns:NetStream;
		private var st:SoundTransform;
		private var videoSound:Number;
		private var amountLoaded:Number;
		private var dur:Number;
		private var client:Object;
		private var timerStatus:Timer;
		private var timerLoad:Timer;
		private var ns_second:Number;
		private var minuta:Number;
		private var secunda:Number;
		private var min:Number;
		private var sec:Number;
		private var s_min:String;
		private var s_sec:String;
		private var secItem:Number;
		private var minItem:Number;
		
		private var imgLoader:LoaderMax;
		
		private var viad:VIADController;
		private var viadCont:Sprite;
		private var viadBg:Sprite;
		private var viadSection:String;
		
		private var viad2:VIADController;
		private var viadCont2:Sprite;
		private var viadBg2:Sprite;
		private var viadSection2:String;
		
		private var postroll:NMPostroll;
		
		public function NMVideoConstructor(vid:Video, postCont:Sprite, img:Sprite, barp:Sprite, barl:Sprite, bart:Sprite, time:VideoTime, st:Stage, postbg:Sprite, cont_more:Sprite)
		{
			
			this._stage = st;
			this.videoObj = vid;
			this.imageObj = img;
			this.barLoad = barl;
			this.barProgress = barp;
			this.barTime = bart;
			this.videoTime = time;
			this.viadCont = postCont;
			this.viadBg = postbg;
			this.viadCont2 = postCont;
			this.viadBg2 = postbg;
			this.contMore = cont_more;
			
			viadSection = "79";
			viadSection2 = "252";
			
			NMVideoFullscreen.videoConstructor = this;
			NMPlayerObjects.videoConstructor = this;
			VIADController.videoConstructor = this;
			
			paramArr = videoPlayer.getAllParameters();
			
			videoPath = paramArr[0];
			imagePath = paramArr[1];
			adv = paramArr[2];
			videoPanel = paramArr[3];
			advType = paramArr[5];
			
			loadedVideo = false;
			playedVideo = false;
			videoSound = 0.5;
			
			initVideoConstructor();
			
			
		}
		
		private function initVideoConstructor():void
		{
			
			barProgress.width = barLoad.width = barTime.width = 0;
			
			nc = new NetConnection();
			nc.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			nc.connect(null);
			ns = new NetStream(nc);
			
			if (imagePath == "NO_IMAGE") {
				
				initVideoObject();
				
			} else {
				
				loadImageFile();
				
			}
			
			if (advType == 0) {
				
				viad = new VIADController(viadCont, viadBg, viadSection, 1);
				viad2 = new VIADController(viadCont2, viadBg2, viadSection2, 2);
				
			} else {
				
				postroll = new NMPostroll(viadCont, viadBg);
				
			}
			
			playerObjects.alignObjects();
			
		}
		
		private function loadImageFile():void
		{
			
			imgLoader = new LoaderMax({name:"imgLoader", onComplete:completeImageHandler});
			imgLoader.append(new ImageLoader(imagePath, {container:imageObj, scaleMode:"proportionalInside"}));
			imgLoader.load();
			
		}
		
		public function reloadImageFile(file:String):void
		{
			
			imgLoader.unload();
			
			while(imageObj.numChildren > 0) {
				imageObj.removeChildAt(imageObj.numChildren-1);
			}
			
			imgLoader.append(new ImageLoader(file, {container:imageObj, scaleMode:"proportionalInside"}));
			imgLoader.load();
			
		}
		
		private function completeImageHandler(event:LoaderEvent):void
		{
			
			playerObjects.alignObjects();
			
		}
		
		private function netStatusHandler(event:NetStatusEvent):void
		{
			
			switch (event.info.code) {
				case "NetStream.Play.StreamNotFound" :
					break;
				case "NetStream.Play.Start" :
					streamStart();
					break;
				case "NetStream.Play.Stop" :
					streamEnd();
					break;
			}
			
		}
		
		public function videoRelatedPlay(vid:String):void
		{
			
			videoPath = vid;
			
			ns.play(videoPath);
			
			hideImage();
			
		}
		
		public function videoPlay():void
		{
			
			if (imagePath == "NO_IMAGE") {
				
				togglePlayVideo();
				
			} else {
				
				if (loadedVideo == true) {
					
					togglePlayVideo();
					
				} else {
					
					initVideoObject();
					
				}
				
			}
			
			hideImage();
			
		}
		
		private function togglePlayVideo():void
		{
			
			if (playedVideo == false) {
				
				ns.play(videoPath);
				
			} else {
				
				ns.resume();
				
			}
			
		}
		
		public function videoPause():void
		{
			
			ns.pause();
			
		}
		
		private function streamStart():void
		{
			
			playedVideo = true;
			
			videoPlayer.sendUserEvent(2);
			
			if (NMVideoPlayer.DEBUG_MODE) {
				trace("[VIDEO] Video Start\n");
			}
			
		}
		
		private function streamEnd():void
		{
			
			videoPlayer.sendUserEvent(3);
			
			playedVideo = false;
			
			if (adv == 1) {
				
				if (advType == 0) {
					
					viad.resizePostroll(_stage.stageWidth, _stage.stageHeight);
					viad.postrollStart();
					
				} else {
					
					postroll.postrollStart();
					
				}
				
			}
			
			videoPause();
			ns.seek(0);
			
			playerObjects.pauseStateObjects();
			showImage();
			
			if (NMVideoPlayer.DEBUG_MODE) {
				trace("[VIDEO] Video End\n");
			}
			
			playerObjects.createRelatedVideos();
		}
		
		public function postrollStart():void
		{
			
			videoPlayer.sendUserEvent(4);
			
			if (NMVideoPlayer.DEBUG_MODE) {
				trace("[VIDEO] Postroll Start\n");
			}
			
		}
		
		public function postrollEnd():void
		{
			
			videoPlayer.sendUserEvent(5);
			
			if (NMVideoPlayer.DEBUG_MODE) {
				trace("[VIDEO] Postroll End\n");
			}
			
		}
		
		public function detectViadSections(num:int):void
		{
			
			if (num == 1) {
				
				viad2.resizePostroll(_stage.stageWidth, _stage.stageHeight);
				viad2.postrollStart();
				
			}
			
		}
		
		public function initVideoObject():void
		{
			
			loadedVideo = true;
			
			timerStatus = new Timer(10);
			timerStatus.addEventListener(TimerEvent.TIMER, videoStatus);
			timerLoad = new Timer(10);
			timerLoad.addEventListener(TimerEvent.TIMER, progressLoad);
			
			ns.addEventListener(IOErrorEvent.IO_ERROR, ioError);
			ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			ns.bufferTime = 0.5;
			ns.client = this;
			ns.checkPolicyFile = true;
			videoObj.attachNetStream(ns);
			videoObj.smoothing = true;
			
			st = new SoundTransform(videoSound);
			ns.soundTransform = st;
			
			timerLoad.start();
			
			try {
				
				ns.play(videoPath);
				
			} catch(err:Error) {
				
				errorVideoHandler();
				
			}
			
			ns.seek(0);
			if (imagePath == "NO_IMAGE") {
				
				ns.pause();
				
			}
			
			timerStatus.start();
			
			client = new Object();
			client.onCuePoint = onCuePoint;
			client.onMetaData = onMetaData;
			ns.client = client;
			
		}
		
		private function onCuePoint(info:Object):void
		{
			
			// cue points
			
		}
		private function onMetaData(info:Object):void
		{
			
			dur = info.duration;
			videoObj.width = info.width;
			videoObj.height = info.height;
			
			playerObjects.alignObjects();
			
		}
		
		private function ioError(event:IOErrorEvent):void
		{
			
			errorVideoHandler();
			
		}
		
		private function errorVideoHandler():void
		{
			
			if (NMVideoPlayer.DEBUG_MODE) {
				trace("[VIDEO ERROR] Video Handler\n");
			}
			
		}
		
		private function videoStatus(event:TimerEvent):void
		{
			
			barProgress.width = Math.floor(ns.time / dur * _stage.stageWidth);
			
			videoTimeHandler();
			
		}
		
		public function replaseVideoStatus():void
		{
			
			timerStatus.stop();
			
			barProgress.width = _stage.mouseX;
			ns.seek(dur * (barProgress.width / _stage.stageWidth));
			
			timerStatus.start();
			
		}
		
		private function progressLoad(event:TimerEvent):void
		{
			
			amountLoaded = ns.bytesLoaded / ns.bytesTotal;
			resizeBarLoadAndTime();
			
			if (amountLoaded == 1) {
				
				timerLoad.stop();
				
			}
			
		}
		
		private function videoTimeHandler():void
		{
			
			ns_second = ns.time;
			minuta = Math.floor(dur/60);
			secunda = Math.floor(dur - (minuta*60));
			min = Math.floor(ns_second/60);
			sec = Math.floor(ns_second-(min*60));
			
			if (min < 10) {
				
				s_min = "0" + String(min);
				
			} else {
				
				s_min = String(min);
				
			}
			if (sec < 10) {
				
				s_sec = "0" + String(sec);
				
			} else {
				
				s_sec = String(sec);
				
			}
			
			if (minuta < 10) {
				
				if (secunda < 10) {
					
					videoTime.time.text = s_min + ":" + s_sec + " / 0" + minuta + ":0" + secunda;
					
				} else {
					
					videoTime.time.text = s_min + ":" + s_sec + " / 0" + minuta + ":" + secunda;
					
				}
				
			} else {
				
				if (secunda < 10) {
					
					videoTime.time.text = s_min + ":" + s_sec + " / " + minuta + ":0" + secunda;
					
				} else {
					
					videoTime.time.text = s_min + ":" + s_sec + " / " + minuta + ":" + secunda;
					
				}
				
			}
			
		}
		
		public function getVideoTime():String
		{
			
			secItem = Math.floor(dur * (_stage.mouseX/_stage.stageWidth));
			minItem = Math.floor(secItem / 60);
			secItem = Math.floor(secItem % 60);
			
			return (minItem < 10 ? "0" : "") + minItem + ":" + (secItem < 10 ? "0" : "") + secItem;
			
		}
		
		public function setVideoSound(sound:Number):void
		{
			
			videoSound = sound;
			
			if (st != null) {
				
				st.volume = videoSound;
				ns.soundTransform = st;
				
			}
			
		}
		
		private function hideImage():void
		{
			
			TweenMax.to(imageObj.parent, 0.3, {autoAlpha:0});
			
		}
		
		private function showImage():void
		{
			
			TweenMax.to(imageObj.parent, 0.3, {autoAlpha:1});
			
		}
		
		public function resizeBarLoadAndTime():void
		{
			
			barLoad.width = barTime.width = amountLoaded * _stage.stageWidth;
			
		}
		
		
	}
}