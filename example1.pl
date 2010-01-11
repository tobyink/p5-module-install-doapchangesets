use lib "lib";
use Module::Install::Admin::DOAPChangeSets;

my $foo = bless {}, 'Foo';

Module::Install::Admin::DOAPChangeSets::write_doap_changes(
	$foo, 'trine.ttl', 'trine.txt');


package Foo;
sub name {
	return 'RDF-Triney';
}
sub _top {
	return $_[0];
}
1;