unit UCCNetwork;

{$mode objfpc}{$H+}{$interfaces corba}

interface

uses
  SysUtils, Math, UCCMatrix, UCCLayers, UCCLosses, UCCOptimizers, UCCTypes;

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
  Gradient: TMatrix;
begin
  if FOptimizer <> nil then
    FOptimizer.IncrementStep;
    
  Gradient := OutputGradient;
  for i := Length(FLayers) - 1 downto 0 do
    Gradient := FLayers[i].Backward(Gradient, LearningRate);
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

end.
