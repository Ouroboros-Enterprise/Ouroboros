{$mode objfpc}
unit gui;

interface

uses
  crt, snake, node, apple;

type
  TGUI = class
  private
    Spielfeld: array[-1..20, -1..20] of char;
    procedure PlaceBorders;
    procedure PlaceSnake(ASnake: TSnake);
    procedure PlaceApple(AApple: TApple);
  public
    constructor Create;
    procedure GenGUI(ASnake: TSnake; AApple: TApple);
    procedure GameOver();
  end;

implementation
  procedure TGUI.PlaceBorders;
  var
    i: Integer;
  begin
    for i := -1 to 20 do
    begin
      Spielfeld[-1, i] := '#';
      Spielfeld[20, i] := '#';
      Spielfeld[i, -1] := '#';
      Spielfeld[i, 20] := '#';
    end;
  end;

  constructor TGUI.Create;
    begin
    end;

  procedure TGUI.PlaceSnake(ASnake: TSnake);
    var 
      currentNode: TNode;
    begin
      currentNode := ASnake;
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
      Spielfeld[AApple.X, AApple.Y] := '@';
    end;

  procedure TGUI.GenGUI(ASnake: TSnake; AApple: TApple); 
    var
      i, j: Integer;
      feld: char;
    begin
      clrscr;
      for i := -1 to 20 do
        for j := -1 to 20 do
          Spielfeld[i, j] := ' ';

      PlaceBorders();
      PlaceSnake(ASnake);
      PlaceApple(AApple);

      for j := -1 to 20 do
      begin
        for i := -1 to 20 do
        begin
          feld := Spielfeld[i, j];
          // Terminal-Schriften sind normalerweise doppelt so hoch wie breit.
          // Wir ergänzen ein Leerzeichen, damit "Pixel" quadratisch wirken:
          if feld = '#' then
            write(feld, feld) // Für den Rand zwei Raute-Zeichen (damit er dicker aussieht)
          else
            write(feld, ' '); // Für den Rest ein Leerzeichen als Padding
        end;

        writeln;
      end;
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