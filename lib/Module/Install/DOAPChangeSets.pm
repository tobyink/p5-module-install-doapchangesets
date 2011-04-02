package Module::Install::DOAPChangeSets;

use 5.008;
use base qw(Module::Install::Base);
use strict;

our $VERSION = '0.102';

sub write_doap_changes {
	my $self = shift;
	$self->admin->write_doap_changes(@_) if $self->is_admin;
}

sub write_doap_changes_xml {
	my $self = shift;
	$self->admin->write_doap_changes_xml(@_) if $self->is_admin;
}

1;

__END__
=head1 NAME

Module::Install::DOAPChangeSets - write your distribution change log in RDF

=head1 DESCRIPTION

This package allows you to write your Changes file in Turtle or RDF/XML and
autogenerate a human-readable text file.

To do this, create an RDF file called "Changes.ttl" (or something like that)
and describe your distribution's changes in RDF using the Dublin Core, DOAP,
and DOAP Change Sets vocabularies. Then in your Makefile.PL, include:

  write_doap_changes "Changes.ttl", "Changes", "turtle";

This line will read your data from the file named as the first argument,
parse it using either Turtle or RDFXML parsers (the third argument), and
output a human-readable changelog to the file named as the second argument.

The defaults are "Changes.ttl", "Changes", "turtle", so if you name the
files like that, then you can exclude all the arguments and just include
this in your Makefile.PL:

  write_doap_changes;

There's also a line you can use to output a Changes.xml file:

  write_doap_changes_xml "Changes.ttl", "Changes.xml", "turtle";

=head1 WHY?

Why not?

=head1 BUGS

Please report any bugs to L<http://rt.cpan.org/>.

=head1 SEE ALSO

L<Module::Install>, L<Module::Install::DOAPChangeSets::Format> .

L<http://www.perlrdf.org/>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Toby Inkster

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
