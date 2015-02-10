package dl.samples;
import dl.samples.LevelGeneration.Player;
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
import flash.Lib;
import haxe.Constraints.Function;

/**
 * ...
 * @author Namide
 */

/**
 * Sprite of walls and floors (fix)
 */
class Floor extends Sprite
{
	public function new( body:Body, color:UInt )
	{
		super();
		
		this.x = body.x;
		this.y = body.y;
		
		graphics.beginFill( color );
		graphics.drawRect( 0, 0, body.shape[0].getW(), body.shape[0].getH() );
		graphics.endFill();
	}	
}

/**
 * Graphic sprite for player (movable)
 */
class Player extends Floor
{
	public var body:Body;
	
	public function new( body:Body, color:UInt )
	{
		super( body, color );
		this.body = body;
	}
	
	public function refresh()
	{
		this.x = Math.round(body.x);
		this.y = Math.round(body.y);
	}
}

/**
 * Main class
 */
class LevelGeneration extends Sprite
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
		
		new LevelGeneration();
	}
	
	public function new() 
	{
		super();
		init();
	}
	
	public function init()
	{
		space = new SpaceGrid( TILE_SIZE, TILE_SIZE );
		physic = new PlatformPhysicSystem( 2.0 );
		time = new Timer(50, 0);
		
		var levelData:LevelDatas = {
			tileSize: TILE_SIZE,
			levelGrid: [
				[2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2],
				[2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2],
				[2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2],
				[2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2],
				[2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 2],
				[2, 0, 0, 0, 0, 1, 1, 1, 0, 0, 2, 0, 0, 0, 1, 2],
				[2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 2],
				[2, 1, 1, 1, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 2],
				[2, 0, 0, 0, 0, 0, 0, 1, 1, 1, 2, 0, 1, 0, 0, 2],
				[2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2],
				[2, 0, 0, 0, 2, 1, 0, 0, 0, 0, 0, 0, 2, 1, 1, 2],
				[2, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 2],
				[2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 0, 0, 2],
				[2, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 2],
				[2, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 2],
				[2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2],
				[2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 2],
				[2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2],
				[2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2],
				[2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2]
			],
			playerDatas: {
				runTileSec: 12,
				jumpTileHeightMin: 1.5,
				jumpTileHeightMax: 3,
				jumpTileWidthMin: 3,
				jumpTileWidthMax: 6,
				posTile: {x:1, y:1},
				contacts: BodyContactsFlags.active,
				physic: BodyPhysicFlags.gravity | BodyPhysicFlags.dependant | BodyPhysicFlags.velocity,
				size:{x:0.75, y:0.75},
				graphic:function(b:Body, c:PlatformPlayerController) {
					player = new Player( b, 0x53f852 );
					playerControl = c;
					physic.addBody( b );
					space.addBody( b );
					STAGE.addChild( player );
				}
			},
			tilesDatas: [ {
					id: 1,
					contacts: BodyContactsFlags.passive | BodyContactsFlags.fix | BodyContactsFlags.platformTop,
					graphic:function(b:Body) {
						var floor = new Floor( b, 0x2dbe1f );
						physic.addBody( b );
						space.addBody( b );
						STAGE.addChild( floor );
					}
				},
				{
					id: 2,
					contacts: BodyContactsFlags.passive | BodyContactsFlags.fix | BodyContactsFlags.wall,
					graphic:function(b:Body) {
						var floor = new Floor( b, 0x3bdf2b );
						physic.addBody( b );
						space.addBody( b );
						STAGE.addChild( floor );
					}
				}
			]
		}
		
		PlatformLevelGen.getInstance().generate( levelData, physic );
		
		time.onFrameUpdate = refresh;
	}
	
	public function refresh( dt:Float, lastUpdateForFrame:Bool )
	{
		playerControl.update( dt );
		physic.updateMoves();
		space.hitTest();
		physic.updatePositions(space);
		
		if ( lastUpdateForFrame )
		{
			player.refresh();
			if ( player.body.y > 1024 )
			{
				player.body.setPos( TILE_SIZE, TILE_SIZE );
				player.body.physic.vX =
				player.body.physic.vY = 0;
			}
		}
	}
}