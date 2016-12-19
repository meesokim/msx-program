unit FmfMap;

{-----------------------------------------------------------------------------
TFmfMap�̎g����

procedure TForm1.FormPaint(Sender : TObject);
var
  Map : TFmfMap;
  i, X, Y : Integer;
begin

  Map := TFmfMap.Create('test.fmf');
  if not Map.IsOpen then Exit;

  // �܂���
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
  FMF�t�@�C���w�b�_�[(20byte)
------------------------------------------------------------------------------}
type TFmfHeader = packed Record
  Identifier: LongWord; // �t�@�C���^�C�v���ʎq '_FMF'
  Size:       LongWord; // �T�C�Y
  Width:      LongWord; // �}�b�v�̉���
  Height:     LongWord; // �}�b�v�̏c��
  CWidth:	  Byte;     // �`�b�v�̉���
  CHeight:	  Byte;     // �`�b�v�̏c��
  LayerCount: Byte;     // ���C���[�̐�
  BitCount:   Byte;     // �����f�[�^�̃r�b�g�J�E���g
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
  �R���X�g���N�^
------------------------------------------------------------------------------}
constructor TFmfMap.Create();
begin
end;
constructor TFmfMap.Create(const Path: String);
begin
  Open(Path);
end;

{------------------------------------------------------------------------------
  �f�X�g���N�^
------------------------------------------------------------------------------}
destructor TFmfMap.Free();
begin
  Close;
end;


{------------------------------------------------------------------------------
  �}�b�v���J��
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
  �}�b�v���J����Ă��邩?
------------------------------------------------------------------------------}
function TFmfMap.IsOpen(): Boolean;
begin
  Result := (Length(Data) > 0);
end;
{------------------------------------------------------------------------------
  �}�b�v�����
------------------------------------------------------------------------------}
procedure TFmfMap.Close();
begin
  Finalize(Data);
  FillChar(FHeader, sizeof(FHeader), 0);
end;

{------------------------------------------------------------------------------
  �w����W�̃}�b�v�l���擾
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
    {���̊֐��̖߂�l��z��̓Y�����Ƃ��Ē��ڎg�������Ȃ�
    �G���[�R�[�h�Ƃ��Ďg�p���Ȃ����̐�����Ԃ����A��O�𑗏o�����������S}
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
  �w����W�̃}�b�v�l��ݒ�
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
  �w�背�C���[�̃|�C���^�ʒu���擾
------------------------------------------------------------------------------}
function TFmfMap.GetLayer(LayerIndex : Byte): Pointer;
begin
  if LayerIndex >= FHeader.layerCount then
    Result := Nil
  else
    Result := @Data[FHeader.Width * FHeader.Height * LayerIndex * FHeader.BitCount div 8];
end;

end.
