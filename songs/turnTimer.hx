import funkin.editors.charter.Charter;
import objects.TurnTimerSprite;

public var turnTimer:TurnTimerSprite;
var earliestPoint:Float = PlayState.chartingMode && Charter.startHere ? Charter.startHere : 0;
var latestPoint:Float = 0;

function postCreate():Void {
	turnTimer = new TurnTimerSprite();
	turnTimer.visible = !PlayState.coopMode;
	turnTimer.screenCenter(FlxAxes.X);
	turnTimer.cameras = [camHUD];
	turnTimer.y = 60;
	add(turnTimer);
	updateTiming();
}

function postUpdate(elapsed:Float):Void {
	if (turnTimer.visible) {
		var gapTooSmall = latestPoint - earliestPoint <= Conductor.crochet * Conductor.beatsPerMeasure;
		if (!gapTooSmall) turnTimer.percent = FlxMath.remapToRange(inst.time, earliestPoint, latestPoint, 0, 1);
		turnTimer.alpha = lerp(turnTimer.alpha, gapTooSmall ? 0 : 1, 0.15);
	}
}

function updateTiming(?note:Note):Void {
	if (turnTimer.visible) {
		var timeOffset:Float = Conductor.stepCrochet * (Conductor.beatsPerMeasure / 2);
		if (note == null) {
			for (strumLine in strumLines)
				if (strumLine.opponentSide == PlayState.opponentMode)
					for (note in strumLine.notes)
						if (!note.isSustainNote && note.strumTime > earliestPoint) // unsure if putting a break is needed for unnecessary looping, will look into later
							latestPoint = Math.max(note.strumTime - timeOffset, 0);
		} else if (!note.isSustainNote && note.strumLine.opponentSide == PlayState.opponentMode) {
			earliestPoint = note.strumTime + getSustainLength(note);
			if (note.nextNote.isSustainNote) {
				var lastNote:Note;
				sustainLoop(note.nextNote, (sustain:Note) -> lastNote = sustain.nextNote);
				latestPoint = Math.max(lastNote == null ? earliestPoint : lastNote.strumTime - timeOffset, 0);
			} else latestPoint = Math.max(note.nextNote.strumTime - timeOffset, 0);
		}
	}
}

function onNoteHit(event):Void {
	updateTiming(event.note);
}
function onPlayerMiss(event):Void {
	updateTiming(event.note);
}

function getSustainLength(note:Note):Float {
	var length:Float = 0;
	sustainLoop(note.nextNote, (sustain:Note) -> length += sustain.sustainLength, true);
	return length;
}
function sustainLoop(note:Note, func:Note->Void, ?noEffectParent:Bool):Void {
	var aNote:Note = note;
	noEffectParent ??= false;
	while (aNote != null) {
		if (noEffectParent ? aNote != note : true)
			func(aNote);
		aNote = aNote.nextSustain;
	}
}