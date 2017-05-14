package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;

class HUD extends FlxGroup 
{

	private var back:FlxSprite;
	private var parent:PlayState;
	
	public var txtAngle:FlxText;
	
	public var txtPower:FlxText;
	public var txtHealth:FlxText;
	
	public var txtWind:FlxText;
	
	public function new(Parent:PlayState) 
	{
		super();
		parent = Parent;
		back = new FlxSprite(0, FlxG.height - 30);
		back.makeGraphic(FlxG.width, 30, FlxColor.GRAY);
		add(back);
		
		txtAngle = new FlxText(10, 0, 120, "Angle: 000", 12);
		txtAngle.y = FlxG.height - txtAngle.height - 5;
		add(txtAngle);
		
		txtPower = new FlxText(0, 0, 120, "Power: 000", 12);
		txtPower.x = FlxG.width - 130;
		txtPower.y = FlxG.height - txtPower.height -5;
		add(txtPower);
		
		txtHealth = new FlxText(0, 0, 120, "Health: 000", 12);
		txtHealth.y = FlxG.height - txtHealth.height - 5;
		txtHealth.screenCenter(FlxAxes.X);
		add(txtHealth);
		
		txtWind = new FlxText(5, 5, 120, "Wind: 000", 12);
		add(txtWind);
		
	}
	
	override public function update(elapsed:Float):Void 
	{
		switch (parent.playerTurn)
		{
			case 0:
				txtAngle.text = "Angle: " + Std.string(Std.int(-parent.turret01.angle));
				txtPower.text = "Power: " + Std.string(Std.int(parent.turret01.power));
				txtHealth.text = "Health: " + Std.string(Std.int(parent.tank01.health));
				
			case 1:
				
				txtAngle.text = "Angle: " + Std.string(Std.int(-parent.turret02.angle));
				txtPower.text = "Power: " + Std.string(Std.int(parent.turret02.power));
				txtHealth.text = "Health: " + Std.string(Std.int(parent.tank02.health));
				
			default:
				
		}
		
		txtWind.text = "Wind: " + Std.string(parent.windAmt);
		
		super.update(elapsed);
	}
	
}