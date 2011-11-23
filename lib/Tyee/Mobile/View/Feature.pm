package Tyee::Mobile::View::Feature;

use strict;
use warnings;

use base 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    ENCODING     => 'utf-8',
    EVAL_PERL    => '1',
    PRE_CHOMP  => 1,
    POST_CHOMP => 1,
    render_die => 1,
);

=head1 NAME

Tyee::Mobile::View::Feature - TT View for Tyee::Mobile

=head1 DESCRIPTION

TT View for Tyee::Mobile.

=head1 SEE ALSO

L<Tyee::Mobile>

=head1 AUTHOR

Phillip Smith

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
