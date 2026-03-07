{$mode objfpc}
unit apple;

interface

uses
  snake, node;

type
  TApple = class
  protected
    FX: Integer;
    FY: Integer;
  public
    constructor Create(ASnake: TSnake);
    procedure Eat(ASnake: TSnake); // randomized coords

    property X: Integer read FX write FX;
    property Y: Integer read FY write FY;
  end;

implementation

  // AX und AY sind Koordinaten von der snake, daher random generieren (und kontrollieren dass nicht gleicher G-Spot generiert wurde wie die Snake xD)
  constructor TApple.Create(ASnake: TSnake);
    begin
      Eat(ASnake);
    end;

  procedure TApple.Eat(ASnake: TSnake);
    var
      currentNode: TNode;  
      blockiert: Boolean;
      RX, RY: Integer;
    begin
      while True do
        begin
          blockiert := False;

          RX := Random(20); // 0 bis 19
          RY := Random(20); // 0 bis 19

          currentNode := ASnake; // Startpunkt der Snake
          while currentNode <> nil do
            begin
              if (currentNode.X = RX) and (currentNode.Y = RY) then
                begin
                  blockiert := True;
                  Break; // Schleife verlassen, da Blockierung gefunden
                end;
              currentNode := currentNode.Next; // Zum nächsten Knoten wechseln
            end;

          if not blockiert then
            begin
              FX := RX; // Apfel-Koordinaten setzen
              FY := RY;
              Break; // Schleife verlassen, da gültige Position gefunden
            end;
        end;
    end; // Eat func
end. // Wollen wir jetzt nicht die main machen? Was?
// sind wir hier fertig? KA glaub schon - wenns rumkäfert, dann fixen wirs später - OK