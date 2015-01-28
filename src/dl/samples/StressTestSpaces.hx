package dl.samples ;

import dl.physic.body.Body;
import dl.physic.body.ShapeRect;
import dl.physic.contact.BodyContact.BodyContactsFlags;
import dl.physic.contact.SpaceGrid;
import dl.physic.contact.SpaceSimple;
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
	public static inline var MAX_SIZE:Int = 2048;
	public static inline var CIRCLE:Int = 22;
	
	public static inline var TEST_GRID:Bool = true;
	public static inline var TEST_SIMPLE:Bool = false;
	
	public static inline var activeN:Int = 2000;
	public static inline var passiveN:Int = 2000;
	
	static var m:StressTestSpaces;
	
	var datas:Array<Data>;
	var spaceG:SpaceGrid;
	var spaceS:SpaceSimple;
	var sprite:Sprite;
	
	var timesG:Array<Float>;
	var timesS:Array<Float>;
	
	
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
		spaceG = new SpaceGrid( 32, 32, 0, MAX_SIZE + 20, 0, MAX_SIZE + 20);
		spaceS = new SpaceSimple();
		sprite = new Sprite();
		timesG = [];
		timesS = [];
		
		for ( i in 0...passiveN )
		{
			var s2 = new ShapeRect( 20, 20 );
			var b2 = new Body(s2, Math.random() * MAX_SIZE, Math.random() * MAX_SIZE);
			b2.addBodyContact( BodyContactsFlags.passive | BodyContactsFlags.fix );
			var d2 = new Data(b2);
			
			spaceG.addBody( b2 );
			spaceS.addBody( b2 );
		}
		
		for ( i in 0...activeN )
		{
			var s1 = new ShapeRect( 20, 20 );
			var b1 = new Body( s1, Math.random() * MAX_SIZE, Math.random() * MAX_SIZE );
			b1.addBodyContact( BodyContactsFlags.active );
			//b1.contacts.flags = BodyContactsFlags.active;
			
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
		t += 1 / 60;
		pt.x = d.p.x + d.d * Math.cos( d.t + t );
		pt.y = d.p.y + d.d * Math.sin( d.t + t );
		d.b.setPos( pt.x, pt.y );
		return pt;
	}
	
	function refresh( d:Dynamic ):Void
	{
		var t = 0.0;
		
		if (print)
			trace( " " + activeN + " actives ; " + passiveN + " passives " );
		
		// calculate grid
		if ( TEST_GRID )
		{
			// run test grid
			t = haxe.Timer.stamp();
			var lg = spaceG.hitTest();
			timesG.push( (haxe.Timer.stamp() - t)*1000 );
			
			// updates positions
			for ( d in datas )
				updatePos(d);
				
			var averageG = 0.0;
			for ( f in timesG )
				averageG += f;
			averageG /= timesG.length;
			
			if (print)
				trace( 'grid: ' + lg.length + " col in - " + Math.round(timesG[timesG.length-1] * 100) / 100 /*+ " average:" + Math.round( averageG * 100 ) / 100*/ + " ms" );
		}
		
		// calculate simple
		if ( TEST_SIMPLE )
		{
			// run test simple
			t = haxe.Timer.stamp();
			var ls = spaceS.hitTest();
			timesS.push( (haxe.Timer.stamp() - t)*1000 );
			
			// updates positions
			for ( d in datas )
				updatePos(d);
			
			var averageS = 0.0;
			for ( f in timesS )
				averageS += f;
			averageS /= timesS.length;
			
			if (print)
				trace( 'simp: ' + ls.length + " col in - " + Math.round(timesS[timesS.length-1] * 100) / 100 /*+ " average:" + Math.round( averageS * 100 ) / 100*/ + " ms" );
		}
		
		if (print)
			trace( " --- " );
		
	}
	
}