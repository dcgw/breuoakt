package net.noiseinstitute.battledore_and_shuttlecock {
    import net.flashpunk.graphics.Image;
    import net.flashpunk.utils.Input;
    import net.noiseinstitute.basecode.Static;
    import net.noiseinstitute.basecode.VectorMath;

    public class Battledore extends Thing {
        private static const ACCELERATION:Number = 0.1;
        private static const DECELERATION:Number = 0.1;
        private static const MAX_SPEED:Number = 4;

        public function Battledore() {
            var image:Image = Image.createRect(8, 64);
            image.centerOrigin();
            graphic = image;

            setHitbox(image.width, image.height, image.originX, image.originY);
        }

        override public function update():void {
            Static.point.x = 0;
            if (Input.pressed(Main.KEY_LEFT)) {
                Static.point.x--;
            }
            if (Input.pressed(Main.KEY_RIGHT)) {
                Static.point.x++;
            }

            Static.point.y = 0;
            if (Input.pressed(Main.KEY_UP)) {
                Static.point.y--;
            }
            if (Input.pressed(Main.KEY_DOWN)) {
                Static.point.y++;
            }

            VectorMath.normalizeInPlace(Static.point);
            VectorMath.scaleInPlace(Static.point, ACCELERATION);
            VectorMath.addTo(velocity, Static.point);

            var speed:Number = VectorMath.magnitude(velocity);
            if (speed > MAX_SPEED) {
                VectorMath.scaleInPlace(velocity, MAX_SPEED/speed);
            }

            super.update();
        }
    }
}
