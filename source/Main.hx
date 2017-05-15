package;

import axollib.AxolAPI;
import flixel.FlxGame;
import openfl.display.Sprite;
import axollib.DissolveState;

class Main extends Sprite
{
	public function new()
	{
		super();
		AxolAPI.firstState = PlayState;
		addChild(new FlxGame(0, 0, DissolveState));
	}
}
