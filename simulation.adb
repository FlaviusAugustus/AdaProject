-- A skeleton of a program for an assignment in programming languages
-- The students should rename the tasks of producers, consumers, and the buffer
-- Then, they should change them so that they would fit their assignments
-- They should also complete the code with constructions that lack there
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; 
with Ada.Numerics.Discrete_Random;
with Constants; use Constants;
with Tasks; 

procedure Simulation is
   P: array ( 1 .. Number_Of_Products ) of Tasks.Producer;
   K: array ( 1 .. Number_Of_Consumers ) of Tasks.Consumer;
begin
   for I in 1 .. Number_Of_Products  loop
      P(I).Start(I, 10);
   end loop;
   for J in 1 .. Number_Of_Consumers loop
      K(J).Start(J, 12);
   end loop;
end Simulation;
