package dl.socket.server ;
import dl.samples.SocketServer;
import dl.socket.SockMsg.UserData;
import haxe.CallStack;
import haxe.io.Eof;
import sys.net.Socket;

/**
 * ...
 * @author Namide
 */
class SockServerUser
{
	public var name:String;
	public var id:Int;
	public var room:SockRoom;
	public var datas:Dynamic;
	
	public var socket:Socket;
	public var server:SocketServer;
	public var active:Bool;
	
	public var dispatch:Bool;
	
	public function new(sv:SocketServer, skt:Socket)
	{
		id = ++sv.clientN;
		name = SockConfig.USER_NAME + Std.string( id );
		server = sv;
		socket = skt;
		active = true;
		dispatch = true;
	}
	
	public function toString():String
	{
		var peer = socket.peer();
		var pstr = Std.string(peer.host) + ':' + peer.port;
		return id + "_" + pstr + ( (name == null || name == '') ? '' : ('('+name+')') );
	}
	
	public function send(brut:SockMsg/*msg:DSocketMsg*/)
	{
		if ( !dispatch )
			return;
		
		/*if ( brut.cmd != Cmd.transferDatasServer )
			trace( "send:", brut );*/
		
		try
		{
			socket.output.writeString( brut.getString() + '\n' );
		}
		catch (e:Eof)
		{
			active = false;
		}
	}
	
	public function sendPolicy()
	{
		//trace( "MS: Sending policies to " + socket.peer().host );
		
		/*var sbuf:StringBuf = new StringBuf();
		sbuf.add( '<cross-domain-policy>' );
		sbuf.add( '<allow-access-from="*" to-ports="*" />' );
		sbuf.add( '</cross-domain-policy>' );
		sbuf.addChar( 0 );  // Flash Player needs a null char at the end
		socket.output.writeString( sbuf.toString() );
		socket.output.flush();*/
		
		
		var port     = SockConfig.PORT;
		var domains  = ['*'];
		var to_ports = '*';
		var sbuf     = new StringBuf();
		
		sbuf.add( "<?xml version=\"1.0\"?><!DOCTYPE cross-domain-policy SYSTEM \"http://www.adobe.com/xml/dtds/cross-domain-policy.dtd\"><cross-domain-policy>" );
		for ( domain in domains )
			sbuf.add( "<allow-access-from domain=\"" + domain + "\" to-ports=\"" + to_ports + "\" />" );
		
		sbuf.add( "</cross-domain-policy>" );
		sbuf.addChar( 0 );
		
		//var c = socket.accept();
		try
		{
			socket.output.writeString( sbuf.toString() );
			socket.output.flush();
			socket.close();
		}
		catch ( e : Eof )
		{
			active = false;
			trace(e);
			//console.write( "!PS: Policy server error\n     " + e );
		}
		
		
		
		
		
		/*	
			//var s = "<?xml version=\"1.0\"?><!DOCTYPE cross-domain-policy SYSTEM \"http://www.adobe.com/xml/dtds/cross-domain-policy.dtd\"><cross-domain-policy><allow-access-from domain=\"" + "*" + "\" to-ports=\"" + "*" + "\" /></cross-domain-policy>\x00";
			
			var s = '<?xml version="1.0"?>';
			s += '<!DOCTYPE cross-domain-policy SYSTEM "http://www.adobe.com/xml/dtds/cross-domain-policy.dtd">';
			s += '<cross-domain-policy>';
			//s += '<allow-http-request-headers-from domain="'+Std.string(SocketConfig.IP)+'" headers="*"/>';
			s += '<site-control permitted-cross-domain-policies="all"/>';
			//s += '<allow-access-from domain="'+Std.string(SocketConfig.IP)+'" to-ports="'+Std.string(SocketConfig.PORT)+'" />';
			s += '<allow-access-from domain="*" to-ports="*" />';
			s += "</cross-domain-policy>\x00";
			
			try {
				socket.output.writeString( s );
				socket.output.flush();
				socket.close();
			} catch ( e:Eof ) { trace( haxe.CallStack.toString(haxe.CallStack.exceptionStack()) ); active = false; }
		*/
	}
	
	public function getUserData( id:Bool = true, name:Bool = true, roomData:Bool = false, datas:Bool = false ):UserData
	{
		var ud:UserData = { };
		
		if ( id )
			ud.i = this.id;
			
		if ( name )
			ud.n = this.name;
			
		if ( roomData )
			ud.r = room.getRoomData( false, false );
		
		if ( datas )
			ud.d = this.datas;
		
		return ud;
	}
}