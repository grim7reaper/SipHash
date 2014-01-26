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
with Ada.Text_IO;
with SipHash;

---------------------------------------------------------------------
-- SipHash_Tests
--
-- Purpose:
--   This procedure tests the SipHash implementation.
-- Exceptions:
--   None.
-- References:
--   [1]J.-P. Aumasson and D. J. Bernstein, “SipHash: a fast short-input
--      PRF.” 18-Sep-2012 (https://131002.net/siphash/siphash.pdf)
--   [2]J.-P. Aumasson and D. J. Bernstein, "Reference C implementation"
--      (https://131002.net/siphash/siphash24.c)
---------------------------------------------------------------------
procedure SipHash_Tests is
   package T_IO renames Ada.Text_IO;
   package M_IO is new T_IO.Modular_IO(SipHash.U64);

   use type SipHash.U64;

   -- Key used for all tests.
   -- Cf. Appendix A, p. 19 of [1]
   Key : constant SipHash.Key_Type := (
     16#00#, 16#01#, 16#02#, 16#03#, 16#04#, 16#05#, 16#06#, 16#07#,
     16#08#, 16#09#, 16#0a#, 16#0b#, 16#0c#, 16#0d#, 16#0e#, 16#0f#);

   ---------------------------------------------------------------------
   -- Test_Paper
   --
   -- Purpose:
   --   This function tests the implementation against the test values
   --   provided in the original paper (Cf. Appendix A, p. 19 of [1]).
   -- Return:
   --   Returns True if the test passed, otherwise False.
   -- Exceptions:
   --   None.
   ---------------------------------------------------------------------
   function Test_Paper
     return Boolean is
      -- Cf. Appendix A, p. 19 of [1]
      Input : SipHash.Byte_Sequence:= (
        16#00#, 16#01#, 16#02#, 16#03#, 16#04#, 16#05#, 16#06#, 16#07#,
        16#08#, 16#09#, 16#0a#, 16#0b#, 16#0c#, 16#0d#, 16#0e#);
      -- Cf. Appendix A, p. 19 of [1]
      Expected_Output : constant SipHash.U64 := 16#a129ca6149be45e5#;
      Result : SipHash.U64;
   begin
      Result := SipHash.SipHash_24(Input, Key);
      if Result /= Expected_Output then
         T_IO.Put("Test_Paper failed: ");
         M_IO.Put(Expected_Output, Base => 16);
         T_IO.Put(" /=");
         M_IO.Put(Result, Base => 16);
         T_IO.New_Line;
         return False;
      else
         return True;
      end if;
   end Test_Paper;

   ---------------------------------------------------------------------
   -- Test_Empty_Input
   --
   -- Purpose:
   --   This function tests the implementation with an empty input.
   -- Return:
   --   Returns True if the test passed, otherwise False.
   -- Exceptions:
   --   None.
   ---------------------------------------------------------------------
   function Test_Empty_Input
     return Boolean is
      Empty_Input : constant SipHash.Byte_Sequence(1..0) :=
        (others => 16#00#);
      -- Cf. Reference C implementation[2].
      -- (reordered to match little-endian encoding)
      Expected_Output : constant SipHash.U64 := 16#726fdb47dd0e0e31#;
      Result : SipHash.U64;
   begin
      Result := SipHash.SipHash_24(Empty_Input, Key);
      if Result /= Expected_Output then
         T_IO.Put("Test_Empty_Input failed: ");
         M_IO.Put(Expected_Output, Base => 16);
         T_IO.Put(" /=");
         M_IO.Put(Result, Base => 16);
         T_IO.New_Line;
         return False;
      else
         return True;
      end if;
   end Test_Empty_Input;

   ---------------------------------------------------------------------
   -- Test_Reference_Implementation
   --
   -- Purpose:
   --   This function tests the implementation against the test values
   --   provided in the reference C implementation (Cf. [2]).
   -- Return:
   --   Returns True if the test passed, otherwise False.
   -- Exceptions:
   --   None.
   ---------------------------------------------------------------------
   function Test_Reference_Implementation
     return Boolean is
      type Result_Array is array(SipHash.U64 range <>) of SipHash.U64;

      -- Cf. Reference C implementation[2].
      -- (reordered to match little-endian encoding)
      Expected : constant Result_Array(1..63) := (
        16#74f839c593dc67fd#, 16#0d6c8009d9a94f5a#, 16#85676696d7fb7e2d#,
        16#cf2794e0277187b7#, 16#18765564cd99a68d#, 16#cbc9466e58fee3ce#,
        16#ab0200f58b01d137#, 16#93f5f5799a932462#, 16#9e0082df0ba9e4b0#,
        16#7a5dbbc594ddb9f3#, 16#f4b32f46226bada7#, 16#751e8fbc860ee5fb#,
        16#14ea5627c0843d90#, 16#f723ca908e7af2ee#, 16#a129ca6149be45e5#,
        16#3f2acc7f57c29bdb#, 16#699ae9f52cbe4794#, 16#4bc1b3f0968dd39c#,
        16#bb6dc91da77961bd#, 16#bed65cf21aa2ee98#, 16#d0f2cbb02e3b67c7#,
        16#93536795e3a33e88#, 16#a80c038ccd5ccec8#, 16#b8ad50c6f649af94#,
        16#bce192de8a85b8ea#, 16#17d835b85bbb15f3#, 16#2f2e6163076bcfad#,
        16#de4daaaca71dc9a5#, 16#a6a2506687956571#, 16#ad87a3535c49ef28#,
        16#32d892fad841c342#, 16#7127512f72f27cce#, 16#a7f32346f95978e3#,
        16#12e0b01abb051238#, 16#15e034d40fa197ae#, 16#314dffbe0815a3b4#,
        16#027990f029623981#, 16#cadcd4e59ef40c4d#, 16#9abfd8766a33735c#,
        16#0e3ea96b5304a7d0#, 16#ad0c42d6fc585992#, 16#187306c89bc215a9#,
        16#d4a60abcf3792b95#, 16#f935451de4f21df2#, 16#a9538f0419755787#,
        16#db9acddff56ca510#, 16#d06c98cd5c0975eb#, 16#e612a3cb9ecba951#,
        16#c766e62cfcadaf96#, 16#ee64435a9752fe72#, 16#a192d576b245165a#,
        16#0a8787bf8ecb74b2#, 16#81b3e73d20b49b6f#, 16#7fa8220ba3b2ecea#,
        16#245731c13ca42499#, 16#b78dbfaf3a8d83bd#, 16#ea1ad565322a1a0b#,
        16#60e61c23a3795013#, 16#6606d7e446282b93#, 16#6ca4ecb15c5f91e1#,
        16#9f626da15c9625f3#, 16#e51b38608ef25f57#, 16#958a324ceb064572#);
      Input  : SipHash.Byte_Sequence(1..63);
      Result : SipHash.U64;
      Status : Boolean := True;
   begin
      -- Test the following inputs:
      -- Input = 00              (1 byte)
      -- Input = 00 01           (2 bytes)
      -- Input = 00 01 02        (3 bytes)
      -- ...
      -- Input = 00 01 02 ... 3e (63 bytes)
      for I in Input'Range loop
         Input(I) := SipHash.U8(I-1);
         Result   := SipHash.SipHash_24(Input(1..I), Key);
         if Result /= Expected(I) then
            T_IO.Put("Test_Reference_Implementation failed for"
              & SipHash.U64'Image(I) & " bytes: ");
            M_IO.Put(Expected(I), Base => 16);
            T_IO.Put(" /=");
            M_IO.Put(Result, Base => 16);
            T_IO.New_Line;
            Status := False;
            exit;
         end if;
      end loop;
      return Status;
   end Test_Reference_Implementation;

   Status : Boolean := True;
begin
   Status := Status and Test_Paper;
   Status := Status and Test_Empty_Input;
   Status := Status and Test_Reference_Implementation;
   -- Check if everything went well.
   if Status then
      T_IO.Put_Line("All tests passed!");
   end if;
end SipHash_Tests;
