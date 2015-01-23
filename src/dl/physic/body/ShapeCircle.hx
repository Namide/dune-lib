package dl.physic.body;
import dl.physic.body.Shape.ShapeType;

/**
 * ...
 * @author Namide
 */
class ShapeCircle extends Shape
{
	public var r(default, default):Float;
	
	public function new() 
	{
		super();
		type = ShapeType.circle;
		r = 0.0;
	}
	
	override public function updateAABB( x:Float, y:Float, fix:Bool )
	{
		move( x, y, fix );
		
		var rd = r + r;
		aabbXMin = x;
		aabbXMax = x + rd;
		aabbYMin = x;
		aabbYMax = y + rd;
	}
}