package Tyee::Mobile;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    ConfigLoader
    Static::Simple
    Unicode::Encoding
    CustomErrorMessage
/;

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in tyee_mobile.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'Tyee::Mobile',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
);
# optional (values in this example are the defaults)
__PACKAGE__->config->{'custom-error-message'}->{'uri-for-not-found'} = '/';
__PACKAGE__->config->{'custom-error-message'}->{'error-template'}    = 'error.tt';
__PACKAGE__->config->{'custom-error-message'}->{'content-type'}      = 'text/html; charset=utf-8';
__PACKAGE__->config->{'custom-error-message'}->{'view-name'}         = 'Feature';
__PACKAGE__->config->{'custom-error-message'}->{'response-status'}   = 500;

# Start the application
__PACKAGE__->setup();


=head1 NAME

Tyee::Mobile - Catalyst based application

=head1 SYNOPSIS

    script/tyee_mobile_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<Tyee::Mobile::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Phillip Smith

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
