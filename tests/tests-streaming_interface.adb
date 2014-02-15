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
with SipHash.PRF;

---------------------------------------------------------------------
-- Tests.Streaming_Interface
--
-- Purpose:
--   This procedure tests the Streaming interface of SipHash.
-- Exceptions:
--   None.
-- References:
--   [1]J.-P. Aumasson and D. J. Bernstein, “SipHash: a fast short-input
--      PRF.” 18-Sep-2012 (https://131002.net/siphash/siphash.pdf)
--   [2]J.-P. Aumasson and D. J. Bernstein, "Reference C implementation"
--      (https://131002.net/siphash/siphash24.c)
---------------------------------------------------------------------
procedure Tests.Streaming_Interface is
   package T_IO renames Ada.Text_IO;
   package SipHash24 is new SipHash.PRF(Nb_Compression_Rounds  => 2,
                                        Nb_Finalization_Rounds => 4);

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
      Hash   : SipHash24.Object := SipHash24.Initialize(Key);
      Result : SipHash.U64;
   begin
      for I in Paper_Input'Range loop
         SipHash24.Update(Hash, Paper_Input(I));
      end loop;
      SipHash24.Finalize(Hash, Result);
      if Result /= Paper_Output then
         Put_Error("Test_Paper", Paper_Output, Result);
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
      Hash   : SipHash24.Object := SipHash24.Initialize(Key);
      Result : SipHash.U64;
   begin
      SipHash24.Finalize(Hash, Result);
      if Result /= Empty_Output then
         Put_Error("Test_Empty_Input", Empty_Output, Result);
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
      Hash   : SipHash24.Object := SipHash24.Initialize(Key);
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
         SipHash24.Update(Hash, Input(Input'First));
         if I > 1 then
            SipHash24.Update(Hash, Input(Input'First + 1.. I));
         end if;
         SipHash24.Finalize(Hash, Result);
         if Result /= C_Ref_Output(I) then
            Put_Error("Test_Reference_Implementation",
                      C_Ref_Output(I), Result);
            Status := False;
            exit;
         end if;
         SipHash24.Reset(Hash, Key);
      end loop;
      return Status;
   end Test_Reference_Implementation;

   Status : Boolean := True;
begin
   T_IO.Put_Line("SipHash v" & SipHash.Version_String);
   Status := Status and Test_Paper;
   Status := Status and Test_Empty_Input;
   Status := Status and Test_Reference_Implementation;
   -- Check if everything went well.
   if Status then
      T_IO.Put_Line("All tests passed!");
   end if;
end Tests.Streaming_Interface;

