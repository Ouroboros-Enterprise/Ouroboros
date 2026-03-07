{$mode objfpc}
unit gui;

interface

uses
  snake, node, game, apple;

type
  TGUI = class
  // -1 = border. 20 = border, 0..19 = gültiger bereich
  var Spielfeld: array[-1..20, -1..20] of char; // Ist das richtig so, also mit 0 bis 20? fuck, das muss bei -1 starten, da 0 noch gültiger bereich ist oh ja könnte sein. Und wir müssen wohl jeden Frame den Array clearen... Ansonsten müssten wir uns ja merken wo die Figur gerade eben war
  private // ja wir generieren das feld dann einfach komplett neu, ist weniger anstrengend
    procedure PlaceBorders;
    procedure PlaceSnake(ASnake: TSnake); // platziert das dann die koordinaten der snek segs? ja
    procedure PlaceApple(AApple: TApple); // und das dann vom apfel (der nicht weit vom stamm fällt)
  public
    constructor Create;
    procedure GenGUI(ASnake: TSnake; AApple: TApple);
    procedure GameOver();
  end;

implementation
  procedure TGUI.PlaceBorders;
  begin
    for var i := 0 to 20 do
    begin
      Spielfeld[0, i] := '#';
      Spielfeld[20, i] := '#';
      Spielfeld[i, 0] := '#';
      Spielfeld[i, 20] := '#';
    end;
  end;

  constructor TGUI.Create;
    begin
    end;

  procedure TGUI.PlaceSnake(ASnake: TSnake);
    begin
      var currentNode := ASnake.Head;
      Spielfeld[currentNode.X, currentNode.Y] := 'X'; // Kopf der Schlange
      currentNode := currentNode.Next;
      
      while currentNode <> nil do
        begin 
          Spielfeld[currentNode.X, currentNode.Y] := 'O';
          currentNode := currentNode.Next;
        end;
    end;

  procedure TGUI.PlaceApple(AApple: TApple);
    begin
      Spielfeld[AApple.X][AApple.Y] := '@';
    end;

  procedure TGUI.GenGUI(ASnake: TSnake; AApple: TApple); 
    begin
      PlaceBorders();
      PlaceSnake(ASnake);
      PlaceApple(AApple);

      // Füllt die restlichen felder mit spaces (' ')
      // Gibt das Spielfeld im terminal aus
      for var i := 0 to 20 do
      begin
        for var j := 0 to 20 do
        begin
          //checken ob das feld leer (nil etc) ist, wenn ja dann mit ' ' befüllen
          feld := Spielfeld[i][j];
          if feld = nil then
            feld := ' ';
            
          write(feld); // printet das das? //Ja, es ist ja nil, weil wir sonst nichts setzen, und dann wird es eben mit einem Leerzeichen ersetzt.
        end;

        writeln;
      end;

      //Was machen wir, wenn das Game vorbei ist? wir brauchen noch ne game over function, die nen kreativen text anzeigt
    end;

  procedure TGUI.GameOver;
    begin
      writeln(' _____ ____  _      _____   ____  _     _____ ____ ');
      writeln('/  __//  _ \/ \__/|/  __/  /  _ \/ \ |\/  __//  __\');
      writeln('| |  _| / \|| |\/|||  \    | / \|| | //|  \  |  \/|');
      writeln('| |_//| |-||| |  |||  /_   | \_/|| \// |  /_ |    /');
      writeln('\____\\_/ \|\_/  \|\____\  \____/\__/  \____\\_/\_\');                                      
    end;
end.