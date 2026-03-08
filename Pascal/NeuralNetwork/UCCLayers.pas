unit UCCLayers;

{$mode objfpc}{$H+}{$interfaces corba}

interface

uses
  Classes, SysUtils, Math, UCCMatrix, UCCActivations, UCCOptimizers, UCCTypes;

type
  ILayer = interface
    function Forward(Input: TMatrix): TMatrix;
    function Backward(OutputGradient: TMatrix; LearningRate: Double): TMatrix;
    function GetParameterCount: Integer;
    procedure SetOptimizer(const Id: string; Opt: IOptimizer);
    procedure Save(Stream: TStream);
    procedure Load(Stream: TStream);
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
    destructor Destroy; override;
    function Forward(Input: TMatrix): TMatrix;
    function Backward(OutputGradient: TMatrix; LearningRate: Double): TMatrix;
    function GetParameterCount: Integer;
    procedure SetOptimizer(const Id: string; Opt: IOptimizer);
    procedure Save(Stream: TStream);
    procedure Load(Stream: TStream);
  end;

  TEmbedding = class(TInterfacedObject, ILayer)
  private
    FWeights: TMatrix;
    FOptimizer: IOptimizer;
    FLayerId: string;
    FInputCache: TMatrix;
  public
    constructor Create(VocabSize, EmbeddingDim: Integer);
    destructor Destroy; override;
    function Forward(Input: TMatrix): TMatrix;
    function Backward(OutputGradient: TMatrix; LearningRate: Double): TMatrix;
    function GetParameterCount: Integer;
    procedure SetOptimizer(const Id: string; Opt: IOptimizer);
    procedure Save(Stream: TStream);
    procedure Load(Stream: TStream);
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
    destructor Destroy; override;
    function Forward(Input: TMatrix): TMatrix;
    function Backward(OutputGradient: TMatrix; LearningRate: Double): TMatrix;
    function GetParameterCount: Integer;
    procedure SetOptimizer(const Id: string; Opt: IOptimizer);
    procedure Save(Stream: TStream);
    procedure Load(Stream: TStream);
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
  // Input comes from previous layer, we don't free it here.
  // But we might need to free our cache if it's already set.
  // Actually, we'll assume the Network class manages the "flow" matrices.
  // The caches are internal.
  if FOutputCache <> nil then FOutputCache.Free;
  if FActivationCache <> nil then FActivationCache.Free;
  
  FInputCache := Input; // Shared reference, don't free
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
  ActDeriv, WeightGradients, InputGradient, Trans, temp: TMatrix;
begin
  if FActivation <> nil then
  begin
    ActDeriv := FActivation.Derivative(FActivationCache);
    OutputGradient := OutputGradient.MultiplyElementWise(ActDeriv);
    ActDeriv.Free;
  end;

  Trans := FInputCache.Transpose;
  WeightGradients := OutputGradient.Multiply(Trans);
  Trans.Free;
  
  Trans := FWeights.Transpose;
  InputGradient := Trans.Multiply(OutputGradient);
  Trans.Free;

  if FOptimizer <> nil then
    FOptimizer.Update(FLayerId, FWeights, WeightGradients, FBiases, OutputGradient, LearningRate)
  else
  begin
    temp := WeightGradients.MultiplyScalar(LearningRate);
    FWeights := FWeights.Subtract(temp); temp.Free;
    
    temp := OutputGradient.MultiplyScalar(LearningRate);
    FBiases := FBiases.Subtract(temp); temp.Free;
  end;

  WeightGradients.Free;
  Result := InputGradient;
end;

destructor TDense.Destroy;
begin
  FWeights.Free;
  FBiases.Free;
  if FOutputCache <> nil then FOutputCache.Free;
  if FActivationCache <> nil then FActivationCache.Free;
  inherited;
end;

function TDense.GetParameterCount: Integer;
begin
  Result := (FWeights.Rows * FWeights.Cols) + (FBiases.Rows * FBiases.Cols);
end;

procedure TDense.Save(Stream: TStream);
begin
  FWeights.SaveToStream(Stream);
  FBiases.SaveToStream(Stream);
end;

procedure TDense.Load(Stream: TStream);
begin
  FWeights.LoadFromStream(Stream);
  FBiases.LoadFromStream(Stream);
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
  WeightGradients, temp: TMatrix;
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
  begin
    temp := WeightGradients.MultiplyScalar(LearningRate);
    FWeights := FWeights.Subtract(temp); temp.Free;
  end;

  WeightGradients.Free;
  Result := TMatrix.Create(FInputCache.Rows, FInputCache.Cols); // Input is discrete, usually 0 gradient
end;

destructor TEmbedding.Destroy;
begin
  FWeights.Free;
  inherited;
end;

function TEmbedding.GetParameterCount: Integer;
begin
  Result := FWeights.Rows * FWeights.Cols;
end;

procedure TEmbedding.Save(Stream: TStream);
begin
  FWeights.SaveToStream(Stream);
end;

procedure TEmbedding.Load(Stream: TStream);
begin
  FWeights.LoadFromStream(Stream);
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
  // Cleanup old caches
  for t := 0 to High(FInputs) do FInputs[t].Free;
  for t := 0 to High(FHiddenStates) do FHiddenStates[t].Free;
  
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
    
    if FActivation = nil then // if we didn't use an activation, preActivation is h
    begin
       // in this case we don't free preActivation separately
    end else preActivation.Free;

    FHiddenStates[t+1] := h;
  end;
  Result := h;
end;

destructor TSimpleRNN.Destroy;
var
  i: Integer;
begin
  FWx.Free; FWh.Free; FBh.Free;
  for i := 0 to High(FInputs) do FInputs[i].Free;
  for i := 0 to High(FHiddenStates) do FHiddenStates[i].Free;
  inherited;
end;

function TSimpleRNN.Backward(OutputGradient: TMatrix; LearningRate: Double): TMatrix;
var
  dWx, dWh, dBh, dInput, dhNext, h, dtanh, da, dx, temp: TMatrix;
  t, k, sequenceLength: Integer;
begin
  sequenceLength := Length(FInputs);
  dWx := TMatrix.Create(FWx.Rows, FWx.Cols);
  dWh := TMatrix.Create(FWh.Rows, FWh.Cols);
  dBh := TMatrix.Create(FBh.Rows, FBh.Cols);
  dInput := TMatrix.Create(sequenceLength, FWx.Cols);
  
  dhNext := OutputGradient; // Initial gradient from above
  
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
    dtanh.Free;
    
    temp := da.Multiply(FInputs[t].Transpose);
    dWx := dWx.Add(temp); temp.Free;
    
    temp := da.Multiply(FHiddenStates[t].Transpose);
    dWh := dWh.Add(temp); temp.Free;
    
    dBh := dBh.Add(da);
    
    dx := FWx.Transpose.Multiply(da);
    for k := 0 to dx.Rows - 1 do
      dInput.SetValue(t, k, dx.Data[k]);
    dx.Free;
      
    temp := FWh.Transpose.Multiply(da);
    if dhNext <> OutputGradient then dhNext.Free; // Free previous dhNext if it was internal
    dhNext := temp;
    da.Free;
  end;
  if dhNext <> OutputGradient then dhNext.Free;

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
    temp := dWx.MultiplyScalar(LearningRate);
    FWx := FWx.Subtract(temp); temp.Free;
    
    temp := dWh.MultiplyScalar(LearningRate);
    FWh := FWh.Subtract(temp); temp.Free;
    
    temp := dBh.MultiplyScalar(LearningRate);
    FBh := FBh.Subtract(temp); temp.Free;
  end;
  
  dWx.Free; dWh.Free; dBh.Free;
  Result := dInput;
end;

function TSimpleRNN.GetParameterCount: Integer;
begin
  Result := (FWx.Rows * FWx.Cols) + (FWh.Rows * FWh.Cols) + (FBh.Rows * FBh.Cols);
end;

procedure TSimpleRNN.Save(Stream: TStream);
begin
  FWx.SaveToStream(Stream);
  FWh.SaveToStream(Stream);
  FBh.SaveToStream(Stream);
end;

procedure TSimpleRNN.Load(Stream: TStream);
begin
  FWx.LoadFromStream(Stream);
  FWh.LoadFromStream(Stream);
  FBh.LoadFromStream(Stream);
end;

end.
