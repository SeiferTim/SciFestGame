# SciFestGame

## Overview

I was invited to participate in SciFest: Game On! at the St Louis Science Center on 5/13/2017. I decided to challenge myself to make a 'finished' game during the course of the event in order to show the process of making a game to visitors.

This is the result of that challenge.

## Concept

I asked my daughter what type of game I should make, and she suggested a 'Tank Shooter' - a simple enough game where players take turns firing shells at each other from opposite sides of a map. Each play can adjust their angle and power for shooting, and the first player to knock out their opponent wins.

Based on knowing this, I came up with a concise list of what I would need to make this a complete game:

- Randomly generated terrain
- tanks for 2 players
- a turn-system where each player can act one at a time
- ability to adjust angle and power on a player's turn
- bullet that explodes when it impacts the ground/player, and destroys terrain
- 'gravity' so tanks won't float over destroyed ground
- health for each player and a game over/victory when one player dies

Seems simple enough.
I also wanted to refrain from using any import graphic assets. I wanted to draw everything with code.

Of course, I would be using [HaxeFlixel](http://haxeflixel.com/) for this.

## Coding

### Terrain Generation

First, I needed to create the terrain for the tanks to fight on. I knew that I could use a `bitmapData` and draw on top of it, but I didn't just want to draw a line at every X position starting from a random Y position - it would look too random. Instead, I thought about using Perlin Noise to come up with a sort of 'height map'. I made a `bitmapData` that was as wide as my game, and 1 pixel heigh, and called `perlinNoise` on it, setting some randomized parameters, to try and make each game more unique:

```haxe
var noise:BitmapData = new BitmapData(FlxG.width,1, false, 0xFF000000);
noise.perlinNoise(Std.int(FlxG.width), 4,FlxG.random.int(5,20), FlxG.random.int(), false, false, 7, true, [new Point(FlxG.random.float(0,FlxG.width), 0)]);
```

Next, I setup a new, transparent `FlxSprite` with the same dimensions of my screen, and then looped through each x pixel. I looked at the matching x pixel of the noise `bitmapData`, and, based on how much red was in that pixel, started at a different y pixel on my `FlxSprite` then drew green pixels all the way to the bottom of the `FlxSprite`. I added some random variations to these ground pixels to make it interesting.

```haxe
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
```

This worked surprisingly well! I had to tweak the perlin parameters a bit to get it looking good enough, and I probably could spend some more time making it more perfect, but, for this project, it was perfect.

### Tanks

Making the players' tanks were pretty simple. I made a `FlxSprite` for the body, that would take a color as a parameter, so I could pick the color for each player later on (I went with Cyan and Orange), and then a `Turret` `FlxSprite` that would follow it's parent body, and be able to rotate around the players' chosen angle.

I had to add a function to my `Ground` class that would take an x position and y position and return the next highest y where there is solid ground. This was how I placed each tank on the map initially, and, each tank would also check to see if there was empty space beneath them duing `update`, and fall if there was.

```haxe
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
```

It's a pretty simple function - just check the pixel on the ground to see if it's black (empty) or not.

### Taking Turns

The logic for my turn-system is pretty simple: 

1. Show the current player's turn on the screen (fade in/out text)
2. Give the current player control
3. When player hits Space, turn off control, and fire a bullet at the specified angle and power
4. Wait until bullet hits something, then call the `Ground.doExplosion` function.
5. `doExplosion` will start drawing expanding yellow circles around a set point on the ground sprite.
6. After it draws the last circle, check to see if either tank overlaps yellow pixels on the ground, and decrease their health by 10 if they do.
7. Replace any non-green, non-black pixels on the ground with transparent-black pixels
8. Wait until there are no falling tanks
9. If either tank is dead, go to game over, otherwise, advance to the next player and start over

### Player Control

I made a simple hud that sits at the bottom of the screen and shows the current player's angle, power, and health.

When a player has control, the player can press Up and Down to adjust the angle of their shot, and Left and Right to adjust their power.

The angle directly changes the angle of thier turret:

```haxe
turret01.angle = FlxAngle.wrapAngle(turret01.angle);
```

Space fires their bullet.

### Bullet

Sneakily, there is only one bullet object in the game. I just kill/revive it as needed - it's a quick and dirty trick since there will never be more than one on the screen at once.

The `Bullet` class is a `FlxSprite` with `acceleration.y` set to 500.

When a player fires, I place the bullet at the tip of their turret:

```haxe
p = FlxPoint.get(turret01.width, 2);
p.rotate(FlxPoint.weak(), turret01.angle);
bullet.x = turret01.x + p.x;
bullet.y = turret01.y +  p.y;
```

Give it a velocity based on angle and power:

```haxe
bullet.velocity.set(turret01.power*(5), 0);
bullet.velocity.rotate(FlxPoint.weak(), turret01.angle);
bullet.velocity.x += bullet.velocity.x * (windAmt / 200);
```

...and then wait for it to detect that it hits something.

To handle the explosion, I setup a `FlxTween` that goes from 1 to 30, and, each time it updates, draws a yellow circle centered on the same point. The effect is of a growing, yellow circle.

```haxe
public function doExplosion(X:Int, Y:Int):Void
{
	expPos = FlxPoint.get(X, Y);
	expTween = FlxTween.num(1, 30, .33, {type:FlxTween.ONESHOT, ease:FlxEase.quartOut, onComplete:finishExplosion}, drawExplosion);
}

private function drawExplosion(Value:Float):Void
{
	drawCircle(Std.int(expPos.x), Std.int(expPos.y), Std.int(Value), FlxColor.YELLOW, {pixelHinting:false});
}
```

When the Tween finishes, I look at each tank, and see if they are overlapping any yellow pixels. If they are, I deal damgage to them.

After that, I replace any non-green-hued pixels with transparent-black. I originally tried just changing all yellow pixels to transparent-black, but, it turns out that `drawCircle` creates some pixels that are semi-opaque, I guess for anti-aliasing? So, when I just replaced the yellow pixels, it would leave a faint ring around the edge of the explosion.

```haxe
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
```

This is how the destructable terrain works.

### Tank Gravity

Tanks should fall if there is empty space below them:

```haxe
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
```

The `fell` flag is used to let the `PlayState` know if it can continue to the next player or not. I could probably only have it check after the explosion has finished, but this is fine.

### Game Over

Finally, after the tanks have finished falling (if at all), I check to see who's still alive, and, if one (or both) have died, the game ends. I allow the player to restart with Space.

## Conclusion

So that's it! The game works! I ended up adding some wind at the last minute to make it a bit harder to hit your opponent (Although, it needs more work to be good).

I think there's a lot that could be added to the game: more players, different weapons, better terrain, etc, but, for a game I made in a single day, it's pretty good!

You can try the game out here: http://www.tims-world.com/projects/scifest-game/
