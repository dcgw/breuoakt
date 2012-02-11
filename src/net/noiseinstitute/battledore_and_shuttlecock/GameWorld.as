package net.noiseinstitute.battledore_and_shuttlecock {
    import net.flashpunk.World;

    public class GameWorld extends World {
        public function GameWorld() {
            var leftBattledore:Battledore = new Battledore();
            var rightBattledore:Battledore = new Battledore();

            add(leftBattledore);
            add(rightBattledore);

            var shuttlecock:Shuttlecock = new Shuttlecock();
        }
    }
}
