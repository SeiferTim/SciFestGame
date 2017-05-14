package;

import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;

class Turret extends FlxSprite 
{
	public var power:Int;
	public var attach:Tank;

	public function new(Owner:Int, Color:FlxColor, Attach:Tank) 
	{
		super();
		makeGraphic(12, 4, Color, true);
		attach = Attach;
		origin.x = 0;
		origin.y = 2;
		power = 50;
	}
	
	override public function update(elapsed:Float):Void 
	{
		x = attach.x + (attach.width / 2);
		y = attach.y - 2;
		if(!attach.alive)
			kill();
		super.update(elapsed);
		
	}
	
	
	
}