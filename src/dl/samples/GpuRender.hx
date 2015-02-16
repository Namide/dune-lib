package dl.samples;
import dl.socket.client.SockClientScan;
import dl.socket.client.SockClientUser;
import dl.socket.SockMsg.TransferDatasServer;
import dl.utils.PlatformLevelFactory;
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
import haxe.Json;

class Floor extends Sprite
{
	public function new( body:Body, color:Int )
	{
		super();
		
		this.x = body.x;
		this.y = body.y;
		
		graphics.beginFill( color );
		graphics.drawRect( 0, 0, body.shape[0].getW(), body.shape[0].getH() );
		graphics.endFill();
	}	
}

class Player extends Floor
{
	public var body:Body;
	public var id:Int;
	
	public function new( body:Body, color:Int, id:Int = -1 )
	{
		super( body, color );
		
		this.body = body;
		this.id = id;
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
class GpuRender extends Sprite
{
	public static inline var TILE_SIZE:Int = 32;
	public static inline var USER_SCALE:Float = 0.8;
	
	static var STAGE:Stage;
	
	var time:Timer;
	var space:SpaceGrid;
	var physic:PlatformPhysicSystem;
	
	var playerMe:Player;
	var playerControl:PlatformPlayerController;
	
	static function main() 
	{
		STAGE = Lib.current.stage;
		STAGE.scaleMode = StageScaleMode.NO_SCALE;
		STAGE.align = StageAlign.TOP_LEFT;
		
		new GpuRender();
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
		
		initLevel();
		time.onFrameUpdate = refresh;
	}
	
	function initLevel()
	{
		var levelGrid:Array<Array<UInt>> = [
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
		];
		
		var playerDatas:PlayerData = {
			runTileSec: 12,
			jumpTileHeightMin: 1.5,
			jumpTileHeightMax: 3,
			jumpTileWidthMin: 3,
			jumpTileWidthMax: 6,
			posTile: { x:1, y:1 },
			physic: BodyPhysicFlags.gravity | BodyPhysicFlags.dependant | BodyPhysicFlags.velocity,
			contacts: BodyContactsFlags.drivable | BodyContactsFlags.active,
			size:{x:0.5,y:0.7},
			graphic:function(b:Body, c:PlatformPlayerController)
			{
				playerMe = new Player( b, 0x888800 );
				playerControl = c;
				physic.addBody( b );
				space.addBody( b );
				STAGE.addChild( playerMe );
			}
		}
		
		var tilesDatas:Array<TileData> = [
			{
				idFlag: 1,
				contacts: BodyContactsFlags.passive | BodyContactsFlags.fix | BodyContactsFlags.platformTop,
				graphic:function(b:Body)
				{
					var floor = new Floor( b, 0xDD0000 );
					physic.addBody( b );
					space.addBody( b );
					STAGE.addChild( floor );
				}
			},
			{
				idFlag: 2,
				contacts: BodyContactsFlags.passive | BodyContactsFlags.fix | BodyContactsFlags.wall,
				graphic:function(b:Body)
				{
					var floor = new Floor( b, 0xDD00DD );
					physic.addBody( b );
					space.addBody( b );
					STAGE.addChild( floor );
				}
			}
		
		];
		
		var levelData:LevelDatas = { levelGrid:levelGrid, playerDatas:playerDatas, tilesDatas:tilesDatas, tileSize:32 };
		
		PlatformLevelFactory.getInstance().generate( levelData, physic );
	}
	
	function refresh( dt:Float, lastUpdateForFrame:Bool )
	{
		playerControl.update( dt );
		physic.updateMoves();
		space.hitTest();
		physic.updatePositions(space);
		
		if ( lastUpdateForFrame )
			playerMe.refresh();
	}
}