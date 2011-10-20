package Tyee::Mobile::Controller::Root;
use Moose;
use namespace::autoclean;
use List::Util qw( first );

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

Tyee::Mobile::Controller::Root - Root Controller for Tyee::Mobile

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    my $sections = $c->config->{'sections'};
    my $topics   = $c->config->{'topics'};
    $c->stash(
        results => $c->model('API')->lookup_latest_grouped(),
        sections => $sections,
        topics   => $topics,
        template => 'index.tt',
    );
}

# Story URIs are /Section/YYYY/MM/DD/Slug/
# TODO Change to a RegEx capture
sub story :Path :Args(5) {
    my ( $self, $c, $section, $year, $month, $day, $slug ) = @_;
    my $path = join('/', $section, $year, $month, $day, $slug);
    $c->stash(
        story => $c->model('API')->lookup_story( $path ),
        path    => $path,
        template => 'article.tt'
    );
}


# Blog URIs are /Blogs/TheHook/Media/2011/09/08/Tyee-App-Canadian-Magazine/
# TODO Change this to a RegEx capture
sub blog :Path :Args(7) {
    my ( $self, $c, $blogs, $blog, $section, $year, $month, $day, $slug ) = @_;
    my $path = join('/', $blogs, $blog, $section, $year, $month, $day, $slug);
    $c->stash(
        story => $c->model('API')->lookup_story( $path ),
        path  => $path,
        template => 'blog.tt'
    );
}

# /(Section name) (list latest 20 from section name)
# TODO Change this to a RegEx capture
# Need to capture the section URL and convert to section name lookup
sub section :Path :Args(1) {
    my ( $self, $c, $section_path ) = @_;
    my $sections = $c->config->{'sections'};
    my $section = first { $_->{url} =~ $section_path } @$sections;
    $c->stash(
        results => $c->model('API')->lookup_topic( $section->{'name'} ),
        title   => $section->{'name'},
        template => 'section.tt',
    )
}

# /Topcics (list all sections & Topics)

sub topic :Path :Args(2) {
    my ( $self, $c, $stub, $topic_path ) = @_;
    # TODO
    # Check if $topic is TheHook. If so, detach to sub blogs
    my $topics = $c->config->{'topics'};
    my $topic = first { $_->{url} =~ $topic_path } @$topics;
    $c->stash(
        results => $c->model('API')->lookup_topic( $topic->{'name'} ),
        title   => $topic->{'name'},
        template => 'section.tt'
    )
}

# TODO
# /Blogs/TheHook Need to handle this ...
#
#sub blogs {}


sub search :Regex('^search$') {
    my ( $self, $c ) = @_;
    my $query = $c->req->param('query');
    $c->stash(
        results => $c->model('API')->lookup_query( $query ),
        title   => $query,
        template => 'section.tt'
    )
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Phillip Smith

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
