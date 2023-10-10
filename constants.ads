package Constants is
    Number_Of_Products: constant Integer := 5;
    Number_Of_Assemblies: constant Integer := 3;
    Number_Of_Consumers: constant Integer := 2;   

    subtype Consumer_Type is Integer range 1 .. Number_Of_Consumers;
    subtype Product_Type is Integer range 1 .. Number_Of_Products;
    subtype Assembly_Type is Integer range 1 .. Number_Of_Assemblies;

    type Products is (empty, Wheel, Interior, SteeringWheel, EngineComponents, Paint);
    type Assemblies is (empty, SportsCar,  Car, Motorbike);
    type Consumers is (empty, Mike, Bob);
end Constants;
