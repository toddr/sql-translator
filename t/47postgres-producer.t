#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::SQL::Translator qw(maybe_plan);

use Data::Dumper;
use FindBin qw/$Bin/;

# Testing 1,2,3,4...
#=============================================================================

BEGIN {
    maybe_plan(6,
        'SQL::Translator::Producer::PostgreSQL',
        'Test::Differences',
    )
}
use Test::Differences;
use SQL::Translator;



my $table = SQL::Translator::Schema::Table->new( name => 'mytable');

my $field1 = SQL::Translator::Schema::Field->new( name => 'myfield',
                                                  table => $table,
                                                  data_type => 'VARCHAR',
                                                  size => 10,
                                                  default_value => undef,
                                                  is_auto_increment => 0,
                                                  is_nullable => 1,
                                                  is_foreign_key => 0,
                                                  is_unique => 0 );

my $field1_sql = SQL::Translator::Producer::PostgreSQL::create_field($field1);

is($field1_sql, 'myfield character varying(10)', 'Create field works');

my $field2 = SQL::Translator::Schema::Field->new( name      => 'myfield',
                                                  table => $table,
                                                  data_type => 'VARCHAR',
                                                  size      => 25,
                                                  default_value => undef,
                                                  is_auto_increment => 0,
                                                  is_nullable => 0,
                                                  is_foreign_key => 0,
                                                  is_unique => 0 );

my $alter_field = SQL::Translator::Producer::PostgreSQL::alter_field($field1,
                                                                $field2);
is($alter_field, qq[ALTER TABLE mytable ALTER COLUMN myfield SET NOT NULL;
ALTER TABLE mytable ALTER COLUMN myfield TYPE character varying(25);],
 'Alter field works');

$field1->name('field3');
my $add_field = SQL::Translator::Producer::PostgreSQL::add_field($field1);

is($add_field, 'ALTER TABLE mytable ADD COLUMN field3 character varying(10);', 'Add field works');

my $drop_field = SQL::Translator::Producer::PostgreSQL::drop_field($field2);
is($drop_field, 'ALTER TABLE mytable DROP COLUMN myfield;', 'Drop field works');

my $field3 = SQL::Translator::Schema::Field->new( name      => 'time_field',
                                                  table => $table,
                                                  data_type => 'TIME',
                                                  default_value => undef,
                                                  is_auto_increment => 0,
                                                  is_nullable => 0,
                                                  is_foreign_key => 0,
                                                  is_unique => 0 );

my $field3_sql = SQL::Translator::Producer::PostgreSQL::create_field($field3);

is($field3_sql, 'time_field time NOT NULL', 'Create time field works');

my $field4 = SQL::Translator::Schema::Field->new( name      => 'bytea_field',
                                                  table => $table,
                                                  data_type => 'bytea',
                                                  size => '16777215',
                                                  default_value => undef,
                                                  is_auto_increment => 0,
                                                  is_nullable => 0,
                                                  is_foreign_key => 0,
                                                  is_unique => 0 );

my $field4_sql = SQL::Translator::Producer::PostgreSQL::create_field($field4);

is($field4_sql, 'bytea_field bytea NOT NULL', 'Create bytea field works');