# dune-lib

lib for Haxe games development

## Objectives

* lightweight
* easy
* performance


## Compile the samples

**MS Windows**

1. Run the commands to compile it with the file `compile-samples.bat`
2. All the compiled files are in the new directory: `bin-all/`

! For `bin-all/MultiPlayer.swf` and `bin-all/SocketClientTchat.swf` you must run a server


**Linux**

1. Go on this directory
1. Run the commands to compile it: `haxe src/dl/samples/compile-all.hxml`
2. All the compiled files are in the new directory: `bin-all/`

! For `bin-all/MultiPlayer.swf` and `bin-all/SocketClientTchat.swf` you must run a server


## Run the server
width Neko 2.x

**MS Windows**

1. Compile the samples
2. Run the file `bin-all/server/run-server.bat`

**Linux**

1. Compile the samples
2. Run the command to start the server: `sudo neko bin-all/server/SocketServer.n`

! superuser (`sudo`) to use the port 843 (Flash Policy File distributor)


## Roadmap

* sockets
	* 80% client (only flash)
	* 80% server (only neko)

* physic
	* 90% platform jump
	* collisions
		* 70% squares
		* 100% space grid
		* 50% multi-player
	* reaction
		* 25% mass (body)
		* 0% velocity (body)
		* 50% priority
			1. movables (with velocity and mass)
			2. fixes (by area)
* input
	* 0% gamepad
	* 90% keyboard
	