#!/usr/bin/env perl

use Test::More;

use IO::SigGuard qw( send );

can_ok( 'IO::SigGuard', 'send' );

ok(
    !IO::SigGuard->can('sysread'),
    'lazy-load function isn’t loaded originally',
);

pipe my $r, my $w;
close $w;

IO::SigGuard::sysread($r, my $buf, 1);

ok(
    IO::SigGuard->can('sysread'),
    'lazy-load function is loaded after use',
);

done_testing();
