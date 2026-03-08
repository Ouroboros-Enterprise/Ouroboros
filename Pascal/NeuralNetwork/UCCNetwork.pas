unit UCCNetwork;

{$mode objfpc}{$H+}{$interfaces corba}

interface

uses
  Classes, SysUtils, Math, UCCMatrix, UCCLayers, UCCLosses, UCCOptimizers, UCCTypes;

type
  TNetwork = class
  public
    FLayers: array of ILayer;
    FLossFunction: ILoss;
    FOptimizer: IOptimizer;

    constructor Create;
    procedure AddLayer(Layer: ILayer);
    procedure SetLossFunction(Loss: ILoss);
    procedure SetOptimizer(Opt: IOptimizer);
    
    function Forward(Input: TMatrix): TMatrix;
    procedure Backward(OutputGradient: TMatrix; LearningRate: Double);
    
    function GetTotalParameters: Integer;
    procedure Train(const Inputs, Targets: TMatrixArray; Epochs: Integer; LearningRate: Double);
    function Predict(Input: TMatrix): TMatrix;
    
    procedure Save(const FileName: string);
    procedure Load(const FileName: string);
  end;

implementation

constructor TNetwork.Create;
begin
  SetLength(FLayers, 0);
end;

procedure TNetwork.AddLayer(Layer: ILayer);
begin
  SetLength(FLayers, Length(FLayers) + 1);
  FLayers[High(FLayers)] := Layer;
end;

procedure TNetwork.SetLossFunction(Loss: ILoss);
begin
  FLossFunction := Loss;
end;

procedure TNetwork.SetOptimizer(Opt: IOptimizer);
var
  i: Integer;
begin
  FOptimizer := Opt;
  for i := 0 to Length(FLayers) - 1 do
    FLayers[i].SetOptimizer('layer_' + IntToStr(i), FOptimizer);
end;

function TNetwork.Forward(Input: TMatrix): TMatrix;
var
  i: Integer;
begin
  Result := Input;
  for i := 0 to Length(FLayers) - 1 do
    Result := FLayers[i].Forward(Result);
end;

procedure TNetwork.Backward(OutputGradient: TMatrix; LearningRate: Double);
var
  i: Integer;
  PrevGradient, NextGradient: TMatrix;
begin
  if FOptimizer <> nil then
    FOptimizer.IncrementStep;
    
  NextGradient := OutputGradient;
  for i := Length(FLayers) - 1 downto 0 do
  begin
    PrevGradient := NextGradient;
    NextGradient := FLayers[i].Backward(PrevGradient, LearningRate);
    if PrevGradient <> OutputGradient then
      PrevGradient.Free;
  end;
  NextGradient.Free; // Final input gradient
end;

function TNetwork.GetTotalParameters: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Length(FLayers) - 1 do
    Result := Result + FLayers[i].GetParameterCount;
end;

procedure TNetwork.Train(const Inputs, Targets: TMatrixArray; Epochs: Integer; LearningRate: Double);
var
  Epoch, i: Integer;
  TotalLoss: Double;
  Output, ErrorGradient: TMatrix;
begin
  WriteLn('Total Parameters: ', GetTotalParameters);
  
  for Epoch := 1 to Epochs do
  begin
    TotalLoss := 0;
    for i := 0 to Length(Inputs) - 1 do
    begin
      Output := Forward(Inputs[i]);
      TotalLoss := TotalLoss + FLossFunction.Calculate(Output, Targets[i]);
      
      ErrorGradient := FLossFunction.Derivative(Output, Targets[i]);
      Backward(ErrorGradient, LearningRate);
    end;
    
    if (Epoch = 1) or (Epoch mod 10 = 0) then
      WriteLn(Format('Epoch %d/%d - Loss: %f', [Epoch, Epochs, TotalLoss / Length(Inputs)]));
  end;
end;

function TNetwork.Predict(Input: TMatrix): TMatrix;
begin
  Result := Forward(Input);
end;

procedure TNetwork.Save(const FileName: string);
var
  Stream: TFileStream;
  i, LayerCount: Integer;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    LayerCount := Length(FLayers);
    Stream.Write(LayerCount, SizeOf(Integer));
    for i := 0 to LayerCount - 1 do
      FLayers[i].Save(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TNetwork.Load(const FileName: string);
var
  Stream: TFileStream;
  i, LayerCount: Integer;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead);
  try
    Stream.Read(LayerCount, SizeOf(Integer));
    if LayerCount <> Length(FLayers) then
      raise Exception.Create('Model file layer count mismatch');
    for i := 0 to LayerCount - 1 do
      FLayers[i].Load(Stream);
  finally
    Stream.Free;
  end;
end;

end.
