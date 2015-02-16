package dl.render;

/**
 * ...
 * @author Namide
 */
class RenderHeaps
{
	public var engine : h3d.Engine;
	public var s3d : h3d.scene.Scene;
	public var s2d : h2d.Scene;
	
	public var onInit() Void->Void;
	
	public function new() 
	{
		hxd.System.start(function() {
			engine = new h3d.Engine();
			engine.onReady = setup;
			engine.init();
		});
	}
	
	function setup() {
		engine.onResized = s2d.checkResize;/*function() {
			s2d.checkResize();
			onResize();
		};*/
		s3d = new h3d.scene.Scene();
		s2d = new h2d.Scene();
		s3d.addPass(s2d);
		
		if ( onInit != null )
			onInit();
	}
	
	public function render( tSec:Float) {
		
		s2d.checkEvents();
		
		s2d.setElapsedTime(tSec / 60);
		s3d.setElapsedTime(tSec / 60);
		
		engine.render(s3d);
	}
}