package dl.socket.client ;
import dl.socket.SockMsg.Role;
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
	public var role:Role;
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
		s.role = role;
		return s;
	}
	
	/*public function getAllName():String
	{
		return ( role.toInt() > Role.basic.toInt() ) ? ("@" + name) : name;
	}*/
	
	public inline function fullName()
	{
		return ( ( role > Role.roomMaster ) ? "!" : ( role == Role.roomMaster ) ? "@" : "" ) + name;
	}
}