package breuoakt;

class Sayings {
    var sayingsForHitBrick:Array<String>;
    var sayingsForLostBall:Array<String>;

    public function new() {
        sayingsForHitBrick = ["ow!", "that hurt!", "you rotter!", "wizard!", "first rate!", "you really are a brick!",
                "first class!", "my word!", "jolly good!", "well done!", "clear off!", "oi!", "hurrah!", "superb!",
                "blimey!", "cor!", "crikey!", "top hole!"];
        sayingsForLostBall = ["chin up", "never mind", "not to worry", "oh no", "bad show",
                "that must be a bit of a blow for you", "it'll all sort itself out", "buck up",
                "time for a nice cup of tea"];
    }

    public function forHitBrick() {
        return sayingsForHitBrick[Std.random(sayingsForHitBrick.length)];
    }

    public function forLostBall() {
        return sayingsForLostBall[Std.random(sayingsForLostBall.length)];
    }
}
