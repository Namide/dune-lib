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
	
	function getB1()
	{
		var s1 = new ShapeRect( 32, 32 );
		var b1 = new Body( s1, 0, 0 );
		b1.colliderType = BodyColliderFlags.active;
		return b1;
	}
	
	function getB2()
	{
		var s2 = new ShapeRect( 20, 20 );
		var b2 = new Body( s2, 32, 32 );
		b2.colliderType = BodyColliderFlags.passive;
		b2.physicType = BodyPhysicFlags.fix;
		return b2;
	}
	
	function getB3()
	{
		var s2 = new ShapeRect( 20, 20 );
		var b2 = new Body( s2, 16, 16 );
		b2.colliderType = BodyColliderFlags.passive;
		b2.physicType = BodyPhysicFlags.fix;
		return b2;
	}
	
	function init()
	{
		spaceG = new SpaceGrid( 32, 32 );
		spaceS = new SpaceSimple();
		
		// ACTIVE
			
			spaceG.addBody( getB1() );
			spaceS.addBody( getB1() );
			
		
		// PASSIVE
		
			spaceG.addBody( getB2() );
			spaceS.addBody( getB2() );
			spaceG.addBody( getB3() );
			spaceS.addBody( getB3() );
			
		
		var lg = spaceG.hitTest();
		var ls = spaceS.hitTest();
		
		trace( 'grid: ' + lg.length + " col " );
		trace( 'simp: ' + ls.length + " col " );
	}
	
}