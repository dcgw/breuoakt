package net.noiseinstitute.battledore_and_shuttlecock {
    import flash.geom.Point;

    import net.flashpunk.Entity;
    import net.flashpunk.graphics.Image;

    public class Shuttlecock extends Entity {
        private static const GRAVITY:Number = 0.1;

        public var prevX:Number = 0;
        public var prevY:Number = 0;

        public var velocity:Point = new Point;

        public function Shuttlecock() {
            var image:Image = Image.createRect(8, 8);
            image.centerOrigin();
            graphic = image;

            setHitbox(image.width, image.height, image.originX, image.originY);
        }

        override public function update():void {
            prevX = x;
            prevY = y;

            velocity.y += GRAVITY;

            x += velocity.x;
            y += velocity.y;
        }
    }
}
