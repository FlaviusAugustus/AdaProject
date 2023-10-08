package Constants is
    Number_Of_Products: constant Integer := 5;
    Number_Of_Assemblies: constant Integer := 3;
    Number_Of_Consumers: constant Integer := 2;   
    subtype Consumer_Type is Integer range 1 .. Number_Of_Consumers;
    subtype Product_Type is Integer range 1 .. Number_Of_Products;
    subtype Assembly_Type is Integer range 1 .. Number_Of_Assemblies;
    Product_Name: constant array (Product_Type) of String(1 .. 8)
     := ("Product1", "Product2", "Product3", "Product4", "Product5");
    Assembly_Name: constant array (Assembly_Type) of String(1 .. 9)
     := ("Assembly1", "Assembly2", "Assembly3");
end Constants;
