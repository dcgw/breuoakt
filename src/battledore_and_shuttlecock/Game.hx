package battledore_and_shuttlecock;

import kong.KongregateApi;
import kong.Kongregate;
import hopscotch.math.Range;
import flash.media.SoundTransform;
import hopscotch.graphics.FontFace;
import flash.text.TextFormatAlign;
import hopscotch.graphics.Text;
import flash.media.Sound;
import nme.installer.Assets;
import hopscotch.input.analogue.Mouse;
import hopscotch.input.analogue.IPointer;
import haxe.PosInfos;
import hopscotch.input.digital.MouseButton;
import hopscotch.input.digital.Button;
import flash.Lib;
import hopscotch.Playfield;
import hopscotch.engine.Engine;

class Game extends Playfield {
    static inline var WIDTH = 640;
    static inline var HEIGHT = 480;
    static inline var LOGIC_RATE = 60;

    static inline var SHUTTLECOCK_START_SPEED = 4.0;
    static inline var LIFT_ON_HIT = 4.0;

    static inline var MUSIC_VOLUME = 0.2;
    static inline var BIP_VOLUME = 0.2;
    static inline var BIP_PAN_AMOUNT = 0.2;

    static inline var SCORE_SUBMIT_INTERVAL = 180;

    var startButton:Button;

    var kongregate:KongregateApi;

    var score:Int;
    var submittedHighscore:Int;

    var frame:Int;
    var lastScoreSubmitFrame:Int;

    var title:Text;
    var scoreText:Text;

    var leftBattledore:Battledore;
    var rightBattledore:Battledore;

    var shuttlecock:Shuttlecock;
    var net:Net;

    var musicPlaying:Bool;

    var bip:Sound;
    var bipSoundTransform:SoundTransform;

    static function main () {
        #if flash
        haxe.Log.trace = function(v:Dynamic, ?pos:PosInfos) {
            flash.Lib.trace(pos.fileName + ":" + pos.lineNumber + ": " + v);
        }
        #end

        var engine = new Engine(Lib.current, WIDTH, HEIGHT, LOGIC_RATE);

        engine.console.enabled = false;

        var startButton = new MouseButton(Lib.current.stage);
        engine.inputs.push(startButton);

        var pointer = new Mouse(Lib.current.stage);
        engine.inputs.push(pointer);

        Kongregate.loadApi(function(kongregate:KongregateApi) {
            kongregate.services.connect();
            engine.playfield = new Game(startButton, pointer, kongregate);
            engine.start();
        });
    }

    public function new (startButton:Button, pointer:IPointer, kongregate:KongregateApi) {
        super();

        this.startButton = startButton;

        this.kongregate = kongregate;

        score = 0;
        submittedHighscore = 0;

        frame = 0;
        lastScoreSubmitFrame = 0;

        var fontFace = new FontFace(Assets.getFont("assets/04B_03__.ttf").fontName);

        title = new Text();
        title.text = "Battledore and Shuttlecock";
        title.fontFace = fontFace;
        title.fontSize = 16;
        title.wordWrap = true;
        title.color = 0xffffff;
        title.y = 16;
        title.width = WIDTH;
        title.align = TextFormatAlign.CENTER;
        addGraphic(title);

        scoreText = new Text();
        scoreText.text = "click to start";
        scoreText.fontFace = fontFace;
        scoreText.fontSize = 16;
        scoreText.wordWrap = true;
        scoreText.color = 0xffffff;
        scoreText.y = 32;
        scoreText.width = WIDTH;
        scoreText.align = TextFormatAlign.CENTER;
        addGraphic(scoreText);

        leftBattledore = new Battledore(pointer);
        leftBattledore.offsetX = -WIDTH * 0.34;
        addEntity(leftBattledore);

        rightBattledore = new Battledore(pointer);
        rightBattledore.offsetX = WIDTH * 0.34;
        addEntity(rightBattledore);

        shuttlecock = new Shuttlecock();
        shuttlecock.x = WIDTH * 0.5;
        shuttlecock.y = HEIGHT * 0.25;
        shuttlecock.active = false;
        addEntity(shuttlecock);

        net = new Net();
        net.x = WIDTH * 0.5;
        net.y = HEIGHT;
        addEntity(net);

        musicPlaying = false;

        bip = Assets.getSound("assets/bip.mp3");
        bipSoundTransform = new SoundTransform(BIP_VOLUME);
    }

    override public function begin (frame:Int) {
        this.frame = frame;

        super.begin(frame);
    }

    override public function update(frame:Int) {
        this.frame = frame;

        super.update(frame);

        if (startButton.justPressed) {
            checkSubmitHighscore(true);

            shuttlecock.x = WIDTH * 0.5;
            shuttlecock.y = HEIGHT *  0.25;

            var direction = if (Math.random() * 2 < 1) -1 else 1;
            shuttlecock.velocity.x = direction * SHUTTLECOCK_START_SPEED;
            shuttlecock.velocity.y = -1;

            shuttlecock.active = true;

            updateScore(0);

            if (!musicPlaying) {
                var music = Assets.getSound("assets/PreludeNo6InDMinor.mp3");
                var soundTransform = new SoundTransform(MUSIC_VOLUME);
                music.play(0, 2147483647, soundTransform);
                musicPlaying = true;
            }
        }

        if (shuttlecock.active) {
            if (shuttlecock.collideEntity(leftBattledore)) {
                collideWithBattledore(leftBattledore);
            } else if (shuttlecock.collideEntity(rightBattledore)) {
                collideWithBattledore(rightBattledore);
            }

            if (shuttlecock.collideEntity(net)
                    || shuttlecock.y > HEIGHT
                    || shuttlecock.x < 0
                    || shuttlecock.x > WIDTH) {
                checkSubmitHighscore(true);
                shuttlecock.x = WIDTH * 0.5;
                shuttlecock.y = HEIGHT * 0.25;
                shuttlecock.active = false;
            }
        }
    }

    function collideWithBattledore (battledore:Battledore) {
        bipSoundTransform.pan = Range.clampFloat(0.5 + BIP_PAN_AMOUNT * (shuttlecock.x - WIDTH*0.5) / WIDTH, 0, 1);
        bip.play(1, 0, bipSoundTransform);

        updateScore(score + 1);

        if (shuttlecock.prevX > battledore.prevX) {
            var collideX = battledore.x + (Shuttlecock.WIDTH + Battledore.WIDTH) * 0.5 + 1;
            if (shuttlecock.x < collideX) {
                shuttlecock.x = collideX + collideX - shuttlecock.x;
            }
            if (shuttlecock.velocity.x < 0) {
                shuttlecock.velocity.x = -shuttlecock.velocity.x;
            }
        } else {
            var collideX = battledore.x - (Shuttlecock.WIDTH + Battledore.WIDTH) * 0.5 - 1;
            if (shuttlecock.x > collideX) {
                shuttlecock.x = collideX + collideX - shuttlecock.x;
            }
            if (shuttlecock.velocity.x > 0) {
                shuttlecock.velocity.x = -shuttlecock.velocity.x;
            }
        }

        shuttlecock.velocity.x += battledore.velocity.x;
        shuttlecock.velocity.y += battledore.velocity.y - LIFT_ON_HIT;
    }

    function updateScore(score:Int) {
        this.score = score;
        scoreText.text = Std.string(score);
        checkSubmitHighscore();
    }

    inline function checkSubmitHighscore(forceSubmit=false) {
        if (forceSubmit || lastScoreSubmitFrame + SCORE_SUBMIT_INTERVAL < frame ) {
            if (score > submittedHighscore) {
                kongregate.stats.submit("Highscore", score);
                submittedHighscore = score;
                lastScoreSubmitFrame = frame;
            }
        }
    }
}
