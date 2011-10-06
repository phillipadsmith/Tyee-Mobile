use strict;
use warnings;

use Tyee::Mobile;

my $app = Tyee::Mobile->apply_default_middlewares(Tyee::Mobile->psgi_app);
$app;

