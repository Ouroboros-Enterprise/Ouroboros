program Ouroboros;

uses
  snake;
  map;

begin+
  var snake := TSnake.Create();

  while True do
  begin
    gameMap.Display;
    snake.Move;
    Sleep(200); // Adjust the speed of the game
  end;
end.