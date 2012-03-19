package Tyee::Mobile::Controller::Root;
use Moose;
use namespace::autoclean;
use List::Util qw( first );
use DateTime;
use DateTime::Format::ISO8601;

BEGIN { extends 'Catalyst::Controller' }

use constant SECTIONS => __PACKAGE__->config->{'sections'};
use constant TOPICS   => __PACKAGE__->config->{'topics'};

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config( namespace => '' );


=head1 NAME

Tyee::Mobile::Controller::Root - Root Controller for Tyee::Mobile

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;
    my $sections = $c->config->{'sections'};
    my $topics   = $c->config->{'topics'};
    $c->stash(
        results  => $c->model( 'API' )->lookup_latest_grouped(),
        sections => $sections,
        topics   => $topics,
        template => 'index.tt',
    );
}

# Story URIs are /Section/YYYY/MM/DD/Slug/
# TODO Change to a RegEx capture
sub story : Path : Args(5) {
    my ( $self, $c, $section_path, $year, $month, $day, $slug ) = @_;
    my $path  = join( '/', $section_path, $year, $month, $day, $slug );
    my $size  = $c->req->param( 'size' ); # Text size
    my $story = $c->model( 'API' )->lookup_story( $path );
    my $now   = DateTime->today();
    my $story_date
        = DateTime::Format::ISO8601->parse_datetime( $story->{'storyDate'} );

# Compare two DateTime objects. The semantics are compatible with Perl's sort() function;
# it returns -1 if $dt1 < $dt2, 0 if $dt1 == $dt2, 1 if $dt1 > $dt2.
    my $date_str
        = $now->ymd eq $story_date->ymd
        ? 'Today'
        : join( ' ', $story_date->day, $story_date->month_abbr, $story_date->year );

    # Return the first matching element of a search on the url attribute
    # across the sections array. Used to properly display section names
    # in the section overview pages.
    my $sections = $c->config->{'sections'};
    my $section = first { $_->{url} =~ $section_path } @$sections;
    $c->stash(
        story    => $story,
        date     => $date_str,
        path     => $path,
        section  => $section,
        size     => $size,
        template => 'article.tt'
    );
}

# TODO
# /Blogs/TheHook Need to handle this ...
#
sub blog : Regex('^Blogs/TheHook$') {
    my ( $self, $c ) = @_;
    $c->stash(
        results  => $c->model( 'API' )->lookup_path( '/Blogs/TheHook' ),
        title    => 'The Hook Blog',
        template => 'section.tt',
    );
}

# Blog URIs are /Blogs/TheHook/Media/2011/09/08/Tyee-App-Canadian-Magazine/
# TODO Change this to a RegEx capture
sub blog_post : Path('/Blogs/TheHook') : Args(5) {
    my ( $self, $c, $section_path, $year, $month, $day, $slug )
        = @_;
    $c->stash->{'blog'} = 'The Hook Blog: ';
    $c->forward('story');
}

# /(Section name) (list latest 20 from section name)
# TODO Change this to a RegEx capture
# Need to capture the section URL and convert to section name lookup
sub section : Path : Args(1) {
    my ( $self, $c, $section_path ) = @_;

    # Return the first matching element of a search on the url attribute
    # across the sections array. Used to properly display section names
    # in the section overview pages.
    my $sections = $c->config->{'sections'};
    my $section = first { $_->{url} =~ $section_path } @$sections;
    $c->stash(
        results  => $c->model( 'API' )->lookup_topic( $section->{'name'} ),
        title    => $section->{'name'},
        template => 'section.tt',
    );
}

# /Topcics (list all sections & Topics)

sub topic : Path('/Topic/') : Args(1) {
    my ( $self, $c, $stub, $topic_path ) = @_;

    # TODO
    # Check if $topic is TheHook. If so, detach to sub blogs
    my $topics = $c->config->{'topics'};
    my $topic = first { $_->{url} =~ $topic_path } @$topics;
    $c->stash(
        results  => $c->model( 'API' )->lookup_topic( $topic->{'name'} ),
        title    => $topic->{'name'},
        template => 'section.tt'
    );
}


sub search : Regex('^search$') {
    my ( $self, $c ) = @_;
    my $query = $c->req->param( 'query' );
    $c->stash(
        results  => $c->model( 'API' )->lookup_query( $query ),
        title    => $query,
        template => 'search_results.tt'
    );
}

sub contact : Path('/contact') : Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(
        template => 'contact.tt'
    );
}

=head2 default

Standard 404 error page

=cut

sub default : Path {
    my ( $self, $c ) = @_;
    $c->response->status( 404 );
    $c->stash(
        template => '404.tt'
    );
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {
}

=head1 AUTHOR

Phillip Smith

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
