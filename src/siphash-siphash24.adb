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
-- SipHash.SipHash24
--
-- Implementation Notes:
--   This package implements SipHash-2-4 using multiple call to
--   Sip_Round instead of a loop.
--
-- Portability Issues:
--   - 64-bit integers are required.
--   - Depends on little-endian encoding?
------------------------------------------------------------------------
package body SipHash.SipHash24 is
   ---------------------------------------------------------------------
   -- Hash
   ---------------------------------------------------------------------
   function Hash(Input : in Byte_Sequence; Key : in Key_Type)
     return U64 is
      Nb_Blocks : constant I64 := I64(Input'Length / Block_Size);
      -- Initialization --
      K0 : U64 := Pack_As_LE(Key(1..8));
      K1 : U64 := Pack_As_LE(Key(9..16));
      V0 : U64 := K0 xor 16#736f6d6570736575#;
      V1 : U64 := K1 xor 16#646f72616e646f6d#;
      V2 : U64 := K0 xor 16#6c7967656e657261#;
      V3 : U64 := K1 xor 16#7465646279746573#;
   begin
      -- Compression --
      for I in 0 .. Nb_Blocks-1 loop
         declare
            Start : U64 := Input'First + U64(I)*U64(Block_Size);
            Stop  : U64 := Start + U64(Block_Size)-1;
            Block : U64 := Pack_As_LE(Input(Start..Stop));
         begin
            V3 := V3 xor Block;
            Sip_Round(V0, V1, V2, V3);
            Sip_Round(V0, V1, V2, V3);
            V0 := V0 xor Block;
         end;
      end loop;
      declare -- Process the last block.
         Last_Block_Size : constant U64 := Input'Length and 7;
         Block : U64 := Shift_Left(Input'Length, 56);
      begin
         for I in 1 .. Last_Block_Size loop
            declare
               Index : U64 := Input'Last-Last_Block_Size+I;
            begin
               Block := Block or Rotate_Left(U64(Input(Index)),
                                             Integer(I-1) * 8);
            end;
         end loop;
         V3 := V3 xor Block;
         Sip_Round(V0, V1, V2, V3);
         Sip_Round(V0, V1, V2, V3);
         V0 := V0 xor Block;
      end;
      -- Finalization --
      V2 := V2 xor 16#ff#;
      Sip_Round(V0, V1, V2, V3);
      Sip_Round(V0, V1, V2, V3);
      Sip_Round(V0, V1, V2, V3);
      Sip_Round(V0, V1, V2, V3);
      return V0 xor V1 xor V2 xor V3;
   end Hash;
end SipHash.SipHash24;
