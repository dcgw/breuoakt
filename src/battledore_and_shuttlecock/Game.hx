package battledore_and_shuttlecock;

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

    var startButton:Button;

    var score:Int;

    //var title:Text;
    //var scoreText:Text;

    var leftBattledore:Battledore;
    var rightBattledore:Battledore;

    var shuttlecock:Shuttlecock;
    var net:Net;

    static function main () {
        var engine = new Engine(Lib.current, WIDTH, HEIGHT, LOGIC_RATE);

        var startButton = new Button(); // TODO
        engine.inputs.push(startButton);

        engine.playfield = new Game(startButton);
        engine.start();

    }

    public function new (startButton:Button) {
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

        leftBattledore = new Battledore();
        leftBattledore.offsetX = -WIDTH * 0.34;
        addEntity(leftBattledore);

        rightBattledore = new Battledore();
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
        if (startButton.pressed) {
            shuttlecock.x = WIDTH * 0.5;
            shuttlecock.y = HEIGHT *  0.25;

            var direction = if (Math.random() * 2 < 1) -1 else 1;
            shuttlecock.velocity.x = direction * SHUTTLECOCK_START_SPEED;
            shuttlecock.velocity.y = 0;

            shuttlecock.active = true;

            updateScore(0);
        }
    }

    function updateScore(score:Int) {
        this.score = score;
        //scoreText.text = Std.string(score);
        //scoreText.width = scoreText.textWidth;
        //scoreText.centerOrigin();
    }
}
