import funkin.editors.charter.Charter;
import objects.TurnTimerSprite;

public var turnTimer:TurnTimerSprite;
var earliestPoint:Float = PlayState.chartingMode && Charter.startHere ? Charter.startHere : 0;
var latestPoint:Float = 0;
// would be doing "set_" but that just doesn't work for some reason
function greaterTimeCheck(oldTime:Float, newTime:Float):Float
	return newTime > oldTime ? newTime : oldTime;

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
		var calculatedStepDuration:Float = (latestPoint - earliestPoint) / Conductor.stepCrochet; // step count between points
		var stepsPerMeasure:Float = Conductor.beatsPerMeasure * Conductor.stepsPerBeat; // total steps per measure
		var stepOffset:Float = 0.7; // shortens "stepsPerMeasure" amount by said amount of steps
		/* trace(
			calculatedStepDuration,
			Math.max(stepsPerMeasure - stepOffset, 0), // Math.max used to prevent negative numbers
			calculatedStepDuration < Math.max(stepsPerMeasure - stepOffset, 0) // final math
		); */
		var gapTooSmall = calculatedStepDuration < Math.max(stepsPerMeasure - stepOffset, 0);
		if (!gapTooSmall) turnTimer.percent = FlxMath.remapToRange(inst.time, earliestPoint, latestPoint, 0, 1);
		turnTimer.alpha = lerp(turnTimer.alpha, gapTooSmall ? 0 : 1, 0.15);
	}
}

function updateTiming(?note:Note):Void {
	if (turnTimer.visible) {
		if (note == null) {
			var newTime:Float = 0;
			for (strumLine in strumLines)
				if (strumLine.opponentSide == PlayState.opponentMode)
					for (note in strumLine.notes)
						if (!note.isSustainNote && note.strumTime > earliestPoint) // unsure if putting a break is needed for unnecessary looping, will look into later
							newTime = note.strumTime;
			latestPoint = greaterTimeCheck(latestPoint, newTime);
		} else if (!note.isSustainNote && note.strumLine.opponentSide == PlayState.opponentMode) {
			earliestPoint = greaterTimeCheck(earliestPoint, note.strumTime + getSustainLength(note));
			if (note.nextNote.isSustainNote) {
				var lastNote:Note;
				function timeCheck(saidNote:Note) {
					sustainLoop(saidNote.nextNote, (sustain:Note) -> lastNote = sustain.nextNote);
					if (lastNote != null && lastNote.strumTime == saidNote.strumTime)
						timeCheck(lastNote);
				}
				timeCheck(note);
				latestPoint = lastNote == null ? earliestPoint : greaterTimeCheck(latestPoint, lastNote.strumTime);
			} else latestPoint = greaterTimeCheck(latestPoint, note.nextNote.strumTime);
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