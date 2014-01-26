# SipHash: a fast short-input PRF

This is a pure Ada implementation of the SipHash PRF (currently, only
SipHash-2-4 is implemented).

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

## Compilation

In debug mode:

    $ gnatmake -Psiphash

In release mode:

    $ gnatmake -Psiphash -Xmode=release

## Testing

To run the tests:

    $ ./bin/siphash_tests

## Reference

J.-P. Aumasson and D. J. Bernstein,
“[SipHash: a fast short-input PRF](https://131002.net/siphash/siphash.pdf).”
18-Sep-2012.


J.-P. Aumasson and D. J. Bernstein,
"[Reference C implementation](https://131002.net/siphash/siphash24.c)"

## License

This software is licensed under the BSD3 license.

© 2013-2014 Sylvain Laperche <sylvain.laperche@gmail.com>.
