package dl.samples;
import dl.utils.PlatformLevelGen;
import dl.utils.Timer;
import dl.physic.body.Body;
import dl.physic.body.ShapeRect;
import dl.physic.contact.BodyContact.BodyContactsFlags;
import dl.physic.contact.SpaceGrid;
import dl.input.PlatformPlayerController;
import dl.physic.move.BodyPhysic.BodyPhysicFlags;
import dl.physic.move.PlatformPhysicSystem;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;
import haxe.Constraints.Function;

class Floor extends Sprite
{
	public function new( body:Body )
	{
		super();
		
		this.x = body.x;
		this.y = body.y;
		
		graphics.beginFill( 0xCC0000 );
		graphics.drawRect( 0, 0, body.shape.getW(), body.shape.getH() );
		graphics.endFill();
	}	
}

class Player extends Floor
{
	public var body:Body;
	
	public function new( body:Body )
	{
		super( body );
		this.body = body;
		
		graphics.clear();
		graphics.beginFill( 0x00CC00 );
		graphics.drawRect( 0, 0, body.shape.getW(), body.shape.getH() );
		graphics.endFill();
	}
	
	public function refresh()
	{
		this.x = body.x;
		this.y = body.y;
	}
}

/**
 * ...
 * @author Namide
 */
class MultiPlayer extends Sprite
{
	public static inline var TILE_SIZE:Int = 32;
	static var STAGE:Stage;
	
	var time:Timer;
	var space:SpaceGrid;
	var physic:PlatformPhysicSystem;
	
	var player:Player;
	var playerControl:PlatformPlayerController;
	
	static function main() 
	{
		STAGE = Lib.current.stage;
		STAGE.scaleMode = StageScaleMode.NO_SCALE;
		STAGE.align = StageAlign.TOP_LEFT;
		
		new MultiPlayer();
	}
	
	public function new() 
	{
		super();
		
		/*for ( i in 0...5 )
			addFloor( i, 5 );
		
		addFloor( 2, 4 );*/
		init();
		
	}
	
	public function init()
	{
		space = new SpaceGrid( TILE_SIZE, TILE_SIZE );
		physic = new PlatformPhysicSystem( 2.0 );
		time = new Timer(50, 0);
		
		// ENUM GENERATION
		
		var levelGrid:Array<Array<UInt>> = [
			[2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2],
			[2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2],
			[2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2],
			[2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2],
			[2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 2],
			[2, 0, 0, 0, 0, 1, 1, 1, 0, 0, 2, 0, 0, 0, 1, 2],
			[2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 1, 2],
			[2, 1, 1, 1, 0, 0, 0, 0, 0, 0, 2, 1, 1, 0, 0, 2],
			[0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 2, 0, 0, 0, 0, 2],
			[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			[0, 0, 0, 0, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			[0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
		];
		
		var playerDatas:PlayerData = {
			runTileSec: 12,
			jumpTileHeightMin: 1.5,
			jumpTileHeightMax: 3,
			jumpTileWidthMin: 3,
			jumpTileWidthMax: 6,
			posTile: {x:1,y:1},
			contacts: BodyPhysicFlags.gravity | BodyPhysicFlags.dependant | BodyPhysicFlags.velocity,
			size:{x:0.8,y:0.8},
			graphic:function(b:Body, c:PlatformPlayerController)
			{
				player = new Player( b );
				playerControl = c;
				physic.addBody( b );
				space.addBody( b );
				STAGE.addChild( player );
			}
		}
		
		var tilesDatas:Array<TileData> = [
			{
				id: 1,
				contacts: BodyContactsFlags.passive | BodyContactsFlags.fix | BodyContactsFlags.platformTop,
				graphic:function(b:Body)
				{
					var floor = new Floor( b );
					physic.addBody( b );
					space.addBody( b );
					STAGE.addChild( floor );
				}
			},
			{
				id: 2,
				contacts: BodyContactsFlags.passive | BodyContactsFlags.fix | BodyContactsFlags.wall,
				graphic:function(b:Body)
				{
					var floor = new Floor( b );
					physic.addBody( b );
					space.addBody( b );
					STAGE.addChild( floor );
				}
			}
		
		];
		
		var levelData:LevelDatas = { levelGrid:levelGrid, playerDatas:playerDatas, tilesDatas:tilesDatas, tileSize:32 };
		
		
		PlatformLevelGen.getInstance().generate( levelData, physic );
		
		
		
		
		
		
		
		/*runPxSec:Float = 12 * 32, 
		jumpHeightMin:Float = 1.5 * 32,
		jumpHeightMax:Float = 3 * 32,
		jumpLength:Float = 6 * 32*/
		// BodyPhysicFlags.gravity | BodyPhysicFlags.dependant | BodyPhysicFlags.velocity 
		
		time.onFrameUpdate = refresh;
		
		
		// BodyContactsFlags.passive | BodyContactsFlags.fix | BodyContactsFlags.platformTop
	}
	
	public function refresh( dt:Float, lastUpdateForFrame:Bool )
	{
		playerControl.update( dt );
		physic.updateMoves();
		space.hitTest();
		physic.updatePositions(space);
		
		if ( lastUpdateForFrame )
			player.refresh();
		
		//trace( (haxe.Timer.stamp() - t) + "s" );
	}
	
	/*public function addFloor( x:Int, y:Int)
	{
		var f = new Floor( x, y );
		STAGE.addChild( f );
		physic.addBody( f.body );
		space.addBody( f.body );
		return f;
	}*/
	
}