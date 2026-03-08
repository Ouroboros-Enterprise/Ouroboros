unit UCCTokenizer;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, Generics.Collections, fpjson, jsonparser, UCCTypes;

type
  TWordTokenizer = class
  private
    FWordToIndex: TDictionary<string, Integer>;
    FIndexToWord: TDictionary<Integer, string>;
    FPadId: Integer;
    
    function CleanText(const Text: string): string;
  public
    constructor Create;
    destructor Destroy; override;
    
    procedure Fit(const Corpus: TStringList);
    function Encode(const Text: string): TDoubleArray1D;
    function Decode(const Tokens: TDoubleArray1D): string;
    
    procedure LoadFromJSON(const FileName: string);
    function GetVocabSize: Integer;
    property PadId: Integer read FPadId;
  end;

implementation

constructor TWordTokenizer.Create;
begin
  FWordToIndex := TDictionary<string, Integer>.Create;
  FIndexToWord := TDictionary<Integer, string>.Create;
  FPadId := 0;
  
  // Basic initialization with special tokens if needed
  FWordToIndex.Add('<PAD>', 0);
  FIndexToWord.Add(0, '<PAD>');
end;

destructor TWordTokenizer.Destroy;
begin
  FWordToIndex.Free;
  FIndexToWord.Free;
  inherited;
end;

function TWordTokenizer.CleanText(const Text: string): string;
begin
  Result := LowerCase(Text);
  // Basic cleaning, could be improved
  Result := StringReplace(Result, '.', ' . ', [rfReplaceAll]);
  Result := StringReplace(Result, ',', ' , ', [rfReplaceAll]);
  Result := StringReplace(Result, '!', ' ! ', [rfReplaceAll]);
  Result := StringReplace(Result, '?', ' ? ', [rfReplaceAll]);
end;

procedure TWordTokenizer.Fit(const Corpus: TStringList);
var
  Line, Word: string;
  Words: TStringArray;
  i, j: Integer;
  NextIdx: Integer;
begin
  NextIdx := FWordToIndex.Count;
  for i := 0 to Corpus.Count - 1 do
  begin
    Line := CleanText(Corpus[i]);
    Words := Line.Split([' '], TStringSplitOptions.ExcludeEmpty);
    for j := 0 to High(Words) do
    begin
      Word := Words[j];
      if not FWordToIndex.ContainsKey(Word) then
      begin
        FWordToIndex.Add(Word, NextIdx);
        FIndexToWord.Add(NextIdx, Word);
        Inc(NextIdx);
      end;
    end;
  end;
end;

function TWordTokenizer.Encode(const Text: string): TDoubleArray1D;
var
  Line: string;
  Words: TStringArray;
  i, Idx: Integer;
begin
  Line := CleanText(Text);
  Words := Line.Split([' '], TStringSplitOptions.ExcludeEmpty);
  SetLength(Result, Length(Words));
  for i := 0 to High(Words) do
  begin
    if FWordToIndex.TryGetValue(Words[i], Idx) then
      Result[i] := Idx
    else
      Result[i] := FPadId; // Unknown or pad
  end;
end;

function TWordTokenizer.Decode(const Tokens: TDoubleArray1D): string;
var
  i: Integer;
  Word: string;
begin
  Result := '';
  for i := 0 to High(Tokens) do
  begin
    if FIndexToWord.TryGetValue(Round(Tokens[i]), Word) then
    begin
      if Result <> '' then Result := Result + ' ';
      Result := Result + Word;
    end;
  end;
end;

procedure TWordTokenizer.LoadFromJSON(const FileName: string);
var
  F: TFileStream;
  Parser: TJSONParser;
  Data: TJSONObject;
  Dataset: TJSONArray;
  i: Integer;
  // This is a helper to load from the llm_data.json if we need vocabulary from there
  // Actually PHP saves the tokenizer separately as a serialized object.
  // We might just want to re-fit or have a better way to import the word list.
begin
  // Implementation depends on how we export from PHP
end;

function TWordTokenizer.GetVocabSize: Integer;
begin
  Result := FWordToIndex.Count;
end;

end.
