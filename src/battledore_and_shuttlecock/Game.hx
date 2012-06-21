package battledore_and_shuttlecock;

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

    var pointer:IPointer;
    var startButton:Button;

    var score:Int;

    //var title:Text;
    //var scoreText:Text;

    var leftBattledore:Battledore;
    var rightBattledore:Battledore;

    var shuttlecock:Shuttlecock;
    var net:Net;

    static function main () {
        #if flash
        haxe.Log.trace = function(v:Dynamic, ?pos:PosInfos) {
            flash.Lib.trace(pos.fileName + ":" + pos.lineNumber + ": " + v);
        }
        #end

        var engine = new Engine(Lib.current, WIDTH, HEIGHT, LOGIC_RATE);

        var startButton = new MouseButton(Lib.current.stage);
        engine.inputs.push(startButton);

        var pointer = new Mouse(Lib.current.stage);
        engine.inputs.push(pointer);

        engine.playfield = new Game(startButton, pointer);
        engine.start();
    }

    public function new (startButton:Button, pointer:IPointer) {
        super();

        this.startButton = startButton;

        score = 0;

        //title = new Text("Battledore and Shuttlecock");
        //title.centerOrigin();
        //title.x = WIDTH * 0.5;
        //title.y = 16;
        //addGraphic(title);

        //scoreText = new Text("click to start");
        //scoreText.resizable = true;
        //scoreText.centerOrigin();
        //scoreText.x = WIDTH * 0.5;
        //scoreText.y = 32;
        //addGraphic(scoreText);

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
    }

    override public function update(frame:Int) {
        super.update(frame);

        if (startButton.pressed) {
            shuttlecock.x = WIDTH * 0.5;
            shuttlecock.y = HEIGHT *  0.25;

            var direction = if (Math.random() * 2 < 1) -1 else 1;
            shuttlecock.velocity.x = direction * SHUTTLECOCK_START_SPEED;
            shuttlecock.velocity.y = -1;

            shuttlecock.active = true;

            updateScore(0);
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
                shuttlecock.x = WIDTH * 0.5;
                shuttlecock.y = HEIGHT * 0.25;
                shuttlecock.active = false;
            }
        }
    }

    function collideWithBattledore (battledore:Battledore) {
        //bip.play(1, (battledore.x - WIDTH * 0.5) / WIDTH * 0.5);

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
        //scoreText.text = Std.string(score);
        //scoreText.width = scoreText.textWidth;
        //scoreText.centerOrigin();
    }
}
