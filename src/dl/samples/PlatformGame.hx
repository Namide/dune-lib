package dl.samples;
import dl.physic.body.Body;
import dl.physic.body.ShapeRect;
import dl.physic.contact.BodyContact.BodyContactsFlags;
import dl.physic.contact.SpaceGrid;
import dl.physic.move.BodyPhysic.BodyPhysicFlags;
import dl.physic.move.PlatformPhysicSystem;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;

/**
 * ...
 * @author Namide
 */

class Player extends Sprite
{
	public var body:Body;
	
	public function new( x:Int, y:Int )
	{
		super();
		
		this.x = x * PlatformGame.TILE_SIZE;
		this.y = y * PlatformGame.TILE_SIZE;
		
		var shape = new ShapeRect( PlatformGame.TILE_SIZE, PlatformGame.TILE_SIZE );
		body = new Body( shape, x * PlatformGame.TILE_SIZE, y * PlatformGame.TILE_SIZE );
		body.addBodyPhysic( BodyPhysicFlags.gravity | BodyPhysicFlags.dependant | BodyPhysicFlags.velocity );
		body.addBodyContact( BodyContactsFlags.active );
		
		graphics.beginFill( 0x0000CC );
		graphics.drawRect( 0, 0, PlatformGame.TILE_SIZE, PlatformGame.TILE_SIZE );
		graphics.endFill();
	}
	
	public function refresh()
	{
		this.x = body.x;
		this.y = body.y;
	}
}

class Floor extends Sprite
{
	public var body:Body;
	
	public function new( x:Int, y:Int )
	{
		super();
		
		this.x = x * PlatformGame.TILE_SIZE;
		this.y = y * PlatformGame.TILE_SIZE;
		
		var shape = new ShapeRect( PlatformGame.TILE_SIZE, PlatformGame.TILE_SIZE );
		body = new Body( shape, x * PlatformGame.TILE_SIZE, y * PlatformGame.TILE_SIZE );
		body.addBodyPhysic();
		body.addBodyContact( BodyContactsFlags.passive | BodyContactsFlags.fix | BodyContactsFlags.wall );
		
		graphics.beginFill( 0xCC0000 );
		graphics.drawRect( 0, 0, PlatformGame.TILE_SIZE, PlatformGame.TILE_SIZE );
		graphics.endFill();
	}	
}
 
class PlatformGame extends Sprite
{
	public static inline var TILE_SIZE:Int = 32;
	static var STAGE:Stage;
	
	var space:SpaceGrid;
	var physic:PlatformPhysicSystem;
	
	var player:Player;
	
	static function main() 
	{
		STAGE = Lib.current.stage;
		STAGE.scaleMode = StageScaleMode.NO_SCALE;
		STAGE.align = StageAlign.TOP_LEFT;
		
		new PlatformGame();
	}
	
	public function new() 
	{
		super();
		
		space = new SpaceGrid( TILE_SIZE, TILE_SIZE );
		physic = new PlatformPhysicSystem( 0.8 );
		
		for ( i in 0...5 )
		{
			var f = addFloor( i, 5 );
		}
		
		player = new Player( 1, 1 );
		physic.addBody( player.body );
		space.addBody( player.body );
		
		STAGE.addChild( player );
		STAGE.addEventListener( Event.ENTER_FRAME, refresh );
	}
	
	public function refresh( ?e:Dynamic )
	{
		physic.updateMoves();
		space.hitTest();
		physic.updatePositions();
		
		player.refresh();
	}
	
	public function addFloor( x:Int, y:Int)
	{
		var f = new Floor( x, y );
		STAGE.addChild( f );
		physic.addBody( f.body );
		space.addBody( f.body );
		return f;
	}
	
}