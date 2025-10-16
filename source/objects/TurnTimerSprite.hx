import funkin.backend.system.Flags;

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
		var scale:Float = 160 * Flags.DEFAULT_NOTE_SCALE * 0.9;
		setGraphicSize(scale, scale);
		updateHitbox();
		circleShader = new CustomShader('radialCrop');
		circleShader.percent = 0;
		shader = circleShader;
		antialiasing = !isPixel;
	}
}