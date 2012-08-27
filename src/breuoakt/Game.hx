package breuoakt;

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
    public static inline var WIDTH = 640;
    public static inline var HEIGHT = 480;
    public static inline var LOGIC_RATE = 60;

    static inline var SPRINGINESS = 0.2;
    static inline var HITTINESS = 0.5;

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

    var paddle:Paddle;

    var ball:Ball;

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

        var ceiling = new Ceiling();
        addEntity(ceiling);

        var wall = new Wall();
        wall.y = Ceiling.HEIGHT;
        addEntity(wall);

        wall = new Wall();
        wall.x = WIDTH - Wall.WIDTH;
        wall.y = Ceiling.HEIGHT;
        addEntity(wall);

        var fontFace = new FontFace(Assets.getFont("assets/04B_03__.ttf").fontName);

        title = new Text();
        title.text = "Breuoakt";
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

        paddle = new Paddle(pointer);
        addEntity(paddle);

        ball = new Ball();
        ball.x = WIDTH * 0.5;
        ball.y = HEIGHT * 0.25;
        ball.active = false;
        addEntity(ball);

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

            ball.x = WIDTH * 0.5;
            ball.y = HEIGHT *  0.25;

            ball.velocity.x = 0;
            ball.velocity.y = 0;

            ball.active = true;

            updateScore(0);

            if (!musicPlaying) {
                var music = Assets.getSound("assets/Music.mp3");
                var soundTransform = new SoundTransform(MUSIC_VOLUME);
                music.play(0, 2147483647, soundTransform);
                musicPlaying = true;
            }
        }

        if (ball.active) {
            if (ball.x - Ball.WIDTH * 0.5 < Wall.WIDTH) {
                ball.x = Wall.WIDTH - ball.x + Wall.WIDTH + Ball.WIDTH;
                if (ball.velocity.x < 0) {
                    ball.velocity.x = -ball.velocity.x;
                }
            } else if (ball.x + Ball.WIDTH * 0.5 > WIDTH - Wall.WIDTH) {
                ball.x = WIDTH - Wall.WIDTH - ball.x + WIDTH - Wall.WIDTH - Ball.WIDTH;
                if (ball.velocity.x > 0) {
                    ball.velocity.x = -ball.velocity.x;
                }
            }

            if (ball.y < Ceiling.HEIGHT) {
                ball.y = Ceiling.HEIGHT - ball.y + Ceiling.HEIGHT + Ball.HEIGHT;
                if (ball.velocity.y < 0) {
                    ball.velocity.y = -ball.velocity.y;
                }
            }

            if (ball.collideEntity(paddle)) {
                collideWithPaddle(paddle);
            }
        }
    }

    function collideWithPaddle (paddle:Paddle) {
        bipSoundTransform.pan = Range.clampFloat(0.5 + BIP_PAN_AMOUNT * (ball.x - WIDTH*0.5) / WIDTH, 0, 1);
        bip.play(1, 0, bipSoundTransform);

        var prevBallVelocityX = ball.velocity.x;
        var prevBallVelocityY = ball.velocity.y;

        if (ball.prevY > paddle.prevY) {
            var collideY = paddle.y + (Ball.HEIGHT + Paddle.HEIGHT) * 0.5 + 1;
            if (ball.y < collideY) {
                ball.y = collideY + collideY - ball.y;
            }
            if (ball.velocity.y < 0) {
                ball.velocity.y = -SPRINGINESS * ball.velocity.y;
            }
        } else {
            var collideY = paddle.y - (Ball.HEIGHT + Paddle.HEIGHT) * 0.5 + 1;
            if (ball.y > collideY) {
                ball.y = collideY + collideY - ball.y;
            }
            if (ball.velocity.y > 0) {
                ball.velocity.y = -SPRINGINESS * ball.velocity.y;
            }
        }

        ball.velocity.x += HITTINESS * (paddle.velocity.x - prevBallVelocityX);
        ball.velocity.y += HITTINESS * (paddle.velocity.y - prevBallVelocityY);

        var resting = Math.abs(ball.velocity.y) < 1.5;
    }

    function updateScore(score:Int) {
        this.score = score;
        scoreText.text = Std.string(score);
        checkSubmitHighscore();
    }

    inline function checkSubmitHighscore(forceSubmit=false) {
        if (forceSubmit || lastScoreSubmitFrame + SCORE_SUBMIT_INTERVAL <= frame ) {
            if (score > submittedHighscore) {
                kongregate.stats.submit("Highscore", score);
                submittedHighscore = score;
                lastScoreSubmitFrame = frame;
            }
        }
    }
}
