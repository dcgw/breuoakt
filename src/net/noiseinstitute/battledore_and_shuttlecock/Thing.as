package net.noiseinstitute.battledore_and_shuttlecock {
    import flash.geom.Point;

    import net.flashpunk.Entity;

    public class Thing extends Entity {
        public var velocity:Point = new Point;

        override public function update():void {
            x += velocity.x;
            y += velocity.y;
        }
    }
}
