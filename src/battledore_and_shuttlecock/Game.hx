package battledore_and_shuttlecock;

import flash.Lib;
import hopscotch.Playfield;
import hopscotch.engine.Engine;

class Game extends Playfield {
    static function main () {
        var engine = new Engine(Lib.current, 640, 480, 60);
        engine.playfield = new Game();
        engine.start();
    }

    public function new () {
        super();
    }
}
