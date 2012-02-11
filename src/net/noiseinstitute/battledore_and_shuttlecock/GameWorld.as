package net.noiseinstitute.battledore_and_shuttlecock {
    import net.flashpunk.World;

    public class GameWorld extends World {
        public function GameWorld() {
            var leftBattledore:Battledore = new Battledore();
            leftBattledore.offsetX = -Main.WIDTH * 0.34;
            add(leftBattledore);

            var rightBattledore:Battledore = new Battledore();
            rightBattledore.offsetX = Main.WIDTH * 0.34;
            add(rightBattledore);

            var shuttlecock:Shuttlecock = new Shuttlecock();
            shuttlecock.x = Main.WIDTH * 0.5;
            shuttlecock.y = Main.HEIGHT * 0.25;
            add(shuttlecock);

            var net:Net = new Net();
            net.x = Main.WIDTH * 0.5;
            net.y = Main.HEIGHT;
            add(net);
        }
    }
}
