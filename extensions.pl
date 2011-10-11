#-------------------------------------------------------------------------------
eval 'exec perl -S $0 ${1+"$@"}'
    if $running_under_some_shell;

#-------------------------------------------------------------------------------
use File::Find;
use Cwd;

# Initialize local variables.
$local_dir = ".";
$debug     = 0;

# Print help if there are no options.
usage() if ($#ARGV < 0);

# Parse optional arguments.
while ($_ = $ARGV[0], /^-/)
{
    &usage() if (/-\?|-h$/);

    # When true, prints commands to screen but does nothing.
    /-debug/  && ($debug = 1);
    shift;
}

# Parse mandatory arguments.
$local_dir = shift;
die "Error:  Expected directory name for first argument" if (!-d $local_dir);

# Dump arguments.
if ( $debug )
{
    print "local_dir = ${local_dir}\n";
}

find( \&wanted, $local_dir );
foreach $key (sort(keys %list) )
{
	print "${key}\n";
}

#-------------------------------------------------------------------------------
sub wanted
{
    if ( -f $_ )
    {
		if ( tr/\./\./ )
		{
			$_ =~ s#.+\.#.#g;
			$_ = lc $_;
			$list{$_} = 1;
		}
    }
}

#-------------------------------------------------------------------------------
sub usage
{
    print "usage:  extensions.pl [options] <directory>\n";
    print "\n";
    print "options:  -debug\n";
    exit;
}

