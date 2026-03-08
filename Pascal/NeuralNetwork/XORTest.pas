program XORTest;

{$mode objfpc}{$H+}

uses
  SysUtils, UCCMatrix, UCCNetwork, UCCLayers, UCCActivations, UCCLosses, UCCOptimizers, UCCTypes;

var
  NN: TNetwork;
  Inputs, Targets: array[0..3] of TMatrix;
  i: Integer;
  Output: TMatrix;
begin
  Randomize;
  
  NN := TNetwork.Create;
  NN.AddLayer(TDense.Create(2, 4, TSigmoid.Create));
  NN.AddLayer(TDense.Create(4, 1, TSigmoid.Create));
  
  NN.SetLossFunction(TMSE.Create);
  NN.SetOptimizer(TAdam.Create(0.9, 0.999, 1e-8));
  
  Inputs[0] := TMatrix.FromVector([0, 0]);
  Targets[0] := TMatrix.FromVector([0]);
  
  Inputs[1] := TMatrix.FromVector([0, 1]);
  Targets[1] := TMatrix.FromVector([1]);
  
  Inputs[2] := TMatrix.FromVector([1, 0]);
  Targets[2] := TMatrix.FromVector([1]);
  
  Inputs[3] := TMatrix.FromVector([1, 1]);
  Targets[3] := TMatrix.FromVector([0]);
  
  WriteLn('Training XOR...');
  NN.Train(Inputs, Targets, 1000, 0.1);
  
  WriteLn('Predictions:');
  for i := 0 to 3 do
  begin
    Output := NN.Forward(Inputs[i]);
    WriteLn(Format('Input [%f, %f] - Prediction: %f', [Inputs[i].Data[0], Inputs[i].Data[1], Output.Data[0]]));
  end;
  
  NN.Free;
end.
