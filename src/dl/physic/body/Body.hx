package dl.physic.body ;
import dl.physic.body.ShapePoint;

@:enum
abstract BodyColliderFlags(Int)
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
	
	inline function new( i:Int ) { this = i; }
	
	@:from
	public static function fromInt(i:Int):BodyColliderFlags {
		return new BodyColliderFlags(i);
	}
	
	@:to
	public function toInt():Int {
		return this;
	}
}

@:enum
abstract BodyPhysicFlags(Int)
{
	/**
	 * Your body never move
	 */
	var fix = 1;
	
	/**
	* Your solid reacts with passives bodies (platform, wall, ladder)
	*/
	var dependant = 2;
	
	inline function new( i:Int ) { this = i; }
	
	@:from
	public static function fromInt(i:Int):BodyPhysicFlags {
		return new BodyPhysicFlags(i);
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
class Body
{
	/**
	* Delimit the shape of this body
	*/
	public var shape(default, default):Shape;
	public var print(default, default):Shape;
	
	/**
	* Other body in contact with this one
	*/
	public var contacts(default, null):BodyContact;

	public var colliderType:BodyColliderFlags;
	public var physicType:BodyPhysicFlags;
	
	public var x(default, null):Float;
	public var y(default, null):Float;
	public var moved(default, null):Bool;
	
	public function new( shape:Shape, x:Float = 0, y:Float = 0 ) 
	{
		colliderType = 0 | BodyColliderFlags.passive;
		this.shape = shape;
		this.contacts = new BodyContact( this );
		
		this.x = x;
		this.y = y;
		shape.updateAABB( x, y );
		this.print = shape.clone();
	}
	
	public inline function setPos( x:Float, y:Float )
	{
		#if (debug)
		
			if ( physicType & BodyPhysicFlags.fix != 0 )
				throw "Can't move a fix body!";
				
		#end
		
		var m = (x != this.x && y != this.y);
		
		if ( m )
		{
			this.x = x;
			this.y = y;
			moved = true;
		}
	}
	
	public function updateAABB()
	{
		#if (debug)
		
			if ( physicType & BodyPhysicFlags.fix != 0 )
				throw "Can't updateAABB() a fix body!";
				
		#end
		
		if ( !moved )
			return;
			
		var t = print;
		print = shape;
		
		t.updateAABB( x, y );
		shape = t;
		moved = false;
	}
	
	public function toString() {
		return "[Body"+colliderType+" x:" + x + " y:" + y + " " + shape +"]";
	}
	
	
	
	
}