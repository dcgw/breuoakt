package net.noiseinstitute.battledore_and_shuttlecock {
    import net.flashpunk.graphics.Image;
    import net.flashpunk.utils.Input;
    import net.noiseinstitute.basecode.Static;
    import net.noiseinstitute.basecode.VectorMath;

    public class Battledore extends Thing {
        private static const ACCELERATION:Number = 0.5;
        private static const DECELERATION:Number = 0.4;
        private static const MAX_SPEED:Number = 8;

        public function Battledore() {
            var image:Image = Image.createRect(8, 64);
            image.centerOrigin();
            graphic = image;

            setHitbox(image.width, image.height, image.originX, image.originY);
        }

        override public function update():void {
            Static.point.x = 0;
            if (Input.check(Main.KEY_LEFT)) {
                Static.point.x--;
            }
            if (Input.check(Main.KEY_RIGHT)) {
                Static.point.x++;
            }

            Static.point.y = 0;
            if (Input.check(Main.KEY_UP)) {
                Static.point.y--;
            }
            if (Input.check(Main.KEY_DOWN)) {
                Static.point.y++;
            }

            VectorMath.normalizeInPlace(Static.point);
            VectorMath.scaleInPlace(Static.point, ACCELERATION);

            if (Static.point.x == 0) {
                if (velocity.x > DECELERATION) {
                    Static.point.x = -DECELERATION;
                } else if (velocity.x < -DECELERATION) {
                    Static.point.x = DECELERATION;
                } else {
                    velocity.x = 0;
                }
            }

            if (Static.point.y == 0) {
                if (velocity.y > DECELERATION) {
                    Static.point.y = -DECELERATION;
                } else if (velocity.y < -DECELERATION) {
                    Static.point.y = DECELERATION;
                } else {
                    velocity.y = 0;
                }
            }

            VectorMath.addTo(velocity, Static.point);

            var speed:Number = VectorMath.magnitude(velocity);
            if (speed > MAX_SPEED) {
                VectorMath.scaleInPlace(velocity, MAX_SPEED/speed);
            }

            super.update();
        }
    }
}
