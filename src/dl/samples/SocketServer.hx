package dl.samples ;
import dl.socket.server.SockConsole;
import dl.socket.server.SockRoomList;
import dl.socket.server.SockServerScan;
import dl.socket.server.SockServerUser;
import dl.socket.SockConfig;
import dl.socket.SockMsg;
import haxe.io.Eof;
import haxe.io.Output;
import neko.vm.Thread;
import dl.socket.server.db.SockUserDB;
import dl.socket.SockMsg.SendSubject;
import dl.socket.SockMsg.SockMsgGen;
import sys.net.Host;
import sys.net.Socket;

/**
 * @author Namide from YellowAfterlife
 */

class SockUserAdmin extends SockServerUser
{
	public function new( sv:SocketServer )
	{
		super(sv, null);
		name = 'Server';
	}
	
	override public function toString():String
	{
		return name + '(console)';
	}
	
	override public function send(brut:SockMsg)
	{
		server.console.write( brut.getString() );
	}
}

class SocketServer
{
	static var _MAIN:SocketServer;
	
	public var socket:Socket;
	public var socketPolicy:Socket;
	
	public var clients:Array<SockServerUser>;
	public var process:SockServerScan;
	public var rooms:SockRoomList;
	public var clientN:Int;
	public var users:Null<SockUserDB>;
	
	public var console:SockConsole;
	public var admin:SockUserAdmin;
	
	public function close()
	{
		console.close();
		
		if ( SockConfig.SERVER_USERS_FILE != null )
			users.close();
		
		Sys.exit(0);
	}
	
	public function broadcast( brut:SockMsg, list:Array<SockServerUser> )
	{
		for (cl in list)
			if ( cl.active )
				cl.send( brut );
	}
	
	public function onChat( chars:String, cl:SockServerUser )
	{
		process.appli( chars, cl );
	}
	
	function threadAccept()
	{
		while (true)
		{
			var sk = socket.accept();
			if (sk != null)
			{
				var cl = new SockServerUser( this, sk );
				Thread.create(getThreadListen(cl));
			}
		}
	}
	
	function getThreadListen(cl:SockServerUser)
	{
		return function()
		{
			console.write( Std.string(cl) + ' connected' );
			
			while (cl.active)
			{
				try
				{
					var text = cl.socket.input.readLine();
					if (cl.active)
					{
						onChat(text, cl);
					}
				}
				// disconnect
				catch (e:Dynamic)
				{
					//console.write( Std.string(cl) +  " socket error: " + e );
					break;
				}
			}
			
			console.write( Std.string(cl) +  " disconnected" );
			
			var ro = cl.room;
			rooms.rm( cl, false );
			if ( ro != null )
				broadcast( SockMsgGen.getSend( SendSubject.messageSystem, cl.name + ' disconnected' ), ro.getCls() );
			
			if ( Lambda.has( clients, cl ) )
				clients.remove( cl );
			
			try
			{
				cl.socket.shutdown(true, true);
				cl.socket.close();
			}
			catch (e:Dynamic)
			{
				//trace(e);
			}
		}
	}
	
	function initPolicy( port:Int = 843 )
	{
		var host = SockConfig.IP;
		
		try
		{
			socketPolicy = new Socket();
			socketPolicy.bind( new Host( host), port );
			socketPolicy.listen( 10 );
		}
		catch (z:Dynamic)
		{
			console.write( '!PS: Policy server not bind to port\n     Can\'t running on port ' + SockConfig.IP + '\n' );
			return;
		}
		
		Thread.create(threadPolicy);
	}
	
	function threadPolicy()
	{
		var req	     = null;
		var c	     = null;
		
		
		console.write( 'PS: Policy server initialised\n    (ip:' + SockConfig.IP + ' port:' + 843 + ')\n' );
		
		while ( true )
		{
			c	= socketPolicy.accept();
			
			try
			{
				req = c.input.readString( 22 );
				c.input.readByte();  // Flash Player ends with a null char
			}
			catch ( e:Eof ) { }
			
			if ( req == "<policy-file-request/>" )
			{
				returnPolicy( c );
				
			}
		}
    }
	
	public function returnPolicy( soc:Socket )
	{
		var port     = SockConfig.PORT;
		var domains  = ['*'];
		var to_ports = '*';
		var sbuf     = new StringBuf();
		
		console.write( "PS: Sending policies to " + soc.peer().host );
		
		sbuf.add( "<?xml version=\"1.0\"?><!DOCTYPE cross-domain-policy SYSTEM \"http://www.adobe.com/xml/dtds/cross-domain-policy.dtd\"><cross-domain-policy>" );
		for ( domain in domains )
			sbuf.add( "<allow-access-from domain=\"" + domain + "\" to-ports=\"" + to_ports + "\" />" );
		
		sbuf.add( "</cross-domain-policy>" );
		sbuf.addChar( 0 );
		
		try
		{
			soc.output.writeString( sbuf.toString() );
			soc.output.flush();
			soc.close();
		}
		catch ( e : Eof )
		{
			console.write( "!PS: Policy server error\n     " + e );
		}
	}
	
	public function new()
	{
		console = new SockConsole();
		users = (SockConfig.SERVER_USERS_FILE == null) ? null : new SockUserDB();
		
		// Add a policy distributor
		if ( SockConfig.SEND_POLICY_843 )
			initPolicy();
		
		// Server
		process = new SockServerScan( this );
		clientN = 0;
		
		try
		{
			socket = new Socket();
			socket.bind(new Host(SockConfig.IP), SockConfig.PORT);
			socket.listen(3); // number of pending connections before they get refused
		}
		catch (z:Dynamic)
		{
			console.write( '!MS: Main server not bind to port\n     Can\'t running on port ' + SockConfig.IP + '\n' );
			return;
		}
		console.write( 'MS: Main server initialized\n    (ip:'+SockConfig.IP+' port:'+SockConfig.PORT+')\n' );
		
		clients = [];
		rooms = new SockRoomList();
		admin = new SockUserAdmin(this);
		console.onSend = function(t:String)
		{
			onChat(t, admin);
			return true;
		};
		
		Thread.create(threadAccept);
		if ( SockConfig.SERVER_USERS_FILE != null )
			users.open();
		console.open();
		
	}
	
	static function main()
	{
		_MAIN = new SocketServer();
	}
}