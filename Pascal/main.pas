program Ouroboros;

uses
  crt,
  snake,
  game;

var
  MyGame: TGame;
  Ch: Char;
  started: Boolean = False;
  AX, AY: Integer;

begin
  Randomize;
  AX := Random(20);
  AY := Random(20);
  
  MyGame := TGame.Create(AX, AY);

  while not started do
  begin
    if KeyPressed then
      begin // Kansnt wieder was pullen. Hab noch gerade eben was geändert. Jetzt ist au
        Ch := ReadKey;
        case Ch of
          ' ', #13: begin MyGame.Start(); started := True end;
      end;
    end; 
  end;
end. 

{
komisch, vorher gings
}