Gnus Bogofilter
===============

**[Bogofilter][] mail filter features for [Gnus][] ([Emacs's][Emacs]
mail and news client)**

[Bogofilter]: http://bogofilter.sourceforge.net/
[Gnus]: http://www.gnus.org/
[Emacs]: https://www.gnu.org/software/emacs/


Info
----

To manually install this package put `gnus-bogofilter.el` file somewhere
in Emacs's `load-path` and add expression `(require 'gnus-bogofilter)`
in Gnus's init file (for example `~/.gnus.el`). The Bogofilter program
must be installed separately. It should be available in all common
GNU/Linux distributions.

This package adds a Bogofilter mail-splitting function
`bogofilter-split` which can be used with Gnus's `nnmail-split-fancy` or
`nnimap-split-fancy`.

There are also interactive commands for Gnus's summary buffer. Commands
`bogofilter-register-ham` and `bogofilter-register-spam` can be used to
manually train Bogofilter's database. Command `bogofilter-check` prints
current message's Bogofilter classification and spam score. Variable
`bogofilter-program` configures the Bogofilter executable program.

See functions' and variable's description for more info.


Why not Gnus spam package?
--------------------------

Gnus has its own full-featured spam-filtering framework. I have used it
many years but, in my opinion, it's over-designed and complicated. It
practically requires Gnus registry too which adds to the complexity. For
basic Bogofilter-based mail-filtering a simpler approach may suit
better. Thus, this package.


Copyright and License
---------------------

Copyright (C) 2015 Teemu Likonen <<tlikonen@iki.fi>>

PGP: [4E10 55DC 84E9 DFF6 13D7 8557 719D 69D3 2453 9450][PGP]

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation, either version 3 of the License, or (at your
option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
Public License for more details.

The license text: <http://www.gnu.org/licenses/gpl-3.0.html>

[PGP]: http://koti.kapsi.fi/~dtw/pgp-key.asc
