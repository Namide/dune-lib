package dl.utils;

import dl.utils.LevelGen.PlayerData;

typedef LevelFile = {
	var playerDatas:PlayerData;
	var tileSize:Float;
	var tilesDatas:Array<TileData>;
	var levelGrid:Array<UInt>;
}

typedef TileData = {
	var id:UInt;
	var contacts:BodyContactsFlags;
}

typedef PlayerData = {
	@:optional var i: Int;
	@:optional var n: String;
	@:optional var r: String;
	@:optional var rp: String;
}

/**
 * ...
 * @author Namide
 */
class LevelGen
{
	static var _MAIN:LevelGen;
	
	private function new() { }
	
	private static function getInstance():LevelGen
	{
		if (_MAIN == null)
			_MAIN = new LevelGen();
		
		return _MAIN;
	}
	
}