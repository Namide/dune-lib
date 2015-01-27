package dl.physic.contact ;
import dl.physic.body.Body;

@:enum
abstract BodyContactsFlags(Int)
{
	/**
	* This body don't test the collision but the actives bodies tests the collision with this one
	*/
	var passive = 1;
	
	/**
	* This body test the collision with the passives bodies
	*/
	var active = 2;
	
	/**
	* You can jump from bottom over a platform
	*/
	var platformBottom = 4;
	var platformTop = 8;
	var platformLeft = 16;
	var platformRight = 32;
	
	/**
	* You can't cross it
	*/
	var wall = 64;
	
	/**
	* You can climb it
	*/
	//var lader = 4;
	
	/**
	* Collision is activated, but not physic.
	* It's usable for life, ennemy, ammo...
	*/
	var item = 128;
	var fix = 256;
	
	inline function new( i:Int ) { this = i; }
	
	@:from
	public static function fromInt(i:Int):BodyContactsFlags {
		return new BodyContactsFlags(i);
	}
	
	@:to
	public function toInt():Int {
		return this;
	}
}

/**
 * ...
 * @author Namide
 */
class BodyContact
{
	public var parent:Body;
	public var list(default, default):Array<Body>;
	
	public var flags:BodyContactsFlags;
	
	public function new( p:Body ) 
	{
		parent = p;
		list = [];
	}
	
	/*public inline function hasType( type:BodyContactsFlags ):Bool {
		return hasTypeInA( type, list );
	}
	
	public inline function getByType( type:BodyContactsFlags ):Array<Body> {
		return list.filter( function( cb:Body ):Bool { return cb.colliderType & type == type; });
	}*/
	
	public inline function push( body:Body ):Void { list.push( body ); }
	public inline function length():UInt { return list.length; }
	
	public inline function clear() {
		untyped list.length = 0;
	}

	/*inline function hasTypeInA( type:BodyContactsFlags, a:Array<Body> ):Bool {
		return Lambda.exists( a, function(cp:Body):Bool { return cp.colliderType & type == type; });
	}*/
}