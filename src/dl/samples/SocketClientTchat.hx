package dl.samples ;

import dl.socket.client.SockClientScan;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;
import dl.socket.client.SockClientTchatUI;
import dl.socket.client.SockClientUser;

/**
 * ...
 * @author Namide
 */

class SocketClientTchat 
{
	static var _MAIN:SocketClientTchat;
	
	var _graphic:SockClientTchatUI;
	var _process:SockClientScan;
	
	static function main() 
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		_MAIN = new SocketClientTchat();
	}
	
	function new()
	{
		_graphic = new SockClientTchatUI();
		
		_process = new SockClientScan();
		_process.onChat = _graphic.appendText;
		_process.onOthers = _graphic.refreshOthers;
		_process.onMe = _graphic.refreshMe;
		_process.onRoom = _graphic.changeRoom;
		_process.onConnected = _graphic.connect;
		_process.onMsgSystem = function( text:String, type:SystemMsg ) { _graphic.appendText("<i>"+text+"</i>"); };
		
		_graphic.sendMsg = _process.appliChat;
		
		Lib.current.stage.addChild( _graphic );
	}
	
}