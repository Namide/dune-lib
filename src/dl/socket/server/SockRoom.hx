package dl.socket.server ;
import dl.socket.SockMsg.RoomData;

/**
 * ...
 * @author Namide
 */
class SockRoom
{
	public var name:String;
	public var pass:String;
	public var clients:Array<SockServerUser>;
	
	public function new(name:String, pass:String = null)
	{
		this.name = name;
		this.pass = (pass != null) ? pass : "";
		clients = [];
	}
	
	public function getRoomData( userList:Bool = false, userNumber:Bool = true ):RoomData
	{
		var rd:RoomData = { n:name, p:(pass == "") ? "" : "1" };
		
		if ( userNumber )
			rd.l = clients.length;
		
		if ( userList )
		{
			rd.u = [];
			for ( u in clients )
				rd.u.push( u.getUserData( true, true, false ) );
		}
		
		return rd;
	}
	
}