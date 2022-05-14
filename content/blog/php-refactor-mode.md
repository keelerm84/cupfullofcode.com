+++
categories = ["Emacs", "PHP"]
tags = ["php", "refactoring", "emacs"]
date = 2014-09-21T00:00:00+00:00
description = "Wrapping a command line tool in a convenient emacs package"
title = "Performing Controlled PHP Refactorings in Emacs"
type = "blog"
+++

By day, I work as a PHP developer at
[Research Square](http://researchsquare.com).  My time is spent developing new
functionality for the RS suite of products.  This may include working in
greenfield code bases or extending our legacy products.  In either case, dozens
of times a day, I find myself performing various code refactorings.<!--more-->

# The Problem

Refactoring code is imperative to maintaining a healthy code base.  Technical
debt can quickly pile up in even a moderately sized code base, let alone across
a system flirting with a million lines of code.  It is the job of any developer
to ensure code is refactored whenever the existing design begins to offer
friction.  It is absolutely critical that these refactorings in no way alter
the behavior of the system.

In Martin Fowler's book,
[Refactoring: Improving the Design of Existing Code](http://martinfowler.com/books/refactoring.html),
he discusses a variety of common refactoring patterns, outlining the necessary
steps to execute these methods safely and efficiently.  While the steps given
are excellent, to perform them manually is not only tedious, but horribly error
prone.

While some IDEs provide automated support for such refactorings, text editors
like vim and emacs do not.  As a long time user of both (with emacs being my
favored editor these days), I needed to look elsewhere to achieve this kind of
support.

# The Solution

During my search for a decent solution, I came across the
[php-refactoring-browser](https://github.com/QafooLabs/php-refactoring-browser)
by QafooLabs.  The php-refactoring-browser is a command-line tool, written in
PHP, that can perform a variety of refactoring methods on a particular file.
Following the guidelines from Fowler's books, each refactoring is a series of
simple steps that ensure the system's behavior is left unaltered.

# A New Problem

I tried out this tool for a while and absolutely loved the results.  The
php-refactoring-browser performed remarkably well and provided me with a
solution I had desperately been seeking.  But alas, there was a problem.

While I love the command-line, using the php-refactoring-browser
directly was time consuming and frankly, quite annoying.  Each refactoring
method requires a decent number of arguments, including the file and associated
line numbers to operate on.

For example, in order to convert a local variable to an instance variable, the
command would look something like

{{< highlight bash >}}
php refactor.phar convert-local-to-instance-variable FileToRefactor.php 17 $aLocalVariableName
{{< / highlight >}}

Further more, the php-refactoring-browser will only generate a patch of the
necessary changes.  It will not modify the files inline.  Not only was I
responsible for providing all of these input parameters, I also had to manually
apply the patch, and then refresh the file in my editor.

# A New Solution

Being an enthusiastic user of emacs, I knew there had to be a better way.  So I
set out to create a minor mode for working with the php-refactoring-browser.
[php-refactor-mode](https://github.com/keelerm84/php-refactor-mode.el) is the
result.

This minor mode allows you to quickly perform a variety of the refactoring
methods available through the php-refactoring-browser with a few short
keystrokes.  Since emacs already knows the path to the file and any line
numbers, I was relieved from ever having to think about that again.  And as for
things emacs doesn't know, such as the new method name I might want to use, it
can simply prompt me for it.

Furthermore, the minor mode will automatically apply the resulting patch from
the php-refactoring-browser and re-read the file contents so you can focus on
the work at hand, never breaking your flow to think about the steps for
performing these refactorings.

As a final benefit, each refactoring can be undone as one atomic operation.  So
if you decide you don't like the results, press `C-_` and proceed as if it never
happened.

## Let's See It In Action

Below is a video demoing some of the supported refactoring methods provided by
php-refactor-mode.  If you're an emacs user who writes PHP, I hope you'll
consider giving it a try.  The package is available for installation on melpa
and of course the source code is available on github.

{{< youtube J9lbdtdsPi4 >}}

# vim Users

If you're a vim user, then you're in luck.
[vim-php-refactoring](https://github.com/vim-php/vim-php-refactoring) is a vim
plugin that provides the same type of support.  In fact, it was a great source
of inspiration for my emacs package.  Thanks for paving the way!

