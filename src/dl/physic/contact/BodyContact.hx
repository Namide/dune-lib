package dl.physic.contact ;
import dl.physic.body.Body;
import dl.physic.body.Shape;

@:enum
abstract BodyLimitFlags(Int)
{
	var none = 0;
	var top = 1;
	var left = 2;
	var right = 4;
	var bottom = 8;
	
	inline function new( i:Int ) { this = i; }
	
	@:from
	public static function fromInt(i:Int):BodyLimitFlags {
		return new BodyLimitFlags(i);
	}
	
	@:to
	public function toInt():Int {
		return this;
	}
	
	@:op(A & B)
	public function and(b: BodyLimitFlags): BodyLimitFlags
	{
		return new BodyLimitFlags( this & b.toInt() );
	}
	
	@:op(A | B)
	public function or(b: BodyLimitFlags): BodyLimitFlags
	{
		return new BodyLimitFlags( this | b.toInt() );
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
	
	@:op(A & B)
	public function and(b: BodyContactState): BodyContactState
	{
		return new BodyContactState( this & b.toInt() );
	}
	
	@:op(A | B)
	public function or(b: BodyContactState): BodyContactState
	{
		return new BodyContactState( this | b.toInt() );
	}
}

@:enum
abstract BodyContactsFlags(Int)
{
	var none = 0;
	
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
	//var item = 128;
	
	/**
	 * Never move (like wall or floor)
	 */
	var fix = 256;
	
	/**
	 * Can be receive data moves out the physic engine.
	 * In example it can be push by an active object.
	 */
	var drivable = 512;
	
	
	inline function new( i:Int ) { this = i; }
	
	@:from
	public static function fromInt(i:Int):BodyContactsFlags {
		return new BodyContactsFlags(i);
	}
	
	@:to
	public function toInt():Int {
		return this;
	}
	
	@:op(A & B)
	public function and(b: BodyContactsFlags): BodyContactsFlags
	{
		return new BodyContactsFlags(this & b.toInt());
	}
	
	@:op(A | B)
	public function or(b: BodyContactsFlags): BodyContactsFlags
	{
		return new BodyContactsFlags( this | b.toInt() );
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
	
	public inline function push( body:Body ):Void { list.push( body ); }
	public inline function change( bodies:Array<Body> ):Void { list = bodies; }
	public inline function length():Int { return list.length; }
	
	public inline function classByArea():Void
	{
		list.sort( function( a:Body, b:Body ):Int {
			if ( parent.shape[0].getHitArea( a.shape[0] ) < parent.shape[0].getHitArea( b.shape[0] ) )
				return 1;
			return -1;
		} );
	}
	
	public static inline function classBodiesByContactArea( shape:Shape, list:Array<Body> ):Void
	{
		list.sort( function( a:Body, b:Body ):Int {
			if ( shape.getHitArea( a.shape[0] ) < shape.getHitArea( b.shape[0] ) )
				return 1;
			return -1;			
		} );
	}
	
	public inline function clear() {
		untyped list.length = 0;
		state = BodyContactState.init;
	}
}