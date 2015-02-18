package dl.samples ;
import dl.socket.server.SockServer.SocketServer;

class SocketServerUI
{
	static var _MAIN:SocketServer;
	
	static function main()
	{
		_MAIN = new SocketServer();
	}
}