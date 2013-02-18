package Tyee::Mobile::Controller::Root;
use Moose;
use namespace::autoclean;
use List::Util qw( first );
use DateTime;
use DateTime::Format::ISO8601;

BEGIN { extends 'Catalyst::Controller' }

# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config( namespace => '' );

has topics => ( isa => 'ArrayRef', is => 'ro', required => 1 );
has topics_by_name => (
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $names = {
            map { $_->{'name'} => $_ } @{ shift()->topics }
        };
        return $names;
    },
    traits  => ['Hash'],
    handles => { lookup_topic_by_name => 'get' }
);
has sections => ( isa => 'ArrayRef', is => 'ro', required => 1 );
has sections_by_name => (
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $names = {
            map { $_->{'name'} => $_ } @{ shift()->sections }
        };
        return $names;
    },
    traits  => ['Hash'],
    handles => { lookup_section_by_name => 'get' }
);

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
    $c->stash(
        results  => $c->model( 'API' )->lookup_latest_grouped(),
        sections => $self->sections,
        topics   => $self->topics,
        template => 'index.tt',
    );
}

# Story URIs are /Section/YYYY/MM/DD/Slug/
# TODO Change to a Chained capture
sub story : Path : Args(5) {
    my ( $self, $c, $section_path, $year, $month, $day, $slug ) = @_;
    my $path;
    # TODO Basically, the URI for blogs is now missing a section
    # So I have to shift around the arguments to make the API lookup work
    # This sucks, but it works for the moment
    if ( $slug ) {
        $path = join( '/', $section_path, $year, $month, $day, $slug );
    } else { # This is shit, but it'll make things work for now
        $path = join( '/', 'Blogs/TheHook', $section_path, $year, $month, $day );
    }
    my $size  = $c->req->param( 'size' );                    # Text size
    my $story = $c->model( 'API' )->lookup_story( $path );
    my $now   = DateTime->today();
    my $story_date
        = DateTime::Format::ISO8601->parse_datetime( $story->{'storyDate'} );

# Compare two DateTime objects. The semantics are compatible with Perl's sort() function;
# it returns -1 if $dt1 < $dt2, 0 if $dt1 == $dt2, 1 if $dt1 > $dt2.
    my $date_str
        = $now->ymd eq $story_date->ymd
        ? 'Today'
        : join( ' ',
        $story_date->day, $story_date->month_abbr, $story_date->year );

    # Return the first matching element of a search on the url attribute
    # across the sections array. Used to properly display section names
    # in the section overview pages.
    my $sections = $self->sections;
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
# Blog URIs are /Blogs/TheHook/Media/2011/09/08/Tyee-App-Canadian-Magazine/
# TODO Change this to a Chained capture
# TODO Also, the section name doesn't make it to story {}. Need to fix.
# TODO More importantly, when we re-launched The Hook with a newe URI format
# we broke this route. Need a better fix, but -- for now -- hacking story works
sub blog_post : Path('/Blogs/TheHook') : Args(4) {
    my ( $self, $c, $year, $month, $day, $slug ) = @_;
    my $section = $self->lookup_section_by_name( 'The Hook Blog' );
    $c->stash->{'blog'} = 'The Hook Blog: ';
    $c->forward( 'story' );
}

# TODO Change to a Chained capture
sub blog : Regex('^Blogs/TheHook$') {
    my ( $self, $c ) = @_;
    $c->stash(
        results  => $c->model( 'API' )->lookup_latest_blogs,
        title    => 'The Hook Blog',
        template => 'section.tt',
    );
}


# /(Section name) (list latest 20 from section name)
sub section : Chained('/') : PathPart('') : CaptureArgs(1) {
    my ( $self, $c, $section_name ) = @_;
    my $section = $self->lookup_section_by_name( $section_name )
        || $c->detach( 'default' );
    $c->stash( section => $section );
}

sub show : Chained('section') : PathPart('') : Args(0) { 
    my ( $self, $c ) = @_;
    my $section = $c->stash->{'section'};
    $c->stash->{'section'} = ''; # Clearning this out, b/c the template shows it.
    $c->stash(
        results  => $c->model( 'API' )->lookup_topic( $section->{'name'} ),
        title    => $section->{'name'},
        template => 'section.tt',
    );
}

# /Topics (list all sections & Topics)
sub topic : Path('/Topic') : Args(1) {
    my ( $self, $c, $topic_path ) = @_;

    # TODO
    # Check if $topic is TheHook. If so, detach to sub blogs
    my $topics = $self->topics;
    my $topic = first { $_->{url} =~ $topic_path } @$topics;
    $c->stash(
        results  => $c->model( 'API' )->lookup_topic( $topic->{'name'} ),
        title    => $topic->{'name'},
        template => 'section.tt'
    );
}

# TODO Change to Path route, not Regex
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
    $c->stash( template => 'contact.tt' );
}

=head2 default

Standard 404 error page

=cut

sub default : Path {
    my ( $self, $c ) = @_;
    $c->response->status( 404 );
    $c->stash(
        url      => $c->req->path,
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
