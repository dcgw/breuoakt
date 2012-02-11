package net.noiseinstitute.battledore_and_shuttlecock {
    import net.flashpunk.World;
    import net.flashpunk.utils.Input;

    public class GameWorld extends World {
        private static const SHUTTLECOCK_START_SPEED:Number = 4;

        private var leftBattledore:Battledore = new Battledore();
        private var rightBattledore:Battledore = new Battledore();
        private var shuttlecock:Shuttlecock = new Shuttlecock();
        private var net:Net = new Net();

        public function GameWorld() {
            leftBattledore.offsetX = -Main.WIDTH * 0.34;
            add(leftBattledore);

            rightBattledore.offsetX = Main.WIDTH * 0.34;
            add(rightBattledore);

            shuttlecock.x = Main.WIDTH * 0.5;
            shuttlecock.y = Main.HEIGHT * 0.25;
            shuttlecock.active = false;
            add(shuttlecock);

            net.x = Main.WIDTH * 0.5;
            net.y = Main.HEIGHT;
            add(net);
        }

        override public function update():void {
            if (Input.mousePressed) {
                shuttlecock.x = Main.WIDTH * 0.5;
                shuttlecock.y = Main.HEIGHT * 0.25;

                var direction:int = Math.floor(Math.random() * 2);
                if (direction < 1) {
                    direction = -1;
                }
                shuttlecock.velocity.x = direction * SHUTTLECOCK_START_SPEED;
                shuttlecock.velocity.y = 0;

                shuttlecock.active = true;
            }

            if (shuttlecock.collideWith(net, shuttlecock.x, shuttlecock.y)) {
                shuttlecock.x = Main.WIDTH * 0.5;
                shuttlecock.y = Main.HEIGHT * 0.25;
                shuttlecock.active = false;
            }

            super.update();
        }
    }
}
