package dl.socket.server ;
import dl.samples.SocketServer;
import haxe.format.JsonParser;
import haxe.format.JsonPrinter;
import haxe.Json;
import neko.Lib;
import neko.vm.Thread;
import dl.socket.SockMsg.Chat;
import dl.socket.SockMsg.Cmd;
import dl.socket.SockMsg.RoomData;
import dl.socket.SockMsg.Send;
import dl.socket.SockMsg.SendSubject;
import dl.socket.SockMsg.SockMsgGen;
import dl.socket.SockMsg.UserData;
import dl.socket.SockMsg.UserID;
import sys.io.Process;

/**
 * ...
 * @author Namide
 */
class SockServerScan
{
	var sv:SocketServer;
	
	public function new(sv:SocketServer) 
	{
		this.sv = sv;
	}
	
	function findClientsByName( name:String, clients:Array<SockServerUser> ):Array<SockServerUser>
	{
		var r:Array<SockServerUser> = [];
		name = name.toLowerCase();
		for (cl in clients)
		{
			if (cl.name.toLowerCase().indexOf(name) != -1)
				r.push(cl);
		}
		
		return r;
	}
	
	public inline static function getBrutErrorSystem( msg:String = null ):SockMsg
	{
		var send:Send = (msg == null) ? { s:SendSubject.errorSystem } : { s:SendSubject.errorSystem, d:msg };
		return new SockMsg( Cmd.send, send );
	}
	
	public inline static function getBrutUserData( user:SockServerUser ):SockMsg
	{
		var u:UserData = { i:user.id, n:user.name, r:user.room.name };
		return new SockMsg( Cmd.setUserData, u );
	}
	
	public inline static function testWord( s:String ):Bool
	{
		// /^([a-zA-Z_-]+)$/i.match(s);
		return ~/^[a-z0-9-]{3,10}$/i.match(s);//new EReg("^(\w)$", "i").match(w);
	}
	
	function updateUserName( cl:SockServerUser, newUser:UserData )
	{
		var newName = newUser.n;
		
		if (  	newName.length < SockConfig.USER_NAME_LENGTH_MIN ||
				newName.length > SockConfig.USER_NAME_LENGTH_MAX )
		{
			cl.send( SockMsgGen.getSend( SendSubject.errorSystem,
											'your name must have min:' +
											SockConfig.USER_NAME_LENGTH_MIN +
											' , max:' +
											SockConfig.USER_NAME_LENGTH_MAX +
											' character' ) );
			return;
		}
		
		if ( !testWord(newName) )
		{
			cl.send( SockMsgGen.getSend( SendSubject.errorSystem, newName + ' is not a valid name' ) );
			return;
		}
		var name = newName;
		if ( userExist( name ) )
		{
			cl.send( SockMsgGen.getSend( SendSubject.errorSystem, newName + ' such name already exists' ) );
			return;
		}
		
		appliUserName( cl, name );
	}
	
	function appliUserName( cl:SockServerUser, name:String )
	{
		sv.console.write( Std.string(cl) + ' rename > ' + name );
		
		cl.name = name;
		
		var u:UserData = { };
		u.n = name;
		u.i = cl.id;
		
		if ( cl.room != null )
		{
			sv.broadcast( new SockMsg( Cmd.setUserData, u ), cl.room.clients );
		}
	}
	
	inline function userExist( name:String ):Bool
	{
		return 	Lambda.exists( sv.clients, function( c:SockServerUser ):Bool { return c.name.toLowerCase() == name.toLowerCase(); } ) || 
				(sv.users != null && sv.users.hasName( name ) );
	}
	
	function updateUserRoom( cl:SockServerUser, newUser:UserData )
	{
		var newRoomName = newUser.r;
		
		if (  	newRoomName.length < SockConfig.USER_NAME_LENGTH_MIN ||
				newRoomName.length > SockConfig.USER_NAME_LENGTH_MAX )
		{
			cl.send( SockMsgGen.getSend( SendSubject.errorSystem,
											newRoomName +
											' room name must have min:' +
											SockConfig.USER_NAME_LENGTH_MIN +
											' , max:' +
											SockConfig.USER_NAME_LENGTH_MAX +
											' character' ) );
			return;
		}
		
		if ( !testWord(newRoomName) )
		{
			return cl.send( SockMsgGen.getSend( SendSubject.errorSystem,
												newRoomName + ' is not a valid room name' ) );
		}
		var name = newRoomName;
		var pass = (newUser.rp == null) ? "" : newUser.rp;
		
		if ( name == SockConfig.ROOM_DEFAULT && pass != "" )
			cl.send( SockMsgGen.getSend( 	SendSubject.errorSystem, 
											name + ' can\'t be private' ) );
		
		if ( sv.rooms.change( cl, name, pass ) )
		{
			sv.console.write( Std.string(cl) + ' change room > ' + name );
		}
		else
		{
			cl.send( SockMsgGen.getSend( 	SendSubject.errorSystem, 
											name + ' is private, you must have a password' ) );
		}
		
	}
	
	inline function updateUser( cl:SockServerUser, newUser:UserData )
	{
		// CHANGE THE NAME
		if ( newUser.n != null )
		{
			updateUserName( cl, newUser );
			// check the name to avoid errors
			newUser.n = cl.name;
		}
		
		// CHANGE THE ROOM
		if ( newUser.r != null )
		{
			updateUserRoom( cl, newUser );
			// check the room name to avoid errors
			newUser.r = ( cl.room != null ) ? cl.room.name : SockConfig.ROOM_DEFAULT;
			newUser.rp = ( cl.room != null ) ? cl.room.pass : "";
		}
		
		return newUser;
	}
	
	function serverCommands( chars:String, cl:SockServerUser )
	{
		var a = chars.split(" ");
		switch( a[0] )
		{
			case "/help" :
				
				sv.console.write( "\nCOMMANDS\n" );
				sv.console.write( "  /exit        quit app" );
				sv.console.write( "  /kickAll     kick all clients" );
				sv.console.write( "  /clients     print all clients" );
				sv.console.write( "  /rooms       print all rooms\n" );
				
			case "/exit" | "/close":
				
				for ( c in sv.clients )
					c.active = false;
				sv.console.write( "\n!server closed\n" );
				
				sv.close();
				
			case "/kickAll" :
				
				for ( c in sv.clients )
				{
					c.send( SockMsgGen.getSend( SendSubject.messageSystem, c.name + ' has been kicked by admins' ) );
					sv.rooms.remove( c );
					sv.clients.remove( c );
					c.active = false;
				}
				sv.console.write( "\n  all clients kicked!\n" );
				
			case "/clients" :
				
				sv.console.write( "\nCLIENT LIST\n" );
				for ( c in sv.clients )
					sv.console.write( "  " + c.id + " " + c.name + " (" + c.socket.peer().host + ":" + c.socket.peer().port + ")     " + c.room.name );
				
				if ( sv.clients.length < 1 )
					sv.console.write( "  ---\n" );
				else
					sv.console.write( " " );
				
			case "/rooms" :
				
				sv.console.write( "\nROOM LIST\n" );
				for ( r in sv.rooms.all() )
					sv.console.write( "  " + r.name + " (" + r.clients.length + ")" );
				
				if ( sv.rooms.all().length < 1 )
					sv.console.write( "  ---\n" );
				else
					sv.console.write( " " );
			
			case "/room" :
				
				if ( a.length > 1 )
				{
					var r = Lambda.find( sv.rooms.all(), function(r0:SockRoom) { return (r0.name.toLowerCase() == a[1].toLowerCase() ); } );
					if ( r != null )
					{
						sv.console.write( "\n ROOM: " + r.name + "\n" );
						
						for ( c in r.clients )
							sv.console.write( "  " + c.id + " " + c.name + " (" + c.socket.peer().host + ":" + c.socket.peer().port + ")     " + c.room.name );
						
						if ( r.clients.length < 1 )
							sv.console.write( "  ---\n" );
						else
							sv.console.write( " " );
						
					}
					else
					{
						sv.console.write( "\n  room: " + a[1] + " not found\n" );
					}
				}
				
			case "/kick" :
				
				if ( a.length > 1 )
				{
					var c = Lambda.find( sv.clients, function(c0:SockServerUser) { return (c0.id == Std.parseInt( a[1] ) ); } );
					if ( c != null )
					{
						for ( c2 in c.room.clients )
							c2.send( SockMsgGen.getSend( SendSubject.messageSystem, c.name + ' has been kicked by admins' ) );
						
						sv.rooms.remove( c );
						sv.clients.remove( c );
						c.active = false;
						
						sv.console.write( "\n  " + c.id + " " + c.name + " (" + c.socket.peer().host + ":" + c.socket.peer().port + ")     kicked!\n" );
					}
					else
					{
						sv.console.write( "\n  client: " + a[1] + " not found (must be an ID)\n" );
					}
				}
				
				
		}
	}
	
	public function appli( chars:String, cl:SockServerUser )
	{
		// SERVER COMMANDS
		if ( cl == sv.info )
		{
			serverCommands( chars, cl );
			return;
		}
		
		// CLIENTS COMMANDS
		var brut = SockMsg.fromString( chars );
		switch ( brut.cmd )
		{
			case Cmd.send:
				
				var o:Send = brut.struct;
				switch( o.s )
				{
					case SendSubject.connect:
						
						sv.clients.push(cl);
						
						var u:UserData = o.d;
						
						if ( u.n != null || u.r != null )
							u = updateUser( cl, u );
						
						u.i = cl.id;
						u.n = cl.name;
						
						cl.send( SockMsgGen.getSend( SendSubject.connect, u ) );
						
						if ( cl.room == null )
							sv.rooms.add( cl, SockConfig.ROOM_DEFAULT, "" );
						
						return;
						
					case SendSubject.errorSystem:
						
						// Not implemented for server
						return;
						
					case SendSubject.chat:
						
						var o2:Chat = o.d;
						if ( o2.m.length < 1 )
							return cl.send( SockMsgGen.getSend( SendSubject.errorSystem, 'Empty messages not allowed' ) );
						
						o2.f = cl.id;
						
						sv.console.write( cl.id + "_(" + cl.name + ")" + ( (o2.t!=null)?(">"+o2.t):"" ) + ": " + o2.m );
						
						// SEND A MESSAGE TO
						if ( o2.t != null )
						{
							var rc:SockServerUser = (cl.room != null) ? Lambda.find( cl.room.clients, function(u:SockServerUser) { return u.id == o2.t; } ) : null;
							
							if ( rc == null )
								return cl.send( SockMsgGen.getSend( SendSubject.errorSystem, 'User not found' ) );
							
							cl.send( SockMsgGen.getSend( SendSubject.chat, o2 ) );
							rc.send( SockMsgGen.getSend( SendSubject.chat, o2 ) );
							return;
						}
						
						return sv.broadcast( SockMsgGen.getSend( SendSubject.chat, o2 ), cl.room.clients );
						
					case SendSubject.messageSystem:
						
						// Not implemented for server
						return;
						
					case SendSubject.roomList:
						
						var rl:Array<RoomData> = [];
						for ( r in sv.rooms.all() )
							rl.push( { n:r.name, l:r.clients.length, p:(r.pass=="")?"":"1" } );
						
						cl.send( SockMsgGen.getSend( SendSubject.roomList, rl ) );
						return;
					
					case SendSubject.register:
						
						if ( sv.users == null )
							return cl.send( SockMsgGen.getSend( SendSubject.errorSystem, 'Register mode disable' ) );
						
						var ui:UserID = o.d;
						var ereg = ~/\w+@[a-z_\.-]+?\.[a-z]{2,6}/i;
						if ( !ereg.match( ui.m ) )
							return cl.send( SockMsgGen.getSend( SendSubject.errorSystem, ui.m + ' invalid e-mail format' ) );
						
						if ( !testWord(ui.n) )
							return cl.send( SockMsgGen.getSend( SendSubject.errorSystem, ui.n + ' is not a valid name' ) );
						
						if ( userExist(ui.n) && ui.n.toLowerCase() != cl.name.toLowerCase() )
							return cl.send( SockMsgGen.getSend( SendSubject.errorSystem, ui.n + ' such name already exists' ) );
						
						if ( sv.users.hasMail(ui.m) )
						{
							if ( sv.users.get( ui.m, ui.p ) == null )
								return cl.send( SockMsgGen.getSend( SendSubject.errorSystem, 'bad password' ) );
							
							sv.users.update( ui.m, ui.p, ui.n );
						}
						else
						{
							sv.users.insert( ui.m, ui.p, ui.n );
						}
						
						appliUserName( cl, ui.n );
						
						return cl.send( SockMsgGen.getSend( SendSubject.messageSystem, 'You have been registered' ) );
						
					case SendSubject.login:
						
						if ( sv.users == null )
							return cl.send( SockMsgGen.getSend( SendSubject.errorSystem, 'Login mode disable' ) );
						
						var ui:UserID = o.d;
						
						if ( sv.users.hasMail(ui.m) )
						{
							var udb = sv.users.get( ui.m, ui.p );
							if ( udb == null )
								return cl.send( SockMsgGen.getSend( SendSubject.errorSystem, 'bad password' ) );
							
							appliUserName( cl, udb.name );
						}
						else
						{
							return cl.send( SockMsgGen.getSend( SendSubject.errorSystem, 'Entry not found' ) );
						}
					
				}
				
			case Cmd.transferDatasClient :
			
				var msg = SockMsgGen.getTransferDatasServer( brut.struct, cl.id );
				for ( c in cl.room.clients )
					//if ( c != cl )
						c.send( msg );
				return;
			
			case Cmd.transferDatasServer :
				
				// Not implemented for server
				return;
				
			case Cmd.returnRoomData :
				
				// Not implemented for server
				return;
				
			case Cmd.setUserData :
				
				var newUser:UserData = brut.struct;
				updateUser( cl, newUser );
				return;
				
			case Cmd.other :
				
				// not working
				if ( brut.struct == "<policy-file-request/>\x00" )
				{
					sv.console.write( "MS: Sending policies to:" + sv.socket.peer().host );
					cl.sendPolicy();
				}
				
				cl.active = false;
				//cl.socket.close();
				
		}		
	}
}