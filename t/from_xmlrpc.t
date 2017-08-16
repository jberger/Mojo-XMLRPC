use Mojo::Base -strict;

use Test::More;

use Mojo::XMLRPC 'from_xmlrpc';
use Scalar::Util 'blessed';

my $struct = from_xmlrpc(<<'MESSAGE');
<?xml version="1.0"?>
<methodCall>
   <methodName>examples.getStateName</methodName>
   <params>
      <param>
         <value><i4>41</i4></value>
         </param>
      </params>
   </methodCall>
MESSAGE

is_deeply $struct, {
  type => 'request',
  methodName => 'examples.getStateName',
  params => [41],
}, 'correct message parse';

$struct = from_xmlrpc(<<'MESSAGE');
<?xml version="1.0"?>
<methodCall>
   <methodName>examples.getStateName</methodName>
   <params>
      <param>
         <value><int>3.14</int></value>
         </param>
      </params>
   </methodCall>
MESSAGE

is_deeply $struct, {
  type => 'request',
  methodName => 'examples.getStateName',
  params => [3.14],
}, 'correct message parse';

$struct = from_xmlrpc(<<'MESSAGE');
<?xml version="1.0"?>
<methodResponse>
   <params>
      <param>
         <value><string>South Dakota</string></value>
         </param>
      </params>
   </methodResponse>
MESSAGE

is_deeply $struct, {
  type => 'response',
  params => ['South Dakota'],
}, 'correct message parse';

$struct = from_xmlrpc(<<'MESSAGE');
<?xml version="1.0"?>
<methodResponse>
   <params>
      <param>
         <value><nil/></value>
         </param>
      </params>
   </methodResponse>
MESSAGE

is_deeply $struct, {
  type => 'response',
  params => [undef],
}, 'correct message parse';

$struct = from_xmlrpc(<<'MESSAGE');
<?xml version="1.0"?>
<methodResponse>
   <params>
      <param>
         <value><boolean>1</boolean></value>
         </param>
      </params>
   </methodResponse>
MESSAGE

is $struct->{type}, 'response', 'correct response type';
ok $struct->{params}[0], 'value is true';
ok blessed($struct->{params}[0]), 'is an object';

$struct = from_xmlrpc(<<'MESSAGE');
<?xml version="1.0"?>
<methodResponse>
   <params>
      <param>
         <value><boolean>0</boolean></value>
         </param>
      </params>
   </methodResponse>
MESSAGE

is $struct->{type}, 'response', 'correct response type';
ok !$struct->{params}[0], 'value is false';
ok blessed($struct->{params}[0]), 'is an object';

$struct = from_xmlrpc(<<'MESSAGE');
<?xml version="1.0"?>
<methodResponse>
   <params>
      <param>
         <value><dateTime.iso8601>1998-07-17T14:08:55Z</dateTime.iso8601></value>
         </param>
      </params>
   </methodResponse>
MESSAGE

is $struct->{type}, 'response', 'correct response type';
isa_ok $struct->{params}[0], 'Mojo::Date', 'got a Mojo::Date';
is $struct->{params}[0]->epoch, 900684535, 'got the correct date';

$struct = from_xmlrpc(<<'MESSAGE');
<?xml version="1.0"?>
<methodResponse>
   <params>
      <param>
         <value><dateTime.iso8601>19980717T14:08:55</dateTime.iso8601></value>
         </param>
      </params>
   </methodResponse>
MESSAGE

is $struct->{type}, 'response', 'correct response type';
isa_ok $struct->{params}[0], 'Mojo::Date', 'got a Mojo::Date';
is $struct->{params}[0]->epoch, 900684535, 'got the correct date';

$struct = from_xmlrpc(<<'MESSAGE');
<?xml version="1.0"?>
<methodResponse>
   <params>
      <param>
         <value><base64>eW91IGNhbid0IHJlYWQgdGhpcyE=</base64></value>
         </param>
      </params>
   </methodResponse>
MESSAGE

is $struct->{type}, 'response', 'correct response type';
isa_ok $struct->{params}[0], 'Mojo::XMLRPC::Base64', 'got a Mojo::XMLRPC::Base64 object';
is $struct->{params}[0]->encoded, 'eW91IGNhbid0IHJlYWQgdGhpcyE=', 'got the encoded data';
is $struct->{params}[0]->decoded, q[you can't read this!], 'got the decoded data';

$struct = from_xmlrpc(<<'MESSAGE');
<?xml version="1.0"?>
<methodResponse>
   <params>
      <param>
        <value>
          <array>
            <data>
              <value><i4>12</i4></value>
              <value><string>Egypt</string></value>
              <value><boolean>0</boolean></value>
              <value><i4>-31</i4></value>
            </data>
          </array>
        </value>
      </param>
    </params>
  </methodResponse>
MESSAGE

is_deeply $struct, {
  type => 'response',
  params => [[12, 'Egypt', Mojo::JSON::false, -31]],
}, 'correct message parse';

$struct = from_xmlrpc(<<'MESSAGE');
<?xml version="1.0"?>
<methodResponse>
   <fault>
      <value>
         <struct>
            <member>
               <name>faultCode</name>
               <value><int>4</int></value>
               </member>
            <member>
               <name>faultString</name>
               <value><string>Too many parameters.</string></value>
               </member>
            </struct>
         </value>
      </fault>
   </methodResponse>
MESSAGE

is_deeply $struct, {
  type => 'fault',
  fault => {
   faultCode => 4,
   faultString => 'Too many parameters.',
  },
}, 'correct message parse';

done_testing;

