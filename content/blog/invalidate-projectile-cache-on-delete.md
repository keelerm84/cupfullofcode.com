+++
categories = ["Emacs"]
tags = ["projectile", "elisp", "emacs"]
date = 2014-10-06T21:36:39+00:00
description = "An exercise in defadvice hooks"
title = "Invalidate Projectile Cache on Delete"
+++

[Projectile](https://github.com/bbatsov/projectile) is a staple of my emacs
configuration.  In my opinion, it is one of the all time best packages
available, along with [org-mode](https://github.com/jwiegley/org-mode) and
[magit](https://github.com/magit/magit).

One of my most commonly used commands with projectile is helm-projectile.  This
lets me locate any file in my project by pressing `C-c p h`.  Using the
narrowing abilities of helm, I can quickly filter the list of options to
exactly the one I want.<!--more-->

Because I work on some projects that are extremely large in size, I have
enabled projectiles caching mechanism.  This tells projectile to maintain a
local cache of all the files within a project for faster searching.  You can
enable this with `(setq projectile-enable-caching t)`

Projectile helps maintain the current state of this cache by adding a hook to
find-file.  Whenever a new file is found or created, projectile will
automatically add that new file to the cache.  This saves me from having to
manually invalidate the cache with `C-c p i` every time a create a new file.

However, if I delete a file, projectile does not automatically remove it from
the cache.  The next time I search for a similarly named file, the deleted file
will still show up in the helm list of candidates.  While not a deal breaker,
it is certainly a source of annoyance for me.  Since emacs is all about
tweaking your environment to eliminate those little headaches, I knew I had to
fix it.

At first, I thought adding a hook to delete-file would be the easy,
straightforward fix.  I couldn't find any documentation for a
delete-file-hook.  Having tried to check out the source code, I realized that
while find-file is implemented in lisp, delete-file is actually implemented in
C.

Having been unable to find a hook associated with this function, what was I do
to?

This is where defadvice comes in.  I won't go into detail about how defadvice
works, but the short version is that defadvice allows you to suggest behavior
to emacs before, after, or around an invocation of a particular function.  You
can read more about
[defadvice](https://www.gnu.org/software/emacs/manual/html_node/elisp/Advising-Functions.html)
in the manual.

The below snippet adds advice before the delete-file function is called.  It
checks to see if the file is part of a projectile project; if the file is
cached by projectile, it removes it from the cache.

**NOTE** This defadvice function is no longer necessary.  This functionality has
 now been incorporated into projectile.

{{< highlight lisp >}}
(defadvice delete-file (before purge-from-projectile-cache (filename &optional trash))
  (if (and (projectile-project-p) projectile-enable-caching)
      (let* ((project-root (projectile-project-root))
             (true-filename (file-truename filename))
             (relative-filename (file-relative-name true-filename project-root)))
        (if (projectile-file-cached-p relative-filename project-root)
            (projectile-purge-file-from-cache relative-filename)))))

(ad-activate 'delete-file)
{{< / highlight >}}

That's it.  With just a few short lines, projectile will now invalidate the
cache as soon as I delete a file, just as I would like.  Isn't emacs great?
