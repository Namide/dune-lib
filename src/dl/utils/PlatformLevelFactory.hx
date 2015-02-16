package dl.utils;

import dl.input.PlatformPlayerController;
import dl.physic.body.Body;
import dl.physic.body.ShapeRect;
import dl.physic.contact.BodyContact.BodyContactsFlags;
import dl.physic.move.BodyPhysic.BodyPhysicFlags;
import dl.physic.move.PlatformPhysicSystem;

typedef PosGrid = {
	var i:Int;
	var j:Int;
}

typedef Pos = {
	var x:Float;
	var y:Float;
}

typedef LevelDatas = {
	var playerDatas:PlayerData;
	var tileSize:Float;
	var tilesDatas:Array<TileData>;
	var levelGrid:Array<Array<UInt>>;
}

typedef TileData = {
	var idFlag:UInt;						// must be a flag: 1, 2, 4, 8, 16, 32...
	var contacts:BodyContactsFlags;
	
	@:optional var graphic:Body->Void;
}

typedef PlayerData = {
	var runTileSec:Float;
	var jumpTileHeightMin:Float;
	var jumpTileHeightMax:Float;
	var jumpTileWidthMin:Float;
	var jumpTileWidthMax:Float;
	var posTile:Pos;
	var contacts:BodyContactsFlags;
	var physic:BodyPhysicFlags;
	var size:Pos;
	
	@:optional var graphic:Body->PlatformPlayerController->Void;
}

/**
 * Construct a platform level from a LevelDatas TypeDef
 * 
 * @author Namide
 */
class PlatformLevelFactory
{
	static var _MAIN:PlatformLevelFactory;
	
	private function new() { }
	
	public static function getInstance():PlatformLevelFactory
	{
		if (_MAIN == null)
			_MAIN = new PlatformLevelFactory();
		
		return _MAIN;
	}
	
	public function generate( levelData:LevelDatas, platformPhysicSystem:PlatformPhysicSystem )
	{
		if ( levelData.playerDatas != null )
			genPlayer( levelData.playerDatas, platformPhysicSystem.gY, levelData.tileSize );
		
		if ( levelData.levelGrid != null )
			genGrid( levelData.levelGrid, levelData.tilesDatas, levelData.tileSize );
	}
	
	public function genPlayer( playerData:PlayerData, gravity:Float, tileSize:Float )
	{
		var shape = new ShapeRect( playerData.size.x * tileSize, playerData.size.y * tileSize );
		var body = new Body( shape, playerData.posTile.x * tileSize, playerData.posTile.y * tileSize);
		body.addBodyPhysic( playerData.physic );
		body.addBodyContact( playerData.contacts );
		
		var playerControl = new PlatformPlayerController( body );
		playerControl.init( playerData.runTileSec * tileSize,
							playerData.jumpTileHeightMin * tileSize,
							playerData.jumpTileHeightMax * tileSize,
							playerData.jumpTileWidthMin * tileSize,
							playerData.jumpTileWidthMax * tileSize,
							gravity );
		
		if ( playerData.graphic != null )
			playerData.graphic( body, playerControl );
	}
	
	public function genGrid( grid:Array<Array<UInt>>, tilesData:Array<TileData>, size:Float )
	{
		for ( y in 0...grid.length )
		{
			for ( x in 0...grid[y].length )
			{
				var tile = getTileById( grid[y][x], tilesData );
				if ( tile != null )
				{
					var shape = new ShapeRect( size, size );
					var body = new Body( shape, x * size, y * size );
					body.addBodyPhysic();
					body.addBodyContact( tile.contacts );
					
					if ( tile.graphic != null )
						tile.graphic( body );
				}
			}			
		}
	}
	
	inline function getTileById( id:UInt, tilesData:Array<TileData> ):Null<TileData> {
		return Lambda.find( tilesData, function(a:TileData) { return a.idFlag & id != 0; } );
	}
	
}