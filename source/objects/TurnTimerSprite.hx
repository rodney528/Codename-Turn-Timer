class TurnTimerSprite extends FunkinSprite {
	public var circleShader:CustomShader;

	public var percent(get, set):Float;
	function get_percent():Float
		return circleShader.percent;
	function set_percent(value:Float):Float
		return circleShader.percent = FlxMath.bound(value, 0, 1);

	public function new(?isPixel:Bool) {
		isPixel ??= false;
		super(0, 0, Paths.image('dial-sprite' + (isPixel ? '-pixel' : '')));
		setGraphicSize(50, 50);
		scale.x *= 1.7;
		scale.y *= 1.7;
		updateHitbox();
		circleShader = new CustomShader('circle');
		circleShader.percent = 0;
		shader = circleShader;
		antialiasing = !isPixel;
	}
}