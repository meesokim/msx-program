; bdos.inc : MSX-DOS システムコール
;



; マクロの定義
;

; システムコールアドレス
BDOS        =   0x0005

; TPA アドレス
TPA         =   0x0006

; システムコール
INIDOS      =   0x00            ; システムリセット
GETCON      =   0x01            ; コンソール入力
PUTCON      =   0x02            ; コンソール出力
GETAUX      =   0x03            ; 外部入力
PUTAUX      =   0x04            ; 外部出力
PUTLPT      =   0x05            ; プリンタ出力
IODCN       =   0x06            ; 直接コンソール入出力
GETDCN1     =   0x07            ; 直接コンソール入力その１
GETDCN2     =   0x08            ; 直接コンソール入力その２
PUTSTR      =   0x09            ; 文字列出力
GETSTR      =   0x0a            ; 文字列入力
CHKCON      =   0x0b            ; コンソールの状態チェック
GETVER      =   0x0c            ; バージョン番号の取得
RSTDSK      =   0x0d            ; ディスクリセット
CHGDRV      =   0x0e            ; デフォルト・ドライブの変更
OPNFCB      =   0x0f            ; ファイルのオープン
CLSFCB      =   0x10            ; ファイルのクローズ
FNDFCB1     =   0x11            ; ファイルの検索その１
FNDFCB2     =   0x12            ; ファイルの検索その２
DELFCB      =   0x13            ; ファイルの抹消
SRDFCB      =   0x14            ; シーケンシャルな読み出し
SWRFCB      =   0x15            ; シーケンシャルな書き出し
CRTFCB      =   0x16            ; ファイルの作成
RENFCB      =   0x17            ; ファイル名の変更
GETLGV      =   0x18            ; ログイン・ベクトルの獲得
GETDRV      =   0x19            ; デフォルト・ドライブの獲得
SETDMA      =   0x1a            ; 転送先アドレスの設定
GETDSK      =   0x1b            ; ディスク情報の獲得
RRDFCB      =   0x21            ; ランダムな読み出し
RWRFCB      =   0x22            ; ランダムな書き出し
GETLEN      =   0x23            ; ファイルサイズの獲得
SETREC      =   0x24            ; ランダムレコード・フィールドの設定
RWRREC      =   0x26            ; ランダムな書き込みその２
RRDREC      =   0x27            ; ランダムな読み出しその２
FILREC      =   0x28            ; ランダムな書き込みその３
GETDAT      =   0x2a            ; 日付の獲得
SETDAT      =   0x2b            ; 日付の設定
GETTIM      =   0x2c            ; 時刻の獲得
SETTIM      =   0x2d            ; 時刻の設定
SETVFY      =   0x2e            ; ベリファイ・フラグの設定
ARDSEC      =   0x2f            ; 論理セクタを用いた読み出し
AWRSEC      =   0x30            ; 論理セクタを用いた書き込み


