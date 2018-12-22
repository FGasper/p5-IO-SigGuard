package IO::SigGuard;

sub sysread {
    $result = ( (@_ == 3) ? CORE::sysread( $_[0], $_[1], $_[2] ) : (@_ == 4) ? CORE::sysread( $_[0], $_[1], $_[2], $_[3] ) : die "Wrong args count! sysread(@_)" ) or do {
        goto &sysread if $! == Errno::EINTR();
    };

    return $result;
}

1;
