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
		p = new Point( body.x, body.y );
		t = Math.random() * 500;
		d = StressTestSpaces.CIRCLE * 0.5 + Math.random() * StressTestSpaces.CIRCLE * 0.5;
	} 
}

class StressTestSpaces 
{
	public static inline var MAX:Int = 2048;
	public static inline var CIRCLE:Int = 22;
	static var m:StressTestSpaces;
	
	var datas:Array<Data>;
	var spaceG:SpaceGrid;
	var spaceS:SpaceSimple;
	var sprite:Sprite;
	
	var timesG:Array<Float>;
	var timesS:Array<Float>;
	
	var activeN:Int = 300;
	var passiveN:Int = 2000;
	
	var print:Bool = true;
	
	var t:Float;
	
	static function main() 
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		m = new StressTestSpaces();
	}
	
	public function new()
	{
		init();
	}
	
	function init()
	{
		t = 0;
		datas = [];
		spaceG = new SpaceGrid( 32, 32, 0, MAX + 20, 0, MAX + 20);
		spaceS = new SpaceSimple();
		sprite = new Sprite();
		timesG = [];
		timesS = [];
		
		for ( i in 0...passiveN )
		{
			var s2 = new ShapeRect( 20, 20 );
			var b2 = new Body(s2, Math.random() * MAX, Math.random() * MAX);
			b2.colliderType = BodyColliderFlags.passive;
			b2.physicType = BodyPhysicFlags.fix;
			var d2 = new Data(b2);
			//updatePos(d2);
			
			spaceG.addBody( b2 );
			spaceS.addBody( b2 );
		}
		
		for ( i in 0...activeN )
		{
			var s1 = new ShapeRect( 20, 20 );
			var b1 = new Body( s1, Math.random() * MAX, Math.random() * MAX );
			b1.colliderType = BodyColliderFlags.active;
			
			var d1 = new Data(b1);
			updatePos(d1);
			datas.push( d1 );
			
			spaceG.addBody( b1 );
			spaceS.addBody( b1 );
		}
		
		sprite.addEventListener( Event.ENTER_FRAME, refresh );
	}
	
	inline function updatePos( d:Data )
	{
		var pt = new Point();
		t += 1 / 60;//haxe.Timer.stamp();
		
		pt.x = d.p.x + d.d * Math.cos( d.t + t );
		pt.y = d.p.y + d.d * Math.sin( d.t + t );
		d.b.setPos( pt.x, pt.y );
		//d.b.updateAABB();
		
		return pt;
	}
	
	function refresh( d:Dynamic ):Void
	{
		// updates positions
		for ( d in datas )
			updatePos(d);
		
		// run test grid
		var t = haxe.Timer.stamp();
		var lg = spaceG.hitTest();
		timesG.push( (haxe.Timer.stamp() - t)*1000 );
		
		// updates positions
		for ( d in datas )
			updatePos(d);
		
		// run test simple
		t = haxe.Timer.stamp();
		var ls = spaceS.hitTest();
		timesS.push( (haxe.Timer.stamp() - t)*1000 );
		
		// calculate grid
		var averageG = 0.0;
		for ( f in timesG )
			averageG += f;
		averageG /= timesG.length;
		
		// calculate simple
		var averageS = 0.0;
		for ( f in timesS )
			averageS += f;
		averageS /= timesS.length;
		
		// trace results
		if (print)
		{
			trace( " " + activeN + " actives ; " + passiveN + " passives " );
			trace( 'grid: ' + lg.length + " col in - " + Math.round(timesG[timesG.length-1] * 100) / 100 /*+ " average:" + Math.round( averageG * 100 ) / 100*/ + " ms" );
			trace( 'simp: ' + ls.length + " col in - " + Math.round(timesS[timesS.length-1] * 100) / 100 /*+ " average:" + Math.round( averageS * 100 ) / 100*/ + " ms" );
			trace( '---' );
		}
		
	}
	
}