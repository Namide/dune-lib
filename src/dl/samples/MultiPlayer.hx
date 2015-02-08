package dl.samples;
import dl.socket.client.SockClientScan;
import dl.socket.client.SockClientUser;
import dl.socket.SockMsg.TransferDatasServer;
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
		
		/*graphics.clear();
		graphics.beginFill( color );
		graphics.drawRect( 0, 0, body.shape[0].getW(), body.shape[0].getH() );
		graphics.endFill();*/
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
	public static inline var USER_SCALE:Float = 0.8;
	static var STAGE:Stage;
	
	var time:Timer;
	var space:SpaceGrid;
	var physic:PlatformPhysicSystem;
	var sockets:SockClientScan;
	
	var playerMe:Player;
	var playerControl:PlatformPlayerController;
	
	var playerOther:Array<Player>;
	
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
		init();
	}
	
	public function addPlayer( id:Int, datas:Dynamic )
	{
		var s = new ShapeRect( datas.w, datas.h );
		var b = new Body( s, TILE_SIZE, TILE_SIZE );
		var p = new Player( b, datas.rgb, id );
		
		b.addBodyContact( BodyContactsFlags.passive | BodyContactsFlags.drivable | BodyContactsFlags.wall );
		b.addBodyPhysic( BodyPhysicFlags.none );
		b.name = "other";
		physic.addBody( b );
		b.physic.mass = datas.m;
		space.addBody( b );
		STAGE.addChild( p );
		playerOther.push( p );
	}
	
	public function removePlayer( player:Player )
	{
		var b = player.body;
		physic.removeBody( b );
		space.removeBody( b );
		STAGE.removeChild( player );
		playerOther.remove( player );
	}
	
	public function init()
	{
		space = new SpaceGrid( TILE_SIZE, TILE_SIZE );
		physic = new PlatformPhysicSystem( 2.0 );
		time = new Timer(50, 0);
		playerOther = [];
		
		// SOCKETS
		
		var scu = new SockClientUser();
		var o = {
			rgb:Math.round(Math.random() * 0xFFFFFF),
			w:Math.round(USER_SCALE * TILE_SIZE * (Math.random() * 0.8 + 0.5)),
			h:Math.round(USER_SCALE * TILE_SIZE * (Math.random() * 0.8 + 0.5)),
			m:Math.round( (Math.random() * 0.8 + 0.2) * 100 ) / 100
		};
		scu.datas = o;
		sockets = new SockClientScan( scu );
		
		var updatePlayersFct = function( list:Array<SockClientUser> )
		{
			for ( po in playerOther )
			{
				if ( !Lambda.exists( list, function(c:SockClientUser) { return c.id == po.id; } ) )
					removePlayer( po );
			}
			
			for ( scu in list )
			{
				if ( 	scu.id != playerMe.id &&
						!Lambda.exists( playerOther, function(c:Player) { return c.id == scu.id; } ) )
				{
					addPlayer( scu.id, scu.datas );
				}
			}
			
			//trace("me:"+playerMe.id, "otherLength:"+playerOther.length);
		}
		
		sockets.onOthers = updatePlayersFct;
		sockets.onRoom = function( s:String, other:Array<SockClientUser> ) { updatePlayersFct(other); }
		sockets.onConnected = function(me:SockClientUser)
		{
			/*var p:Player = Lambda.find( playerOther, function(pl:Player) { return pl.id == me.id; } );
			if ( p != null )
				removePlayer( p );*/
			playerMe.id = me.id;
		}
		
		sockets.onGame = function(tds:TransferDatasServer)
		{
			if ( tds.i == playerMe.id )
				return;
			
			var p:Player = Lambda.find( playerOther, function(pl:Player) { return pl.id == tds.i; } );
			var o:Dynamic = Json.parse( tds.d );
			
			if ( p == null )
				return;
			
			// {type:"pos", "x":playerMe.x, "y":playerMe.y}
			if ( o.type == "pos" )
			{
				p.body.setPos( o.x, o.y );
				p.x = o.x;
				p.y = o.y;
				
				p.body.contacts.fixedLimits = o.lim;
				//trace( p.body.physic.flags );
				
				//trace( p.body.contacts.fixedLimits );
				//lim:playerMe.body.contacts.fixedLimits
				//sockets.transfertData( "pos:" + playerMe.x + ";" + playerMe.y );
			}
		}
		
		sockets.onChat = flash.Lib.trace;
		
		
		
		
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
			posTile: { x:1, y:1 },
			physic: BodyPhysicFlags.gravity | BodyPhysicFlags.dependant | BodyPhysicFlags.velocity,
			contacts: BodyContactsFlags.drivable | BodyContactsFlags.active,
			size:{x:sockets.me.datas.w,y:sockets.me.datas.h},//{x:Math.round(USER_SCALE * TILE_SIZE),y:Math.round(USER_SCALE * TILE_SIZE)},
			graphic:function(b:Body, c:PlatformPlayerController)
			{
				b.name = "me";
				playerMe = new Player( b, sockets.me.datas.rgb );
				playerControl = c;
				physic.addBody( b );
				space.addBody( b );
				STAGE.addChild( playerMe );
			}
		}
		
		var tilesDatas:Array<TileData> = [
			{
				id: 1,
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
				id: 2,
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
		
		PlatformLevelGen.getInstance().generate( levelData, physic );
		playerMe.body.physic.mass = sockets.me.datas.m;
		
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
		//if ( playerOther.length > 0 )
		//	trace( playerOther[0].x, playerOther[0].y, playerOther[0].width );
		
		playerControl.update( dt );
		physic.updateMoves();
		space.hitTest();
		physic.updatePositions(space);
		
		if ( lastUpdateForFrame )
		{
			playerMe.refresh();
			
			if ( playerMe.id > -1 )
				sockets.transfertData( {type:"pos", "x":playerMe.x, "y":playerMe.y, lim:playerMe.body.contacts.fixedLimits} );
		}
		
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