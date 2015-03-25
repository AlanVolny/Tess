Tess - time chess
=
====================

A meta-time boardgame (experiment).

There is one board, but multiple slices of it through time; board at t=0, t=1, t=2, and so on. Any changes to board|t=2 propagates to board|t=3, which propagates to board|t=4, which propagates to board|t=5 and so on.

====================

Dependencies:
[openfl](http://www.openfl.org/) 2.1.5 (3 currently has some issues)

Downloads will be add later.

====================

**Curent setup**

The point of the game is to get one of your pawns to the opposite side (victory condition not implemented). No AI, human v human only.

A 4x5x6 board, each side starts with 4 pawns. Pawns can move forward, left, right. A pawn can 'cancel' it's future actions by moving to a different spot. A dead pawn will still remember what actions it does in a non-dead future.

Click on a unit, then click where you'd like the piece to go. In the current setup, units only move to spaces one board in the future. Available spaces are shown in green, kill moves are shown in red. The empty indicator boxes on the board when selecting show the piece's future positions/moves, even if the piece dies before completing all it's moves.

====================

**Screenshots**

Start board:

![Start board](http://i.imgur.com/Z6UDxMx.png)

Selected White1:

![Selected White1|t=1](http://i.imgur.com/lTD31Xc.png)

White2 going for the win!:

![White2 going for the win!](http://i.imgur.com/R8GZfV5.png)

White2 is intercepted by Black1. White2 is selected, allowing you to see where the piece would end up if it was not killed. :

![White2 is intercepted by Black1. White2 is selected, allowing you to see where the piece would end up if it was not killed ](http://i.imgur.com/6EH0WaK.png)

====================

Game pieces are from here:

http://opengameart.org/content/chess-pieces-1