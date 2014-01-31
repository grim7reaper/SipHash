------------------------------------------------------------------------
--  Copyright (c) 2014 Sylvain Laperche <sylvain.laperche@gmail.com>
--  All rights reserved.
--
--  Redistribution and use in source and binary forms, with or without
--  modification, are permitted provided that the following conditions
--  are met:
--  1. Redistributions of source code must retain the above copyright
--     notice, this list of conditions and the following disclaimer.
--  2. Redistributions in binary form must reproduce the above copyright
--     notice, this list of conditions and the following disclaimer in
--     the documentation and/or other materials provided with the
--     distribution.
--  3. Neither the name of author nor the names of its contributors may
--     be used to endorse or promote products derived from this software
--     without specific prior written permission.
--
--  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
--  ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
--  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
--  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
--  COPYRIGHT HOLDERS AND CONTRIBUTORSBE LIABLE FOR ANY DIRECT,
--  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
--  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
--  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
--  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
--  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
--  OF THE POSSIBILITY OF SUCH DAMAGE.
------------------------------------------------------------------------
with Interfaces;

------------------------------------------------------------------------
-- SipHash
--
-- Purpose:
--   This package defines types and constants required to implement the
--   SipHash PRF.
--
--   SipHash is a family of pseudorandom functions (a.k.a. keyed hash
--   functions) optimized for speed on short messages.
--   Target applications include network traffic authentication and
--   defense against hash-flooding DoS attacks.
--
--   SipHash is secure, fast, and simple (for real):
--   * SipHash is simpler and faster than previous cryptographic
--     algorithms (e.g. MACs based on universal hashing)
--   * SipHash is competitive in performance with insecure
--     non-cryptographic algorithms (e.g. MurmurHash).
--   Source: https://131002.net/siphash/
--
-- References:
--   [1]J.-P. Aumasson and D. J. Bernstein, "SipHash: a fast short-input
--      PRF." 18-Sep-2012.
------------------------------------------------------------------------
package SipHash is
   type Version_Type is record
      Major : Natural;
      Minor : Natural;
      Patch : Natural;
   end record;

   Version : constant Version_Type := (0, 2, 2);

   -- Fixed-width integer types.
   type I64 is new Interfaces.Integer_64;
   type U64 is new Interfaces.Unsigned_64;
   type U8  is new Interfaces.Unsigned_8;

   -- A sequence of 8-bit bytes.
   type Byte_Sequence is array(U64 range <>) of U8;
   -- A key is composed of 16 bytes (128 bits).
   subtype Key_Type is Byte_Sequence (U64 range 1..16);

   ---------------------------------------------------------------------
   -- Version_String
   --
   -- Purpose:
   --   Converts the version number to a string suitable for output.
   -- Return:
   --   Returns the version number, as a string suitable for output.
   -- Exceptions:
   --   None.
   ---------------------------------------------------------------------
   function Version_String
     return String;

private
   -- A block of 64 bits contains 8 octets.
   Block_Size : constant U8 := 8;
   -- An unpacked 64-bit integer corresponds to a sequence of 8 bytes.
   subtype U64_Unpacked is Byte_Sequence (U64 range 1..8);

   ---------------------------------------------------------------------
   -- Pack_As_LE
   --
   -- Purpose:
   --   Packs a 64-bit integer using the little-endian encoding.
   -- Parameters:
   --   Input: an unpacked 64-bit integer.
   -- Return:
   --   Returns a 64-bit little-endian integer.
   -- Exceptions:
   --   None.
   ---------------------------------------------------------------------
   function Pack_As_LE(Input : in U64_Unpacked)
     return U64
     with Inline;

   ---------------------------------------------------------------------
   -- Sip_Round
   --
   -- Purpose:
   --   Executes the round function of SipHash.
   -- Parameters:
   --   V0: Internal state(0).
   --   V1: Internal state(1).
   --   V2: Internal state(2).
   --   V3: Internal state(3).
   -- Exceptions:
   --   None.
   ---------------------------------------------------------------------
   procedure Sip_Round(V0, V1, V2, V3 : in out U64)
     with Inline;
end SipHash;
