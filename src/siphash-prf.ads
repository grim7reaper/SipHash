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
generic
   -- Number of compression rounds
   Nb_Compression_Rounds  : Positive;
   -- Number of finalization rounds.
   Nb_Finalization_Rounds : Positive;

------------------------------------------------------------------------
-- SipHash.PRF
--
-- Purpose:
--   This package provides an implementation of the SipHash PRF.
------------------------------------------------------------------------
package SipHash.PRF is
   type Object is limited private;

   ---------------------------------------------------------------------
   -- Initialize
   --
   -- Purpose:
   --   Initializes a SipHash instance with the specified 128-bit secret
   --   key.
   -- Parameters:
   --   Key: a 128-bit secret key.
   -- Return:
   --   Returns an initialized SipHash instance.
   -- Exceptions:
   --   None.
   ---------------------------------------------------------------------
   function Initialize(Key : in Key_Type)
     return Object;

   ---------------------------------------------------------------------
   -- Update
   --
   -- Purpose:
   --   Add a byte to the hash.
   -- Parameters:
   --   Hash: a SipHash instance.
   --   Byte: a byte of data.
   -- Exceptions:
   --   None.
   ---------------------------------------------------------------------
   procedure Update(Hash : in out Object; Byte : in U8);

   ---------------------------------------------------------------------
   -- Update
   --
   -- Purpose:
   --   Add an array of bytes to the hash.
   -- Parameters:
   --   Hash: a SipHash instance.
   --   Byte: an array of bytes.
   -- Exceptions:
   --   None.
   ---------------------------------------------------------------------
   procedure Update(Hash : in out Object; Input : in Byte_Sequence);

   ---------------------------------------------------------------------
   -- Finalize
   --
   -- Purpose:
   --   Runs the finalization round and computes the hash value.
   -- Parameters:
   --   Hash:   a SipHash instance.
   --   Result: the hash value.
   -- Exceptions:
   --   None.
   -- Remarks:
   --   You MUST call Reset before calling Update again.
   ---------------------------------------------------------------------
   procedure Finalize(Hash : in out Object; Result : out U64);

   ---------------------------------------------------------------------
   -- Reset
   --
   -- Purpose:
   --   Re-Initializes the internal state.
   -- Parameters:
   --   Hash: a SipHash instance.
   --   Key:  a 128-bit secret key.
   -- Remarks:
   --   The current state is lost.
   ---------------------------------------------------------------------
   procedure Reset(Hash : in out Object; Key : in Key_Type);

   ---------------------------------------------------------------------
   -- Hash
   --
   -- Purpose:
   --   Computes the hash of the input using the specified 128-bit
   --   secret key.
   -- Parameters:
   --   Input: data to hash.
   --   Key:   a 128-bit secret key.
   -- Return:
   --   Returns the hash value.
   -- Exceptions:
   --   None.
   ---------------------------------------------------------------------
   function Hash(Input : in Byte_Sequence; Key : in Key_Type)
     return U64;

private

   type Object is limited
      record
         -- Interneal state.
         V0          : U64;
         V1          : U64;
         V2          : U64;
         V3          : U64;
         -- Current block.
         Block       : U64;
         -- Position in the current block.
         Block_Index : U8;
         -- Processed bytes' counter (modulo 256)
         Count       : U8;
      end record;
end SipHash.PRF;
