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
}