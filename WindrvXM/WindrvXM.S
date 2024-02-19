*
*	X68k Emulator Host Filesystem Driver version 0.27+boot
*	Programmed By co
*	Boot driver support by Y.Nakamura
*

	CPU	68010

	INCLUDE	DOSCALL.MAC
	INCLUDE IOCSCALL.MAC

WINXM_PORT0	EQU	$E9F000
WINXM_PORT1	EQU	$E9F001

SYSTEM_PORT7	EQU	$E8E00D

COMMAND	EQU	2	コマンド番号
ERRLOW	EQU	3	エラーコード下位8ビット
ERRHIGH	EQU	4	エラーコード上位8ビット
MXUNIT	EQU	13	ユニット数
DEVEND	EQU	14	ドライバ終了アドレス
BDEVNO	EQU	22	ベースドライブ番号

DDHEADER:
	DC.L	-1		+$00	リンクポインタ
	DC.W	$2040		+$04	デバイス属性
	DC.L	DDSTRATEGY	+$06
	DC.L	DDENTRY_FIRST	+$0A
DDNAME:
	DC.B	$01,'SCHDISK'	+$0E	デバイス名 (この名前でないと登録できない)
*	DC.B	'*EMUHOST'	+$0E	デバイス名

BOOTPART:
	DC.B	0			起動パーティション番号(SCSI BOOTROMが書き込む)
SCSIID:
	DC.B	0			SCSI ID + 1(デバイスドライバ初期化時のD2レジスタの値)

DDREQUEST:
	DC.L	0

DDSTRATEGY:
	MOVE.L	A6,-(SP)
	LEA.L	DDREQUEST(PC),A6
	MOVE.L	A5,(A6)
	MOVE.L	(SP)+,A6
	RTS

*デバイスドライバエントリ
DDENTRY:
	MOVE.L	A0,-(SP)
	MOVE.L	A5,-(SP)
	MOVEA.L	DDREQUEST(PC),A5	A5.L: リクエストヘッダアドレス
	MOVEA.L	#WINXM_PORT1,A0		A0.L: ポート1

*コマンド実行開始およびWindrvXMハンドル獲得
@@	SF.B	(A0)			WindrvXM Execute (Write $00, In:なし Out:D0.L)
	TST.L	D0			正しいハンドル値(正の値)が返るまでリトライ
	BMI	@B			ここは素通りする確率のほうが高い
	MOVEA.L	(SP)+,A5

*WindrvXMコマンド実行完了待ち
@@	TST.B	(A0)			WindrvXM Status (Read, In:D0.L Out:Z/NZ)
	BEQ	@B			実行完了(0以外の値が返る)までリトライ

*WindrvXMハンドル解放
	ST.B	(A0)			WindrvXM Release (Write $FF, In:D0.L Out:なし)

	MOVEA.L	(SP)+,A0
	RTS

KEEP_HERE:

*WINDRV互換 デバイスドライバエントリ
DDENTRY_COMPATIBLE:
	MOVEM.L	A0/A5,-(SP)
	MOVEA.L	DDREQUEST(PC),A5	A5.L: リクエストヘッダアドレス

	MOVEA.L	#WINXM_PORT0,A0		A0.L: ポート0
	MOVEQ.L	#0,D0
	MOVE.B	COMMAND(A5),D0		D0.L: コマンド番号
	MOVE.B	D0,(A0)			WINDRV実行 (Write Any, In:A5.L/D0.B Out:Code)

	MOVE.B	D0,ERRLOW(A5)		エラーコード格納
	LSR.W	#8,D0
	MOVE.B	D0,ERRHIGH(A5)

	MOVEM.L	(SP)+,A0/A5
	RTS

KEEP_HERE_COMPATIBLE:

*BCD2桁表示
PUTBCD2:
	MOVE.B	D2,D1
	LSR.B	#4,D1
	BSR	PUTBCD1
	MOVE.B	D2,D1

*	起動時のデバイスドライバ登録ではDOS _PUTCHAR, _PRINTが使えないので
*	すべてIOCS _B_PUTC, _B_PRINTに変更する

*BCD1桁表示 (D0-D1が変化)
PUTBCD1:
	ANDI.W	#$0F,D1
	ADDI.W	#'0',D1
	IOCS	_B_PUTC
	RTS

*初回のみのデバイスドライバエントリ
DDENTRY_FIRST:
	MOVEM.L	D1-D3/A0-A2/A5,-(SP)
	LEA	DDNAME(PC),A5
	MOVE.L	#'*EMU',(A5)		デバイスドライバ名を本来のものに直す
	MOVE.L	#'HOST',4(A5)

	LEA	SCSIID(PC),A5
	MOVE.B	D2,(A5)
	SUBQ.B	#1,D2
	MOVEQ.L	#1,D0
	LSL.B	D2,D0
	OR.B	D0,$0000CEC		IOCSのSCSI ID初期化済フラグを設定

	MOVEA.L	DDREQUEST(PC),A5	A5.L: リクエストヘッダアドレス
*	CMPI.B	#$40,COMMAND(A5)	現行のHuman68kではチェック不要
*	BNE	UNSUPPORTED		エラー:	未対応

*タイトル表示
	LEA	MESSAGE_TITLE(PC),A1
	IOCS	_B_PRINT

*XM6バージョンチェック
	MOVE.W	SR,D3
	ORI.W	#$0700,SR		割り込み禁止

	MOVEA.L	#SYSTEM_PORT7,A0
	MOVE.B	#'X',(A0)
	MOVE.B	(A0),D0			D0.B: 識別コード
	MOVE.B	(A0),D1			D1.B: メジャーバージョン
	MOVE.B	(A0),D2			D2.B: マイナーバージョン

	MOVE.W	D3,SR			割り込みレベル復帰

	CMPI.B	#'6',D0
	BNE	DEVICE_CHECK

*XM6バージョン表示
	LEA	MESSAGE_XM6(PC),A1
	IOCS	_B_PRINT

	MOVE.B	D1,D3			メジャーバージョン
	LSR.B	#4,D1
	BEQ	@F
	BSR	PUTBCD1
@@	MOVE.B	D3,D1
	BSR	PUTBCD1
	MOVEQ.L	#'.',D1
	IOCS	_B_PUTC
	BSR	PUTBCD2			マイナーバージョン

	LEA	MESSAGE_XM62(PC),A1
	IOCS	_B_PRINT

*デバイスチェック
DEVICE_CHECK:
	MOVE.W	#1,-(SP)		バイトアクセス
	PEA	(SP)			転送先アドレス
	MOVE.L	#WINXM_PORT0,-(SP)	転送元アドレス
	DOS	_BUS_ERR
	ADDQ.L	#8,SP
	MOVE.B	(SP)+,D1		SPは+2される

	TST.L	D0
	BNE	NOTFOUND		エラー: デバイスが存在しません

	CMPI.B	#'W',D1			'W'判定
	BEQ	@F			WINDRV互換モード (D1=$57のビット1を利用)

	SUBI.B	#'X',D1			'X'判定
	BEQ	OFFLINE			エラー: エミュレータの設定変更が必要です

	SUBQ.B	#1,D1			'Y'判定
	BNE	UNSUPPORTED		エラー: 未対応

	IOCS	_B_SFTSNS
	MOVE.B	D0,D1			CTRLキー押下でWINDRV互換モード
@@

*常駐開始
	LEA	DDENTRY(PC),A1
	LEA	KEEP_HERE(PC),A2

	BTST.L	#1,D1
	BEQ	@F
	LEA	DDENTRY_COMPATIBLE(PC),A1
	LEA	KEEP_HERE_COMPATIBLE(PC),A2
@@

	LEA	DDHEADER+$0A(PC),A0
	MOVE.L	A1,(A0)			ドライバエントリを設定
	MOVE.L	A2,DEVEND(A5)		常駐終了アドレスを設定

	ST.B	MXUNIT(A5)		ポート未実装の判定のため負の値を設定しておく
	JSR	(A1)			ドライバエントリを実行

	TST.B	MXUNIT(A5)		ユニット数確認
	BLE	NODRIVE			エラー: ドライブがありません

	BTST.L	#1,D1
	BEQ	@F
	LEA	MESSAGE_COMPATIBLE(PC),A1	正常: WINDRV互換で
	IOCS	_B_PRINT
@@

	MOVE.B	BDEVNO(A5),D0
	MOVE.B	MXUNIT(A5),D1
	LEA	FIRSTDRIVE(PC),A0
	ADD.B	D0,(A0)			開始ドライブ名書き換え
	ADD.B	D1,D0			終了ドライブ名書き換え
	ADD.B	D0,LASTDRIVE-FIRSTDRIVE(A0)

	LEA	MESSAGE_DRIVENAME(PC),A1	正常: ドライブA:
	IOCS	_B_PRINT

	LEA	MESSAGE_DRIVENAME2(PC),A1	正常: からZ:
	SUBQ.B	#2,D1
	BCS	@F
	IOCS	_B_PRINT
@@

	LEA	MESSAGE_DRIVENAME3(PC),A1	正常: を登録しました
	BRA	QUIT

NOTFOUND:
	LEA	MESSAGE_NOTFOUND(PC),A1		エラー: デバイスが存在しません
	BRA	ABORT

OFFLINE:
	LEA	MESSAGE_OFFLINE(PC),A1		エラー: エミュレータの設定変更が必要です
	BRA	ABORT

UNSUPPORTED:
	LEA	MESSAGE_UNSUPPORTED(PC),A1	エラー: 未対応
	BRA	ABORT

NODRIVE:
	LEA	MESSAGE_NODRIVE(PC),A1		エラー: ドライブがありません

ABORT:
	MOVE.B	#$0D,ERRLOW(A5)
	MOVE.B	#$70,ERRHIGH(A5)

QUIT:
	IOCS	_B_PRINT

	MOVE.B	BOOTPART(PC),BDEVNO(A5)	起動するパーティション番号をHuman68kに渡す

	CLR.B	COMMAND(A5)		Human68kバグのワークアラウンド
*					(リモートドライブの初期化後にローカルドライブを初期化するとクラッシュ)

	MOVEM.L	(SP)+,D1-D3/A0-A2/A5
	RTS

SECRET:
	PEA	MESSAGE_TITLE2(PC)
	DOS	_PRINT
	PEA	CREDIT(PC)
	DOS	_PRINT
	ADDQ.L	#8,SP
	DOS	_EXIT

	DATA

*エラーメッセージ
MESSAGE_NOTFOUND:
	DC.B	'デバイスが存在しません',$0D,$0A,0

MESSAGE_OFFLINE:
	DC.B	'エミュレータの設定変更が必要です',$0D,$0A,0

MESSAGE_UNSUPPORTED:
	DC.B	'未対応',$0D,$0A,0

MESSAGE_NODRIVE:
	DC.B	'ドライブがありません',$0D,$0A,0

*XM6認識メッセージ
MESSAGE_XM6:
	DC.B	'XM6 version ',0
MESSAGE_XM62:
	DC.B	' が利用可能です',$0D,$0A,0

*登録メッセージ
MESSAGE_COMPATIBLE:
	DC.B	'WINDRV互換で',0

MESSAGE_DRIVENAME:
	DC.B	'ドライブ'
FIRSTDRIVE:
	DC.B	'@:',0			(起動時ドライバ組み込みで渡されるドライブ番号は1から始まる)
MESSAGE_DRIVENAME2:
	DC.B	'から'
LASTDRIVE:
	DC.B	'?:',0			(起動時ドライバ組み込みで渡されるドライブ番号は1から始まる)
MESSAGE_DRIVENAME3:
	DC.B	'を登録しました',$0D,$0A,0

*タイトル
MESSAGE_TITLE:
	DC.B	$0D,$0A
MESSAGE_TITLE2:
	DC.B	'エミュレータ拡張 DRIVER for X680x0 version 0.27+boot',$0D,$0A,0

*ありがとう！
CREDIT:
	DC.B	'Coded by co',$0D,$0A
	DC.B	'Boot driver support by Y.Nakamura',$0D,$0A
	DC.B	'Special thanks to',$0D,$0A
	DC.B	9,'ＰＩ．',$0D,$0A
	DC.B	9,'立花＠桑島技研',$0D,$0A
	DC.B	0

	BSS

	END	SECRET
