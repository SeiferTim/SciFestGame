package;

import flash.display.BitmapData;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.geom.Point;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
using flixel.util.FlxSpriteUtil;

class Ground extends FlxSprite 
{

	public var expTween:FlxTween;
	private var expPos:FlxPoint;
	public var parent:PlayState;
	
	public function new(Parent:PlayState) 
	{
		super();
		parent = Parent;
		
		var noise:BitmapData = new BitmapData(FlxG.width,1, false, 0xFF000000);
		noise.perlinNoise(Std.int(FlxG.width), 4,FlxG.random.int(5,20), FlxG.random.int(), false, false, 7, true, [new Point(FlxG.random.float(0,FlxG.width), 0)]);
		
		
		makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true, "ground");
		for (i in 0...FlxG.width)
		{
			
			var p:Int = noise.getPixel(i, 0);
			var c:Float = FlxColor.fromInt(p).redFloat;
		
			var start:Int = Std.int((FlxG.height * .4) + (FlxG.height * .5 * c));
			
			var c:FlxColor = FlxColor.GREEN.getLightened(.15);
			var d:Float = 0.001;
			
			for (y in start...Std.int(FlxG.height))
			{

				pixels.setPixel32(i, y, c.getDarkened(d).getLightened(FlxG.random.float(0,.1)));
				d *= 1.025;
				
				
				
			}
			
			
		}
		
		dirty = true;
		
	}
	
	public function checkCollide(X:Int, Y:Int):Bool
	{
		if (x <0 || x > FlxG.width)
		{
			if (y <= height)
				return false;
			
		}
		if (y > FlxG.height)
		{
			return true;
			
		}
		else if (y < 0)
		{
			return false;
		}
		return pixels.getPixel(X, Y) != 0;
		
	}
	
	public function findGround(X:Int, ?StartY:Int = -1):Int
	{
		if (StartY == -1)
		{
			for (y in 0...FlxG.height)
			{
				if ( pixels.getPixel(X, y) != 0)
					return y - 1;	
			}
		}
		else
		{
			for (y in StartY...FlxG.height)
			{
				if ( pixels.getPixel(X, y) != 0)
					return y - 1;
			}
		}
		return FlxG.height -1;
	}
	
	public function doExplosion(X:Int, Y:Int):Void
	{
		expPos = FlxPoint.get(X, Y);
		expTween = FlxTween.num(1, 30, .33, {type:FlxTween.ONESHOT, ease:FlxEase.quartOut, onComplete:finishExplosion}, drawExplosion);
	}
	
	private function drawExplosion(Value:Float):Void
	{
		drawCircle(Std.int(expPos.x), Std.int(expPos.y), Std.int(Value), FlxColor.YELLOW, {pixelHinting:false});
	}
	
	private function finishExplosion(_):Void
	{
		var hurt01:Bool = false;
		var hurt02:Bool = false;
		for (X in Std.int(parent.tank01.x)...Std.int(parent.tank01.x+parent.tank01.width))
		{
			for (Y in Std.int(parent.tank01.y)...Std.int(parent.tank01.y+parent.tank01.height))
			{
				
				if ( FlxColor.fromInt(pixels.getPixel32(X, Y)) == FlxColor.YELLOW)
				{
					hurt01 = true;
				}
				
			}
		}
		
		for (X in Std.int(parent.tank02.x)...Std.int(parent.tank02.x + parent.tank02.width))
		{
			for (Y in Std.int(parent.tank02.y)...Std.int(parent.tank02.y + parent.tank02.height))
			{
				
				if ( FlxColor.fromInt(pixels.getPixel32(X, Y)) == FlxColor.YELLOW)
				{
					hurt02 = true;
				}
				
			}
		}
		
		if (hurt01)
		{
			parent.tank01.hurt(20);
			
		}
		
		if (hurt02)
		{
			parent.tank02.hurt(20);
		}
		
		for (X in 0...Std.int(FlxG.width))
		{
			for (Y in 0...Std.int(FlxG.height))
			{
				var g:FlxColor =  FlxColor.fromInt(pixels.getPixel(X, Y));

				if ((Math.floor(g.hue) < Math.floor(FlxColor.GREEN.hue) - 2 || Math.floor(g.hue) > Math.floor(FlxColor.GREEN.hue) + 2) && g != FlxColor.BLACK )
				{
					pixels.setPixel32(X,Y, 0x0);
				}
			}
		}
		
		parent.wait = false;
	}
	
}