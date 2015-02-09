package dl.socket.server ;
import dl.socket.SockMsg.SendSubject;
import haxe.Json;
import dl.socket.SockMsg.Cmd;
import dl.socket.SockMsg.SockMsgGen;
import dl.socket.SockMsg.UserData;

/**
 * ...
 * @author Namide
 */
class SockRoomList
{

	var _list:Array<SockRoom>;
	
	public function new() 
	{
		if ( _list == null )
			_list = [];
	}
	
	public function set( roomName:String, roomPass:String ):SockRoom
	{
		var ro:SockRoom = Lambda.find (_list, function(tmp:SockRoom):Bool { return tmp.name.toLowerCase() == roomName.toLowerCase(); } );
		if ( ro == null )
		{
			ro = new SockRoom( roomName, roomPass );
			_list.push( ro );
		}
		
		return ro;
	}
	
	public function all():Array<SockRoom>
	{
		return _list;
	}
	
	public inline function change( cl:SockServerUser, roomName:String, roomPass:String ):Bool
	{
		return add( cl, roomName, roomPass );
	}
	
	public function add( cl:SockServerUser, roomName:String, roomPass:String ):Bool
	{
		var ro:SockRoom = set( roomName, roomPass );
		if ( ro == null )
			return false;
		
		rm( cl );
		
		ro.addCl( cl );//.clients.push(cl);
		//cl.room = ro;
		
		// send to the new user
		//var ul:Array<UserData> = [];
		//for ( u in ro.getCls()/*.clients*/ )
		//	ul.push( u.getUserData(true, true, false, true, true )/*{ n:u.name, i:u.id }*/ );
		//cl.send( SockMsgGen.getReturnRoomData( ro.name, (ro.pass=="")?"":"1", ul ) );
		cl.send( SockMsgGen.getSend( SendSubject.room, ro.getRoomData( true, false, true ) /*ro.name, (ro.pass=="")?"":"1", ul*/ ) );
		
		
		// Send to all users in the room
		//cl.server.broadcast( new SockMsg( Cmd.setUserData, cl.getUserData( true, true, true, true, true ) ), ro.getCls()/*.clients*/ );
		cl.server.broadcast( SockMsgGen.getSend( SendSubject.user, cl.getUserData(true, true, false, true, true ) ), ro.getCls() );
		
		return true;
	}
	
	public function rm( cl:SockServerUser, dispatchMsg:Bool = true )
	{
		var ro:SockRoom = cl.room;
		if ( ro == null )
			return;
		
		ro.rmCl( cl );//.clients.remove( cl );
		
		if ( ro.clLength() < 1 )//ro.clients.length < 1 )
		{
			_list.remove( ro );
		}
		else if ( dispatchMsg )
		{
			//var ud:UserData = { i:cl.id, n:cl.name/*, r:"?"*/ };
			//cl.server.broadcast( new SockMsg( Cmd.setUserData, cl.getUserData( true, true, false, false, false )/*nu*/ ), ro.getCls() );
			cl.server.broadcast( SockMsgGen.getSend( SendSubject.user, cl.getUserData( true, false, true, false, false )/*nu*/ ), ro.getCls() );
		}
	}
	
}