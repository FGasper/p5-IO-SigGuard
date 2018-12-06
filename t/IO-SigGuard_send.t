#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

use IO::Socket ();

use IO::SigGuard ();

plan tests => 1;

use Socket;

#NB: not 'IGNORE'
$SIG{'QUIT'} = sub {};

socketpair my $psk, my $csk, Socket::PF_UNIX, Socket::SOCK_STREAM, 0;

$csk = IO::Socket->new_from_fd( fileno($csk), 'r+' );

my $ppid = $$;

my $cpid = fork;
die $! if !defined $cpid;
$cpid or do {
    close $psk or die;

    $csk->blocking(0);

    my $rin = q<>;
    vec( $rin, fileno($csk), 1 ) = 1;

    my $rout;

    while (1) {
        if ( select $rout = $rin, undef, undef, undef ) {
            sysread( $csk, my $buf, 65536 ) or die $!;
        }

        #Without this it’s possible to trip Perl’s 120-signals limit.
        select undef, undef, undef, 0.01;
    }

    exit;
};

close $csk or die $!;

my $start = time;

my $secs = 8;

note "Thrashing IPC for $secs seconds to test EINTR resistance …";

while (time - $start < $secs) {
    IO::SigGuard::send( $psk, 'x' x 64, 0 ) or die $!;
}

kill 'KILL', $cpid or die $!;

ok 1;
