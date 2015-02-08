package dl.socket.client ;
import dl.utils.Obj;

/**
 * ...
 * @author Namide
 */
class SockClientUser
{
	public var name:String;
	public var id:Int;
	public var datas:Dynamic;
	//public var onChange:SockClientUser->Void;
	
	public function new() 
	{
		id = -1;
	}
	
	public function clone():SockClientUser
	{
		var s = new SockClientUser();
		s.name = name;
		s.id = id;
		s.datas = Obj.deepCopy( datas );
		return s;
	}
}