package IO::SigGuard;

=encoding utf-8

=head1 NAME

IO::SigGuard - SA_RESTART in pure Perl

=head1 SYNOPSIS

    IO::SigGuard::sysread( $fh, $buf, $size );
    IO::SigGuard::sysread( $fh, $buf, $size, $offset );

    IO::SigGuard::syswrite( $fh, $buf );
    IO::SigGuard::syswrite( $fh, $buf, $len );
    IO::SigGuard::syswrite( $fh, $buf, $len, $offset );

    IO::SigGuard::send( $fh, $msg, $flags );
    IO::SigGuard::send( $fh, $msg, $flags, $to );

    IO::SigGuard::select( $read, $write, $exc, $timeout );

=head1 DESCRIPTION

C<perldoc perlipc> describes how Perl versions from 5.8.0 onward disable
the OS’s SA_RESTART flag when installing Perl signal handlers.

This module imitates that pattern in pure Perl: it does an automatic
restart when a signal interrupts an operation so you can avoid
the generally-useless EINTR error when using
C<sysread()>, C<syswrite()>, and C<select()>.

For this to work, whatever signal handler you implement will need to break
out of this module, probably via either C<die()> or C<exit()>.

=head1 ABOUT C<sysread()> and C<syswrite()>

Other than that you’ll never see EINTR and that
there are no function prototypes used (i.e., you need parentheses on
all invocations), C<sysread()> and C<syswrite()>
work exactly the same as Perl’s equivalent built-ins.

=head1 LAZY-LOADING

As of version 0.13 this module’s functions lazy-load by default. To have
functionality loaded at compile time give the function name to the import
logic, e.g.:

    use IO::SigGuard qw(send recv);

=head1 ABOUT C<select()>

To handle EINTR, C<IO::SigGuard::select()> has to subtract the elapsed time
from the given timeout then repeat the internal C<select()>. Because
the C<select()> built-in’s C<$timeleft> return is not reliable across
all platforms, we have to compute the elapsed time ourselves. By default the
only means of doing this is the C<time()> built-in, which can only measure
individual seconds.

This works, but there are two ways to make it more accurate:

=over

=item * Have L<Time::HiRes> loaded, and C<IO::SigGuard::select()> will use that
module rather than the C<time()> built-in.

=item * Set C<$IO::SigGuard::TIME_CR> to a compatible code reference. This is
useful, e.g., if you have your own logic to do the equivalent of
L<Time::HiRes>—for example, in Linux you may prefer to call the C<gettimeofday>
system call directly from Perl to avoid L<Time::HiRes>’s XS overhead.

=back

In scalar contact, C<IO::SigGuard::select()> is a drop-in replacement
for Perl’s 4-argument built-in.

In list context, there may be discrepancies re the C<$timeleft> value
that Perl returns from a call to C<select>. As per Perl’s documentation
this value is generally not reliable anyway, though, so that shouldn’t be a
big deal. In fact, on systems like MacOS where the built-in’s C<$timeleft>
is completely useless, IO::SigGuard’s return is actually B<better> since it
does provide at least a rough estimate of how much of the given timeout value
is left.

See C<perlport> for portability notes for C<select>.

=head1 TODO

This pattern could probably be extended to other system calls that can
receive EINTR. I’ll consider adding new calls as requested.

=cut

use strict;
use warnings;

use Errno ();

our $VERSION = '0.15';

#As light as possible …

my $result;

sub import {
    shift;

    require "IO/SigGuard/$_.pm" for @_;

    return;
}

our $AUTOLOAD;

sub AUTOLOAD {
    $AUTOLOAD = substr( $AUTOLOAD, 1 + rindex($AUTOLOAD, ':') );

    require "IO/SigGuard/$AUTOLOAD.pm";

    goto &{ IO::SigGuard->can($AUTOLOAD) };
}

=head1 REPOSITORY

L<https://github.com/FGasper/p5-IO-SigGuard>

=head1 AUTHOR

Felipe Gasper (FELIPE)

… with special thanks to Mario Roy (MARIOROY) for extra testing
and a few fixes/improvements.

=head1 COPYRIGHT

Copyright 2017 by L<Gasper Software Consulting|http://gaspersoftware.com>

=head1 LICENSE

This distribution is released under the same license as Perl.

=cut

1;
