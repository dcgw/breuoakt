package net.noiseinstitute.battledore_and_shuttlecock {
    import net.flashpunk.World;
    import net.flashpunk.utils.Input;

    public class GameWorld extends World {
        private static const SHUTTLECOCK_START_SPEED:Number = 4;
        private static const LIFT_ON_HIT:Number = 4;

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

            if (shuttlecock.collideWith(leftBattledore, shuttlecock.x, shuttlecock.y)) {
                collideWithBattledore(leftBattledore);
            } else if (shuttlecock.collideWith(rightBattledore, shuttlecock.x, shuttlecock.y)) {
                collideWithBattledore(rightBattledore);
            }

            if (shuttlecock.collideWith(net, shuttlecock.x, shuttlecock.y)
                    || shuttlecock.y > Main.HEIGHT
                    || shuttlecock.x < 0
                    || shuttlecock.x > Main.WIDTH) {
                shuttlecock.x = Main.WIDTH * 0.5;
                shuttlecock.y = Main.HEIGHT * 0.25;
                shuttlecock.active = false;
            }

            super.update();
        }

        private function collideWithBattledore(battledore:Battledore):void {
            if (shuttlecock.x > battledore.x) {
                if (shuttlecock.velocity.x < 0) {
                    shuttlecock.velocity.x = -shuttlecock.velocity.x;
                }
            } else if (shuttlecock.velocity.x > 0) {
                shuttlecock.velocity.x = -shuttlecock.velocity.x;
            }

            shuttlecock.velocity.x += battledore.velocity.x;
            shuttlecock.velocity.y += battledore.velocity.y - LIFT_ON_HIT;
        }
    }
}
