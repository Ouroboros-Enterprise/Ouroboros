program SLMTrain;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, fpjson, jsonparser, 
  UCCMatrix, UCCNetwork, UCCLayers, UCCActivations, UCCLosses, UCCOptimizers, UCCTypes;

var
  NN: TNetwork;
  JSONStream: TFileStream;
  Parser: TJSONParser;
  Data, SampleObj: TJSONObject;
  Dataset: TJSONArray;
  VocabSize, ContextWindow, i, j, Epoch, Epochs: Integer;
  Input, Target, Prediction, Gradient, InputGrad: TMatrix;
  InputIds: TJSONArray;
  TargetId: Integer;
  LearningRate: Double;
  TotalLoss: Double;

begin
  if not FileExists('../../PHP/NeuronalNetworks/examples/LLM/llm_data.json') then
  begin
    WriteLn('Error: llm_data.json not found.');
    Halt(1);
  end;

  WriteLn('Loading dataset into memory...');
  JSONStream := TFileStream.Create('../../PHP/NeuronalNetworks/examples/LLM/llm_data.json', fmOpenRead);
  Parser := TJSONParser.Create(JSONStream);
  Data := Parser.Parse as TJSONObject;
  VocabSize := Data.Integers['vocabSize'];
  ContextWindow := Data.Integers['contextWindow'];
  Dataset := Data.Arrays['dataset'];
  WriteLn(Format('Vocab Size: %d, Samples: %d', [VocabSize, Dataset.Count]));

  WriteLn('Building Network...');
  NN := TNetwork.Create;
  NN.AddLayer(TEmbedding.Create(VocabSize, 32));
  NN.AddLayer(TSimpleRNN.Create(32, 64, TTanh.Create));
  NN.AddLayer(TDense.Create(64, VocabSize, TSoftmax.Create));

  NN.SetLossFunction(TCategoricalCrossEntropy.Create);
  NN.SetOptimizer(TAdam.Create(0.9, 0.999, 1e-8));

  Epochs := 10;
  if ParamCount > 0 then
    Epochs := StrToIntDef(ParamStr(1), 10);
    
  LearningRate := 0.001;

  WriteLn(Format('Starting Training (%d Epochs, Memory-Safe Benchmark)...', [Epochs]));
  for Epoch := 1 to Epochs do
  begin
    TotalLoss := 0;
    for i := 0 to Dataset.Count - 1 do
    begin
      SampleObj := Dataset.Objects[i];
      InputIds := SampleObj.Arrays['input_ids'];
      TargetId := SampleObj.Integers['target_id'];

      Input := TMatrix.Create(ContextWindow, 1);
      for j := 0 to ContextWindow - 1 do
        Input.Data[j] := InputIds.Integers[j];

      Target := TMatrix.Create(VocabSize, 1);
      Target.Data[TargetId] := 1.0;

      NN.FOptimizer.IncrementStep;
      
      Prediction := NN.Forward(Input); // Reference to last layer cache
      TotalLoss := TotalLoss + NN.FLossFunction.Calculate(Prediction, Target);
      
      Gradient := NN.FLossFunction.Derivative(Prediction, Target); // NEW matrix
      
      NN.Backward(Gradient, LearningRate);
      
      Gradient.Free;
      Target.Free;
      Input.Free;
    end;
    WriteLn(Format('Epoch %d/%d - Loss: %f', [Epoch, Epochs, TotalLoss / Dataset.Count]));
  end;

  WriteLn('Saving model...');
  NN.Save('slm_model.dat');

  NN.Free;
  Parser.Free;
  JSONStream.Free;
end.
