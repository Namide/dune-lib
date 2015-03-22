package dl.socket.client ;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.Socket;
import flash.system.Security;
import dl.socket.SockMsg.SendSubject;
import dl.socket.SockMsg.SockMsgGen;

/**
 * ...
 * @author Namide
 */
class SockPipe
{
	static var _FIRST_INIT:Bool = false;
	function firstInit()
	{
		Security.allowDomain(SockConfig.IP);
		//Security.allowInsecureDomain(_host);
		//Security.loadPolicyFile('xmlsocket://'+ _host +':' + _port);
		_FIRST_INIT = true;
	}
	
	var _socket:Socket;
	
	public var onReceive:SockMsg->Void;
	public var onConnected:SockPipe->Void;
	
	public function new() 
	{
		if (!_FIRST_INIT)
			firstInit();
		
		onReceive = function(s:SockMsg) 	{ trace("configure DSocket.onReceive(s:String)"); };
		onConnected = function(s:SockPipe) 	{ trace("configure DSocket.onConnected(d:DSocketMsg)"); };
		
		_socket = new Socket( SockConfig.IP, SockConfig.PORT );
		_socket.addEventListener( Event.CLOSE, socketClose );
		_socket.addEventListener( Event.CONNECT, socketConnect );
		_socket.addEventListener( ProgressEvent.SOCKET_DATA, socketData );
		_socket.addEventListener( IOErrorEvent.IO_ERROR, socketError );
		_socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, socketError );
	}
	
	function socketConnect(e:Dynamic):Void
	{
		onConnected( this );
	}
	
	public function send( msg:SockMsg ):Void
	{
		try
		{
			_socket.writeUTFBytes( msg.getString() + '\n');
			_socket.flush();
		}
		catch (z:Dynamic)
		{
			onReceive( SockMsgGen.getSend(SendSubject.errorSystem, "Connection lost (" + Std.string(z) + ")") );
		}
	}
	
	function socketData(e:ProgressEvent)
	{
		var text = _socket.readUTFBytes(_socket.bytesAvailable);
		var texts = text.split("\n");
		
		for (t in texts)
		{
			if ( t != "" )
			{
				try
				{
					onReceive( SockMsg.fromString(t) );
				}
				catch (e:Dynamic)
				{
					trace(e, t);
					onReceive( SockMsgGen.getSend(SendSubject.errorSystem, "Parse error: " + t) );
				}
			}
		}
	}
	
	function socketClose(e:Dynamic)
	{
		onReceive( SockMsgGen.getSend( SendSubject.errorSystem, "Connection closed" ) );
	}
	
	function socketError(e:Dynamic)
	{
		onReceive( SockMsgGen.getSend(SendSubject.errorSystem, "Can not connect to server, please try again later (" + Std.string(e.text) + ")" ) );
	}
	
	public function close()
	{
		_socket.close();
	}
}