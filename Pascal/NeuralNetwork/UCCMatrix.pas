unit UCCMatrix;

{$mode objfpc}{$H+}{$interfaces corba}

interface

uses
  SysUtils, Math, UCCTypes;

type
  TMapFunc = function(Val: Double; Row, Col: Integer): Double;

  TMatrix = class;
  TMatrixArray = array of TMatrix;

  TMatrix = class
  public
    Rows, Cols: Integer;
    Data: array of Double;

    constructor Create(ARows, ACols: Integer);
    destructor Destroy; override;

    class function FromArray(const Arr: TDoubleArray2D): TMatrix;
    class function FromVector(const Arr: TDoubleArray1D): TMatrix;
    function ToArray: TDoubleArray2D;

    function Add(M: TMatrix): TMatrix;
    function Subtract(M: TMatrix): TMatrix;
    function Multiply(M: TMatrix): TMatrix; // Dot product
    function MultiplyElementWise(M: TMatrix): TMatrix; // Hadamard
    function MultiplyScalar(N: Double): TMatrix;
    function Transpose: TMatrix;
    function Map(Func: TMapFunc): TMatrix;
    procedure Randomize(MinVal: Double = -1.0; MaxVal: Double = 1.0);
    procedure Clip(Limit: Double);
    
    // Performance helper
    procedure SetValue(R, C: Integer; V: Double); inline;
    function GetValue(R, C: Integer): Double; inline;
  end;

implementation

constructor TMatrix.Create(ARows, ACols: Integer);
begin
  Rows := ARows;
  Cols := ACols;
  SetLength(Data, Rows * Cols);
  FillChar(Data[0], Length(Data) * SizeOf(Double), 0);
end;

destructor TMatrix.Destroy;
begin
  SetLength(Data, 0);
  inherited Destroy;
end;

procedure TMatrix.SetValue(R, C: Integer; V: Double);
begin
  Data[R * Cols + C] := V;
end;

function TMatrix.GetValue(R, C: Integer): Double;
begin
  Result := Data[R * Cols + C];
end;

class function TMatrix.FromArray(const Arr: TDoubleArray2D): TMatrix;
var
  R, C, i, j: Integer;
begin
  R := Length(Arr);
  if R = 0 then exit(TMatrix.Create(0, 0));
  C := Length(Arr[0]);
  Result := TMatrix.Create(R, C);
  for i := 0 to R - 1 do
    for j := 0 to C - 1 do
      Result.SetValue(i, j, Arr[i][j]);
end;

class function TMatrix.FromVector(const Arr: TDoubleArray1D): TMatrix;
var
  R, i: Integer;
begin
  R := Length(Arr);
  Result := TMatrix.Create(R, 1);
  for i := 0 to R - 1 do
    Result.SetValue(i, 0, Arr[i]);
end;

function TMatrix.ToArray: TDoubleArray2D;
var
  i, j: Integer;
begin
  SetLength(Result, Rows, Cols);
  for i := 0 to Rows - 1 do
    for j := 0 to Cols - 1 do
      Result[i][j] := GetValue(i, j);
end;

function TMatrix.Add(M: TMatrix): TMatrix;
var
  i: Integer;
begin
  if (Rows <> M.Rows) or (Cols <> M.Cols) then
    raise Exception.Create('Matrix dimensions must match for addition');
  Result := TMatrix.Create(Rows, Cols);
  for i := 0 to Rows * Cols - 1 do
    Result.Data[i] := Data[i] + M.Data[i];
end;

function TMatrix.Subtract(M: TMatrix): TMatrix;
var
  i: Integer;
begin
  if (Rows <> M.Rows) or (Cols <> M.Cols) then
    raise Exception.Create('Matrix dimensions must match for subtraction');
  Result := TMatrix.Create(Rows, Cols);
  for i := 0 to Rows * Cols - 1 do
    Result.Data[i] := Data[i] - M.Data[i];
end;

function TMatrix.Multiply(M: TMatrix): TMatrix;
var
  i, j, k: Integer;
  V: Double;
begin
  if Cols <> M.Rows then
    raise Exception.Create('Columns of A (' + IntToStr(Cols) + ') must match rows of B (' + IntToStr(M.Rows) + ')');
  
  Result := TMatrix.Create(Rows, M.Cols);
  for i := 0 to Rows - 1 do
    for k := 0 to Cols - 1 do
    begin
      V := GetValue(i, k);
      if V = 0.0 then continue;
      for j := 0 to M.Cols - 1 do
        Result.Data[i * M.Cols + j] := Result.Data[i * M.Cols + j] + V * M.GetValue(k, j);
    end;
end;

function TMatrix.MultiplyElementWise(M: TMatrix): TMatrix;
var
  i: Integer;
begin
  if (Rows <> M.Rows) or (Cols <> M.Cols) then
    raise Exception.Create('Matrix dimensions must match for element-wise multiplication');
  Result := TMatrix.Create(Rows, Cols);
  for i := 0 to Rows * Cols - 1 do
    Result.Data[i] := Data[i] * M.Data[i];
end;

function TMatrix.MultiplyScalar(N: Double): TMatrix;
var
  i: Integer;
begin
  Result := TMatrix.Create(Rows, Cols);
  for i := 0 to Rows * Cols - 1 do
    Result.Data[i] := Data[i] * N;
end;

function TMatrix.Transpose: TMatrix;
var
  i, j: Integer;
begin
  Result := TMatrix.Create(Cols, Rows);
  for i := 0 to Rows - 1 do
    for j := 0 to Cols - 1 do
      Result.SetValue(j, i, GetValue(i, j));
end;

function TMatrix.Map(Func: TMapFunc): TMatrix;
var
  i, j: Integer;
begin
  Result := TMatrix.Create(Rows, Cols);
  for i := 0 to Rows - 1 do
    for j := 0 to Cols - 1 do
      Result.SetValue(i, j, Func(GetValue(i, j), i, j));
end;

procedure TMatrix.Randomize(MinVal, MaxVal: Double);
var
  i: Integer;
begin
  for i := 0 to Rows * Cols - 1 do
    Data[i] := MinVal + Random * (MaxVal - MinVal);
end;

procedure TMatrix.Clip(Limit: Double);
var
  i: Integer;
begin
  for i := 0 to Rows * Cols - 1 do
    Data[i] := Max(-Limit, Min(Limit, Data[i]));
end;

end.
