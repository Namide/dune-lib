package dl;

import dl.physic.body.Body;
import dl.physic.body.ShapeRect;
import dl.physic.space.SpaceGrid;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;

/**
 * ...
 * @author Namide
 */

class Main 
{
	
	static function main() 
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		
		new Main();
	}
	
	public function new()
	{
		var s1 = new ShapeRect( 10, 10 );
		var b1 = new Body(s1);
		b1.type = BodyType.active;
		
		var s2 = new ShapeRect( 10, 10 );
		var b2 = new Body(s2);
		b2.type = BodyType.passive;
		
		b1.updatePos( 5, 5 );
		b2.updatePos( 10, 10 );
		
		var sg = new SpaceGrid( 32, 32 );
		sg.addBody( b1 );
		sg.addBody( b2 );
		
		trace( b1 );
		trace( b2 );
		trace( b1.shape.hitTest(b2.shape) );
		
		
		trace( sg.hitTest() );
	}
	
}