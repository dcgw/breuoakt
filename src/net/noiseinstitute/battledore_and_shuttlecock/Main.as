package net.noiseinstitute.battledore_and_shuttlecock {
    import net.flashpunk.Engine;
    import net.flashpunk.FP;
    import net.flashpunk.utils.Input;
    import net.flashpunk.utils.Key;

    [SWF(width="640", height="480", frameRate="60", backgroundColor="000000")]
    public class Main extends Engine {
        public static const WIDTH:int = 640;
        public static const HEIGHT:int = 480;

        public static const LOGIC_FPS:int = 60;

        public static const KEY_LEFT:String = "left";
        public static const KEY_RIGHT:String = "right";
        public static const KEY_UP:String = "up";
        public static const KEY_DOWN:String = "down";

        public function Main () {
            super(WIDTH, HEIGHT, LOGIC_FPS, true);

            FP.screen.color = 0x000000;
            FP.console.enable();

            Input.define(KEY_LEFT, Key.LEFT);
            Input.define(KEY_RIGHT, Key.RIGHT);
            Input.define(KEY_UP, Key.UP);
            Input.define(KEY_DOWN, Key.DOWN);

            FP.world = new GameWorld();
        }
    }
}
