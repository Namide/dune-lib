package dl.socket.server ;
import dl.socket.SockMsg.Role;
import dl.socket.SockMsg.RoomData;

/**
 * ...
 * @author Namide
 */
class SockRoom
{
	public var name:String;
	public var pass:String;
	var _clients:Array<SockServerUser>;
	
	public function new(name:String, pass:String = null)
	{
		this.name = name;
		this.pass = (pass != null) ? pass : "";
		_clients = [];
	}
	
	function testCls( cl:SockServerUser )
	{
		if ( cl.room == this )
		{
			if ( clLength() == 1 && cl.role == Role.basic )
				cl.role = Role.roomMaster;
		}
		else if ( cl.room == null )
		{
			if ( cl.role == Role.roomMaster )
				cl.role = Role.basic;
		}
	}
	
	public function addCl( cl:SockServerUser )
	{
		_clients.push( cl );
		cl.room = this;
		testCls( cl );
	}
	
	public function rmCl( cl:SockServerUser ):SockServerUser
	{
		_clients.remove( cl );
		cl.room = null;
		testCls( cl );
		return cl;
	}
	
	public function clLength():UInt
	{
		return _clients.length;
	}
	
	public function getCls():Array<SockServerUser>
	{
		return _clients;
	}
	
	public function getRoomData( userList:Bool = false, userNumber:Bool = true ):RoomData
	{
		var rd:RoomData = { n:name, p:(pass == "") ? "" : "1" };
		
		if ( userNumber )
			rd.l = _clients.length;
		
		if ( userList )
		{
			rd.u = [];
			for ( u in _clients )
				rd.u.push( u.getUserData( true, true, false, true ) );
		}
		
		return rd;
	}
	
}