package dl.physic.body ;

@:enum
abstract ShapeType(Int)
{
	var point = 0;
	var rect = 1;
	var circle = 2;
	
	inline function new( i:Int ) { this = i; }
	
	@:from
	public static function fromInt(i:Int):ShapeType {
		return new ShapeType(i);
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
class ShapePoint
{

	var _lastX:Float;
	var _lastY:Float;
	
	public var aabbXMin(default, null):Float;
	public var aabbXMax(default, null):Float;
	public var aabbYMin(default, null):Float;
	public var aabbYMax(default, null):Float;
	
	public var type(default, null):ShapeType;

	public function new() 
	{
		type = ShapeType.point;
	}
	
	functo
	
	public function updateAABB( x:Float, y:Float, fix:Bool = true )
	{
		moved = (x != lx && y != ly);
		
		if ( fix )
		{
			_lastX = this.x;
			_lastY = this.y;
			this.x = x;
			this.y = y;
		}
		
		
		aabbXMin =
		aabbXMax = x;
		aabbYMin =
		aabbYMax = y;
	}
	
	public function toString()
	{
		return "[Shape" + Std.string(type) + " {x:" + Std.string(aabbXMin) + " y:" + Std.string(aabbYMin) + " w:" + Std.string(aabbXMax - aabbXMin) + " h:" + Std.string(aabbYMax - aabbYMin) +"]";
	}
	
	/*public static function getPosToTop( a:ShapePoint ):Float
	{
		if ( a.type == ShapeType.CIRCLE )
		{
			return -( cast( a, ShapeCircle ).r + a.anchorY );
		}
		return - a.anchorY;
	}
	public static function getPosToLeft( a:ShapePoint ):Float
	{
		if ( a.type == ShapeType.CIRCLE )
		{
			return -( cast( a, ShapeCircle ).r + a.anchorX );
		}
		return - a.anchorX;
	}
	public static function getPosToBottom( a:ShapePoint ):Float
	{
		if ( a.type == ShapeType.CIRCLE )
		{
			return cast( a, ShapeCircle ).r - a.anchorY;
		}
		else if ( a.type == ShapeType.RECT )
		{
			return cast( a, ShapeRect ).h - a.anchorY;
		}
		return 0;
	}
	public static function getPosToRight( a:ShapePoint ):Float
	{
		if ( a.type == ShapeType.CIRCLE )
		{
			return cast( a, ShapeCircle ).r - a.anchorX;
		}
		else if ( a.type == ShapeType.RECT )
		{
			return cast( a, ShapeRect ).w - a.anchorX;
		}
		return 0;
	}*/
	
	public static function getW( a:ShapePoint ):Float
	{
		if ( a.type == ShapeType.circle )
			return cast( a, ShapeCircle ).r * 2;
		
		else if ( a.type == ShapeType.rect )
			return cast( a, ShapeRect ).w;
		
		return 0;
	}
	
	public static function getH( a:ShapePoint ):Float
	{
		if ( a.type == ShapeType.circle )
			return cast( a, ShapeCircle ).r * 2;
		
		else if ( a.type == ShapeType.rect )
			return cast( a, ShapeRect ).h;
		
		return 0;
	}
	
	public static function hitTest( a:ShapePoint, b:ShapePoint ):Bool
	{
		if ( !hitTestAABB( a, b ) )
		{
			return false;
		}
		else if ( 	a.type == ShapeType.circle &&
					b.type == ShapeType.circle )
		{
			return hitTestCircles( cast( a, ShapeCircle ), cast( b, ShapeCircle ) );
		}
		else if ( a.type == ShapeType.circle &&
				  b.type == ShapeType.point )
		{
			return hitTestPointCircle( cast( b, ShapePoint ), cast( a, ShapeCircle ) );
		}
		else if ( a.type == ShapeType.point &&
				  b.type == ShapeType.circle )
		{
			return hitTestPointCircle( cast( a, ShapePoint ), cast( b, ShapeCircle ) );
		}
		
		return true;
	}
	
	private inline static function hitTestAABB( a:ShapePoint, b:ShapePoint ):Bool
	{
		return (	a.aabbXMin <= b.aabbXMax &&
					a.aabbXMax >= b.aabbXMin &&
					a.aabbYMin <= b.aabbYMax &&
					a.aabbYMax >= b.aabbYMin	);
	}
	
	private static function hitTestCircles( a:ShapeCircle, b:ShapeCircle ):Bool
	{
		var d1:Float = b.aabbXMin + b.r - (a.aabbXMin + a.r);
		var d2:Float = b.aabbYMin + b.r - (a.aabbYMin + a.r);
		var d3:Float = a.r + b.r;
		
		return ( d1 * d1 - d2 * d2 <= d3 * d3 );
	}
	
	private static function hitTestPointCircle( a:ShapePoint, b:ShapeCircle ):Bool
	{
		var d1:Float = b.aabbXMin + b.r - a.aabbXMin;
		var d2:Float = b.aabbYMin + b.r - a.aabbYMin;
		
		return ( d1 * d1 - d2 * d2 <= b.r * b.r );
	}
}