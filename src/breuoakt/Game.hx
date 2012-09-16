package breuoakt;

import flash.media.SoundChannel;
import hopscotch.math.VectorMath;
import flash.geom.Point;
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

    static inline var BALL_START_X = WIDTH * 0.5;
    static inline var BALL_START_Y = HEIGHT * 0.6;

    static inline var TOP_BRICK_Y = 64;
    static inline var LEFT_BRICK_X = (WIDTH - (NUM_BRICKS_X - 1) * (Brick.WIDTH + BRICK_SPACING_X)) * 0.5;

    static inline var NUM_BRICKS_X = 15;
    static inline var NUM_BRICKS_Y = 8;

    static inline var BRICK_SPACING_X = 6;
    static inline var BRICK_SPACING_Y = 4;

    static inline var SPRINGINESS = 0.2;
    static inline var HITTINESS = 0.5;

    static inline var MUSIC_VOLUME = 0.2;

    static inline var BIP_VOLUME = 0.2;
    static inline var BIP_PAN_AMOUNT = 0.2;

    static inline var MIN_BIP_INTERVAL_FRAMES = 6;

    static inline var MIN_BIP_VELOCITY_CHANGE = 2;
    static inline var MAX_BIP_VELOCITY_CHANGE = 32;

    static inline var POP_VOLUME = 0.2;

    static inline var SCORE_SUBMIT_INTERVAL = 180;

    var startButton:Button;

    var kongregate:KongregateApi;

    var score:Int;
    var submittedHighscore:Int;

    var frame:Int;
    var lastScoreSubmitFrame:Int;

    var paddle:Paddle;

    var ball:Ball;
    var prevBallVelocity:Point;

    var bricks:Array<Brick>;

    var title:Text;
    var scoreText:Text;

    var musicPlaying:Bool;

    var bip:Sound;
    var bipSoundChannel:SoundChannel;
    var bipSoundTransform:SoundTransform;
    var lastBipFrame:Int;

    var aws:Array<Sound>;

    var pops:Array<Sound>;
    var popSoundTransform:SoundTransform;

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

        paddle = new Paddle(pointer);
        addEntity(paddle);

        ball = new Ball();
        ball.x = BALL_START_X;
        ball.y = BALL_START_Y;
        ball.active = false;
        addEntity(ball);

        prevBallVelocity = new Point();

        bricks = [];
        for (x in 0...NUM_BRICKS_X) {
            for (y in 0...NUM_BRICKS_Y) {
                var brick = new Brick();
                brick.x = LEFT_BRICK_X + x * (BRICK_SPACING_X + Brick.WIDTH);
                brick.y = TOP_BRICK_Y + y * (BRICK_SPACING_Y + Brick.HEIGHT);
                addEntity(brick);
                bricks.push(brick);
            }
        }

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

        musicPlaying = false;

        bip = Assets.getSound("assets/bip.mp3");
        bipSoundChannel = null;
        bipSoundTransform = new SoundTransform();
        lastBipFrame = -MIN_BIP_INTERVAL_FRAMES - 1;

        aws = [];
        for (i in 1...4) {
            aws.push(Assets.getSound("assets/aw" + i + ".mp3"));
        }

        pops = [];
        for (i in 1...6) {
            pops.push(Assets.getSound("assets/Pop" + i + ".mp3"));
        }

        popSoundTransform = new SoundTransform(POP_VOLUME);
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

            reset();

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
            for (brick in bricks) {
                if (brick.visible && brick.collideEntity(ball)) {
                    collideWithBrick(brick);
                }
            }

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

            if (ball.y > HEIGHT + Ball.HEIGHT * 0.5) {
                checkSubmitHighscore(true);
                ball.x = BALL_START_X;
                ball.y = BALL_START_Y;
                ball.active = false;

                aws[Std.random(aws.length)].play();
            }

            if (ball.collideEntity(paddle)) {
                collideWithPaddle(paddle);
            }
        }
    }

    function reset() {
        for (brick in bricks) {
            brick.reset();
        }

        ball.x = BALL_START_X;
        ball.y = BALL_START_Y;

        ball.velocity.x = 0;
        ball.velocity.y = 0;
    }

    function collideWithBrick(brick:Brick) {
        if (ball.prevX + Ball.WIDTH * 0.5 < brick.x - Brick.WIDTH * 0.5) {
            if (ball.velocity.x > 0) {
                ball.velocity.x = -ball.velocity.x;
            }
        } else if (ball.prevX - Ball.WIDTH * 0.5 > brick.x + Brick.WIDTH * 0.5) {
            if (ball.velocity.x < 0) {
                ball.velocity.x = -ball.velocity.x;
            }
        }

        if (ball.prevY + Ball.HEIGHT * 0.5 < brick.y - Brick.HEIGHT * 0.5) {
            if (ball.velocity.y > 0) {
                ball.velocity.y = -ball.velocity.y;
            }
        } else if (ball.prevY - Ball.HEIGHT * 0.5 > brick.y + Brick.HEIGHT * 0.5) {
            if (ball.velocity.y < 0) {
                ball.velocity.y = -ball.velocity.y;
            }
        }

        pops[Std.random(pops.length)].play(0, 0, popSoundTransform);
        brick.hit();

        updateScore(score + 1);
    }

    function collideWithPaddle (paddle:Paddle) {
        prevBallVelocity.x = ball.velocity.x;
        prevBallVelocity.y = ball.velocity.y;

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

        VectorMath.subtract(prevBallVelocity, ball.velocity);
        var volume = VectorMath.magnitude(prevBallVelocity);
        volume = (volume - MIN_BIP_VELOCITY_CHANGE) * (MAX_BIP_VELOCITY_CHANGE - MIN_BIP_VELOCITY_CHANGE);
        volume = Range.clampFloat(volume, 0, 1);
        volume *= BIP_VOLUME;

        if (volume > 0) {
            if (bipSoundChannel != null
                    && lastBipFrame + MIN_BIP_INTERVAL_FRAMES > frame) {
                if (volume > bipSoundChannel.soundTransform.volume) {
                    bipSoundChannel.soundTransform.volume = volume;
                }
            } else {
                bipSoundTransform.volume = volume;
                bipSoundTransform.pan = Range.clampFloat(0.5 + BIP_PAN_AMOUNT * (ball.x - WIDTH*0.5) / WIDTH, 0, 1);
                bipSoundChannel = bip.play(1, 0, bipSoundTransform);
                lastBipFrame = frame;
            }
        }
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
