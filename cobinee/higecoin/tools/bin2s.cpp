// 参照ファイルのインクルード
//
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>



// メインプログラムのエントリ
//
int main(int argc, const char *argv[])
{
    // 入力ファイル名の初期化
    const char *inname = NULL;
    
    // 出力ファイル名の初期化
    const char *outname = NULL;
    
    // 出力ファイルサイズの初期化
    int outsize = 0;

    // 名前の初期化
    const char *name = NULL;
    
    // 引数の取得
    while (--argc > 0) {
        ++argv;
        if (strcasecmp(*argv, "-o") == 0) {
            outname = *++argv;
            --argc;
        } else if (strcasecmp(*argv, "-s") == 0) {
            outsize = atoi(*++argv);
            --argc;
        } else if (strcasecmp(*argv, "-n") == 0) {
            name = *++argv;
            --argc;
        } else {
            inname = *argv;
        }
    }
    
    // 入力ファイルがない
    if (inname == NULL) {
        return -1;
    }
    
    // 入力ファイルを開く
    FILE *infile = fopen(inname, "rb");
    
    // 出力ファイルを開く
    FILE *outfile = outname != NULL ? fopen(outname, "w") : stdout;
    
    // ファイルサイズの取得
    if (outsize == 0) {
        fseek(infile, 0, SEEK_END);
        outsize = ftell(infile);
        fseek(infile, 0, SEEK_SET);
    }
    
    // ヘッダの出力
    fprintf(outfile, "; %s\n;\n\n", inname);
    
    // ラベルの出力
    if (name != NULL) {
        fprintf(outfile, "    .module %s\n", name);
        fprintf(outfile, "    .area   _CODE\n\n");
        fprintf(outfile, "_%s::\n\n", name);
    }
    
    // ファイルの読み込み
    int insize = 0;
    int c = 0;
    while ((c = fgetc(infile)) != EOF && insize < outsize) {
        if (insize % 16 == 0) {
            fprintf(outfile, "    .db     ");
        }
        fprintf(outfile, "0x%02x", c);
        if (insize % 16 < 15 && insize < outsize - 1) {
            fprintf(outfile, ", ");
        } else {
            fprintf(outfile, "\n");
        }
        ++insize;
    }
    
    // フッタの出力
    fprintf(outfile, "\n\n");
    
    // 出力ファイルを閉じる
    if (outfile != stdout) {
        fclose(outfile);
    }
    
    // 入力ファイルを閉じる
    fclose(infile);

    // 終了
    return 0;
}


