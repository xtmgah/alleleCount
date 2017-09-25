package Sanger::CGP::AlleleCount::PileupData;

##########LICENCE##########
# Copyright (c) 2014,2015 Genome Research Ltd.
#
# Author: CancerIT <cgpit@sanger.ac.uk>
#
# This file is part of alleleCount.
#
# alleleCount is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation; either version 3 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
##########LICENCE##########

use strict;

use Carp;
use English qw( -no_match_vars );
use warnings FATAL => 'all';

use Const::Fast qw(const);

use Sanger::CGP::AlleleCount;

const my $MIN_DEPTH => 4;
const my $BIT_COVERED => 1;
const my $BIT_ALLELE_A => 2;
const my $BIT_ALLELE_B => 4;

sub new {
  my ($class, $chr, $pos, $allA, $allB) = @_;
  my $self =  { 'chr' => $chr,
                'pos' => $pos,
                'depth' => {},
                'A' => {},
                'C' => {},
                'G' => {},
                'T' => {},
              };
  if(defined $allA) {
    # assume B too
    $self->{'allele_A'} = $allA;
    $self->{'count_A'} = {};
    $self->{'allele_B'} = $allB;
    $self->{'count_B'} = {};
  }
  bless $self, $class;
  return $self;
}

sub chr {
  return shift->{'chr'};
}

sub pos {
  return shift->{'pos'};
}

sub residue_count {
  my ($self, $residue) = @_;
  return scalar keys %{$self->{uc $residue}};
}

sub allele_A {
  my ($self, $allele) = @_;
  $self->{'allele_A'} = $allele if($allele);
  return $self->{'allele_A'};
}

sub allele_B {
  my ($self, $allele) = @_;
  $self->{'allele_A'} = $allele if($allele);
  return $self->{'allele_A'};
}

sub inc_A {
  my ($self, $qname) = @_;
  $self->{'count_A'}->{$qname} = 1;
  return 1;
}

sub inc_B {
  my ($self, $qname) = @_;
  $self->{'count_B'}->{$qname} = 1;
  return 1;
}

sub count_A {
  return scalar keys %{shift->{'count_A'}};
}

sub count_B {
  return scalar keys %{shift->{'count_B'}};
}

sub depth {
  return scalar keys %{shift->{'depth'}};
}

sub register_allele {
  my ($self, $allele, $qname) = @_;
  $allele = uc $allele;
  if($self->{'allele_A'} && $allele eq $self->{'allele_A'}) {
    $self->inc_A($qname);
  }
  elsif($self->{'allele_B'} && $allele eq $self->{'allele_B'}) {
    $self->inc_B($qname);
  }
  $self->{$allele}->{$qname} = 1;
  $self->{'depth'}->{$qname.'.'.$allele} = 1;
  return 1;
}

sub encoded_snp_status {
  my $self = shift;
  my $bit_val = 0;
  if($self->depth >= $MIN_DEPTH) {
    $bit_val += $BIT_COVERED;
    $bit_val += $BIT_ALLELE_A if($self->count_A > 0);
    $bit_val += $BIT_ALLELE_B if($self->count_B > 0);
  }
  return $bit_val;
}

sub readable_snp_status {
  my $self = shift;
  my $status = q{};
  if($self->depth >= $MIN_DEPTH) {
    $status .= 'cov';
    $status .= 'A' if($self->count_A > 0);
    $status .= 'B' if($self->count_B > 0);
  }
  else {
    $status = 'nc';
  }
  return $status;
}

1;
