package breuoakt;

import hopscotch.Static;
class BrickCollider {
    private static var MAX_COLLISIONS_PER_BALL = 4;

    private static var INITIAL_SIZE_TOLERANCE = 2;
    private static var SIZE_TOLERANCE_INCREMENT = 2;
    private static var MAX_SIZE_TOLERANCE = Brick.WIDTH;

    private var bricks:Array<Brick>;

    private var onHit:Ball -> Int -> Bool -> Void;

    private var collidedBrickIndices:Array<Int>;
    private var numCollidedBricks:Int;

    private var brickAboveIndex:Int;
    private var brickRightIndex:Int;
    private var brickBelowIndex:Int;
    private var brickLeftIndex:Int;

    public function new(bricks:Array<Brick>, onHit:Ball -> Int -> Bool -> Void) {
        this.bricks = bricks;
        this.onHit = onHit;

        collidedBrickIndices = [];
        for (i in 0...MAX_COLLISIONS_PER_BALL) {
            collidedBrickIndices.push(-1);
        }
    }

    public function collide(ball:Ball) {
        if (!ball.active) {
            return;
        }

        var brickIndex = 0;
        numCollidedBricks = 0;

        while (brickIndex < bricks.length && numCollidedBricks < MAX_COLLISIONS_PER_BALL) {
            var brick = bricks[brickIndex];
            if (brick.collidable && brick.collideEntity(ball)) {
                this.collidedBrickIndices[numCollidedBricks++] = brickIndex;
            }

            ++brickIndex;
        }

        if (numCollidedBricks < 1) {
            return;
        }

        brickAboveIndex = -1;
        brickRightIndex = -1;
        brickBelowIndex = -1;
        brickLeftIndex = -1;

        var sizeTolerance = INITIAL_SIZE_TOLERANCE;
        while (brickAboveIndex < 0 && brickRightIndex < 0 && brickBelowIndex < 0 && brickLeftIndex < 0
                && sizeTolerance <= MAX_SIZE_TOLERANCE) {
            for (i in 0...numCollidedBricks) {
                brickIndex = collidedBrickIndices[i];
                var brick = bricks[brickIndex];

                Static.point.x = ball.x;
                Static.point.y = ball.y;
                brick.hit(Static.point, ball.velocity);

                if (brick.x + Brick.WIDTH * 0.5 - sizeTolerance < ball.x - Ball.WIDTH * 0.5) {
                    brickLeftIndex = brickIndex;
                } else if (brick.x - Brick.WIDTH * 0.5 + sizeTolerance > ball.x + Ball.WIDTH * 0.5) {
                    brickRightIndex = brickIndex;
                }

                if (brick.y + Brick.HEIGHT * 0.5 - sizeTolerance < ball.y - Ball.HEIGHT * 0.5) {
                    brickAboveIndex = brickIndex;
                } else if (brick.y - Brick.HEIGHT * 0.5 + sizeTolerance > ball.y + Ball.HEIGHT * 0.5) {
                    brickBelowIndex = brickIndex;
                }
            }

            sizeTolerance += SIZE_TOLERANCE_INCREMENT;
        }

        var hitTop = false;

        if (sizeTolerance > MAX_SIZE_TOLERANCE) {
            ball.velocity.x = -ball.velocity.x;
            ball.velocity.y = -ball.velocity.y;
        } else {
            if ((brickRightIndex >= 0 && brickLeftIndex < 0 && ball.velocity.x > 0)
                    || (brickLeftIndex >= 0 && brickRightIndex < 0 && ball.velocity.x < 0)) {
                ball.velocity.x = -ball.velocity.x;
            }

            if ((brickBelowIndex >= 0 && brickAboveIndex < 0 && ball.velocity.y > 0)
                    || (brickAboveIndex >= 0 && brickBelowIndex < 0 && ball.velocity.y < 0)) {
                ball.velocity.y = -ball.velocity.y;
            }

            if (brickBelowIndex >= 0 && brickAboveIndex < 0) {
                brickIndex = brickBelowIndex;
                while (brickIndex >= 0 && !bricks[brickIndex].collidable) {
                    brickIndex -= Game.NUM_BRICKS_X;
                }

                hitTop = brickIndex < 0;
            }
        }

        onHit(ball, numCollidedBricks, hitTop);
    }
}