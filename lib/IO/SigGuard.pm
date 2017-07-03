package IO::SigGuard;

=encoding utf-8

=head1 NAME

IO::SigGuard - Signal protection for sysread/syswrite

=head1 SYNOPSIS

    IO::SigGuard::sysread( $fh, $buf, $size );
    IO::SigGuard::sysread( $fh, $buf, $size, $offset );

    IO::SigGuard::syswrite( $fh, $buf );
    IO::SigGuard::syswrite( $fh, $buf, $len );
    IO::SigGuard::syswrite( $fh, $buf, $len, $offset );

    IO::SigGuard::select( $read, $write, $exc, $timeout );

=head1 DESCRIPTION

C<perldoc perlipc> describes how Perl versions from 5.8.0 onward disable
the OS’s SA_RESTART flag when installing Perl signal handlers.

This module restores that pattern: it does an automatic restart
when a signal interrupts an operation, so you can entirely avoid
the generally-useless C<EINTR> error when using
C<sysread()>, C<syswrite()>, and C<select()>.

=head1 ABOUT C<sysread()> and C<syswrite()>

Other than that you’ll never see C<EINTR> and that
there are no function prototypes used (i.e., you need parentheses on
all invocations), C<sysread()> and C<syswrite()>
work exactly the same as Perl’s equivalent built-ins.

=head1 ABOUT C<select()>

In scalar contact, C<IO::SigGuard::select()> should be a drop-in replacement
for Perl’s built-in.

In list context, there may be discrepancies in the C<$timeleft> value
that Perl returns from a call to C<select>. This value, as per Perl’s
documentation is generally not reliable anyway, so that shouldn’t be a big
deal. In fact, on systems (e.g., MacOS) where the built-in’s C<$timeleft>
is completely useless, IO::SigGuard’s return is actually *better* since it
does provide at least a rough value for how much of the given timeout value
is left.

If you have C<Time::HiRes> loaded, then C<$timeleft> will include fractions
of a second; otherwise, that value will be an integer.

=cut

use strict;
use warnings;

our $VERSION = '0.013';

#As light as possible …

my $read;

sub sysread {
  READ: {
        $read = ( (@_ == 3) ? CORE::sysread( $_[0], $_[1], $_[2] ) : (@_ == 4) ? CORE::sysread( $_[0], $_[1], $_[2], $_[3] ) : die "Wrong args count! (@_)" ) or do {
            if ($!) {
                redo READ if $!{'EINTR'};
            }
        };
    }

    return $read;
}

my $wrote;

sub syswrite {
    $wrote = 0;

  WRITE: {
        $wrote += ( (@_ == 2) ? CORE::syswrite( $_[0], $_[1], length($_[1]) - $wrote, $wrote ) : (@_ == 3) ? CORE::syswrite( $_[0], $_[1], $_[2] - $wrote, $wrote ) : (@_ == 4) ? CORE::syswrite( $_[0], $_[1], $_[2] - $wrote, $_[3] + $wrote ) : die "Wrong args count! (@_)" ) || do {
            if ($!) {
                redo WRITE if $!{'EINTR'};  #EINTR => file pointer unchanged
                return undef;
            }

            die "empty write without error??";  #unexpected!
        };
    }

    return $wrote;
}

my ($start, $last_loop_time, $os_error, $nfound, $timeleft, $timer_cr);

sub select {
    $os_error = $!;

    $timer_cr = Time::HiRes->can('time') || \&CORE::time;

    $start = $timer_cr->();
    $last_loop_time = $start;

  SELECT: {
        ($nfound, $timeleft) = CORE::select( $_[0], $_[1], $_[2], $_[3] - $last_loop_time + $start );
        if ($nfound == -1) {
            if ($!{'EINTR'}) {
                $last_loop_time = $timer_cr->();
                redo SELECT;
            }
        }
        else {

            #select() doesn’t set $! on success, so let’s not clobber what
            #value was there before.
            $! = $os_error;
        }

        return wantarray ? ($nfound, $timeleft) : $nfound;
    }
}

=head1 REPOSITORY

L<https://github.com/FGasper/p5-IO-SigGuard>

=head1 AUTHOR

Felipe Gasper (FELIPE)

… with special thanks to Mario Roy (MARIOROY) for extra testing
and a few fixes/improvements.

=head1 COPYRIGHT

Copyright 2017 by L<Gasper Software Consulting, LLC|http://gaspersoftware.com>

=head1 LICENSE

This distribution is released under the same license as Perl.

=cut

1;
