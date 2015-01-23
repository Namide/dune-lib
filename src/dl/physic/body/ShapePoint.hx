package dl.physic.body ;
import dl.physic.body.Shape.ShapeType;


/**
 * ...
 * @author Namide
 */
class ShapePoint extends Shape
{

	

	public function new() 
	{
		super();
		type = ShapeType.point;
	}
	
	override public function updateAABB( x:Float, y:Float, fix:Bool )
	{
		move( x, y, fix );
		
		aabbXMin =
		aabbXMax = x;
		aabbYMin =
		aabbYMax = y;
	}
	
	public function toString()
	{
		return "[Shape" + Std.string(type) + " {x:" + Std.string(aabbXMin) + " y:" + Std.string(aabbYMin) + " w:" + Std.string(aabbXMax - aabbXMin) + " h:" + Std.string(aabbYMax - aabbYMin) +"]";
	}
	
	
}