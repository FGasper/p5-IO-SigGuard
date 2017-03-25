
use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'IO::SigGuard',
    VERSION_FROM => 'lib/IO/SigGuard.pm',         # finds \$VERSION
    AUTHOR       => 'Felipe Gasper',
    ABSTRACT_FROM => 'lib/IO/SigGuard.pm',
    LICENSE      => 'perl',

    PREREQ_PM    => {
    },
    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources   => {
            repository => {
                type => 'git',
                url  => 'https://github.com/FGasper/p5-IO-SigGuard.git',
                web  => 'https://github.com/FGasper/p5-IO-SigGuard',
            },
        },
    },
    TEST_REQUIRES => {
        'Test::More'      => 0,
        'Test::Simple'    => 0,
        'File::Temp' => 0,
        'File::Slurp' => 0,
    },
);
