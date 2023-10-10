package body Tasks is

   package Random_Assembly is new
     Ada.Numerics.Discrete_Random(Assembly_Type);

   task body Consumer is
      subtype Consumption_Time_Range is Integer range 4 .. 8;
      package Random_Consumption is new
    	Ada.Numerics.Discrete_Random(Consumption_Time_Range);
      G: Random_Consumption.Generator;	--  random number generator (time)
      G2: Random_Assembly.Generator;	--  also (assemblies)
      Consumer_Nb: Consumer_Type;
      Assembly_Number: Integer;
      Consumption: Integer;
      Assembly_Type: Integer;
      DidDeliver: Boolean;
   begin
      accept Start(Consumer_Number: in Consumer_Type;
		 Consumption_Time: in Integer) do
         Random_Consumption.Reset(G);	--  ustaw generator
         Random_Assembly.Reset(G2);	--  też
         Consumer_Nb := Consumer_Number;
	     Consumption := Consumption_Time;
      end Start;
      Put_Line("Started consumer " & Consumers'val(Consumer_Nb)'Image);
      loop
         delay Duration(Random_Consumption.Random(G)); --  simulate consumption
         Assembly_Type := Random_Assembly.Random(G2);
         loop
            select
               Buffer.Deliver(Assembly_Type, Assembly_Number, DidDeliver);
               if DidDeliver then
                  Put_Line(Consumers'val(Consumer_Nb)'Image & ": taken assembly " &
                     Assemblies'val(Assembly_Number)'Image & " number " &
                     Integer'Image(Assembly_Number));
                  exit;
               end if;
             or
               delay Duration(5.0);
             end select;
            Put_Line("Cant deliver, waiting");
         end loop;
      end loop;
   end Consumer;

   task body Producer is
      subtype Production_Time_Range is Integer range 3 .. 6;
      package Random_Production is new
	  Ada.Numerics.Discrete_Random(Production_Time_Range);
      G: Random_Production.Generator;	--  generator liczb losowych
      Product_Type_Number: Integer;
      Product_Number: Integer;
      Production: Integer;
      CanTake: Boolean;
      begin
        accept Start(Product: in Product_Type; Production_Time: in Integer) do
            Random_Production.Reset(G);	--  start random number generator
            Product_Number := 1;
            Product_Type_Number := Product;
            Production := Production_Time;
        end Start;
      Put_Line("Started producer of " & Products'val(Product_Type_Number)'Image);
      loop
         delay Duration(Random_Production.Random(G)); --  symuluj produkcję
         Put_Line("Produced product " & Products'val(Product_Type_Number)'Image
		    & " number "  & Integer'Image(Product_Number));
         -- Accept for storage
         loop
            select
               Buffer.Take(Product_Type_Number, Product_Number, CanTake);
               if CanTake then
                  Put_Line("Product " & Products'val(Product_Type_Number)'Image & " was sent to the buffer");
                  exit;
               end if;
            or
               delay Duration(5.0);
            end select;
            Put_Line("Cant send product to storage, waiting.");
        end loop;
	    Product_Number := Product_Number + 1;
      end loop;
   end Producer;

   task body Buffer is
      Storage_Capacity: constant Integer := 30;
      type Storage_type is array (Product_Type) of Integer;
      Storage: Storage_type
	:= (0, 0, 0, 0, 0);
      Assembly_Content: array(Assembly_Type, Product_Type) of Integer
	:= ((1, 2, 1, 4, 1),
	    (1, 1, 1, 2, 1),
	    (1, 2, 1, 3, 1));
      Max_Assembly_Content: array(Product_Type) of Integer;
      Assembly_Number: array(Assembly_Type) of Integer
	:= (1, 1, 1);
      In_Storage: Integer := 0;
      FailedDelivers: Integer := 0;

      procedure Setup_Variables is
      begin
         for W in Product_Type loop
            Max_Assembly_Content(W) := 0;
            for Z in Assembly_Type loop
               if Assembly_Content(Z, W) > Max_Assembly_Content(W) then
              Max_Assembly_Content(W) := Assembly_Content(Z, W);
               end if;
            end loop;
         end loop;
      end Setup_Variables;

      function Can_Accept(Product: Product_Type) return Boolean is
         Free: Integer;		--  free room in the storage
         -- how many products are for production of arbitrary assembly
         Lacking: array(Product_Type) of Integer;
         -- how much room is needed in storage to produce arbitrary assembly
         Lacking_room: Integer;
         MP: Boolean;			--  can accept
      begin
         if In_Storage >= Storage_Capacity then
            return False;
         end if;
         -- There is free room in the storage
         Free := Storage_Capacity - In_Storage;
         MP := True;
         for W in Product_Type loop
            if Storage(W) < Max_Assembly_Content(W) then
               MP := False;
            end if;
         end loop;
         if MP then
            return True;		--  storage has products for arbitrary
                            --  assembly
         end if;
         if Integer'Max(0, Max_Assembly_Content(Product) - Storage(Product)) > 0 then
            -- exactly this product lacks
            return True;
         end if;
         Lacking_room := 1;			--  insert current product
         for W in Product_Type loop
            Lacking(W) := Integer'Max(0, Max_Assembly_Content(W) - Storage(W));
            Lacking_room := Lacking_room + Lacking(W);
         end loop;
         if Free >= Lacking_room then
            -- there is enough room in storage for arbitrary assembly
            return True;
         else
            -- no room for this product
            return False;
         end if;
      end Can_Accept;

      function Can_Deliver(Assembly: Assembly_Type) return Boolean is
      begin
         for W in Product_Type loop
            if Storage(W) < Assembly_Content(Assembly, W) then
               return False;
            end if;
         end loop;
         return True;
      end Can_Deliver;

      procedure Storage_Contents is
      begin
         for W in Product_Type loop
            Put_Line("Storage contents: " & Integer'Image(Storage(W)) & " "
                   & Products'val(W)'Image);
         end loop;
      end Storage_Contents;

   begin
      Put_Line("Buffer started");
      Setup_Variables;
      loop
	 accept Take(Product: in Product_Type; Number: in Integer;  CanTake: out Boolean) do
	   if Can_Accept(Product) then
	      Put_Line("Accepted product " & Products'val(Product)'Image & " number " &
		Integer'Image(Number));
	      Storage(Product) := Storage(Product) + 1;
            In_Storage := In_Storage + 1;
            CanTake := true;  
  	   else
	      Put_Line("Rejected product " & Products'val(Product)'Image & " number " & Integer'Image(Number));
          FailedDelivers := FailedDelivers + 1;
          CanTake := false;
          if FailedDelivers > 5 then
            In_Storage := 0;
            FailedDelivers := 0;
            Put_Line("Too many lost deliveries! Half of the storage was lost!");
            for W in Product_Type loop
                Storage(W) := Storage(W) / 2;
                In_Storage := In_Storage + Storage(W);
            end loop;
          end if;
	   end if;
	 end Take;
	 Storage_Contents;
	 accept Deliver(Assembly: in Assembly_Type; Number: out Integer; DidDeliver: out Boolean) do
	    if Can_Deliver(Assembly) then
	       Put_Line("Delivered assembly " & Assemblies'val(Assembly)'Image & " number " &
			  Integer'Image(Assembly_Number(Assembly)));
	       for W in Product_Type loop
		  Storage(W) := Storage(W) - Assembly_Content(Assembly, W);
		  In_Storage := In_Storage - Assembly_Content(Assembly, W);
	       end loop;
	       Number := Assembly_Number(Assembly);
             Assembly_Number(Assembly) := Assembly_Number(Assembly) + 1;
             DidDeliver := true; 
	    else
	       Put_Line("Lacking products for assembly " & Assemblies'val(Assembly)'Image);
           DIdDeliver := false;
	    end if;
	 end Deliver;
	 Storage_Contents;
     end loop;
   end Buffer;

end Tasks;
