package utils
{
	import flash.display.Sprite;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	public class NMPostroll extends Sprite
	{
		
		public static var videoConstructor:NMVideoConstructor;
		public static var playerObjects:NMPlayerObjects;
		
		private var container:Sprite;
		private var bg:Sprite;
		private var vid:Video;
		private var nc:NetConnection;
		private var ns:NetStream;
		
		public function NMPostroll(cont:Sprite, postbg:Sprite)
		{
			
			this.container = cont;
			this.bg = postbg;
			
			NMVideoFullscreen.postroll = this;
			
			bg.visible = false;
			
			nc = new NetConnection();
			nc.connect(null);
			ns = new NetStream(nc);
			ns.addEventListener(IOErrorEvent.IO_ERROR, ioError);
			ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			ns.bufferTime = 0.5;
			ns.client = this;
			ns.checkPolicyFile = true;
			
			vid = new Video(16, 9);
			vid.attachNetStream(ns);
			vid.smoothing = true;
			
			ns.play("");
			
			ns.seek(0);
			ns.pause();
			
		}
		
		
		public function postrollStart():void
		{
			
			//playerObjects.traceMessage("POSTROLL");
			
		}
		
		private function netStatusHandler(event:NetStatusEvent):void
		{
			
			switch (event.info.code) {
				
				case "NetStream.Play.StreamNotFound" :
					break;
				case "NetStream.Play.Start" :
					//streamStart();
					break;
				case "NetStream.Play.Stop" :
					streamEnd();
					break;
				
			}
			
		}
		
		private function ioError(event:IOErrorEvent):void
		{
			
			
			
		}
		
		private function streamEnd():void
		{
			
			
			
		}
		
		public function resizePostroll(postW:int, postH:int):void
		{
			
			
			
		}
		
		
		
	}
}