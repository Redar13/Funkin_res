package funkin.api.discord;

import Sys.sleep;
#if discord_rpc
import discord_rpc.DiscordRpc;
#end

class DiscordClient
{
	#if discord_rpc
	public function new()
	{
		trace("Discord Client starting...");
		DiscordRpc.start(
		{
			clientID: "885223855327698985",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		trace("Discord Client started.");

		while (true)
		{
			DiscordRpc.process();
			sleep(2);
			// trace("Discord Client Update");
		}

		DiscordRpc.shutdown();
	}

	public static function shutdown()
	{
		DiscordRpc.shutdown();
	}

	static function onReady()
	{
		DiscordRpc.presence(
		{
			details: "In the Menus",
			state: null,
			largeImageKey: 'icon',
			largeImageText: "Friday Night Funkin': Grafex"
		});
	}

	static function onError(_code:Int, _message:String)
	{
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('Disconnected! $_code : $_message');
	}

	public static function initialize()
	{
		var DiscordDaemon = sys.thread.Thread.create(() -> {
			new DiscordClient();
		});
		trace("Discord Client initialized");
	}

	public static function changePresence(details:String, ?state:String, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float)
	{
		var startTimestamp:Float = if (hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0)
		{
			endTimestamp = startTimestamp + endTimestamp;
		}

		DiscordRpc.presence(
		{
			details: details,
			state: state,
			largeImageKey: 'gameicon',
			largeImageText: "Friday Night Funkin': Grafex",
			smallImageKey: smallImageKey,
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp: Std.int(startTimestamp / 1000),
			endTimestamp: Std.int(endTimestamp / 1000)
		});

		// trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
	}
	#end
}
