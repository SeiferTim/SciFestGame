package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;

class PlayState extends FlxState
{
	
	public var ground:Ground;
	
	public var tank01:Tank;
	public var turret01:Turret;
	
	public var tank02:Tank;
	public var turret02:Turret;
	
	public var playerTurn:Int = -1;
	
	public var topMsg:FlxText;
	
	public var msgTween:FlxTween;
	public var playerAct:Bool = false;
	
	public var keyPressDelay:Float = 0;
	
	public var hud:HUD;
	
	public var bullet:Bullet;
	public var wait:Bool = false;
	
	public var gameEnded:Bool = false;
	
	public var windAmt:Int = 0;
	
	
	override public function create():Void
	{
		
		var bg:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [FlxColor.PURPLE.getDarkened(.1), FlxColor.PURPLE.getDarkened(.9)], 2, -90);
		add(bg);
		
		ground = new Ground(this);
		
		add(ground);
		
		tank01 = new Tank(0, FlxColor.CYAN, this);
		turret01 = new Turret(0, FlxColor.CYAN, tank01);
		
		tank01.x = FlxG.random.int(40, 120);
		tank01.y = ground.findGround(tank01.getBaseX()) - tank01.height;
		turret01.angle = -45;
		add(tank01);
		add(turret01);
		
		tank02  = new Tank(1, FlxColor.ORANGE, this);
		turret02 = new Turret(1, FlxColor.ORANGE, tank02);
		
		tank02.x = FlxG.width - FlxG.random.int(40, 120) - tank02.width;
		tank02.y = ground.findGround(tank02.getBaseX()) - tank02.height;
		
		turret02.angle = -135;
		
		add(tank02);
		add(turret02);
		
		bullet = new Bullet(this);
		add(bullet);
		
		topMsg = new FlxText();
		topMsg.size = 22;
		topMsg.y = 10;
		topMsg.screenCenter(FlxAxes.X);
		topMsg.alpha = 0;
		add(topMsg);
		
		
		hud = new HUD(this);
		add(hud);
		
		showPlayerTurn(0);
		
		super.create();
		
	}

	override public function update(elapsed:Float):Void
	{
		if (gameEnded)
		{
			if (FlxG.keys.anyJustReleased([SPACE]))
				FlxG.resetGame();
		}
		else
		{
			
		
			if (keyPressDelay >0)
				keyPressDelay -= elapsed;
			else
			{		
				if (playerAct)
				{
					
					switch(playerTurn)
					{
						case 0:
							
							if (FlxG.keys.anyPressed([UP, W]))
							{
								turret01.angle-= 5;
								turret01.angle = FlxAngle.wrapAngle(turret01.angle);
								keyPressDelay = .02;
							}
							else if (FlxG.keys.anyPressed([DOWN, S]))
							{
								turret01.angle+= 5;
								turret01.angle = FlxAngle.wrapAngle(turret01.angle);
								keyPressDelay = .02;
							}
							if (FlxG.keys.anyPressed([LEFT, A]))
							{
								turret01.power -= 5;
								if (turret01.power < 0)
									turret01.power = 0;
								keyPressDelay = .02;
								
							}
							else if (FlxG.keys.anyPressed([RIGHT, D]))
							{
								turret01.power += 5;
								if (turret01.power > 100)
									turret01.power = 100;
								keyPressDelay = .02;
							}
							if (FlxG.keys.anyJustReleased([SPACE]))
							{
								fireBullet();
							}
						case 1:
							
							if (FlxG.keys.anyPressed([UP, W]))
							{
								turret02.angle-= 5;
								turret02.angle = FlxAngle.wrapAngle(turret02.angle);
								keyPressDelay = .02;
							}
							else if (FlxG.keys.anyPressed([DOWN, S]))
							{
								turret02.angle+= 5;
								turret02.angle = FlxAngle.wrapAngle(turret02.angle);
								keyPressDelay = .02;
							}
							if (FlxG.keys.anyPressed([LEFT, A]))
							{
								turret02.power -= 5;
								if (turret02.power < 0)
									turret02.power = 0;
								keyPressDelay = .02;
								
							}
							else if (FlxG.keys.anyPressed([RIGHT, D]))
							{
								turret02.power += 5;
								if (turret02.power > 100)
									turret02.power = 100;
								keyPressDelay = .02;
							}
							if (FlxG.keys.anyJustReleased([SPACE]))
							{
								fireBullet();
							}
							
							
					}
					
				}
				else if (!wait)
				{
					if (!tank01.alive || !tank02.alive)
					{				
						if (!tank01.alive && !tank02.alive)
						{
							topMsg.text = "DRAW!";
						}
						else if (!tank01.alive)
						{
							topMsg.text = "Player 2 Wins!";
						}
						else if (!tank02.alive)
						{
							topMsg.text = "Player 1 Wins!";
						}
						topMsg.screenCenter(FlxAxes.X);
						msgTween = FlxTween.tween(topMsg, {alpha:1}, .2, {type:FlxTween.ONESHOT, ease:FlxEase.sineIn, onComplete:GameEnd});
					}
					else if (!tank01.fell && !tank02.fell)
					{
						showPlayerTurn(playerTurn == 0 ? 1 : 0);
					}
				}
			}
		}
		super.update(elapsed);
	}
	
	private function GameEnd(_):Void
	{
		playerAct = false;
		
		var gameover:FlxText = new FlxText();
		gameover.size = 34;
		gameover.text = "GAME OVER";
		gameover.screenCenter();
		gameover.alpha = 0;
		FlxTween.tween(gameover, {alpha:1}, .2, {type:FlxTween.ONESHOT, ease:FlxEase.sineIn, onComplete:GameEnd2, startDelay:.1});
		add(gameover);
		
		var pressAny:FlxText = new FlxText();
		pressAny.size = 12;
		pressAny.text = "PRESS [SPACE] TO START OVER";
		pressAny.screenCenter();
		pressAny.y = gameover.y + gameover.height + 5;
		pressAny.alpha = 0 ;
		FlxTween.tween(pressAny, {alpha:1}, .2, {type:FlxTween.ONESHOT, ease:FlxEase.sineIn, onComplete:GameEnd3, startDelay:.2});
		add(pressAny);
	}
	
	private function GameEnd2(_):Void
	{
		
	}
	
	
	private function GameEnd3(_):Void
	{
		gameEnded = true;
	}
	
	public function fireBullet():Void
	{
		
		var p:FlxPoint;
		
		switch(playerTurn)
		{
			case 0:
				
				p = FlxPoint.get(turret01.width, 2);
				p.rotate(FlxPoint.weak(), turret01.angle);
				
				bullet.x = turret01.x + p.x;
				bullet.y = turret01.y +  p.y;
				
				
				bullet.velocity.set(turret01.power*(5), 0);
				bullet.velocity.rotate(FlxPoint.weak(), turret01.angle);
				bullet.velocity.x += bullet.velocity.x * (windAmt / 200);
				bullet.revive();
				
				p.put();
				
				playerAct = false;
				
				
			case 1:
				
				p = FlxPoint.get(turret02.width, 2);
				p.rotate(FlxPoint.weak(), turret02.angle);
				
				bullet.x = turret02.x + p.x;
				bullet.y = turret02.y +  p.y;
				
				bullet.velocity.set(turret02.power*(5), 0);
				bullet.velocity.rotate(FlxPoint.weak(), turret02.angle);
				bullet.velocity.x += bullet.velocity.x * (windAmt / 200);
				bullet.revive();
				
				p.put();
				
				playerAct = false;
		}
	}
	
	
	private function showPlayerTurn(PlayerTurn:Int):Void
	{
		windAmt = FlxG.random.int( -100, 100);
		wait = true;
		playerTurn = PlayerTurn;
		topMsg.text = "Player " + Std.string(PlayerTurn+1);
		topMsg.alpha = 0;
		topMsg.screenCenter(FlxAxes.X);
		msgTween = FlxTween.tween(topMsg, {alpha:1}, .2, {type:FlxTween.ONESHOT, ease:FlxEase.sineIn, onComplete:FinishPlayerTurn});
	}
	
	private function FinishPlayerTurn(_):Void
	{
		msgTween = FlxTween.tween(topMsg, {alpha:0}, .2, {type:FlxTween.ONESHOT, ease:FlxEase.sineOut, onComplete:ReadyPlayerTurn, startDelay:1});
	}
	
	private function ReadyPlayerTurn(_):Void
	{
		playerAct = true;
	}
}
