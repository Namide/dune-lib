package dl.socket.client ;

/**
 * ...
 * @author Namide
 */
class SockClientUser
{
	public var name:String;
	public var id:Int;
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
		return s;
	}
}