*
*	X68k Emulator Host Filesystem Driver version 0.27
*	Programmed By co
*

	CPU	68010

	INCLUDE	DOSCALL.MAC
	INCLUDE IOCSCALL.MAC

WINXM_PORT0	EQU	$E9F000
WINXM_PORT1	EQU	$E9F001

SYSTEM_PORT7	EQU	$E8E00D

COMMAND	EQU	2	�R�}���h�ԍ�
ERRLOW	EQU	3	�G���[�R�[�h����8�r�b�g
ERRHIGH	EQU	4	�G���[�R�[�h���8�r�b�g
MXUNIT	EQU	13	���j�b�g��
DEVEND	EQU	14	�h���C�o�I���A�h���X
BDEVNO	EQU	22	�x�[�X�h���C�u�ԍ�

DDHEADER:
	DC.L	-1		+$00	�����N�|�C���^
	DC.W	$2040		+$04	�f�o�C�X����
	DC.L	DDSTRATEGY	+$06
	DC.L	DDENTRY_FIRST	+$0A
	DC.B	'*EMUHOST'	+$0E	�f�o�C�X��

DDREQUEST:
	DC.L	0

DDSTRATEGY:
	MOVE.L	A5,DDREQUEST
	RTS

*�f�o�C�X�h���C�o�G���g��
DDENTRY:
	MOVE.L	A0,-(SP)
	MOVE.L	A5,-(SP)
	MOVEA.L	DDREQUEST(PC),A5	A5.L: ���N�G�X�g�w�b�_�A�h���X
	MOVEA.L	#WINXM_PORT1,A0		A0.L: �|�[�g1

*�R�}���h���s�J�n�����WindrvXM�n���h���l��
@@	SF.B	(A0)			WindrvXM Execute (Write $00, In:�Ȃ� Out:D0.L)
	TST.L	D0			�������n���h���l(���̒l)���Ԃ�܂Ń��g���C
	BMI	@B			�����͑f�ʂ肷��m���̂ق�������
	MOVEA.L	(SP)+,A5

*WindrvXM�R�}���h���s�����҂�
@@	TST.B	(A0)			WindrvXM Status (Read, In:D0.L Out:Z/NZ)
	BEQ	@B			���s����(0�ȊO�̒l���Ԃ�)�܂Ń��g���C

*WindrvXM�n���h�����
	ST.B	(A0)			WindrvXM Release (Write $FF, In:D0.L Out:�Ȃ�)

	MOVEA.L	(SP)+,A0
	RTS

KEEP_HERE:

*WINDRV�݊� �f�o�C�X�h���C�o�G���g��
DDENTRY_COMPATIBLE:
	MOVEM.L	A0/A5,-(SP)
	MOVEA.L	DDREQUEST(PC),A5	A5.L: ���N�G�X�g�w�b�_�A�h���X

	MOVEA.L	#WINXM_PORT0,A0		A0.L: �|�[�g0
	MOVEQ.L	#0,D0
	MOVE.B	COMMAND(A5),D0		D0.L: �R�}���h�ԍ�
	MOVE.B	D0,(A0)			WINDRV���s (Write Any, In:A5.L/D0.B Out:Code)

	MOVE.B	D0,ERRLOW(A5)		�G���[�R�[�h�i�[
	LSR.W	#8,D0
	MOVE.B	D0,ERRHIGH(A5)

	MOVEM.L	(SP)+,A0/A5
	RTS

KEEP_HERE_COMPATIBLE:

*BCD2���\��
PUTBCD2:
	MOVE.B	D2,D1
	LSR.B	#4,D1
	BSR	PUTBCD1
	MOVE.B	D2,D1

*BCD1���\�� (D0-D1���ω�)
PUTBCD1:
	ANDI.W	#$0F,D1
	ADDI.W	#'0',D1
	MOVE.W	D1,-(SP)
	DOS	_PUTCHAR
	ADDQ.L	#2,SP
	RTS

*����݂̂̃f�o�C�X�h���C�o�G���g��
DDENTRY_FIRST:
	MOVEM.L	D1-D3/A0-A2/A5,-(SP)
	MOVEA.L	DDREQUEST(PC),A5	A5.L: ���N�G�X�g�w�b�_�A�h���X
*	CMPI.B	#$40,COMMAND(A5)	���s��Human68k�ł̓`�F�b�N�s�v
*	BNE	UNSUPPORTED		�G���[:	���Ή�

*�^�C�g���\��
	PEA	MESSAGE_TITLE(PC)
	DOS	_PRINT
	ADDQ.L	#4,SP

*XM6�o�[�W�����`�F�b�N
	MOVE.W	SR,D3
	ORI.W	#$0700,SR		���荞�݋֎~

	MOVEA.L	#SYSTEM_PORT7,A0
	MOVE.B	#'X',(A0)
	MOVE.B	(A0),D0			D0.B: ���ʃR�[�h
	MOVE.B	(A0),D1			D1.B: ���W���[�o�[�W����
	MOVE.B	(A0),D2			D2.B: �}�C�i�[�o�[�W����

	MOVE.W	D3,SR			���荞�݃��x�����A

	CMPI.B	#'6',D0
	BNE	DEVICE_CHECK

*XM6�o�[�W�����\��
	PEA	MESSAGE_XM6(PC)
	DOS	_PRINT

	MOVE.B	D1,D3			���W���[�o�[�W����
	LSR.B	#4,D1
	BEQ	@F
	BSR	PUTBCD1
@@	MOVE.B	D3,D1
	BSR	PUTBCD1
	MOVE.W	#'.',-(SP)
	DOS	_PUTCHAR
	ADDQ.L	#2,SP
	BSR	PUTBCD2			�}�C�i�[�o�[�W����

	PEA	MESSAGE_XM62(PC)
	DOS	_PRINT
	ADDQ.L	#8,SP

*�f�o�C�X�`�F�b�N
DEVICE_CHECK:
	MOVE.W	#1,-(SP)		�o�C�g�A�N�Z�X
	PEA	(SP)			�]����A�h���X
	MOVE.L	#WINXM_PORT0,-(SP)	�]�����A�h���X
	DOS	_BUS_ERR
	ADDQ.L	#8,SP
	MOVE.B	(SP)+,D1		SP��+2�����

	TST.L	D0
	BNE	NOTFOUND		�G���[: �f�o�C�X�����݂��܂���

	CMPI.B	#'W',D1			'W'����
	BEQ	@F			WINDRV�݊����[�h (D1=$57�̃r�b�g1�𗘗p)

	SUBI.B	#'X',D1			'X'����
	BEQ	OFFLINE			�G���[: �G�~�����[�^�̐ݒ�ύX���K�v�ł�

	SUBQ.B	#1,D1			'Y'����
	BNE	UNSUPPORTED		�G���[: ���Ή�

	IOCS	_B_SFTSNS
	MOVE.B	D0,D1			CTRL�L�[������WINDRV�݊����[�h
@@

*�풓�J�n
	LEA	DDENTRY(PC),A1
	LEA	KEEP_HERE(PC),A2

	BTST.L	#1,D1
	BEQ	@F
	LEA	DDENTRY_COMPATIBLE(PC),A1
	LEA	KEEP_HERE_COMPATIBLE(PC),A2
@@

	LEA	DDHEADER+$0A(PC),A0
	MOVE.L	A1,(A0)			�h���C�o�G���g����ݒ�
	MOVE.L	A2,DEVEND(A5)		�풓�I���A�h���X��ݒ�

	ST.B	MXUNIT(A5)		�|�[�g�������̔���̂��ߕ��̒l��ݒ肵�Ă���
	JSR	(A1)			�h���C�o�G���g�������s

	TST.B	MXUNIT(A5)		���j�b�g���m�F
	BLE	NODRIVE			�G���[: �h���C�u������܂���

	BTST.L	#1,D1
	BEQ	@F
	PEA	MESSAGE_COMPATIBLE(PC)	����: WINDRV�݊���
	DOS	_PRINT
	ADDQ.L	#4,SP
@@

	MOVE.B	BDEVNO(A5),D0
	MOVE.B	MXUNIT(A5),D1
	LEA	FIRSTDRIVE(PC),A0
	ADD.B	D0,(A0)			�J�n�h���C�u����������
	ADD.B	D1,D0			�I���h���C�u����������
	ADD.B	D0,LASTDRIVE-FIRSTDRIVE(A0)

	PEA	MESSAGE_DRIVENAME(PC)	����: �h���C�uA:
	DOS	_PRINT

	PEA	MESSAGE_DRIVENAME2(PC)	����: ����Z:
	SUBQ.B	#2,D1
	BCS	@F
	DOS	_PRINT
@@	ADDQ.L	#8,SP

	PEA	MESSAGE_DRIVENAME3(PC)	����: ��o�^���܂���
	BRA	QUIT

NOTFOUND:
	PEA	MESSAGE_NOTFOUND(PC)	�G���[: �f�o�C�X�����݂��܂���
	BRA	ABORT

OFFLINE:
	PEA	MESSAGE_OFFLINE(PC)	�G���[: �G�~�����[�^�̐ݒ�ύX���K�v�ł�
	BRA	ABORT

UNSUPPORTED:
	PEA	MESSAGE_UNSUPPORTED(PC)	�G���[: ���Ή�
	BRA	ABORT

NODRIVE:
	PEA	MESSAGE_NODRIVE(PC)	�G���[: �h���C�u������܂���

ABORT:
	MOVE.B	#$0D,ERRLOW(A5)
	MOVE.B	#$70,ERRHIGH(A5)

QUIT:
	DOS	_PRINT
	ADDQ.L	#4,SP

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

*�G���[���b�Z�[�W
MESSAGE_NOTFOUND:
	DC.B	'�f�o�C�X�����݂��܂���',$0D,$0A,0

MESSAGE_OFFLINE:
	DC.B	'�G�~�����[�^�̐ݒ�ύX���K�v�ł�',$0D,$0A,0

MESSAGE_UNSUPPORTED:
	DC.B	'���Ή�',$0D,$0A,0

MESSAGE_NODRIVE:
	DC.B	'�h���C�u������܂���',$0D,$0A,0

*XM6�F�����b�Z�[�W
MESSAGE_XM6:
	DC.B	'XM6 version ',0
MESSAGE_XM62:
	DC.B	' �����p�\�ł�',$0D,$0A,0

*�o�^���b�Z�[�W
MESSAGE_COMPATIBLE:
	DC.B	'WINDRV�݊���',0

MESSAGE_DRIVENAME:
	DC.B	'�h���C�u'
FIRSTDRIVE:
	DC.B	'A:',0
MESSAGE_DRIVENAME2:
	DC.B	'����'
LASTDRIVE:
	DC.B	'@:',0
MESSAGE_DRIVENAME3:
	DC.B	'��o�^���܂���',$0D,$0A,0

*�^�C�g��
MESSAGE_TITLE:
	DC.B	$0D,$0A
MESSAGE_TITLE2:
	DC.B	'�G�~�����[�^�g�� DRIVER for X680x0 version 0.27',$0D,$0A,0

*���肪�Ƃ��I
CREDIT:
	DC.B	'Coded by co',$0D,$0A
	DC.B	'Special thanks to',$0D,$0A
	DC.B	9,'�o�h�D',$0D,$0A
	DC.B	9,'���ԁ��K���Z��',$0D,$0A
	DC.B	0

	BSS

	END	SECRET