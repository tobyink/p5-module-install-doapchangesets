package Module::Install::Admin::DOAPChangeSets;

use strict;
use RDF::DOAP::ChangeSets;
use File::Slurp qw(slurp);
use URI::file;
use Module::Install::Base;

use vars qw{$VERSION @ISA};
BEGIN {
	$VERSION = '0.03';
	@ISA     = qw{Module::Install::Base};
}

sub write_doap_changes
{
	my $self = shift;
	my $in   = shift || "Changes.ttl";
	my $out  = shift || "Changes";
	my $fmt  = shift || "turtle";
	my $type = shift || "auto";

	my $data  = slurp($in);
	my $inuri = URI::file->new_abs($in);

	my $changeset = RDF::DOAP::ChangeSets->new($inuri, undef, $type, $fmt);
	$changeset->to_file($out);
}

sub write_doap_changes_xml
{
	my $self = shift;
	my $in   = shift || "Changes.ttl";
	my $out  = shift || "Changes.xml";
	my $fmt  = shift || "turtle";
	
	my $r = system("rapper -q -i $fmt -o rdfxml-abbrev $in >$out");
	warn "Error running 'rapper'\n" if $r;
}

1;
