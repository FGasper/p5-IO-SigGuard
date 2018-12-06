# NAME

IO::SigGuard - SA\_RESTART in pure Perl

# SYNOPSIS

    IO::SigGuard::sysread( $fh, $buf, $size );
    IO::SigGuard::sysread( $fh, $buf, $size, $offset );

    IO::SigGuard::syswrite( $fh, $buf );
    IO::SigGuard::syswrite( $fh, $buf, $len );
    IO::SigGuard::syswrite( $fh, $buf, $len, $offset );

    IO::SigGuard::send( $fh, $msg, $flags );
    IO::SigGuard::send( $fh, $msg, $flags, $to );

    IO::SigGuard::select( $read, $write, $exc, $timeout );

# DESCRIPTION

`perldoc perlipc` describes how Perl versions from 5.8.0 onward disable
the OS’s SA\_RESTART flag when installing Perl signal handlers.

This module imitates that pattern in pure Perl: it does an automatic
restart when a signal interrupts an operation so you can avoid
the generally-useless EINTR error when using
`sysread()`, `syswrite()`, and `select()`.

For this to work, whatever signal handler you implement will need to break
out of this module, probably via either `die()` or `exit()`.

# ABOUT `sysread()` and `syswrite()`

Other than that you’ll never see EINTR and that
there are no function prototypes used (i.e., you need parentheses on
all invocations), `sysread()` and `syswrite()`
work exactly the same as Perl’s equivalent built-ins.

# LAZY-LOADING

As of version 0.13 this module’s functions lazy-load by default. To have
functionality loaded at compile time give the function name to the import
logic, e.g.:

    use IO::SigGuard qw(send recv);

# ABOUT `select()`

To handle EINTR, `IO::SigGuard::select()` has to subtract the elapsed time
from the given timeout then repeat the internal `select()`. Because
the `select()` built-in’s `$timeleft` return is not reliable across
all platforms, we have to compute the elapsed time ourselves. By default the
only means of doing this is the `time()` built-in, which can only measure
individual seconds.

This works, but there are two ways to make it more accurate:

- Have [Time::HiRes](https://metacpan.org/pod/Time::HiRes) loaded, and `IO::SigGuard::select()` will use that
module rather than the `time()` built-in.
- Set `$IO::SigGuard::TIME_CR` to a compatible code reference. This is
useful, e.g., if you have your own logic to do the equivalent of
[Time::HiRes](https://metacpan.org/pod/Time::HiRes)—for example, in Linux you may prefer to call the `gettimeofday`
system call directly from Perl to avoid [Time::HiRes](https://metacpan.org/pod/Time::HiRes)’s XS overhead.

In scalar contact, `IO::SigGuard::select()` is a drop-in replacement
for Perl’s 4-argument built-in.

In list context, there may be discrepancies re the `$timeleft` value
that Perl returns from a call to `select`. As per Perl’s documentation
this value is generally not reliable anyway, though, so that shouldn’t be a
big deal. In fact, on systems like MacOS where the built-in’s `$timeleft`
is completely useless, IO::SigGuard’s return is actually **better** since it
does provide at least a rough estimate of how much of the given timeout value
is left.

See `perlport` for portability notes for `select`.

# TODO

This pattern could probably be extended to other system calls that can
receive EINTR. I’ll consider adding new calls as requested.

# REPOSITORY

[https://github.com/FGasper/p5-IO-SigGuard](https://github.com/FGasper/p5-IO-SigGuard)

# AUTHOR

Felipe Gasper (FELIPE)

… with special thanks to Mario Roy (MARIOROY) for extra testing
and a few fixes/improvements.

# COPYRIGHT

Copyright 2017 by [Gasper Software Consulting](http://gaspersoftware.com)

# LICENSE

This distribution is released under the same license as Perl.
