@echo off

RD bin-all /S /Q
::RD doc /S /Q
MD bin-all
MD doc
MD bin-all\server

haxe src/dl/samples/compile-all.hxml

echo @echo off > bin-all\server\run-server.bat
echo neko SocketServer.n >> bin-all\server\run-server.bat
::echo pause >> bin-all\server\run-server.bat

@pause