package dl.physic.body;
import dl.physic.body.ShapePoint.ShapeType;

/**
 * ...
 * @author Namide
 */
class ShapeCircle extends ShapePoint
{
	public var r(default, default):Float;
	
	public function new() 
	{
		super();
		type = ShapeType.circle;
		r = 0.0;
	}
	
	override public function updateAABB( x:Float, y:Float )
	{
		var rd = r + r;
		aabbXMin = x;
		aabbXMax = x + rd;
		aabbYMin = x;
		aabbYMax = y + rd;
	}
}