package IO::SigGuard;

sub recv {
  RECV: {
        $result = ( (@_ == 4) ? CORE::recv( $_[0], $_[1], $_[2], $_[3] ) : die "Wrong args count! recv(@_)" ) or do {
            redo RECV if $! == Errno::EINTR();
        };
    }

    return $result;
}

1;
