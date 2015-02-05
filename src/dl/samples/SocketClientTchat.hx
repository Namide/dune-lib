package dl.samples ;

import dl.socket.client.SockClientScan;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;
import dl.socket.client.SockClientUI;
import dl.socket.client.SockClientUser;

/**
 * ...
 * @author Namide
 */

class SocketClientTchat 
{
	static var _MAIN:SocketClientTchat;
	
	var _graphic:SockClientUI;
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
		_graphic = new SockClientUI();
		
		_process = new SockClientScan();
		_process.onChat = _graphic.appendText;
		_process.onUsers = _graphic.refreshUsers;
		_process.onClear = _graphic.clear;
		_graphic.sendMsg = _process.appliChat;
		
		Lib.current.stage.addChild( _graphic );
	}
	
}