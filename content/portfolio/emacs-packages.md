+++
type = "itemized"
author = "Matthew M. Keeler"
date = "2017-06-22"
title = "Emacs Packages"
description = "Contributions across a variety of emacs packages"
featured = ""
featuredpath = ""
featuredalt = ""
linktitle = ""
format = "emacs"
link = ""
+++

### Projectile

Projectile is a project interaction library for Emacs. Its goal is to provide a
nice set of features operating on a project level without introducing external
dependencies(when feasible).

I added some defadvice to the delete-file functionality that would remove the
file from the cache automatically, preventing the user from having to manually
invalidate everything in order to clean up the file list.

### buster-mode

buster-mode is a minor mode for emacs to speed up development when writing
tests with Buster.js.

My contributed was limited to a minor code improvement that replaced an
unnecessary loop with a better built-in mechanism.

### gist.el

Emacs integration for gist.github.com

Fixed two long outstanding bugs; one was related to errors being generated when
trying to add buffers associated with persisted files and the other was with
private gists being reverted to public access.

### org-journal

Functions to maintain a simple personal diary / journal in Emacs.

I have contributed a few little patches to this project including fixing the
ability to find previous journal entries with customized formats, view-mode
toggling on and off, cleaning up lingering debugging statements and ensuring
that the appropriate major modes were enabled prior to referencing their
functionality.
