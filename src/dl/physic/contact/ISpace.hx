package dl.physic.contact;
import dl.physic.body.Body;

/**
 * @author Namide
 */

interface ISpace 
{
	public function addBody( body:Body ):Void;
	public function removeBody( body:Body ):Void;
	public function hitTest():List<Body>;
}