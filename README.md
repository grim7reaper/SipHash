# SipHash: a fast short-input PRF

This is a pure Ada implementation of the SipHash PRF.

It is based on the original paper and tested against the test values provided in
the paper and in the reference C implementation.

SipHash was designed by Jean-Philippe Aumasson and Daniel J. Bernstein.

## Description

From the [official website](https://131002.net/siphash/):

--------------------------------------------------------------------------------

SipHash is a family of pseudorandom functions (a.k.a. keyed hash functions)
optimized for speed on short messages.

Target applications include network traffic authentication and defense against
hash-flooding DoS attacks.

SipHash is secure, fast, and simple (for real):

* SipHash is simpler and faster than previous cryptographic algorithms (e.g.
  MACs based on universal hashing)
* SipHash is competitive in performance with insecure non-cryptographic
  algorithms (e.g. MurmurHash)

We propose that hash tables switch to SipHash as a hash function. Users of
SipHash already include FreeBSD, OpenDNS, Perl 5, Ruby, or Rust. 

--------------------------------------------------------------------------------

## Usage

Block interface:

    with SipHash.PRF;
    […]
    package SipHash24 is new SipHash.PRF(Nb_Compression_Rounds  => 2,
                                         Nb_Finalization_Rounds => 4);
    […]
    Output := SipHash24.Hash(Input, Key);

Streaming interface:
      
    with SipHash.PRF;
    […]
    package SipHash48 is new SipHash.PRF(Nb_Compression_Rounds  => 4,
                                         Nb_Finalization_Rounds => 8);
    […]
    -- Initialization with the 128-bit secret key.
    Hash : SipHash48.Object := SipHash48.Initialize(Key);
    […]
    -- Processing of each byte of the input.
    for I in Input'Range loop
       SipHash48.Update(Hash, Input(I));
    end loop;
    -- Finalization to compute the hash value.
    SipHash48.Finalize(Hash, Output);

## Compilation

In debug mode:

    $ make

In release mode:

    $ make BUILD_MODE=release

## Testing

To run the tests:

    $ make run_tests

## Reference

J.-P. Aumasson and D. J. Bernstein,
“[SipHash: a fast short-input PRF](https://131002.net/siphash/siphash.pdf).”
18-Sep-2012.


J.-P. Aumasson and D. J. Bernstein,
"[Reference C implementation](https://131002.net/siphash/siphash24.c)"

## License

This software is licensed under the BSD3 license.

Copyright (c) 2014, Sylvain Laperche <sylvain.laperche@gmail.com>
