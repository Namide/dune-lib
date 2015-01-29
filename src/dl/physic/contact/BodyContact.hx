package dl.physic.contact ;
import dl.physic.body.Body;
import dl.physic.body.Shape;

@:enum
abstract BodyLimitFlags(Int)
{
	var none = 0;
	var top = 1;
	var left = 2;
	var right = 3;
	var bottom = 4;
	
	inline function new( i:Int ) { this = i; }
	
	@:from
	public static function fromInt(i:Int):BodyLimitFlags {
		return new BodyLimitFlags(i);
	}
	
	@:to
	public function toInt():Int {
		return this;
	}
}

@:enum
abstract BodyContactState(Int)
{
	var init = 0;
	var contacts = 1;
	var limits = 2;
	
	inline function new( i:Int ) { this = i; }
	
	@:from
	public static function fromInt(i:Int):BodyContactState {
		return new BodyContactState(i);
	}
	
	@:to
	public function toInt():Int {
		return this;
	}
}

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
	public var state:BodyContactState;
	
	public var flags:BodyContactsFlags;
	
	public var fixedLimits:BodyLimitFlags;
	
	public function new( p:Body ) 
	{
		parent = p;
		list = [];
		state = BodyContactState.init;
		fixedLimits = BodyLimitFlags.none;
	}
	
	/*public inline function hasType( type:BodyContactsFlags ):Bool {
		return hasTypeInA( type, list );
	}
	
	public inline function getByType( type:BodyContactsFlags ):Array<Body> {
		return list.filter( function( cb:Body ):Bool { return cb.colliderType & type == type; });
	}*/
	
	public inline function push( body:Body ):Void { list.push( body ); }
	public inline function change( bodies:Array<Body> ):Void { list = bodies; }
	public inline function length():Int { return list.length; }
	
	public function classByArea():Array<Body>
	{
		list.sort( function( a:Body, b:Body ):Int {
			if ( parent.shape.getHitArea( a.shape ) < parent.shape.getHitArea( b.shape ) )
				return 1;
			return -1;			
		} );
		return list;
	}
	
	/*public inline function getHitArea( b:Shape ):Float
	{
		BodyContact._getArea( this, b );
	}*/
	
	
	
	public inline function clear() {
		untyped list.length = 0;
		state = BodyContactState.init;
		fixedLimits = BodyLimitFlags.none;
	}

	/*inline function hasTypeInA( type:BodyContactsFlags, a:Array<Body> ):Bool {
		return Lambda.exists( a, function(cp:Body):Bool { return cp.colliderType & type == type; });
	}*/
	
	
}