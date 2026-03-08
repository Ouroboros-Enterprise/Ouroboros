unit UCCOptimizers;

{$mode objfpc}{$H+}{$interfaces corba}

interface

uses
  SysUtils, Math, UCCMatrix, UCCTypes;

type
  IOptimizer = interface
    procedure Update(const LayerId: string; Weights, WeightGradients, Biases, BiasGradients: TMatrix; LearningRate: Double);
    procedure IncrementStep;
  end;

  TSGD = class(TInterfacedObject, IOptimizer)
    procedure Update(const LayerId: string; Weights, WeightGradients, Biases, BiasGradients: TMatrix; LearningRate: Double);
    procedure IncrementStep;
  end;

  TAdam = class(TInterfacedObject, IOptimizer)
  private
    FBeta1, FBeta2, FEpsilon: Double;
    FStep: Integer;
    // Map of LayerId to M and V matrices
    // For simplicity in Pascal without complex maps, we might need a structure
    type
      TAdamState = record
        MW, VW, MB, VB: TMatrix;
      end;
    var
      FStates: array of record
        Id: string;
        State: TAdamState;
      end;
    function GetState(const LayerId: string; RowsW, ColsW, RowsB, ColsB: Integer): TAdamState;
  public
    constructor Create(Beta1: Double = 0.9; Beta2: Double = 0.999; Epsilon: Double = 1e-8);
    procedure Update(const LayerId: string; Weights, WeightGradients, Biases, BiasGradients: TMatrix; LearningRate: Double);
    procedure IncrementStep;
  end;

implementation

{ TSGD }

procedure TSGD.Update(const LayerId: string; Weights, WeightGradients, Biases, BiasGradients: TMatrix; LearningRate: Double);
var
  i: Integer;
begin
  for i := 0 to Weights.Rows * Weights.Cols - 1 do
    Weights.Data[i] := Weights.Data[i] - LearningRate * WeightGradients.Data[i];
    
  for i := 0 to Biases.Rows * Biases.Cols - 1 do
    Biases.Data[i] := Biases.Data[i] - LearningRate * BiasGradients.Data[i];
end;

procedure TSGD.IncrementStep; begin end;

{ TAdam }

constructor TAdam.Create(Beta1, Beta2, Epsilon: Double);
begin
  FBeta1 := Beta1;
  FBeta2 := Beta2;
  FEpsilon := Epsilon;
  FStep := 0;
end;

function TAdam.GetState(const LayerId: string; RowsW, ColsW, RowsB, ColsB: Integer): TAdamState;
var
  i: Integer;
begin
  for i := 0 to Length(FStates) - 1 do
    if FStates[i].Id = LayerId then exit(FStates[i].State);
  
  SetLength(FStates, Length(FStates) + 1);
  FStates[High(FStates)].Id := LayerId;
  FStates[High(FStates)].State.MW := TMatrix.Create(RowsW, ColsW);
  FStates[High(FStates)].State.VW := TMatrix.Create(RowsW, ColsW);
  FStates[High(FStates)].State.MB := TMatrix.Create(RowsB, ColsB);
  FStates[High(FStates)].State.VB := TMatrix.Create(RowsB, ColsB);
  Result := FStates[High(FStates)].State;
end;

procedure TAdam.Update(const LayerId: string; Weights, WeightGradients, Biases, BiasGradients: TMatrix; LearningRate: Double);
var
  State: TAdamState;
  i: Integer;
  MWS, VWS, MBS, VBS: TMatrix;
  MWHat, VWHat, MBHat, VBHat: Double;
  Correction1, Correction2: Double;
begin
  State := GetState(LayerId, Weights.Rows, Weights.Cols, Biases.Rows, Biases.Cols);
  MWS := State.MW;
  VWS := State.VW;
  MBS := State.MB;
  VBS := State.VB;
  
  Correction1 := 1 - Power(FBeta1, FStep);
  Correction2 := 1 - Power(FBeta2, FStep);
  if Correction1 = 0 then Correction1 := 1;
  if Correction2 = 0 then Correction2 := 1;

  for i := 0 to Weights.Rows * Weights.Cols - 1 do
  begin
    MWS.Data[i] := FBeta1 * MWS.Data[i] + (1 - FBeta1) * WeightGradients.Data[i];
    VWS.Data[i] := FBeta2 * VWS.Data[i] + (1 - FBeta2) * Sqr(WeightGradients.Data[i]);
    
    MWHat := MWS.Data[i] / Correction1;
    VWHat := VWS.Data[i] / Correction2;
    
    Weights.Data[i] := Weights.Data[i] - LearningRate * MWHat / (Sqrt(VWHat) + FEpsilon);
  end;
  
  for i := 0 to Biases.Rows * Biases.Cols - 1 do
  begin
    MBS.Data[i] := FBeta1 * MBS.Data[i] + (1 - FBeta1) * BiasGradients.Data[i];
    VBS.Data[i] := FBeta2 * VBS.Data[i] + (1 - FBeta2) * Sqr(BiasGradients.Data[i]);
    
    MBHat := MBS.Data[i] / Correction1;
    VBHat := VBS.Data[i] / Correction2;
    
    Biases.Data[i] := Biases.Data[i] - LearningRate * MBHat / (Sqrt(VBHat) + FEpsilon);
  end;
end;

procedure TAdam.IncrementStep;
begin
  Inc(FStep);
end;

end.
