package dl.samples ;

import dl.physic.body.Body;
import dl.physic.body.ShapeRect;
import dl.physic.space.SpaceGrid;
import dl.physic.space.SpaceSimple;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.geom.Point;
import flash.Lib;
import haxe.Timer;

/**
 * ...
 * @author Namide
 */

class Data
{
	public var b:Body;
	public var p:Point;
	public var d:Float;
	public var t:Float;
	
	public function new( body:Body )
	{
		b = body;
		p = new Point( Math.random() * 500, Math.random() * 500 );
		t = Math.random() * 500;
		d = 50 + Math.random() * 100;
	} 
}

class TestSpaces 
{
	var spaceG:SpaceGrid;
	var spaceS:SpaceSimple;
	
	static var m:TestSpaces;
	
	static function main() 
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		m = new TestSpaces();
	}
	
	public function new()
	{
		init();
	}
	
	function init()
	{
		spaceG = new SpaceGrid( 32, 32, -1024, 1024, -1024, 1024 );
		spaceS = new SpaceSimple();
		
		// ACTIVE
			var s1 = new ShapeRect( 20, 20 );
			var b1 = new Body( s1, Math.random() * 1024, Math.random() * 1024 );
			b1.colliderType = BodyColliderFlags.active;
			
			var d1 = new Data(b1);
			
			spaceG.addBody( b1 );
			spaceS.addBody( b1 );
		
		
		// PASSIVE
			var s2 = new ShapeRect( 20, 20 );
			var b2 = new Body(s2, Math.random() * 1024, Math.random() * 1024);
			b2.colliderType = BodyColliderFlags.passive;
			b2.physicType = BodyPhysicFlags.fix;
			var d2 = new Data(b2);
			
			spaceG.addBody( b2 );
			spaceS.addBody( b2 );
		
		var lg = spaceG.hitTest();
		var ls = spaceS.hitTest();
		
		trace( 'grid: ' + lg.length + " col " );
		trace( 'simp: ' + ls.length + " col " );
	}
	
}