package dl.physic.body ;
import dl.physic.body.ShapePoint;

@:enum
abstract BodyType(Int)
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
	
	/**
	* Your solid reacts with passives bodies (platform, wall, ladder)
	*/
	var mover = 256;
	
	//public inline static var SOLID_TYPE_EATER:UInt = 32;
	
	inline function new( i:Int ) { this = i; }
	
	@:from
	public static function fromInt(i:Int):BodyType {
		return new BodyType(i);
	}
	
	@:to
	public function toUInt():Int {
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

	public var type:BodyType;
	
	public var x(default, null):Float;
	public var y(default, null):Float;
	public var moved(default, null):Bool;
	
	/*public var x(default, null):Float;
	public var y(default, null):Float;
	
	public var lx(default, null):Float;
	public var ly(default, null):Float;
	
	public var moved:Bool;*/
	//var _lastPosX:Float;
	//var _lastPosY:Float;
	
	//public var insomniac(default, default):Bool = false;
	
	public function new( shape:Shape ) 
	{
		type = 0 | BodyType.passive;
		//moved = false;
		this.shape = shape;
		this.print = shape.clone();
		this.contacts = new BodyContact( this );
	}
	
	public inline function setPos( x:Float, y:Float )
	{
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
		if ( !moved )
			return;
			
		var t = print;
		print = shape;
		t.updateAABB( x, y );
		shape = t;
		moved = false;
	}
	
	/*public inline function moved():Bool {
		return shape.moved;
	}*/
	
	public function toString() {
		return "[Body"+type+" x:" + shape.aabbXMin + " y:" + shape.aabbYMin + " " + shape +"]";
	}
	
	
	
	
}