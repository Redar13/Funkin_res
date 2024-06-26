package;

import flixel.FlxGame;
import flixel.FlxState;
import funkin.util.logging.CrashHandler;
import funkin.save.Save;
import haxe.ui.Toolkit;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;
import openfl.media.Video;
import openfl.net.NetStream;

/**
 * The main class which initializes HaxeFlixel and starts the game in its initial state.
 */
class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = funkin.InitState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 144; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		// We need to make the crash handler LITERALLY FIRST so nothing EVER gets past it.
		CrashHandler.initialize();
		CrashHandler.queryStatus();

		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		// Initialize custom logging.
		haxe.Log.trace = funkin.util.logging.AnsiTrace.trace;
		funkin.util.logging.AnsiTrace.traceBF();

		// Load mods to override assets.
		// TODO: Replace with loadEnabledMods() once the user can configure the mod list.
		funkin.modding.PolymodHandler.loadAllMods();

		stage != null ? init() : addEventListener(Event.ADDED_TO_STAGE, init);
	}

	function init(?event:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	var video:Video;
	var netStream:NetStream;
	var overlay:Sprite;

	/**
	 * Displayed at the top left. Shows FPS and RAM.
	 */
	public static var statisticMonitor:funkin.ui.debug.StatisticMonitor;

	function setupGame():Void
	{
		initHaxeUI();

		// addChild gets called by the user settings code.
		statisticMonitor = new funkin.ui.debug.StatisticMonitor(10, 3, 0xFFFFFF);

		// George recommends binding the save before FlxGame is created.
		Save.load();
		var game:FlxGame = new FlxGame(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash, startFullscreen);


		hxvlc.util.Handle.init();
		// FlxG.game._customSoundTray wants just the class, it calls new from
		// create() in there, which gets called when it's added to stage
		// which is why it needs to be added before addChild(game) here
		//@:privateAccess
		//game._customSoundTray = funkin.ui.options.FunkinSoundTray;
		//game._customSoundTray = funkin.ui.options.GrafexSoundTray;

		addChild(game);

		#if debug
		game.debugger.interaction.addTool(new funkin.util.TrackerToolButtonUtil());
		#end

		addChild(statisticMonitor);

		#if hxcpp_debug_server
		trace('hxcpp_debug_server is enabled! You can now connect to the game with a debugger.');
		#else
		trace('hxcpp_debug_server is disabled! This build does not support debugging.');
		#end
	}

	function initHaxeUI():Void
	{
		// Calling this before any HaxeUI components get used is important:
		// - It initializes the theme styles.
		// - It scans the class path and registers any HaxeUI components.
		Toolkit.init();
		Toolkit.theme = 'dark'; // don't be cringe
		Toolkit.autoScale = false;
		// Don't focus on UI elements when they first appear.
		haxe.ui.focus.FocusManager.instance.autoFocus = false;
		funkin.input.Cursor.registerHaxeUICursors();
		haxe.ui.tooltips.ToolTipManager.defaultDelay = 200;
	}
}
