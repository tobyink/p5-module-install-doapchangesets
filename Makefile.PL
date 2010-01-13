use strict;
use warnings;

use inc::Module::Install;

my $dist = 'Module-Install-DOAPChangeSets';
my $fn   = "lib/$dist.pm"; $fn =~ s#-#/#g;

name                $dist;
perl_version_from   $fn;
version_from        $fn;
abstract_from       $fn;
readme_from         $fn;
author              'Toby Inkster <tobyink@cpan.org>';
license             'perl';

test_requires       'Test::More' => '0.61';

requires            'RDF::Trine'         => '0.112';
requires            'RDF::Query'         => '2.200';
requires            'File::Slurp'        => 0;
requires            'Text::Wrap'         => 0;
requires            'URI::file'          => 0;
requires            'LWP::Simple'        => 0;

resources(
	'homepage'   => "http://search.cpan.org/dist/$dist/",
	'repository' => "http://goddamn.co.uk/viewvc/perlmods/$dist/",
	'bugtracker' => "http://rt.cpan.org/Dist/Display.html?Queue=$dist",
	);
	
write_doap_changes;
write_doap_changes_xml;

include 'Test::Signature';
auto_install;
WriteAll(
	'meta' => 1,
	'sign' => 1,
	);
