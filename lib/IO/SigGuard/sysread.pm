package IO::SigGuard;

sub sysread {
  READ: {
        $result = ( (@_ == 3) ? CORE::sysread( $_[0], $_[1], $_[2] ) : (@_ == 4) ? CORE::sysread( $_[0], $_[1], $_[2], $_[3] ) : die "Wrong args count! sysread(@_)" ) or do {
            redo READ if $! == Errno::EINTR();
        };
    }

    return $result;
}

1;
