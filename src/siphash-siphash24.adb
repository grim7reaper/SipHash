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
   -- Initialize
   ---------------------------------------------------------------------
   function Initialize(Key : in Key_Type)
     return Object is
   begin
      return Hash : Object do
         Reset(Hash, Key);
      end return;
   end Initialize;

   ---------------------------------------------------------------------
   -- Update
   -- Implementation Notes:
   --   The bytes are accumulated into `Block`. Once we get 8 bytes,
   --   `Block` is processed and then cleared.
   ---------------------------------------------------------------------
   procedure Update(Hash: in out Object; Byte : in U8) is
      Offset : U8 := Hash.Block_Index * Block_Size;
   begin
      Hash.Block := Hash.Block or Shift_Left(U64(Byte), Integer(Offset));
      Hash.Count := Hash.Count + 1;
      Hash.Block_Index := Hash.Block_Index + 1;
      if Hash.Block_Index = Block_Size then
         Hash.V3 := Hash.V3 xor Hash.Block;
         Sip_Round(Hash.V0, Hash.V1, Hash.V2, Hash.V3);
         Sip_Round(Hash.V0, Hash.V1, Hash.V2, Hash.V3);
         Hash.V0 := Hash.V0 xor Hash.Block;
         Hash.Block       := 0;
         Hash.Block_Index := 0;
      end if;
   end Update;

   ---------------------------------------------------------------------
   -- Finalize
   -- Implementation Notes:
   --   This procedure executes the following operations:
   --   1. Padding of the last block with null bytes.
   --   2. Encoding of the number of bytes hashed (modulo 256) in the
   --      last byte of the block.
   --   3. Executing the finalization round.
   --   4. Computing the hash value.
   ---------------------------------------------------------------------
   procedure Finalize(Hash : in out Object; Result : out U64) is
      Nb_Bytes_Hashed : constant U8 := Hash.Count;
   begin
      for I in Hash.Block_Index .. Block_Size-1 loop
         Update(Hash, 0);
      end loop;
      update(Hash, Nb_Bytes_Hashed);
      Hash.V2 := Hash.V2 xor 16#ff#;
      Sip_Round(Hash.V0, Hash.V1, Hash.V2, Hash.V3);
      Sip_Round(Hash.V0, Hash.V1, Hash.V2, Hash.V3);
      Sip_Round(Hash.V0, Hash.V1, Hash.V2, Hash.V3);
      Sip_Round(Hash.V0, Hash.V1, Hash.V2, Hash.V3);
      Result := Hash.V0 xor Hash.V1 xor Hash.V2 xor Hash.V3;
   end Finalize;

   ---------------------------------------------------------------------
   -- Reset
   ---------------------------------------------------------------------
   procedure Reset(Hash : in out Object; Key : in Key_Type) is
      K0 : U64 := Pack_As_LE(Key(1..8));
      K1 : U64 := Pack_As_LE(Key(9..16));
   begin
      Hash.V0 := K0 xor 16#736f6d6570736575#;
      Hash.V1 := K1 xor 16#646f72616e646f6d#;
      Hash.V2 := K0 xor 16#6c7967656e657261#;
      Hash.V3 := K1 xor 16#7465646279746573#;
      Hash.Block       := 0;
      Hash.Block_Index := 0;
      Hash.Count       := 0;
   end Reset;

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
