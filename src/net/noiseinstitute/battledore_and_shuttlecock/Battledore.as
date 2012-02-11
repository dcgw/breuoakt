package net.noiseinstitute.battledore_and_shuttlecock {
    import flash.geom.Point;

    import net.flashpunk.Entity;
    import net.flashpunk.graphics.Image;
    import net.flashpunk.utils.Input;

    public class Battledore extends Entity {
        public var offsetX:Number = 0;
        public var velocity:Point = new Point;

        public function Battledore() {
            var image:Image = Image.createRect(8, 64);
            image.centerOrigin();
            graphic = image;

            setHitbox(image.width, image.height, image.originX, image.originY);
        }

        override public function update():void {
            var newX:Number = Input.mouseX + offsetX;
            var newY:Number = Input.mouseY;

            velocity.x = newX - x;
            velocity.y = newY - y;

            x = newX;
            y = newY;

            super.update();
        }
    }
}
