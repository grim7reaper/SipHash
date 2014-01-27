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

------------------------------------------------------------------------
-- SipHash
--
-- Implementation Notes:
--   This package implements utility functions.
--
-- Portability Issues:
--   - 64-bit integers are required.
------------------------------------------------------------------------
package body SipHash is
   ---------------------------------------------------------------------
   -- Version_String
   -- Implementation Notes:
   --   Trims the leading space from of the string returned by
   --   Natural'Image.
   ---------------------------------------------------------------------
   function Version_String
     return String is
      Major : constant String := Natural'Image(Version.Major);
      Minor : constant String := Natural'Image(Version.Minor);
      Patch : constant String := Natural'Image(Version.Patch);
   begin
      return Major(2..Major'Last) & '.' &
             Minor(2..Minor'Last) & '.' & 
             Patch(2..Patch'Last);
   end Version_String;

   ---------------------------------------------------------------------
   -- Pack_As_LE
   ---------------------------------------------------------------------
   function Pack_As_LE(Input : in U64_Unpacked)
     return U64 is
   begin
      return           U64(Input(1))      or
            Shift_Left(U64(Input(2)),  8) or
            Shift_Left(U64(Input(3)), 16) or
            Shift_Left(U64(Input(4)), 24) or
            Shift_Left(U64(Input(5)), 32) or
            Shift_Left(U64(Input(6)), 40) or
            Shift_Left(U64(Input(7)), 48) or
            Shift_Left(U64(Input(8)), 56);
   end Pack_As_LE;

   ---------------------------------------------------------------------
   -- Sip_Round
   --
   -- Implementation Notes:
   --   Operations are ordered in a way that reduce data dependancies.
   ---------------------------------------------------------------------
   procedure Sip_Round(V0, V1, V2, V3 : in out U64) is
   begin
      V0 := V0 + V1;
      V2 := V2 + V3;
      V1 := Rotate_Left(V1, 13);
      V3 := Rotate_Left(V3, 16);
      V1 := V1 xor V0;
      V3 := V3 xor V2;
      V0 := Rotate_Left(V0, 32);
      V2 := V2 + V1;
      V0 := V0 + V3;
      V1 := Rotate_Left(V1, 17);
      V3 := Rotate_Left(V3, 21);
      V1 := V1 xor V2;
      V3 := V3 xor V0;
      V2 := Rotate_Left(V2, 32);
   end Sip_Round;
end SipHash;
