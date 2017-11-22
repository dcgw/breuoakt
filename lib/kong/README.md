# kong.hx

Strongly-typed access to the Kongregate API from Haxe.


## Getting Started

To get an instance of the Kongregate API object, call the static function
`Kongregate.loadApi(onLoad)`. kong.hx will load the Kongregate API in the
background, and call `onLoad` when it is ready. For example:

```haxe
Kongregate.loadApi(function(api:KongregateApi) {
    // Your code here.
    // 'api' is an instance of the Kongregate API object.
});
```

Before using the Kongregate API object, you should call
`api.services.connect()` to connect to the Kongregate back-end (where `api` is
an instance of the Kongregate API). It is good practise to call this function
as soon as possible after obtaining a Kongregate API object. For example:

```haxe
var kongregate:KongregateApi;

function initApi() {
    Kongregate.loadApi(function(api:KongregateApi) {
        // Save Kongregate API reference.
        kongregate = api;

        // Connect to the back-end.
        kongregate.services.connect();
    });
}
```

The Kongregate API object matches the typedef `KongregateApi`, which exposes
the majority of the Kongregate API with strong typing.

Further documentation is available inline in the implementation, and from
the [Kongregate Developer Center][1].


## Example

```haxe
import kong.Kongregate;
import kong.KongregateApi;

class Game {
    static var kongregateApi:KongregateApi;

    static function main () {
        Kongregate.loadApi(function(api:KongregateApi) {
            // Save a reference to the Kongregate API.
            Game.kongregateApi = api;
        
            // Connect to the back-end.
            api.services.connect();
            
            // Start the game.
            Game.start();
        });
    }
    
    static function start() {
        // As a silly example, immediately submit some statistics
        // to Kongregate.
        Game.kongregateApi.stats.submit("highscore", 187560);
        Game.kongregateApi.stats.submit("hoopsJumped", 42);
    }
}
```

## Platforms

kong.hx can be used when targeting Flash 8 or 9 (or later).

It should be straightforward to extend it to work when targeting JavaScript.


## Missing features

kong.hx does not currently support:

 * Custom Chat
 * Feeds and User Messaging

It should be straightforward to add support for these features.


## Authors

Written by Daniel J. Cassidy.

Thanks to Terry Cavanagh for his improvements to the documentation.


## License

Copyright © 2012–2017 Daniel J. Cassidy.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


[1]: http://developers.kongregate.com/docs/api-overview/intro
