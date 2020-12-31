use v6.c;

unit package GSSDP::Raw::Exports;

our @gssdb-exports is export;

BEGIN {
  @gssdb-exports = <
    GSSDP::Raw::Definitions
  >;
}
