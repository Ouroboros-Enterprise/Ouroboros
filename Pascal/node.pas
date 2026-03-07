{$mode objfpc}
unit node;

interface

type
  TNode = class
    protected
      FX: integer;  // von 0 bis 19, <0 und >=20 sind Rand (schlange verreckt)
      FY: integer;
      FNext: TNode;
    public
      constructor Create(AX, AY: integer; ANext: TNode);
  
  
      property X: integer read FX write FX;
      property Y: integer read FY write FY;
      property Next: TNode read FNext write FNext;
  end;

implementation
  constructor TNode.Create(AX, AY: integer; ANext: TNode);
  begin
    FX := AX;
    FY := AY;
    FNext := ANext;
  end;
end.