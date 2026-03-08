unit UCCLayers;

{$mode objfpc}{$H+}{$interfaces corba}

interface

uses
  SysUtils, Math, UCCMatrix, UCCActivations, UCCOptimizers, UCCTypes;

type
  ILayer = interface
    function Forward(Input: TMatrix): TMatrix;
    function Backward(OutputGradient: TMatrix; LearningRate: Double): TMatrix;
    function GetParameterCount: Integer;
    procedure SetOptimizer(const Id: string; Opt: IOptimizer);
  end;

  TDense = class(TInterfacedObject, ILayer)
  private
    FWeights, FBiases: TMatrix;
    FActivation: IActivation;
    FOptimizer: IOptimizer;
    FLayerId: string;
    FInputCache, FOutputCache, FActivationCache: TMatrix;
  public
    constructor Create(InputSize, OutputSize: Integer; Act: IActivation = nil);
    function Forward(Input: TMatrix): TMatrix;
    function Backward(OutputGradient: TMatrix; LearningRate: Double): TMatrix;
    function GetParameterCount: Integer;
    procedure SetOptimizer(const Id: string; Opt: IOptimizer);
  end;

  TEmbedding = class(TInterfacedObject, ILayer)
  private
    FWeights: TMatrix;
    FOptimizer: IOptimizer;
    FLayerId: string;
    FInputCache: TMatrix;
  public
    constructor Create(VocabSize, EmbeddingDim: Integer);
    function Forward(Input: TMatrix): TMatrix;
    function Backward(OutputGradient: TMatrix; LearningRate: Double): TMatrix;
    function GetParameterCount: Integer;
    procedure SetOptimizer(const Id: string; Opt: IOptimizer);
  end;

  TSimpleRNN = class(TInterfacedObject, ILayer)
  private
    FWx, FWh, FBh: TMatrix;
    FActivation: IActivation;
    FOptimizer: IOptimizer;
    FLayerId: string;
    FInputs, FHiddenStates: TMatrixArray;
  public
    constructor Create(InputSize, HiddenSize: Integer; Act: IActivation = nil);
    function Forward(Input: TMatrix): TMatrix;
    function Backward(OutputGradient: TMatrix; LearningRate: Double): TMatrix;
    function GetParameterCount: Integer;
    procedure SetOptimizer(const Id: string; Opt: IOptimizer);
  end;

implementation

{ TDense }

constructor TDense.Create(InputSize, OutputSize: Integer; Act: IActivation);
begin
  FWeights := TMatrix.Create(OutputSize, InputSize);
  FWeights.Randomize(-1.0, 1.0);
  FBiases := TMatrix.Create(OutputSize, 1);
  FBiases.Randomize(-1.0, 1.0);
  FActivation := Act;
end;

procedure TDense.SetOptimizer(const Id: string; Opt: IOptimizer);
begin
  FLayerId := Id;
  FOptimizer := Opt;
end;

function TDense.Forward(Input: TMatrix): TMatrix;
begin
  FInputCache := Input;
  FOutputCache := FWeights.Multiply(Input).Add(FBiases);
  if FActivation <> nil then
  begin
    FActivationCache := FActivation.Forward(FOutputCache);
    Result := FActivationCache;
  end
  else
    Result := FOutputCache;
end;

function TDense.Backward(OutputGradient: TMatrix; LearningRate: Double): TMatrix;
var
  ActDeriv, WeightGradients, InputGradient: TMatrix;
begin
  if FActivation <> nil then
  begin
    ActDeriv := FActivation.Derivative(FActivationCache);
    OutputGradient := OutputGradient.MultiplyElementWise(ActDeriv);
  end;

  WeightGradients := OutputGradient.Multiply(FInputCache.Transpose);
  InputGradient := FWeights.Transpose.Multiply(OutputGradient);

  if FOptimizer <> nil then
    FOptimizer.Update(FLayerId, FWeights, WeightGradients, FBiases, OutputGradient, LearningRate)
  else
  begin
    // Simple SGD fallback if no optimizer set
    FWeights := FWeights.Subtract(WeightGradients.MultiplyScalar(LearningRate));
    FBiases := FBiases.Subtract(OutputGradient.MultiplyScalar(LearningRate));
  end;

  Result := InputGradient;
end;

function TDense.GetParameterCount: Integer;
begin
  Result := (FWeights.Rows * FWeights.Cols) + (FBiases.Rows * FBiases.Cols);
end;

{ TEmbedding }

constructor TEmbedding.Create(VocabSize, EmbeddingDim: Integer);
begin
  FWeights := TMatrix.Create(VocabSize, EmbeddingDim);
  FWeights.Randomize(-1.0, 1.0);
end;

procedure TEmbedding.SetOptimizer(const Id: string; Opt: IOptimizer);
begin
  FLayerId := Id;
  FOptimizer := Opt;
end;

function TEmbedding.Forward(Input: TMatrix): TMatrix;
var
  i, TokenId: Integer;
begin
  FInputCache := Input;
  Result := TMatrix.Create(FWeights.Cols, Input.Rows * Input.Cols);
  for i := 0 to Input.Rows * Input.Cols - 1 do
  begin
    TokenId := Round(Input.Data[i]);
    if (TokenId >= 0) and (TokenId < FWeights.Rows) then
      Move(FWeights.Data[TokenId * FWeights.Cols], Result.Data[i * FWeights.Cols], FWeights.Cols * SizeOf(Double));
  end;
end;

function TEmbedding.Backward(OutputGradient: TMatrix; LearningRate: Double): TMatrix;
var
  WeightGradients: TMatrix;
  i, j, TokenId: Integer;
begin
  WeightGradients := TMatrix.Create(FWeights.Rows, FWeights.Cols);
  for i := 0 to FInputCache.Rows * FInputCache.Cols - 1 do
  begin
    TokenId := Round(FInputCache.Data[i]);
    if (TokenId >= 0) and (TokenId < FWeights.Rows) then
    begin
      // Gradient for this token row
      for j := 0 to FWeights.Cols - 1 do
        WeightGradients.Data[TokenId * FWeights.Cols + j] := WeightGradients.Data[TokenId * FWeights.Cols + j] + OutputGradient.Data[i * FWeights.Cols + j];
    end;
  end;

  if FOptimizer <> nil then
    FOptimizer.Update(FLayerId, FWeights, WeightGradients, TMatrix.Create(0,0), TMatrix.Create(0,0), LearningRate)
  else
    FWeights := FWeights.Subtract(WeightGradients.MultiplyScalar(LearningRate));

  Result := TMatrix.Create(FInputCache.Rows, FInputCache.Cols); // Input is discrete, usually 0 gradient
end;

function TEmbedding.GetParameterCount: Integer;
begin
  Result := FWeights.Rows * FWeights.Cols;
end;

{ TSimpleRNN }

constructor TSimpleRNN.Create(InputSize, HiddenSize: Integer; Act: IActivation);
begin
  FWx := TMatrix.Create(HiddenSize, InputSize);
  FWh := TMatrix.Create(HiddenSize, HiddenSize);
  FBh := TMatrix.Create(HiddenSize, 1);
  FWx.Randomize(-0.1, 0.1);
  FWh.Randomize(-0.1, 0.1);
  FBh.Randomize(-0.1, 0.1);
  FActivation := Act;
end;

procedure TSimpleRNN.SetOptimizer(const Id: string; Opt: IOptimizer);
begin
  FLayerId := Id;
  FOptimizer := Opt;
end;

function TSimpleRNN.Forward(Input: TMatrix): TMatrix;
var
  t, i: Integer;
  x, h, preActivation: TMatrix;
begin
  // Assume Input is InputSize x SequenceLength
  SetLength(FInputs, Input.Cols);
  SetLength(FHiddenStates, Input.Cols + 1);
  
  FHiddenStates[0] := TMatrix.Create(FWh.Rows, 1); // h_{-1} = 0
  h := FHiddenStates[0];
  
  for t := 0 to Input.Cols - 1 do
  begin
    x := TMatrix.Create(Input.Rows, 1);
    for i := 0 to Input.Rows - 1 do
      x.Data[i] := Input.GetValue(i, t);
    FInputs[t] := x;
    
    // h_t = activation(Wx*x + Wh*h_{t-1} + bh)
    preActivation := FWx.Multiply(x).Add(FWh.Multiply(h)).Add(FBh);
    if FActivation <> nil then
      h := FActivation.Forward(preActivation)
    else
      h := preActivation;
    
    FHiddenStates[t+1] := h;
  end;
  Result := h;
end;

function TSimpleRNN.Backward(OutputGradient: TMatrix; LearningRate: Double): TMatrix;
var
  dWx, dWh, dBh, dInput, dhNext, h, dtanh, da, dx: TMatrix;
  t, k, sequenceLength: Integer;
begin
  sequenceLength := Length(FInputs);
  dWx := TMatrix.Create(FWx.Rows, FWx.Cols);
  dWh := TMatrix.Create(FWh.Rows, FWh.Cols);
  dBh := TMatrix.Create(FBh.Rows, FBh.Cols);
  dInput := TMatrix.Create(sequenceLength, FWx.Cols);
  
  dhNext := OutputGradient;
  
  for t := sequenceLength - 1 downto 0 do
  begin
    h := FHiddenStates[t+1];
    if FActivation <> nil then
      dtanh := FActivation.Derivative(h)
    else
    begin
      dtanh := TMatrix.Create(h.Rows, h.Cols);
      for k := 0 to h.Rows * h.Cols - 1 do dtanh.Data[k] := 1.0;
    end;
    
    da := dhNext.MultiplyElementWise(dtanh);
    
    dWx := dWx.Add(da.Multiply(FInputs[t].Transpose));
    dWh := dWh.Add(da.Multiply(FHiddenStates[t].Transpose));
    dBh := dBh.Add(da);
    
    dx := FWx.Transpose.Multiply(da);
    for k := 0 to dx.Rows - 1 do
      dInput.SetValue(t, k, dx.Data[k]);
      
    dhNext := FWh.Transpose.Multiply(da);
  end;
  
  dWx.Clip(1.0);
  dWh.Clip(1.0);
  dBh.Clip(1.0);
  
  if FOptimizer <> nil then
  begin
    FOptimizer.Update(FLayerId + '_Wx', FWx, dWx, FBh, dBh, LearningRate);
    FOptimizer.Update(FLayerId + '_Wh', FWh, dWh, TMatrix.Create(0,0), TMatrix.Create(0,0), LearningRate);
  end
  else
  begin
    FWx := FWx.Subtract(dWx.MultiplyScalar(LearningRate));
    FWh := FWh.Subtract(dWh.MultiplyScalar(LearningRate));
    FBh := FBh.Subtract(dBh.MultiplyScalar(LearningRate));
  end;
  
  Result := dInput;
end;

function TSimpleRNN.GetParameterCount: Integer;
begin
  Result := (FWx.Rows * FWx.Cols) + (FWh.Rows * FWh.Cols) + (FBh.Rows * FBh.Cols);
end;

end.
