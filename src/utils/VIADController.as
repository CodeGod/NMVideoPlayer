package utils
{
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class VIADController extends Sprite
	{
		
		public static var videoConstructor:NMVideoConstructor;
		public static var playerObjects:NMPlayerObjects;
		
		private var container:Sprite;
		private var bg:Sprite;
		private var config:Object;
		private var viad:VIADLoader;
		private var viadState:String;
		private var sect:String;
		private var id:int;
		private var timerUserEvent:Timer;
		
		public function VIADController(cont:Sprite, postbg:Sprite, section:String, sectID:int)
		{
			
			this.container = cont;
			this.bg = postbg;
			this.sect = section;
			this.id = sectID;
			
			NMVideoFullscreen.viad = this;
			
			config = {section_postroll:sect, volume:0.5};
			
			viad = new VIADLoader();
			container.addChild(viad);
			
			viad.addEventListener(VIADEvent.INITIALIZED, loaderInitialized);
			viad.addEventListener(VIADEvent.READY, adReady);
			viad.addEventListener(VIADEvent.OVER, adOver);
			viad.addEventListener(VIADEvent.ERROR, adError);
			
			try {
				
				viad.init(config);
				
			} catch (error:SecurityError) {
				
				securityErrorHandler();
				
			}
			
			bg.visible = false;
			
			timerUserEvent = new Timer(1000);
			timerUserEvent.addEventListener(TimerEvent.TIMER, fireEvent);
			
		}
		
		private function securityErrorHandler():void
		{
			
		}
		
		private function loaderInitialized(event:VIADEvent):void
		{
			
			viad.prepareSection("postroll");
			
		}
		
		private function adReady(event:VIADEvent):void
		{
			
			if (event.data != null) {
				
				//event.data;
				//event.data.width;
				//event.data.height;
				//event.data.url;
				//event.data.type;
				
				viadState = "READY";
				
			} else {
				
				viadState = "FAIL";
				
			}
			
		}
		
		private function adOver(event:VIADEvent):void
		{
			
			viad.abortSection();
			
			bg.visible = false;
			
			videoConstructor.detectViadSections(id);
			videoConstructor.postrollEnd();
			
		}
		
		private function adError(event:VIADEvent):void
		{
			
			viad.abortSection();
			
			bg.visible = false;
			
		}
		
		public function postrollStart():void
		{
			
			if (viadState == "READY") {
				
				viad.startSection();
				
				bg.visible = true;
				
				timerUserEvent.start();
				
			}
			
		}
		
		private function fireEvent(event:TimerEvent):void
		{
			
			videoConstructor.postrollStart();
			timerUserEvent.stop();
			
		}
		
		public function resizePostroll(postW:int, postH:int):void
		{
			
			viad.resize(postW, postH);
			
		}
		
		
		
	}
}