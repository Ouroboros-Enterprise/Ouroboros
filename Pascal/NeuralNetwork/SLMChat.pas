program SLMChat;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, Math,
  UCCMatrix, UCCNetwork, UCCLayers, UCCActivations, UCCOptimizers, UCCTokenizer, UCCTypes;

var
  NN: TNetwork;
  Tokenizer: TWordTokenizer;
  Corpus: TStringList;
  UserInput, Prompt, Response: string;
  InputTokens, OutputTokens: TDoubleArray1D;
  InputMatrix, Prediction: TMatrix;
  ContextWindow, i, step: Integer;
  MaxResponseLength: Integer;
  CumulativeProb, RandomValue: Double;
  PredictedToken: Integer;

begin
  Randomize;
  
  WriteLn('=== Pascal Neural Chat ===');
  
  if not FileExists('slm_model.dat') then
  begin
    WriteLn('Error: slm_model.dat not found. Please run SLMTrain first.');
    Halt(1);
  end;

  Tokenizer := TWordTokenizer.Create;
  // In a real scenario, we'd load the vocab. 
  // For this demo/benchmark, we'll re-fit on the corpus to get the same mapping.
  Corpus := TStringList.Create;
  if FileExists('../../PHP/Neuronal Networks/examples/LLM/corpus.json') then
  begin
    // Simple way to get words for the demo: loading raw JSON as text and fitting
    // (Better would be a proper JSON vocab load, but let's keep it simple for now)
    Corpus.LoadFromFile('../../PHP/Neuronal Networks/examples/LLM/corpus.json');
    Tokenizer.Fit(Corpus);
  end;

  ContextWindow := 4; // Should match training
  
  WriteLn('Loading model...');
  NN := TNetwork.Create;
  NN.AddLayer(TEmbedding.Create(Tokenizer.GetVocabSize, 32));
  NN.AddLayer(TSimpleRNN.Create(32, 64, TTanh.Create));
  NN.AddLayer(TDense.Create(64, Tokenizer.GetVocabSize, TSoftmax.Create));
  NN.Load('slm_model.dat');

  MaxResponseLength := 20;

  while True do
  begin
    Write('Du: ');
    ReadLn(UserInput);

    if (UserInput = '') or (LowerCase(UserInput) = 'quit') then
      Break;

    Prompt := '[REQUEST] ' + UserInput + ' [/REQUEST] [RESPONSE]';
    InputTokens := Tokenizer.Encode(Prompt);

    Write('AI: ');

    for step := 0 to MaxResponseLength - 1 do
    begin
      // Last ContextWindow tokens
      InputMatrix := TMatrix.Create(ContextWindow, 1);
      for i := 0 to ContextWindow - 1 do
      begin
        if (Length(InputTokens) - ContextWindow + i) >= 0 then
          InputMatrix.Data[i] := InputTokens[Length(InputTokens) - ContextWindow + i]
        else
          InputMatrix.Data[i] := Tokenizer.PadId;
      end;

      Prediction := NN.Predict(InputMatrix);
      
      // Sampling
      RandomValue := Random;
      CumulativeProb := 0;
      PredictedToken := Tokenizer.GetVocabSize - 1;
      for i := 0 to Tokenizer.GetVocabSize - 1 do
      begin
        CumulativeProb := CumulativeProb + Prediction.Data[i];
        if RandomValue <= CumulativeProb then
        begin
          PredictedToken := i;
          Break;
        end;
      end;

      if PredictedToken = Tokenizer.PadId then Break; // Simple stop

      Response := Tokenizer.Decode([PredictedToken]);
      Write(Response + ' ');
      
      // Append for next step
      SetLength(InputTokens, Length(InputTokens) + 1);
      InputTokens[High(InputTokens)] := PredictedToken;
    end;
    WriteLn;
    WriteLn;
  end;

  Tokenizer.Free;
  Corpus.Free;
  NN.Free;
end.
