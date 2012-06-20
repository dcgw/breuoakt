package battledore_and_shuttlecock;

import flash.Lib;
import hopscotch.Playfield;
import hopscotch.engine.Engine;

class Game extends Playfield {
    static inline var WIDTH = 640;
    static inline var HEIGHT = 480;
    static inline var LOGIC_RATE = 60;

    static inline var SHUTTLECOCK_START_SPEED = 4.0;
    static inline var LIFT_ON_HIT = 4.0;

    var score:Int;

    //var title:Text;
    //var scoreText:Text;

    var leftBattledore:Battledore;
    var rightBattledore:Battledore;

    static function main () {
        var engine = new Engine(Lib.current, WIDTH, HEIGHT, LOGIC_RATE);
        engine.playfield = new Game();
        engine.start();
    }

    public function new () {
        super();

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
    }
}
