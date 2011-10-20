package Tyee::Mobile::Model::API;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

=head1 NAME

Tyee::Mobile::Model::API - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

Phillip Smith

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

use FindBin;
use lib "$FindBin::Bin/../../WWW-Tyee-API/lib";

use WWW::Tyee::API; 

sub lookup_latest_grouped {
    my ( $self ) = @_;
    my $stories = WWW::Tyee::API->get_latest_grouped();
    return $stories; 
}

sub lookup_story {
    my ( $self, $uri ) = @_;
    my $story = WWW::Tyee::API->get_story( $uri );
    return $story;
}

sub lookup_topic {
    my ( $self, $topic ) = @_; 
    my $stories = WWW::Tyee::API->get_topic( $topic );
    return $stories;
}

sub lookup_query {
    my ( $self, $query ) = @_; 
    my $stories = WWW::Tyee::API->get_query( $query );
    return $stories;
}

__PACKAGE__->meta->make_immutable;

1;
