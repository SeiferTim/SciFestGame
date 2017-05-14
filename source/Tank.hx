package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;

class Tank extends FlxSprite 
{

	public var parent:PlayState;
	public var fell:Bool = false;
	
	public function new(Owner:Int, Color:FlxColor, Parent:PlayState) 
	{
		super();
		parent = Parent;
		makeGraphic(20, 12, Color, true);
		health = 100;
	
		
	}
	
	public function getBaseX():Int
	{
		return Std.int(x + (width / 2));
	}
	
	override public function update(elapsed:Float):Void 
	{
		fell = false;
		if (Std.int(y + height + 1) < parent.ground.findGround(getBaseX(), Std.int(y+height-1)))
		{
			fell = true;
			y++;
		}
		
		super.update(elapsed);
	}
}