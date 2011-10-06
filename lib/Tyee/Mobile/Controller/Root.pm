package Tyee::Mobile::Controller::Root;
use Moose;
use namespace::autoclean;

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
        results => $c->model('API')->latest_grouped(),
        sections => $sections,
        topics   => $topics,
        category  => $c->config->{'category'},
        template => 'index.tt',
    );
}

# /Section/YYYY/MM/DD/Slug/
sub story :Path :Args(5) {
    my ( $self, $c, $section, $year, $month, $day, $slug ) = @_;
    my $path = $section . '/' . $year . '/' . $month . '/' . $day . '/' . $slug . '/';
    $c->stash(
        story => $c->model('API')->lookup_story( $path ),
        path    => $path,
        template => 'article.tt'
    );
}

# /Blogs/TheHook/Media/2011/09/08/Tyee-App-Canadian-Magazine/
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

# /Topcics (list all sections & Topics)



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
