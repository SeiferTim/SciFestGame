package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;

class Bullet extends FlxSprite 
{
	
	public var parent:PlayState;

	public function new(Parent:PlayState) 
	{
		super();
		parent = Parent;
		makeGraphic(4, 4, FlxColor.RED);
		acceleration.y = 500;
		centerOrigin();
		kill();
	}
	
	
	override public function update(elapsed:Float):Void 
	{
		
		if (hitPlayer() || hitGround() || x + width < 0 || x > FlxG.width)
		{
			parent.ground.doExplosion(Std.int(x), Std.int(y));
			kill();
		}
		else 
		{
			
		}
		
		super.update(elapsed);
	}
	
	private function hitPlayer():Bool
	{
		return overlaps(parent.tank01) || overlaps(parent.tank02);
	}
	
	private function hitGround():Bool
	{
		for (i in 0...Std.int(width))
		{
			for (j in 0...Std.int(height))
			{
				if (parent.ground.checkCollide(Std.int(x+i), Std.int(y+j)))
					return true;
			}
		}
		return false;
	}
	
}