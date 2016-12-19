unit FmfMap;

{-----------------------------------------------------------------------------
TFmfMapの使い方

procedure TForm1.FormPaint(Sender : TObject);
var
  Map : TFmfMap;
  i, X, Y : Integer;
begin

  Map := TFmfMap.Create('test.fmf');
  if not Map.IsOpen then Exit;

  // または
  // Map := TFmfMap.Create;
  // if not Map.Open('test.fmf') then Exit;

  for i := 1 to Map.LayerCount - 1 do begin
    for Y := 0 to Map.Height - 1 do begin
      for X := 0 to Map.Width - 1 do begin
        with Canvas do begin
          Canvas.TextOut(X * 32, Y * 32, IntToStr(Map.GetValue(i, X, Y)));
        end;
      end;
    end;
  end;
  
  map.Free;
end;

------------------------------------------------------------------------------}

interface

uses
  SysUtils, Classes;

{-----------------------------------------------------------------------------
  FMFファイルヘッダー(20byte)
------------------------------------------------------------------------------}
type TFmfHeader = packed Record
  Identifier: LongWord; // ファイルタイプ識別子 '_FMF'
  Size:       LongWord; // サイズ
  Width:      LongWord; // マップの横幅
  Height:     LongWord; // マップの縦幅
  CWidth:	  Byte;     // チップの横幅
  CHeight:	  Byte;     // チップの縦幅
  LayerCount: Byte;     // レイヤーの数
  BitCount:   Byte;     // 内部データのビットカウント
  end;

{------------------------------------------------------------------------------
  TFmfMap
------------------------------------------------------------------------------}
type TFmfMap = class(TObject)
  constructor Create(); overload;
  constructor Create(const Path : String); overload;
  destructor Free();

  function Open(const Path: String): Boolean;
  function IsOpen(): Boolean;
  procedure Close();

  function GetValue(LayerIndex : Byte; X, Y : LongWord): Integer;
  procedure SetValue(LayerIndex : Byte; X, Y : LongWord; Value : Integer);

  function GetLayer(LayerIndex : Byte): Pointer;

  private
    FHeader: TFmfHeader;
    Data: Array of Byte;

  published
    property Width:       LongWord read FHeader.Width;
    property Height:      LongWord read FHeader.Height;
    property ChipWidth:   Byte read FHeader.cWidth;
    property ChipHeight:  Byte read FHeader.cHeight;
    property LayerCount:  Byte read FHeader.layerCount;
    property BitCount:    Byte read FHeader.BitCount;

  end;

implementation

{------------------------------------------------------------------------------
  コンストラクタ
------------------------------------------------------------------------------}
constructor TFmfMap.Create();
begin
end;
constructor TFmfMap.Create(const Path: String);
begin
  Open(Path);
end;

{------------------------------------------------------------------------------
  デストラクタ
------------------------------------------------------------------------------}
destructor TFmfMap.Free();
begin
  Close;
end;


{------------------------------------------------------------------------------
  マップを開く
------------------------------------------------------------------------------}
function TFmfMap.Open(const Path: String): Boolean;
 var
  Stream: TFileStream;
  LayerSize: LongWord;
  ElemSize: LongWord;
begin

  Close;

  try
    Stream := TFileStream.Create(Path, fmOpenRead);
    Stream.ReadBuffer(FHeader, SizeOf(TFmfHeader));

    if FHeader.Identifier <> $5F464D46 then begin
      Result := False;
      Exit;
    end;

    ElemSize := FHeader.BitCount div 8;
    LayerSize := FHeader.Width * FHeader.Height * FHeader.LayerCount * ElemSize;
    SetLength(Data, LayerSize);

    Stream.ReadBuffer(Data[0], LayerSize);

  finally
    Stream.Free;
  end;

  Result := True;
end;
{------------------------------------------------------------------------------
  マップが開かれているか?
------------------------------------------------------------------------------}
function TFmfMap.IsOpen(): Boolean;
begin
  Result := (Length(Data) > 0);
end;
{------------------------------------------------------------------------------
  マップを閉じる
------------------------------------------------------------------------------}
procedure TFmfMap.Close();
begin
  Finalize(Data);
  FillChar(FHeader, sizeof(FHeader), 0);
end;

{------------------------------------------------------------------------------
  指定座標のマップ値を取得
------------------------------------------------------------------------------}
function TFmfMap.GetValue(LayerIndex : Byte; X, Y : LongWord): Integer;
var
  LayerPos: Integer;
  pBLayer: PByteArray;
  pWLayer: PWordArray;
begin

  if (LayerIndex >= FHeader.layerCount) or
     (X >= FHeader.Width) or
     (Y >= FHeader.Height) then begin
    {この関数の戻り値を配列の添え字として直接使いたいなら
    エラーコードとして使用しない正の整数を返すか、例外を送出した方が安全}
    Result := -1;
    Exit;
  end;

  LayerPos := FHeader.Width * FHeader.Height * LayerIndex * FHeader.BitCount div 8;

  if FHeader.BitCount = 8 then begin
    pBLayer := @Data[LayerPos];
    Result := pBLayer[Y * FHeader.Width + X];
  end else begin
    pWLayer := @Data[LayerPos];
    Result := pWLayer[Y * FHeader.Width + X];
  end;

end;

{------------------------------------------------------------------------------
  指定座標のマップ値を設定
------------------------------------------------------------------------------}
procedure TFmfMap.SetValue(LayerIndex : Byte; X, Y : LongWord; Value : Integer);
var
  LayerPos: Integer;
  pBLayer: PByteArray;
  pWLayer: PWordArray;  
begin
  if (LayerIndex >= FHeader.layerCount) or
     (X >= FHeader.Width) or
     (Y >= FHeader.Height) then Exit;

  LayerPos := FHeader.Width * FHeader.Height * LayerIndex * FHeader.BitCount div 8;

  if FHeader.BitCount = 8 then begin
    pBLayer := @Data[LayerPos];
    pBLayer[Y * FHeader.Width + X] := Value;
  end else begin
    pWLayer := @Data[LayerPos];
    pWLayer[Y * FHeader.Width + X] := Value;
  end;

end;

{------------------------------------------------------------------------------
  指定レイヤーのポインタ位置を取得
------------------------------------------------------------------------------}
function TFmfMap.GetLayer(LayerIndex : Byte): Pointer;
begin
  if LayerIndex >= FHeader.layerCount then
    Result := Nil
  else
    Result := @Data[FHeader.Width * FHeader.Height * LayerIndex * FHeader.BitCount div 8];
end;

end.
