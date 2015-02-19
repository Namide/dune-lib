package dl.socket.server ;
import dl.socket.server.SockServer.SocketServer;
import dl.socket.SockMsg.RoomData;
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
	
	function set( roomName:String, roomPass:String, roomDatas:Dynamic ):SockRoom
	{
		var ro:SockRoom = Lambda.find (_list, function(tmp:SockRoom):Bool { return tmp.name.toLowerCase() == roomName.toLowerCase(); } );
		if ( ro == null )
		{
			ro = new SockRoom( roomName, roomPass, roomDatas );
			_list.push( ro );
		}
		
		return ro;
	}
	
	public function all():Array<SockRoom>
	{
		return _list;
	}
	
	public inline function change( cl:SockServerUser, roomName:String, roomPass:String, ?datas:Dynamic = null ):Bool
	{
		return add( cl, roomName, roomPass, datas );
	}
	
	public function add( cl:SockServerUser, roomName:String, roomPass:String, roomDatas:Dynamic ):Bool
	{
		// CHECK OR CREATE THE ROOM
		var ro:SockRoom = set( roomName, roomPass, roomDatas );
		if ( ro == null )
			return false;
		
		
		// REMOVE FROM THE LAST ROOM
		var oldRoom = cl.room;
		rm( cl, false );
		if ( oldRoom != null )
			cl.server.broadcast( SockMsgGen.getSend( SendSubject.user, cl.getUserData( true, false, true, false, false ) ), oldRoom.getCls() );
		
		
		// ADD ON THE NEW ROOM
		ro.addCl( cl );
		
		// INFORM THE USERS IN THE NEW ROOM
		cl.send( SockMsgGen.getSend( SendSubject.room, ro.getRoomData( true, false, true ) ) );
		cl.server.broadcast( SockMsgGen.getSend( SendSubject.user, cl.getUserData(true, true, false, true, true ) ), ro.getCls() );
		
		informDefaultRoom( cl.server );
		
		return true;
	}
	
	public function rm( cl:SockServerUser, dispatchMsg:Bool = true )
	{
		var ro:SockRoom = cl.room;
		if ( ro == null )
			return;
		
		ro.rmCl( cl );
		
		if ( ro.clLength() < 1 )
		{
			_list.remove( ro );
		}
		else if ( dispatchMsg )
		{
			cl.server.broadcast( SockMsgGen.getSend( SendSubject.user, cl.getUserData( true, false, true, false, false ) ), ro.getCls() );
		}
		
		if ( dispatchMsg )
			informDefaultRoom( cl.server );
	}
	
	public function getRoomListData( sv:SocketServer ):Array<RoomData>
	{
		var rl:Array<RoomData> = [];
		for ( r in sv.rooms.all() )
			if ( SockConfig.ROOM_DEFAULT_IS_ROOM || r.name.toLowerCase() != SockConfig.ROOM_DEFAULT_NAME.toLowerCase() )
				rl.push( r.getRoomData( false, true ) );
		return rl;
	}
	
	function informDefaultRoom( sv:SocketServer )
	{
		if ( !SockConfig.ROOM_DEFAULT_IS_ROOM )
		{
			var ro:SockRoom = Lambda.find( _list, function(tmp:SockRoom):Bool { return tmp.name.toLowerCase() == SockConfig.ROOM_DEFAULT_NAME.toLowerCase(); } );
			if ( ro != null )
				sv.broadcast( SockMsgGen.getSend( SendSubject.roomList, getRoomListData(sv) ), ro.getCls() );
		}
	}
}