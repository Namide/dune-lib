package dl.socket.client ;

/**
 * ...
 * @author Namide
 */
class SockClientUser
{
	public var name:String;
	public var id:Int;
	public var onChange:SockClientUser->Void;
	
	public function new() 
	{
		id = -1;
	}
}