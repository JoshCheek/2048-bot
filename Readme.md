2048 Robot
==========

In response to [a challenge](https://twitter.com/Ex_Caelum/status/771393100015030275).

Video of it shittily beating 2048 [here](https://twitter.com/josh_cheek/status/771502796340400128).

```sh
# To play (use the arrow keys or vim keybindings)
$ bin/play

# To watch the bot play (it's not very good)
$ bin/watch

# To run the tests (if you don't have rspec, do `gem install rspec`)
$ rspec
```

Accuracy
--------

The current implementation doesn't consider that 4 can spawn.
Namely b/c that seemed less important than getting the AI to be able
to beat the game as it was, and I feel like I need to read their code
in order to find out the real answer for how fours appear.

...actually, as I write this, I realize it's stupid, so I just checked
and found the answer in like 3 minutes: there's a 90% chance of getting
a 2 and a 10% chance of getting a 4 ([code](https://github.com/gabrielecirulli/2048/blob/837ca51b6f254c416cb74b6a1baa1bb7cc7e6fd1/js/game_manager.js#L69)).


The board
---------

Assumes a terminal of `xterm-256color`
You'll know it works if you see nuanced colours.
You can check your terminal with `$ echo $TERM`.


The neural network
------------------

I spent several hours refactoring a neural network to try to use it,
but so far haven't figured out any reasonable way to do so (it assumes
you know where you want the bot to move, but if I knew, then I presumably
wouldn't need the network, I'd just make that the heuristic).
One possibility is to play myself and record my own moves, then train the
bot to prefer those moves, at least to bootstrap it past random synapses.
That's already started in that I addes a binary to play the game,
so now it's just record the boards played and the moves made.

It might also have an issue with the size of the inputs, though.
I tried dividing by the maximum tile, but it was large enough (32k)
to reduce all inputs, effectively to 0. In retrospect, I probably
should have log base 2'd it, and then divided by the power.
Whatevz.


The heuristic
-------------

I've tried a number of different things now. The one that seems to work best
is to give it points for ascending sequences. Otherwise it's too inclined to
let the big tiles go to the middle.


The heuristic bot
-----------------

Just plays forward some number of moves and then calculates the heuristic
to see which one looked best. This suffers from the mediocrity of the heuristic,
and the fact that the board will place the tile randomly, but the bot
looks at it as if that's where the tile will appear. I could maybe make the
random tile be an "opponent" in a minimax style game. This would probably do
pretty well b/c it wouldn't gain false confidence due to random luck as it
simulates the game.


Probability clouds
------------------

IDK if there's a word for this idea, but I've been learning about
quantum mechanics, and one interesting facet is that the positions
of elementary particles propagate as a probability wave (the probability
wave can go through both slits of the double slit experiment, and then
interfere with itself on the other side, hence this famous experiment)
I wonder if there's not a way to explore a similar concept here.

Obviously it'd be foolish to actually treat it this way, b/c they would
interfere in a nonuseful way, eg:

```
---------
| 0 | 0 |
---------
```

Would have equal probability of being generated, so:

```
-------------------
| 0: 50% | 0: 50% |
| 2: 50% | 2: 50% |
-------------------
```

Then shift right:

```
--------------------
| 0: 100% | 0: 25% |
|         | 2: 50% |
|         | 4: 25% |
--------------------
```

Which makes no sense. But, if slices of probabilities were
kept separate, we could represent it like this:

```
50%:  ---------
      | 2 | 0 |
      ---------
50%:  ---------
      | 0 | 2 |
      ---------
```

Then shift right:

```
50%:  ---------
      | 0 | 2 |
      ---------
50%:  ---------
      | 0 | 2 |
      ---------
```

And consolidate:

```
100%: ---------
      | 0 | 2 |
      ---------
```

Then again, maybe this is just a form of caching?

IDK, might give it a shot. Would enjoy seeing how that
drives changes to the `Board` class.


License
-------

Do what the fuck you want to
