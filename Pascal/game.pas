{$mode objfpc}
unit game;

interface

uses
  snake;
  node;
  apple;
  gui;

type
  TGame = class
  private
    FSnake: TSnake;
    FApple: TApple;
    FAppleCount: Integer;
    FGUI: TGUI;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Update;
    procedure Start;
  end;

implementation
constructor TGame.Create(AStartX, AStartY: Integer)
  var
    ANext: TNode;
  begin
    ANext := TNode.Create(1, 2, nil);
    FSnake := TSnake.Create(AStartX, AStartY, ANext);
    FApple := TApple.Create(FSnake); // darf nicht mit snake kollidieren
    FAppleCount := 0;
  end;

procedure TGame.Start; 
  var
    Input: Char;
    DX, DY: Integer;
    AX, AY: Integer;
    AGrow: Boolean;
  begin
    while true do // game loop
      if KeyPressed then
      begin
        Input := ReadKey;
        case Input of
          'w', 'W', #72: begin DX := 0; DY := -1; end;
          's', 'S', #80: begin DX := 0; DY := 1; end;
          'a', 'A', #75: begin DX := -1; DY := 0; end;
          'd', 'D', #77: begin DX := 1; DY := 0; end;
      end;
      AX := FSnake.X + DX;
      AY := FSnake.Y + DY; // Kann ich kurz mal alles pushen? Kann ich aufs Terminal?

      // Schlange frisst den Apfel, so wie Eva die verbotene Frucht im garten Eden
      AGrow := (AX = FApple.X) and (AY = FApple.Y);
      if AGrow then
      begin
        FApple.Eat(FSnake); // Neue Apfel Koords
        Inc(FAppleCount); // erhöht apple count um 1
      end;

      // Führt move logik aus und detected Kollision
      // Kollision -> break aus der loop -> game over screen
      if FSnake.Move(AX, AY, AGrow) then
        Break;

      // Zeigt jetzt den Frame an
      FGUI.GenGUI(FSnake, FApple);
    end;
    FGUI.GameOver();
  end;


procedure TGame.Update;
  begin
  end;

destructor TGame.Destroy;
  begin
    FSnake.Free;
    FApple.Free;
    inherited Destroy;
  end;
end.

{
1 apple auf map (vorerst)

Idee:

gameloop:
prüft I/O
berechnet neue koords vom snake head
  -> führt dann move methode von snake objekt aus
  -> wertet return aus
    -> wenn kollision, dann break aus gameloop und gameover screen + message

gibt alle objekte (koordinaten sind wichtig) an GUI

GUI baut frame und zeigt es an.
}