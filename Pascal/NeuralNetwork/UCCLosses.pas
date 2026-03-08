unit UCCLosses;

{$mode objfpc}{$H+}{$interfaces corba}

interface

uses
  SysUtils, Math, UCCMatrix, UCCTypes;

type
  ILoss = interface
    function Calculate(Output, Target: TMatrix): Double;
    function Derivative(Output, Target: TMatrix): TMatrix;
  end;

  TMSE = class(TInterfacedObject, ILoss)
    function Calculate(Output, Target: TMatrix): Double;
    function Derivative(Output, Target: TMatrix): TMatrix;
  end;

  TCategoricalCrossEntropy = class(TInterfacedObject, ILoss)
    function Calculate(Output, Target: TMatrix): Double;
    function Derivative(Output, Target: TMatrix): TMatrix;
  end;

implementation

function TMSE.Calculate(Output, Target: TMatrix): Double;
var
  i: Integer;
  Diff: Double;
begin
  Result := 0;
  for i := 0 to Output.Rows * Output.Cols - 1 do
  begin
    Diff := Output.Data[i] - Target.Data[i];
    Result := Result + Diff * Diff;
  end;
  Result := Result / (Output.Rows * Output.Cols);
end;

function TMSE.Derivative(Output, Target: TMatrix): TMatrix;
var
  i: Integer;
begin
  Result := TMatrix.Create(Output.Rows, Output.Cols);
  for i := 0 to Output.Rows * Output.Cols - 1 do
    Result.Data[i] := 2 * (Output.Data[i] - Target.Data[i]) / (Output.Rows * Output.Cols);
end;

function TCategoricalCrossEntropy.Calculate(Output, Target: TMatrix): Double;
var
  i: Integer;
  Val: Double;
begin
  Result := 0;
  for i := 0 to Output.Rows * Output.Cols - 1 do
  begin
    if Target.Data[i] > 0 then
    begin
      Val := Max(Output.Data[i], 1e-15);
      Result := Result - Target.Data[i] * Ln(Val);
    end;
  end;
end;

function TCategoricalCrossEntropy.Derivative(Output, Target: TMatrix): TMatrix;
var
  i: Integer;
begin
  // For Softmax + CCE, the derivative is output - target
  Result := TMatrix.Create(Output.Rows, Output.Cols);
  for i := 0 to Output.Rows * Output.Cols - 1 do
    Result.Data[i] := Output.Data[i] - Target.Data[i];
end;

end.
