unit UCCActivations;

{$mode objfpc}{$H+}{$interfaces corba}

interface

uses
  SysUtils, Math, UCCMatrix, UCCTypes;

type
  IActivation = interface
    function Forward(Input: TMatrix): TMatrix;
    function Derivative(Input: TMatrix): TMatrix;
  end;

  TReLU = class(TInterfacedObject, IActivation)
    function Forward(Input: TMatrix): TMatrix;
    function Derivative(Input: TMatrix): TMatrix;
  end;

  TSigmoid = class(TInterfacedObject, IActivation)
    function Forward(Input: TMatrix): TMatrix;
    function Derivative(Input: TMatrix): TMatrix;
  end;

  TTanh = class(TInterfacedObject, IActivation)
    function Forward(Input: TMatrix): TMatrix;
    function Derivative(Input: TMatrix): TMatrix;
  end;

  TSoftmax = class(TInterfacedObject, IActivation)
    function Forward(Input: TMatrix): TMatrix;
    function Derivative(Input: TMatrix): TMatrix;
  end;

implementation

function ReLUFunc(Val: Double; R, C: Integer): Double;
begin
  if Val > 0 then Result := Val else Result := 0;
end;

function ReLUDerivFunc(Val: Double; R, C: Integer): Double;
begin
  if Val > 0 then Result := 1 else Result := 0;
end;

function TReLU.Forward(Input: TMatrix): TMatrix;
begin
  Result := Input.Map(@ReLUFunc);
end;

function TReLU.Derivative(Input: TMatrix): TMatrix;
begin
  Result := Input.Map(@ReLUDerivFunc);
end;

function SigmoidFunc(Val: Double; R, C: Integer): Double;
begin
  Result := 1 / (1 + Exp(-Val));
end;

function SigmoidDerivFunc(Val: Double; R, C: Integer): Double;
begin
  Result := Val * (1 - Val);
end;

function TSigmoid.Forward(Input: TMatrix): TMatrix;
begin
  Result := Input.Map(@SigmoidFunc);
end;

function TSigmoid.Derivative(Input: TMatrix): TMatrix;
begin
  Result := Input.Map(@SigmoidDerivFunc);
end;

function TanhFunc(Val: Double; R, C: Integer): Double;
begin
  Result := (Exp(Val) - Exp(-Val)) / (Exp(Val) + Exp(-Val));
end;

function TanhDerivFunc(Val: Double; R, C: Integer): Double;
begin
  Result := 1 - (Val * Val);
end;

function TTanh.Forward(Input: TMatrix): TMatrix;
begin
  Result := Input.Map(@TanhFunc);
end;

function TTanh.Derivative(Input: TMatrix): TMatrix;
begin
  Result := Input.Map(@TanhDerivFunc);
end;

function TSoftmax.Forward(Input: TMatrix): TMatrix;
var
  i, j: Integer;
  MaxVal, Sum: Double;
  ExpVals: TMatrix;
begin
  ExpVals := TMatrix.Create(Input.Rows, Input.Cols);
  for j := 0 to Input.Cols - 1 do
  begin
    MaxVal := -1e30;
    for i := 0 to Input.Rows - 1 do
      if Input.GetValue(i, j) > MaxVal then MaxVal := Input.GetValue(i, j);
    
    Sum := 0;
    for i := 0 to Input.Rows - 1 do
    begin
      ExpVals.SetValue(i, j, Exp(Input.GetValue(i, j) - MaxVal));
      Sum := Sum + ExpVals.GetValue(i, j);
    end;
    
    for i := 0 to Input.Rows - 1 do
      ExpVals.SetValue(i, j, ExpVals.GetValue(i, j) / Sum);
  end;
  Result := ExpVals;
end;

function TSoftmax.Derivative(Input: TMatrix): TMatrix;
var
  i: Integer;
begin
  // Softmax derivative is complex but for CCE loss it simplifies to (output - target)
  // Here we just return 1 for elementwise if needed, but usually handled in loss.
  Result := TMatrix.Create(Input.Rows, Input.Cols);
  for i := 0 to Input.Rows * Input.Cols - 1 do
    Result.Data[i] := 1.0; 
end;

end.
