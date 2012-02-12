package net.noiseinstitute.battledore_and_shuttlecock {
    import flash.geom.Point;

    import net.flashpunk.Entity;
    import net.flashpunk.graphics.Image;
    import net.flashpunk.utils.Input;

    public class Battledore extends Entity {
        public var offsetX:Number = 0;
        public var prevX:Number = 0;
        public var prevY:Number = 0;
        public var velocity:Point = new Point;

        public function Battledore() {
            var image:Image = Image.createRect(8, 64);
            image.centerOrigin();
            graphic = image;

            setHitbox(image.width, image.height, image.originX, image.originY);
        }

        override public function update():void {
            prevX = x;
            prevY = y;

            x = Input.mouseX + offsetX;
            y = Input.mouseY;

            velocity.x = x - prevX;
            velocity.y = y - prevY;

            super.update();
        }
    }
}
