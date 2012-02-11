package net.noiseinstitute.battledore_and_shuttlecock {
    import net.flashpunk.Engine;
    import net.flashpunk.FP;

    [SWF(width="640", height="480", frameRate="60", backgroundColor="000000")]
    public class Main extends Engine {
        public static const WIDTH:int = 640;
        public static const HEIGHT:int = 480;

        public static const LOGIC_FPS:int = 60;

        public function Main () {
            super(WIDTH, HEIGHT, LOGIC_FPS, true);

            FP.screen.color = 0x000000;
            FP.console.enable();

            FP.world = new GameWorld();
        }
    }
}
