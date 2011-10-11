#-------------------------------------------------------------------------------
eval 'exec perl -S $0 ${1+"$@"}'
    if $running_under_some_shell;

#-------------------------------------------------------------------------------
use File::Basename;
use File::Copy;
use File::Path;
use File::Find;
use Time::Local;
use Cwd;

#
# Technique to bind to Edgeserver build module at runtime (the use
# directive binds at compile time).
#
($name, $path) = fileparse("$0");

($path = "./") if (!$path);

require "e:/dev/binsrc/Build.pm";

# Initialize local variables.
$local_dir = ".";
$debugging = 0;
$use_srclist = 0;
$mod_attributes = 0;
$quiet = 0;
$match_arg = ".*";
$outfile = "";

# Print help if there are no options.
usage() if ($#ARGV < 0);

# Parse optional arguments.
while ($_ = $ARGV[0], /^-/)
{
    &usage() if (/-\?|-h$/);

    # When true, prints commands to screen but does nothing.
    /-a/     && ($mod_attributes = 1);
    /-d/     && ($debugging = 1);
    /-m(.+)/  && ($match_arg = $1);
    /-o(.+)/ && ($outfile = $1);
    /-q/     && ($quiet = 1);
    /-s/     && ($use_srclist = 1);
    shift;
}

# Parse mandatory arguments.
$local_dir = shift;
die "Error:  Expected directory name for first argument" if (!-d $local_dir);

# Dump arguments.
if ( $debugging )
{
    print "local_dir = ${local_dir}\n";
    print "use_srclist = ${use_srclist}\n";
    print "outfile = ${outfile}\n";
    print "modify attributes = ${mod_attributes}\n";
    print "match_arg = ${match_arg}\n";
}

if ( $outfile )
{
    open OUT, ">$outfile" or die "can not open ${outfile}\n";
}

#find( \&wanted, $local_dir );
finddepth( \&wanted, $local_dir );
@list = sort @list;
for $i ( 0 .. $#list )
{
    ($etime, $date, $time, $path) = split / /, $list[$i];
    print $path;
}

close OUT;

#-------------------------------------------------------------------------------
sub diff
{
	if ( $_ =~ /$match_arg/ )
	{
		$dir = getcwd();
	    $result = (&call_system ("vdiff.exe -B -T -Q -XEnul -r ${_}"));
	    if ($result == 0)
	    {
			# The file is in the archive and it is the same.
			if ( !$quiet )
			{
	        	print "  ${dir}\\${_}\n";
			}
	    }
	    elsif ($result == 256)
		{
			# The file is not in the archive.
			if ( !$quiet )
			{
	            print "- ${dir}\\${_}\n";
			}
		}
	    elsif ($result == 512)
	    {
			# The file is in the archive and it is different.
			if ( !$quiet )
			{
	        	print "+ ${dir}\\${_}\n";
	        }
	        if ( $outfile )
	        {
	            print OUT "${dir}\\${_}\n";
	        }
	        if ( $mod_attributes )
	        {
	            (&call_system ("attrib.exe -a -r ${_}") == 0) || die "Error: Could not set the archive bit for ${cwd}/${_}\n";
	        }
	    }
	    else
	    {
			# I do not recognize this return value.
	        die "vdiff.exe returned a value of ${result}.\n";
	    }
	}
}

#-------------------------------------------------------------------------------
sub wanted
{
    if ( -f $_ )
	{
		if ( $use_srclist )
		{
			if ( /^srclist$/ )
			{
				open( SRCLIST, "<srclist" );
				while ( $_ = <SRCLIST> )
				{
					# Strip quotes and newline.
					s/\"//g;
					s/\n//g;

					# Ignore blank lines.
					if ( $_ eq "" )
					{
						next;
					}

					diff( "\"${_}\"" );
		 		}

				close( SRCLIST );
			}
		}
		else
		{
			diff( $_ );
		}
	}
}

#-------------------------------------------------------------------------------
sub usage
{
    print "usage:  rdiff.pl [options] <directory>\n";
    print "\n";
    print "        -a              modify attributes (attrib.exe -a -r)\n";
    print "        -d              debug\n";
    print "        -h              help\n";
    print "        -o\"file\"        create list of files that differ (usable as a srclist)\n";
    print "        -m\"regex match\" example: -m\"(\\.cpp)|(\\.h)|(\\.c\$)\"\n";
    print "        -q              quiet\n";
    print "        -s              only diff files in srclist\n";
    print "\n";
    print "Output takes the form of:  prefix filename, where prefix is\n";
    print "' '	File is the same\n";
    print "'+'	File is different than the archive\n";
    print "'-'	File is missing from the archive\n";
    print "\n";
    exit;
}

