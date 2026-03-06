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
    procedure Move(AX, AY: Integer);
    procedure CheckInput;

  private
    procedure WallCollision;
    procedure SelfCollision;
  end;



implementation
  constructor TSnake.Create(AX, AY: Integer; ANext: TNode);
  begin
    inherited Create(AX, AY, ANext);
    FNext := new TNode(AX + 1, AY, nil); // eins rechts vom Kopf der Schlange
  end;

  procedure TSnake.WallCollision;
  begin
    if (FX < 0) or (FX >= 20) or (FY < 0) or (FY >= 20) then
      raise Exception.Create('Game Over: Gegen die Wand gelaufen!');
  end;

  procedure TSnake.SelfCollision;
  var
    Current: TNode;
  begin
    Current := FNext;
    while Current <> nil do
    begin
      if (Current.FX = FX) and (Current.FY = FY) then
        raise Exception.Create('Game Over: Gegen sich selbst gelaufen!');
      Current := Current.FNext;
    end;
  end;

  procedure TSnake.CheckInput;
  var
    Ch: Char;
  begin
    if KeyPressed then
    begin
      Ch := ReadKey;
      case Ch of
        'w', 'W': Move(FX, FY - 1);
        's', 'S': Move(FX, FY + 1);
        'a', 'A': Move(FX - 1, FY);
        'd', 'D': Move(FX + 1, FY);
        #72: Move(FX, FY - 1);  // Up arrow
        #80: Move(FX, FY + 1);  // Down arrow
        #75: Move(FX - 1, FY);  // Left arrow
        #77: Move(FX + 1, FY);  // Right arrow
      end;
    end;
  end;

  procedure TSnake.Move(AX, AY: Integer);
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
    if Current.FNext <> nil then
      Current.FNext := nil; // Letztes Segment entfernen

    WallCollision; 
    SelfCollision;
  end;
end.hu=