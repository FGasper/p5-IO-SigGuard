#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

use IO::Socket ();

use IO::SigGuard ();

plan tests => 1;

#NB: not 'IGNORE'
$SIG{'QUIT'} = sub {};

my ($pr, $cw);

use Socket;
socketpair my $psk, my $csk, Socket::PF_UNIX, Socket::SOCK_STREAM, 0;

$csk = IO::Socket->new_from_fd( fileno($csk), 'r+' );

my $ppid = $$;

my $cpid = fork;
die $! if !defined $cpid;
$cpid or do {
    close $psk;

    $csk->blocking(0);

    my $rin = q<>;
    vec( $rin, fileno($csk), 1 ) = 1;

    my $rout;

    while (1) {
        if ( select undef, $rout = $rin, undef, undef ) {
            syswrite( $csk, ('x' x 32) ) or die $!;
        }
        kill 'QUIT', $ppid or die $!;

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
    my $from = IO::SigGuard::recv( $psk, my $buf, 65536, 0 );
    die $! if !defined $from;
}

kill 'KILL', $cpid or die $!;

ok 1;
