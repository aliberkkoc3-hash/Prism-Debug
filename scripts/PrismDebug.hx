import Main;
import funkin.modding.module.Module;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.system.System;

class PrismDebug extends Module {
	var panel:FlxSprite;
	var accent:FlxSprite;
	var header:FlxText;

	var fpsText:FlxText;
	var peakText:FlxText;
	var frameText:FlxText;
	var memoryText:FlxText;
	var resolutionText:FlxText;
	var footer:FlxText;

	var panelVisible:Bool = false;
	var detailedMode:Bool = false;

	var currentState:Dynamic = null;
	var fpsPeak:Int = 0;

	// Prism color palette
	var cyan:Int = 0xFF36D9FF;
	var green:Int = 0xFF55E878;
	var orange:Int = 0xFFFFAA32;
	var red:Int = 0xFFFF4545;
	var white:Int = 0xFFE6EDF5;
	var muted:Int = 0xFF71869A;

	// Fixed position and size
	var panelX:Int = 10;
	var panelY:Int = 10;
	var panelWidth:Int = 290;
	var panelHeight:Int = 180;

	// Always-on-top priority
	var topLayer:Int = 999999;

	function new() {
		super("PrismDebug", 0);
	}

	override function onCreate(event) {
		super.onCreate(event);
		trace("[PrismDebug] Initialized.");
	}

	function applyTopLayer() {
		if (panel == null)
			return;

		panel.zIndex = topLayer;
		accent.zIndex = topLayer + 1;
		header.zIndex = topLayer + 2;
		fpsText.zIndex = topLayer + 3;
		peakText.zIndex = topLayer + 4;
		frameText.zIndex = topLayer + 5;
		memoryText.zIndex = topLayer + 6;
		resolutionText.zIndex = topLayer + 7;
		footer.zIndex = topLayer + 8;
	}

	function createPanel() {
		panel = new FlxSprite(panelX, panelY);
		panel.makeGraphic(panelWidth, panelHeight, 0xEE101722);
		panel.scrollFactor.set(0, 0);

		accent = new FlxSprite(panelX, panelY);
		accent.makeGraphic(3, panelHeight, cyan);
		accent.scrollFactor.set(0, 0);

		header = new FlxText(panelX + 12, panelY + 8, 265, "PRISM DEBUG");
		header.setFormat(null, 16, cyan, "left");
		header.scrollFactor.set(0, 0);

		fpsText = new FlxText(panelX + 12, panelY + 38, 265, "");
		fpsText.setFormat(null, 14, green, "left");
		fpsText.scrollFactor.set(0, 0);

		peakText = new FlxText(panelX + 12, panelY + 60, 265, "");
		peakText.setFormat(null, 12, white, "left");
		peakText.scrollFactor.set(0, 0);

		frameText = new FlxText(panelX + 12, panelY + 80, 265, "");
		frameText.setFormat(null, 12, green, "left");
		frameText.scrollFactor.set(0, 0);

		memoryText = new FlxText(panelX + 12, panelY + 100, 265, "");
		memoryText.setFormat(null, 12, green, "left");
		memoryText.scrollFactor.set(0, 0);

		resolutionText = new FlxText(panelX + 12, panelY + 120, 265, "");
		resolutionText.setFormat(null, 12, cyan, "left");
		resolutionText.scrollFactor.set(0, 0);

		footer = new FlxText(panelX + 12, panelY + 148, 265, "PRISM CREW // BEYOND THE SPECTRUM");
		footer.setFormat(null, 9, muted, "left");
		footer.scrollFactor.set(0, 0);

		panel.visible = panelVisible;
		accent.visible = panelVisible;
		header.visible = panelVisible;
		fpsText.visible = panelVisible;
		peakText.visible = panelVisible && detailedMode;
		frameText.visible = panelVisible && detailedMode;
		memoryText.visible = panelVisible;
		resolutionText.visible = panelVisible && detailedMode;
		footer.visible = panelVisible;

		FlxG.state.add(panel);
		FlxG.state.add(accent);
		FlxG.state.add(header);
		FlxG.state.add(fpsText);
		FlxG.state.add(peakText);
		FlxG.state.add(frameText);
		FlxG.state.add(memoryText);
		FlxG.state.add(resolutionText);
		FlxG.state.add(footer);

		applyTopLayer();
	}

	function destroyPanel() {
		if (panel != null) {
			panel.destroy();
			panel = null;
		}
		if (accent != null) {
			accent.destroy();
			accent = null;
		}
		if (header != null) {
			header.destroy();
			header = null;
		}
		if (fpsText != null) {
			fpsText.destroy();
			fpsText = null;
		}
		if (peakText != null) {
			peakText.destroy();
			peakText = null;
		}
		if (frameText != null) {
			frameText.destroy();
			frameText = null;
		}
		if (memoryText != null) {
			memoryText.destroy();
			memoryText = null;
		}
		if (resolutionText != null) {
			resolutionText.destroy();
			resolutionText = null;
		}
		if (footer != null) {
			footer.destroy();
			footer = null;
		}
	}

	function getFPSColor(fps:Int):Int {
		if (fps < 30)
			return red;
		if (fps < 50)
			return orange;
		return green;
	}

	function getFrameColor(ms:Float):Int {
		if (ms > 33)
			return red;
		if (ms >= 17)
			return orange;
		return green;
	}

	function getMemoryColor(mb:Float):Int {
		if (mb >= 512)
			return red;
		if (mb >= 256)
			return orange;
		return green;
	}

	function updatePanel() {
		if (panel == null)
			return;

		var fps:Int = 0;
		var frameTime:Float = 0;

		if (FlxG.elapsed > 0) {
			fps = Math.floor(1 / FlxG.elapsed);
			frameTime = FlxG.elapsed * 1000;
		}

		if (fps > fpsPeak)
			fpsPeak = fps;

		var memoryMB:Float = System.totalMemory / 1048576;
		var memoryRounded:Float = Math.round(memoryMB * 10) / 10;
		var frameRounded:Float = Math.round(frameTime * 100) / 100;

		fpsText.text = "FPS: " + fps;
		fpsText.color = getFPSColor(fps);

		peakText.text = "FPS PEAK: " + fpsPeak;
		peakText.color = getFPSColor(fpsPeak);

		frameText.text = "FRAME TIME: " + frameRounded + " ms";
		frameText.color = getFrameColor(frameTime);

		memoryText.text = "MEMORY: " + memoryRounded + " MB";
		memoryText.color = getMemoryColor(memoryMB);

		resolutionText.text = "RESOLUTION: " + FlxG.width + " x " + FlxG.height;
		resolutionText.color = cyan;

		header.text = detailedMode ? "PRISM DEBUG // ADVANCED" : "PRISM DEBUG";

		fpsText.visible = panelVisible;
		memoryText.visible = panelVisible;

		peakText.visible = panelVisible && detailedMode;
		frameText.visible = panelVisible && detailedMode;
		resolutionText.visible = panelVisible && detailedMode;

		panel.visible = panelVisible;
		accent.visible = panelVisible;
		header.visible = panelVisible;
		footer.visible = panelVisible;
	}

	override function onUpdate(event) {
		super.onUpdate(event);

		if (FlxG.state == null)
			return;

		if (currentState != FlxG.state) {
			destroyPanel();
			currentState = FlxG.state;
			createPanel();
		}

		if (Main.debugDisplay != null)
			Main.debugDisplay.visible = false;

		// CTRL + F6: Advanced mode
		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.F6) {
			detailedMode = !detailedMode;
			panelVisible = true;
		}
		// F6: Toggle panel
		else if (FlxG.keys.justPressed.F6) {
			panelVisible = !panelVisible;
		}

		updatePanel();
	}

	override function onDestroy(event) {
		destroyPanel();
		super.onDestroy(event);
	}
}
