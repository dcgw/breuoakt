package breuoakt;

import flash.text.TextField;
import flash.Lib;
import flash.display.Sprite;
import hopscotch.Static;
import hopscotch.math.Range;
import hopscotch.math.VectorMath;
import flash.geom.Point;

class BrickCollider {
    private static var HIT_CORNER_ANGLE_ALLOWANCE = 3 * Math.PI / 180;

    private var ballBelowMaxAngle:Float;
    private var ballLeftMinAngle:Float;
    private var ballLeftMaxAngle:Float;
    private var ballAboveMinAngle:Float;
    private var ballAboveMaxAngle:Float;
    private var ballRightMinAngle:Float;
    private var ballRightMaxAngle:Float;
    private var ballBelowMinAngle:Float;

    private var bricks:Array<Brick>;

    private var onHit:Ball -> Int -> Bool -> Void;

    private var point:Point;

    public function new(bricks:Array<Brick>, onHit:Ball -> Int -> Bool -> Void) {
        this.bricks = bricks;
        this.onHit = onHit;
        point = new Point();

        point.x = -Brick.WIDTH;
        point.y = Brick.HEIGHT;

        ballBelowMaxAngle = VectorMath.angle(point) + HIT_CORNER_ANGLE_ALLOWANCE;
        ballLeftMinAngle = VectorMath.angle(point) - HIT_CORNER_ANGLE_ALLOWANCE;

        point.y = -Brick.HEIGHT;

        ballLeftMaxAngle = VectorMath.angle(point) + HIT_CORNER_ANGLE_ALLOWANCE;
        ballAboveMinAngle = VectorMath.angle(point) - HIT_CORNER_ANGLE_ALLOWANCE;

        point.x = Brick.WIDTH;

        ballAboveMaxAngle = VectorMath.angle(point) + HIT_CORNER_ANGLE_ALLOWANCE;
        ballRightMinAngle = VectorMath.angle(point) - HIT_CORNER_ANGLE_ALLOWANCE;

        point.y = Brick.HEIGHT;

        ballRightMaxAngle = VectorMath.angle(point) + HIT_CORNER_ANGLE_ALLOWANCE;
        ballBelowMinAngle = VectorMath.angle(point) - HIT_CORNER_ANGLE_ALLOWANCE;
    }

    public function collide(ball:Ball): Void {
        var middleBrickColumn = Math.floor((ball.x - Game.LEFT_BRICK_X + Brick.WIDTH * 0.5 + Game.BRICK_SPACING_X * 0.5)
                / (Brick.WIDTH + Game.BRICK_SPACING_X));
        var middleBrickRow = Math.floor((ball.y - Game.TOP_BRICK_Y + Brick.HEIGHT * 0.5 + Game.BRICK_SPACING_Y * 0.5)
                / (Brick.HEIGHT + Game.BRICK_SPACING_Y));

        var middleBrickIndex = middleBrickColumn + middleBrickRow * Game.NUM_BRICKS_X;

        var middleBrickTop = Game.TOP_BRICK_Y + middleBrickRow * (Brick.HEIGHT + Game.BRICK_SPACING_Y) - Brick.HEIGHT * 0.5;
        var middleBrickLeft = Game.LEFT_BRICK_X + middleBrickColumn * (Brick.WIDTH + Game.BRICK_SPACING_X) - Brick.WIDTH * 0.5;
        var middleBrickRight = middleBrickLeft + Brick.WIDTH;
        var middleBrickBottom = middleBrickTop + Brick.HEIGHT;

        var middleBrickX = middleBrickLeft + Brick.WIDTH * 0.5;
        var middleBrickY = middleBrickTop + Brick.HEIGHT * 0.5;

        if (!collideBrick(ball, middleBrickIndex)) {
            return;
        }

        var topLeftBrickIndex = middleBrickIndex - Game.NUM_BRICKS_X - 1;
        var topBrickIndex = middleBrickIndex - Game.NUM_BRICKS_X;
        var topRightBrickIndex = middleBrickIndex - Game.NUM_BRICKS_X + 1;
        var leftBrickIndex = middleBrickIndex - 1;
        var rightBrickIndex = middleBrickIndex + 1;
        var bottomLeftBrickIndex = middleBrickIndex + Game.NUM_BRICKS_X - 1;
        var bottomBrickIndex = middleBrickIndex + Game.NUM_BRICKS_X;
        var bottomRightBrickIndex = middleBrickIndex + Game.NUM_BRICKS_X + 1;

        var topBrickCollidable = getCollidableBrick(topBrickIndex) != null;
        var leftBrickCollidable = getCollidableBrick(leftBrickIndex) != null;
        var rightBrickCollidable = getCollidableBrick(rightBrickIndex) != null;
        var bottomBrickCollidable = getCollidableBrick(bottomBrickIndex) != null;

        var numCollidedBricks = 1;
        numCollidedBricks += if (collideBrick(ball, topLeftBrickIndex)) 1 else 0;
        numCollidedBricks += if (collideBrick(ball, topBrickIndex)) 1 else 0;
        numCollidedBricks += if (collideBrick(ball, topRightBrickIndex)) 1 else 0;
        numCollidedBricks += if (collideBrick(ball, leftBrickIndex)) 1 else 0;
        numCollidedBricks += if (collideBrick(ball, rightBrickIndex)) 1 else 0;
        numCollidedBricks += if (collideBrick(ball, bottomLeftBrickIndex)) 1 else 0;
        numCollidedBricks += if (collideBrick(ball, bottomBrickIndex)) 1 else 0;
        numCollidedBricks += if (collideBrick(ball, bottomRightBrickIndex)) 1 else 0;

        point.x = ball.x - middleBrickX;
        point.y = ball.y - middleBrickY;

        var angleFromBrickToBall = VectorMath.angle(point);

        var ballBelow = angleFromBrickToBall <= ballBelowMaxAngle || angleFromBrickToBall >= ballBelowMinAngle;
        var ballAbove = angleFromBrickToBall <= ballAboveMaxAngle && angleFromBrickToBall >= ballAboveMinAngle;
        var ballLeft = angleFromBrickToBall <= ballLeftMaxAngle && angleFromBrickToBall >= ballLeftMinAngle;
        var ballRight = angleFromBrickToBall <= ballRightMaxAngle && angleFromBrickToBall >= ballRightMinAngle;

        var bounced = false;
        var onTop = false;

        if (ballBelow && ball.velocity.y < 0 && !bottomBrickCollidable) {
            ball.velocity.y = -ball.velocity.y;
            ball.y = middleBrickBottom + Ball.HEIGHT * 0.5 + 1;
            bounced = true;
        }

        if (ballLeft && ball.velocity.x > 0 && !leftBrickCollidable) {
            ball.velocity.x = -ball.velocity.x;
            ball.x = middleBrickLeft - Ball.WIDTH * 0.5 - 1;
            bounced = true;
        }

        if (ballAbove && ball.velocity.y > 0 && !topBrickCollidable) {
            ball.velocity.y = -ball.velocity.y;
            ball.y = middleBrickTop - Ball.HEIGHT * 0.5 - 1;
            bounced = true;

            var brickIndex = middleBrickIndex - Game.NUM_BRICKS_X - Game.NUM_BRICKS_X;
            while (brickIndex >= 0 && !bricks[brickIndex].collidable) {
                brickIndex -= Game.NUM_BRICKS_X;
            }

            onTop = brickIndex < 0;
        }

        if (ballRight && ball.velocity.x < 0 && !rightBrickCollidable) {
            ball.velocity.x = -ball.velocity.x;
            ball.x = middleBrickRight + Ball.WIDTH * 0.5 + 1;
            bounced = true;
        }

        if (!bounced) {
            // There are no easy answers.
            // Something must be done.
            // This is something.
            // Therefore we must do this.
            ball.velocity.x = -ball.velocity.x;
            ball.velocity.y = -ball.velocity.y;
        }

        onHit(ball, numCollidedBricks, onTop);
    }

    private function getCollidableBrick(brickIndex:Int):Brick {
        if (brickIndex < 0 || brickIndex >= bricks.length) {
            return null;
        }

        var brick = bricks[brickIndex];

        if (brick.collidable) {
            return brick;
        } else {
            return null;
        }
    }

    private function collideBrick(ball:Ball, brickIndex:Int): Bool {
        var brick = getCollidableBrick(brickIndex);

        if (brick != null && brick.collideEntity(ball)) {
            point.x = ball.x;
            point.y = ball.y;

            brick.hit(point, ball.velocity);

            return true;
        } else {
            return false;
        }
    }
}