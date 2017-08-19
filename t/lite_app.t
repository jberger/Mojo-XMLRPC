use Mojolicious::Lite;

use Test::More;
use Test::Mojo;

use Mojo::XMLRPC qw[encode_xmlrpc decode_xmlrpc];

post '/' => sub {
  my $c = shift;
  my $message = decode_xmlrpc($c->req->body);
  unless ($message->{methodName} eq 'echo') {
    return $c->render(data => encode_xmlrpc(fault => 400, 'Only echo is supported'));
  }
};

my $t = Test::Mojo->new;

subtest 'fault' => sub {
  $t->post_ok('/', encode_xmlrpc(method => 'notecho', 42))
    ->status_is(200);
  my $response = decode_xmlrpc($t->tx->res->body);
  
  my %expect = (
    faultCode => 400,
    faultString => 'Only echo is supported',
  );
  is_deeply $response->fault, \%expect, 'correct fault response';
};

done_testing;

