unit snake;

uses
  node;

interface
type
  TSnake = class(TNode)

  public
    constructor Create(AX, AY: Integer; ANext: TNode)
    begin
      inherited Create(AX, AY, ANext);
    end;
    function Move(AX, AY, ASegs: Integer): Boolean;

  private
    function SelfCollision: Boolean;
    function WallCollision: Boolean;
  end;



implementation
  constructor TSnake.Create(AX, AY: Integer; ANext: TNode);
  begin
    inherited Create(AX, AY, ANext);
    FNext := new TNode(AX + 1, AY, nil); // eins rechts vom Kopf der Schlange
  end;

  function TSnake.WallCollision: Boolean;
  begin
    Result := (FX < 0) or (FX >= 20) or (FY < 0) or (FY >= 20); // wenn true dann kollison
  end;

  function TSnake.SelfCollision: Boolean;
  var
    Current: TNode;
  begin
    Result := False;  
    Current := FNext;   

    while Current <> nil do
    begin
    
      if (Current.X = Self.X) and (Current.Y = Self.Y) then
      begin
        Result := True;  
        Exit;
      end;
      Current := Current.Next;
    end;
  end;


  // AX und AY sind die neuen Koordinaten vom neuen Head, AGrow ist wahr, wenn Apfel gefressen
  function TSnake.Move(AX, AY, AGrow: Boolean): Boolean;
  { Erstellt einen neuen Kopf der Schlange und entfernt das letzte Segment, um die Bewegung zu simulieren. }
  var
    NewHead: TNode;
    Current: TNode;
  begin
    NewHead := new TNode(AX, AY, FNext); 
    FNext := NewHead; 


    Current := FNext;
    while (Current.FNext <> nil) and (Current.FNext.FNext <> nil) do
      Current := Current.FNext;
      
    if Current.FNext <> nil and not AGrow then // wenn nächstes nicht nil und kein neues segment
      Current.FNext := nil; // Letztes Segment entfernen, bei grow behalten
    

    Result := not WallCollision and not SelfCollision;
  end;

end;
end.