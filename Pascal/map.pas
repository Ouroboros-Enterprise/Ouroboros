unit map;

interface


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