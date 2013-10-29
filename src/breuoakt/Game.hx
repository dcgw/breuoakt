package breuoakt;

#if flash
import hopscotch.Static;
import haxe.PosInfos;
#end

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
import openfl.Assets;
import hopscotch.input.analogue.Mouse;
import hopscotch.input.analogue.IPointer;
import hopscotch.input.digital.MouseButton;
import hopscotch.input.digital.Button;
import flash.Lib;
import hopscotch.Playfield;
import hopscotch.engine.Engine;

class Game extends Playfield {
    public static inline var WIDTH = 640;
    public static inline var HEIGHT = 480;
    public static inline var LOGIC_RATE = 120;

    static inline var MAX_BALLS_IN_PLAY = 32;

    static inline var BALL_SPAWN_DISTANCE_FROM_PADDLE = 64;
    static inline var BALL_SPAWN_MIN_DISTANCE_FROM_BRICKS = 16;
    static inline var BALL_SPAWN_MIN_Y = TOP_BRICK_Y + NUM_BRICKS_Y * (Brick.HEIGHT + BRICK_SPACING_Y)
            + BALL_SPAWN_MIN_DISTANCE_FROM_BRICKS;

    static inline var TOP_BRICK_Y = 82;
    static inline var LEFT_BRICK_X = (WIDTH - (NUM_BRICKS_X - 1) * (Brick.WIDTH + BRICK_SPACING_X)) * 0.5;

    public static inline var NUM_BRICKS_X = 15;
    static inline var NUM_BRICKS_Y = 7;

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

    static inline var YAY_VOLUME = 0.3;

    static inline var SCORE_SUBMIT_INTERVAL = 180;

    var startButton:Button;

    var kongregate:KongregateApi;

    var score:Int;
    var submittedHighscore:Int;

    var frame:Int;
    var lastScoreSubmitFrame:Int;

    var paddle:Paddle;

    var numBallsInPlay:Int;
    var balls:Array<Ball>;
    var prevBallVelocity:Point;

    var bricks:Array<Brick>;

    var brickCollider:BrickCollider;

    var banners:Banners;

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

    var yay:Sound;
    var yaySoundTransform:SoundTransform;

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

        balls = [];
        for (i in 0...MAX_BALLS_IN_PLAY) {
            var ball = new Ball();
            balls.push(ball);
            addEntity(ball);
        }
        numBallsInPlay = 0;

        prevBallVelocity = new Point();

        bricks = [];
        for (y in 0...NUM_BRICKS_Y) {
            for (x in 0...NUM_BRICKS_X) {
                var brick = new Brick();
                brick.x = LEFT_BRICK_X + x * (BRICK_SPACING_X + Brick.WIDTH);
                brick.y = TOP_BRICK_Y + y * (BRICK_SPACING_Y + Brick.HEIGHT);
                addEntity(brick);
                bricks.push(brick);
            }
        }

        brickCollider = new BrickCollider(bricks, onHit);

        banners = new Banners();
        addGraphic(banners);

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

        yay = Assets.getSound("assets/yay.mp3");
        yaySoundTransform = new SoundTransform(YAY_VOLUME);
    }

    override public function begin (frame:Int) {
        this.frame = frame;
        reset();

        super.begin(frame);
    }

    override public function update(frame:Int) {
        this.frame = frame;

        super.update(frame);

        if (startButton.justPressed) {
            checkSubmitHighscore(true);

            reset();

            balls[0].active = true;
            numBallsInPlay = 1;

            updateScore(0);

            if (!musicPlaying) {
                var music = Assets.getSound("assets/Music.mp3");
                var soundTransform = new SoundTransform(MUSIC_VOLUME);
                music.play(0, 2147483647, soundTransform);
                musicPlaying = true;
            }
        }

        for (ball in balls) {
            if (ball.active) {
                brickCollider.collide(ball);

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
                    banners.onLoseBall(ball.x);

                    ball.reset();

                    aws[Std.random(aws.length)].play();

                    if (--numBallsInPlay == 0) {
                        checkSubmitHighscore(true);
                    }
                }

                if (ball.collideEntity(paddle)) {
                    collideWithPaddle(paddle, ball);
                }
            }
        }
    }

    function reset() {
        for (ball in balls) {
            ball.reset();
        }
        balls[0].visible = true;
        numBallsInPlay = 0;

        for (brick in bricks) {
            brick.reset();
        }

        banners.reset();
    }

    function spawnBall(x:Float, y:Float) {
        if (numBallsInPlay >= MAX_BALLS_IN_PLAY) {
            return;
        }

        var i = 0;
        var ball = balls[numBallsInPlay];
        while (ball.visible) {
            ++i;
            ball = balls[(numBallsInPlay + i) % MAX_BALLS_IN_PLAY];
        }

        ball.spawn(x, y);
        ++numBallsInPlay;
    }

    function onHit(ball:Ball, brickCount:Int, hitTop:Bool) {
        if (hitTop && ball.yayPrimed) {
            var ballSpawnY = Math.max(paddle.y - BALL_SPAWN_DISTANCE_FROM_PADDLE, BALL_SPAWN_MIN_Y);
            spawnBall(paddle.x, ballSpawnY);
            yay.play(0, 0, yaySoundTransform);
            ball.yayPrimed = false;
        }

        pops[Std.random(pops.length)].play(0, 0, popSoundTransform);

        var points = 0;
        for (i in 0...brickCount) {
            points += ball.multiplier * numBallsInPlay;
            ball.incrementMultiplier();
        }

        banners.onHitBrick(points, ball.x, ball.y, hitTop);

        updateScore(score + points);
    }

    function collideWithPaddle (paddle:Paddle, ball:Ball) {
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
                    bipSoundChannel.soundTransform = bipSoundChannel.soundTransform;
                }
            } else {
                bipSoundTransform.volume = volume;
                bipSoundTransform.pan = Range.clampFloat(0.5 + BIP_PAN_AMOUNT * (ball.x - WIDTH*0.5) / WIDTH, 0, 1);
                bipSoundChannel = bip.play(1, 0, bipSoundTransform);
                lastBipFrame = frame;
            }
        }

        ball.yayPrimed = true;

        ball.resetMultiplier();
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
