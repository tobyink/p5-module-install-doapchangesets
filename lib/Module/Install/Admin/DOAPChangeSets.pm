package Module::Install::Admin::DOAPChangeSets;

use strict;
use RDF::Trine;
use RDF::Query;
use File::Slurp qw(slurp);
use URI::file;
use Module::Install::Base;
use Text::Wrap;

use vars qw{$VERSION @ISA};
BEGIN {
	$VERSION = '0.00_03';
	@ISA     = qw{Module::Install::Base};
}

sub __write_doap_changes__project_data__current
{
	my $self  = shift;
	my $model = shift;
	my $inuri = shift;

	my $sparql = "
	PREFIX dc: <http://purl.org/dc/terms/>
	PREFIX dcs: <http://ontologi.es/doap-changeset#>
	PREFIX doap: <http://usefulinc.com/ns/doap#>
	PREFIX foaf: <http://xmlns.com/foaf/0.1/>
	PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
	SELECT *
	WHERE
	{
		<$inuri> dc:subject ?project .
		?project	a doap:Project .
		OPTIONAL { <$inuri> dc:title ?title . }
		OPTIONAL { <$inuri> rdfs:label ?title . }
		OPTIONAL { ?project doap:name ?distname . }
		OPTIONAL { ?project rdfs:label ?distname . }
		OPTIONAL { ?project dc:title ?distname . }
		OPTIONAL { ?project doap:created ?created . }
		OPTIONAL { ?project doap:homepage ?homepage . }
		OPTIONAL { ?project doap:bug-database ?bugdatabase . }
		OPTIONAL
		{
			?project doap:maintainer ?maint .
			?maint foaf:name ?maintname .
			OPTIONAL { ?maint foaf:mbox ?maintmbox . }
		}
	}
	";
	
	my $query    = RDF::Query->new($sparql);
	my $results  = $query->execute($model);
	my $projects = {};
	my $doctitle = '';
	while (my $row = $results->next)
	{
		my $p = $row->{'project'}->as_ntriples;
		$projects->{$p}->{'EXISTS'}++;
		$projects->{$p}->{'distname'} = $row->{'distname'}->literal_value
			if UNIVERSAL::isa($row->{'distname'}, 'RDF::Trine::Node::Literal');
		$projects->{$p}->{'created'} = $row->{'created'}->literal_value
			if UNIVERSAL::isa($row->{'created'}, 'RDF::Trine::Node::Literal');
		$projects->{$p}->{'homepage'}->{ $row->{'homepage'}->uri }++
			if UNIVERSAL::isa($row->{'homepage'}, 'RDF::Trine::Node::Resource');
		$projects->{$p}->{'bugdatabase'}->{ $row->{'bugdatabase'}->uri }++
			if UNIVERSAL::isa($row->{'bugdatabase'}, 'RDF::Trine::Node::Resource');
		$projects->{$p}->{'maint'}->{ $row->{'maint'}->as_ntriples }->{'name'} = $row->{'maintname'}->literal_value
			if UNIVERSAL::isa($row->{'maintname'}, 'RDF::Trine::Node::Literal');
		$projects->{$p}->{'maint'}->{ $row->{'maint'}->as_ntriples }->{'mbox'}->{ $row->{'maintmbox'}->uri }++
			if UNIVERSAL::isa($row->{'maintmbox'}, 'RDF::Trine::Node::Resource');
		$doctitle = $row->{'title'}->literal_value
			if UNIVERSAL::isa($row->{'title'}, 'RDF::Trine::Node::Literal');
	}
	
	foreach my $k (keys %$projects)
	{
		$projects->{$k}->{'distname'} = $self->_top->name
			unless length $projects->{$k}->{'distname'};
	}
	
	return [$projects, $doctitle];
}

sub __write_doap_changes__project_data__legacy
{
	my $self  = shift;
	my $model = shift;
	my $inuri = shift;

	my $sparql = "
	PREFIX dc: <http://purl.org/dc/terms/>
	PREFIX doap: <http://usefulinc.com/ns/doap#>
	PREFIX foaf: <http://xmlns.com/foaf/0.1/>
	PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
	SELECT *
	WHERE
	{
		<$inuri> dc:references ?project .
		?project	a doap:Project .
		OPTIONAL { <$inuri> dc:title ?title . }
		OPTIONAL { <$inuri> rdfs:label ?title . }
		OPTIONAL { ?project doap:name ?distname . }
		OPTIONAL { ?project rdfs:label ?distname . }
		OPTIONAL { ?project dc:title ?distname . }
		OPTIONAL { ?project doap:created ?created . }
		OPTIONAL { ?project doap:homepage ?homepage . }
		OPTIONAL { ?project doap:bug-database ?bugdatabase . }
		OPTIONAL
		{
			?project doap:maintainer ?maint .
			?maint foaf:name ?maintname .
			OPTIONAL { ?maint foaf:mbox ?maintmbox . }
		}
	}
	";
	
	my $query    = RDF::Query->new($sparql);
	my $results  = $query->execute($model);
	my $projects = {};
	my $doctitle = '';
	while (my $row = $results->next)
	{
		my $p = $row->{'project'}->as_ntriples;
		$projects->{$p}->{'EXISTS'}++;
		$projects->{$p}->{'distname'} = $row->{'distname'}->literal_value
			if UNIVERSAL::isa($row->{'distname'}, 'RDF::Trine::Node::Literal');
		$projects->{$p}->{'created'} = $row->{'created'}->literal_value
			if UNIVERSAL::isa($row->{'created'}, 'RDF::Trine::Node::Literal');
		$projects->{$p}->{'homepage'}->{ $row->{'homepage'}->uri }++
			if UNIVERSAL::isa($row->{'homepage'}, 'RDF::Trine::Node::Resource');
		$projects->{$p}->{'bugdatabase'}->{ $row->{'bugdatabase'}->uri }++
			if UNIVERSAL::isa($row->{'bugdatabase'}, 'RDF::Trine::Node::Resource');
		$projects->{$p}->{'maint'}->{ $row->{'maint'}->as_ntriples }->{'name'} = $row->{'maintname'}->literal_value
			if UNIVERSAL::isa($row->{'maintname'}, 'RDF::Trine::Node::Literal');
		$projects->{$p}->{'maint'}->{ $row->{'maint'}->as_ntriples }->{'mbox'}->{ $row->{'maintmbox'}->uri }++
			if UNIVERSAL::isa($row->{'maintmbox'}, 'RDF::Trine::Node::Resource');
		$doctitle = $row->{'title'}->literal_value
			if UNIVERSAL::isa($row->{'title'}, 'RDF::Trine::Node::Literal');
	}

	foreach my $k (keys %$projects)
	{
		$projects->{$k}->{'distname'} = $self->_top->name
			unless length $projects->{$k}->{'distname'};
	}

	return [$projects, $doctitle];
}

sub __write_doap_changes__release_data__current
{
	my $self     = shift;
	my $model    = shift;
	my $p        = shift;
	my $projects = shift;
	
	my $sparql = "
	PREFIX dc: <http://purl.org/dc/terms/>
	PREFIX dcs: <http://ontologi.es/doap-changeset#>
	PREFIX doap: <http://usefulinc.com/ns/doap#>
	PREFIX foaf: <http://xmlns.com/foaf/0.1/>
	PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
	SELECT *
	WHERE
	{
		$p doap:release ?version .
		?version doap:revision ?revision .
		OPTIONAL { ?version dc:issued ?issued . }
		OPTIONAL { ?version rdfs:label ?vname . }
		OPTIONAL
		{
			?version dcs:changeset [ dcs:item ?item ] .
			OPTIONAL { ?item a ?itemtype . }
			OPTIONAL { ?item rdfs:label ?itemlabel . }
		}
	}
	";

	my $query    = RDF::Query->new($sparql);
	my $results  = $query->execute($model);
	while (my $row = $results->next)
	{
		my $v = $row->{'version'}->as_ntriples;
		$projects->{$p}->{'v'}->{$v}->{'EXISTS'}++;
		
		$projects->{$p}->{'v'}->{$v}->{'revision'} = $row->{'revision'}->literal_value
			if UNIVERSAL::isa($row->{'revision'}, 'RDF::Trine::Node::Literal');
		$projects->{$p}->{'v'}->{$v}->{'issued'} = $row->{'issued'}->literal_value
			if UNIVERSAL::isa($row->{'issued'}, 'RDF::Trine::Node::Literal');
		$projects->{$p}->{'v'}->{$v}->{'name'} = $row->{'vname'}->literal_value
			if UNIVERSAL::isa($row->{'vname'}, 'RDF::Trine::Node::Literal');
		
		if (UNIVERSAL::isa($row->{'item'}, 'RDF::Trine::Node'))
		{
			my $c = $row->{'item'}->as_ntriples;
			$projects->{$p}->{'v'}->{$v}->{'c'}->{$c}->{'label'} = $row->{'itemlabel'}->literal_value
				if UNIVERSAL::isa($row->{'itemlabel'}, 'RDF::Trine::Node::Literal');
			$projects->{$p}->{'v'}->{$v}->{'c'}->{$c}->{'type'} = $row->{'itemtype'}->uri
				if UNIVERSAL::isa($row->{'itemtype'}, 'RDF::Trine::Node::Resource')
				and $row->{'itemtype'}->uri ne 'http://ontologi.es/doap-changeset#Change';
		}
	}
}

sub __write_doap_changes__release_data__legacy
{
	my $self     = shift;
	my $model    = shift;
	my $p        = shift;
	my $projects = shift;
	
	my $sparql = "
	PREFIX dc: <http://purl.org/dc/terms/>
	PREFIX asc: <http://aaronland.info/ns/changefile/>
	PREFIX doap: <http://usefulinc.com/ns/doap#>
	PREFIX foaf: <http://xmlns.com/foaf/0.1/>
	PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
	SELECT *
	WHERE
	{
		?version dc:isVersionOf $p .
		?version doap:Version [ doap:revision ?revision ] .
		OPTIONAL { ?version doap:Version [ doap:created ?issued ] . }
		OPTIONAL { ?version rdfs:label ?vname . }
		OPTIONAL { ?version asc:changes [ ?itemtype ?itemlabel ] . }
	}
	";

	my $query    = RDF::Query->new($sparql);
	my $results  = $query->execute($model);
	while (my $row = $results->next)
	{
		my $v = $row->{'version'}->as_ntriples;
		$projects->{$p}->{'v'}->{$v}->{'EXISTS'}++;
		
		$projects->{$p}->{'v'}->{$v}->{'revision'} = $row->{'revision'}->literal_value
			if UNIVERSAL::isa($row->{'revision'}, 'RDF::Trine::Node::Literal');
		$projects->{$p}->{'v'}->{$v}->{'issued'} = $row->{'issued'}->literal_value
			if UNIVERSAL::isa($row->{'issued'}, 'RDF::Trine::Node::Literal');
		$projects->{$p}->{'v'}->{$v}->{'name'} = $row->{'vname'}->literal_value
			if UNIVERSAL::isa($row->{'vname'}, 'RDF::Trine::Node::Literal');
		
		if (UNIVERSAL::isa($row->{'itemlabel'}, 'RDF::Trine::Node'))
		{
			my $c = $row->{'itemlabel'}->as_ntriples;
			$projects->{$p}->{'v'}->{$v}->{'c'}->{$c}->{'label'} = $row->{'itemlabel'}->literal_value
				if UNIVERSAL::isa($row->{'itemlabel'}, 'RDF::Trine::Node::Literal');
				
			if (UNIVERSAL::isa($row->{'itemtype'}, 'RDF::Trine::Node::Resource'))
			{
				my $u = $row->{'itemtype'}->uri;
				
				if ($u =~ m'^http://aaronland.info/ns/changefile/(addition|update|bugfix|removal)$')
				{
					$projects->{$p}->{'v'}->{$v}->{'c'}->{$c}->{'type'} =
						'http://ontologi.es/doap-changeset#'.(ucfirst $1);
				}
			}
		}
	}	
}

sub write_doap_changes
{
	my $self = shift;
	my $in   = shift || "Changes.ttl";
	my $out  = shift || "Changes";
	my $fmt  = shift || "turtle";
	my $type = shift || "auto";

	my $IN    = slurp($in);
	my $inuri = URI::file->new_abs($in);

	my $model  = RDF::Trine::Model->new( RDF::Trine::Store->temporary_store );
	my $parser = RDF::Trine::Parser->new($fmt);
	$parser->parse_into_model("$inuri", $IN, $model);
	
	if (lc $type eq 'auto')
	{
		my $r = RDF::Query->new(
			"ASK WHERE { ?version <http://ontologi.es/doap-changeset#changeset> ?set .}")
			->execute($model);
		if ($r->get_boolean)
		{
			$type = 'current';
		}
		else
		{
			$type = 'legacy';
		}
	}
	
	my ($projects, $doctitle);
	if (lc $type eq 'legacy')
	{
		($projects, $doctitle) = @{ __write_doap_changes__project_data__legacy($self, $model, $inuri) };
	}
	else
	{
		($projects, $doctitle) = @{ __write_doap_changes__project_data__current($self, $model, $inuri) };
	}
	
	unless (length $doctitle)
	{
		foreach my $project (sort keys %$projects)
		{
			if (length $doctitle == 0
			or  length $doctitle > $projects->{$project}->{'distname'})
			{
				$doctitle = $projects->{$project}->{'distname'};
			}
		}
		if (length $doctitle)
		{
			$doctitle = "Changes for $doctitle";
		}
		else
		{
			$doctitle = "Changes";
		}
	}

	open OUT, ">$out";
	print OUT "#" x 76 . "\n";
	print OUT "## $doctitle " . ("#" x (72 - length $doctitle)) . "\n";
	print OUT "#" x 76 . "\n\n";
	foreach my $project (sort keys %$projects)
	{
		print OUT $projects->{$project}->{'distname'} . "\n";
		print OUT ('=' x length $projects->{$project}->{'distname'}) . "\n\n";
		
		print OUT sprintf("Created:      %s\n", $projects->{$project}->{'created'})
			if $projects->{$project}->{'created'};
		foreach my $u (sort keys %{ $projects->{$project}->{'homepage'} })
		{
			print OUT sprintf("Home page:    <%s>\n", $u);
		}
		foreach my $u (sort keys %{ $projects->{$project}->{'bugdatabase'} })
		{
			print OUT sprintf("Bug tracker:  <%s>\n", $u);
		}
		foreach my $m (sort keys %{ $projects->{$project}->{'maint'} })
		{
			my @mboxes = sort keys %{$projects->{$project}->{'maint'}->{$m}->{'mbox'}};
			my $mbox = shift @mboxes;
			
			if (defined $mbox) { print OUT sprintf("Maintainer:   %s <%s>\n", $projects->{$project}->{'maint'}->{$m}->{'name'}, $mbox); }
			else               { print OUT sprintf("Maintainer:   %s\n", $projects->{$project}->{'maint'}->{$m}->{'name'}, $mbox); }
		}
		print OUT "\n";
		
		if (lc $type eq 'legacy')
		{
			__write_doap_changes__release_data__legacy($self, $model, $project, $projects);
		}
		else
		{
			__write_doap_changes__release_data__current($self, $model, $project, $projects);
		}

		foreach my $version (sort { $b->{'revision'} cmp $a->{'revision'} } values %{$projects->{$project}->{'v'}})
		{
			print OUT $version->{'revision'};
			print OUT sprintf(' [%s]', $version->{'issued'})
				if $version->{'issued'};
			print OUT sprintf(' # %s', $version->{'name'})
				if $version->{'name'};
			print OUT "\n";
			foreach my $change (values %{$version->{'c'}})
			{
				my $sigil = '';
				if (defined $change->{'type'}
				and $change->{'type'} =~ m!doap.changeset.(.+)$!)
				{
					$sigil = '('.$1.') ';
				}
				print OUT wrap(' - ', '   ', sprintf("%s%s", $sigil, $change->{'label'})) . "\n";
			}
			print OUT "\n";
		}
		
	}
	close OUT;
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
