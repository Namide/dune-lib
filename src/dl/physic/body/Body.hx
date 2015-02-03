package dl.physic.body ;
import dl.physic.body.ShapePoint;
import dl.physic.contact.BodyContact;
import dl.physic.move.BodyPhysic;

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
	public var physic(default, null):BodyPhysic;
	
	
	//public var colliderType:BodyContactsFlags;
	//public var physicType:BodyPhysicFlags;
	
	public var x(default, null):Float;
	public var y(default, null):Float;
	
	/*public var vX(default, null):Float;
	public var vY(default, null):Float;
	public var mass(default, null):Float;*/
	
	public var moved(default, null):Bool;
	
	public function new( shape:Shape, x:Float = 0, y:Float = 0 ) 
	{
		//colliderType = 0 | BodyContactsFlags.passive;
		this.shape = shape;
		this.contacts = new BodyContact( this );
		
		this.x = x;
		this.y = y;
		shape.updateAABB( x, y );
		this.print = shape.clone();
		moved = true;
	}
	
	public function setPos( x:Float, y:Float )
	{
		#if (debug)
			
			if ( contacts != null &&
				 contacts.flags & BodyContactsFlags.fix != 0 )
				throw "Can't move a fix body!";
			
		#end
		
		var m = (x != this.x || y != this.y);
		if ( m )
		{
			this.x = x;
			this.y = y;
			moved = true;
		}
	}
	
	public function setX( x:Float )
	{
		#if (debug)
			
			if ( contacts != null &&
				 contacts.flags & BodyContactsFlags.fix != 0 )
				throw "Can't move a fix body!";
			
		#end
		
		var m = x != this.x;
		if ( m )
		{
			this.x = x;
			moved = true;
		}
	}
	
	public function setY( y:Float )
	{
		#if (debug)
			
			if ( contacts != null &&
				 contacts.flags & BodyContactsFlags.fix != 0 )
				throw "Can't move a fix body!";
			
		#end
		
		var m = y != this.y;
		if ( m )
		{
			this.y = y;
			moved = true;
		}
	}
	
	public function addPos( x:Float, y:Float )
	{
		#if (debug)
			
			if ( contacts != null &&
				 contacts.flags & BodyContactsFlags.fix != 0 )
				throw "Can't move a fix body!";
			
		#end
		
		var m = (x != 0 || y != 0);
		if ( m )
		{
			this.x += x;
			this.y += y;
			moved = true;
		}
	}
	
	public function updateAABB( updatePrint:Bool = true )
	{
		#if (debug)
		
			if ( contacts != null &&
				 contacts.flags & BodyContactsFlags.fix != 0 )
				throw "Can't updateAABB() a fix body!";
			
		#end
		
		if ( !moved )
			return;
		
		if ( updatePrint )
		{
			var t = print;
			print = shape;
			shape = t;
			moved = false;
		}
		
		shape.updateAABB( x, y );
		
	}
	
	public inline function addBodyContact( flags:BodyContactsFlags = 0 ):Void
	{
		if ( contacts == null )
			contacts = new BodyContact(this);
		
		contacts.flags = flags;
	}
	
	public inline function addBodyPhysic( flags:BodyPhysicFlags = 0 ):Void
	{
		if ( physic == null )
			physic = new BodyPhysic(this);
		
		physic.flags = flags;
	}
	
	public function toString() {
		return "[Body x:" + x + " y:" + y + " " + shape +"]";
	}
	
	
	
	
}