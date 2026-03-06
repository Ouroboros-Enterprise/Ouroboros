program Ouroboros;

uses
  snake;
  game;

var
  game: TGame;
  Ch: Char;
  started: Boolean = False;
  AX, AY: Integer;

begin
  Randomize;
  AX := Random(20);
  AY := Random(20);
  game := TGame.Create(AX, AY);

  while not started do
  begin
    if KeyPressed then
      begin
        Ch := ReadKey;
        case Ch of
          ' ', #13: begin game.Start(); started := True end;
      end;
    end; 
  end;
end. 

{
komisch, vorher gings
}