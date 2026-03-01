/*=============================================================================+
 * Compilation steps (use BUILD):                                              +
 *=============================================================================+
 * *> CRTCMD CMD(&O/&ON) PGM(*LIBL/CVTRPGFREC) SRCFILE(&L/&F)            -  <* +
 * *>        MODE(*ALL) ALLOW(*ALL)                                      -  <* +
 * *>        HLPPNLGRP(CVTRPGFREH) HLPID(*CMD)                           -  <* +
 * *>        TEXT(&X)                                                       <* +
 *============================================================================*/
/*==================================================================*/
/*   Programmer: Ewarwoowar                                         */
/*   Date      : 08/05/15                                           */
/*                                                                  */
/*   Function  : Converts an RPG/ILE fixed-format source to         */
/*               free-format.                                       */
/*                                                                  */
/*   CPP       : CVTRPGFREC                                         */
/*                                                                  */
/********************************************************************/
             CMD        PROMPT('Convert RPG/ILE to Free-form')

             PARM       KWD(FROMMBR) TYPE(*NAME) SPCVAL((*ALL)) MIN(1) +
                          PROMPT('From member')

             PARM       KWD(FROMFILE) TYPE(FRMFILE) PROMPT('From file')
 FRMFILE:    QUAL       TYPE(*NAME) DFT(QRPGLESRC) SPCVAL((QRPGLESRC)) +
                          EXPR(*YES)
             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*CURLIB) (*LIBL)) +
                          EXPR(*YES) PROMPT('Library')

             PARM       KWD(TOFILE) TYPE(TOFILE) PROMPT('To file')
 TOFILE:     QUAL       TYPE(*NAME) LEN(10) DFT(QRPGLESRC)
             QUAL       TYPE(*NAME) DFT(*FROMLIB) SPCVAL((*FROMLIB) +
                          (*CURLIB) (*LIBL)) PROMPT('Library')

             PARM       KWD(TOMBR) TYPE(*NAME) DFT(*FROMMBR) +
                          SPCVAL((*FROMMBR)) PROMPT('To member')


             PARM       KWD(INDINC) TYPE(*DEC) LEN(1) RSTD(*YES) DFT(3) +
                          VALUES(2 3 4) CHOICEPGM(*NONE) PMTCTL(*PMTRQS) +
                          PROMPT('Indentation increment')

             PARM       KWD(INDCMT) TYPE(*CHAR) LEN(1) RSTD(*YES) DFT(Y) VALUES(Y N) +
                          PMTCTL(*PMTRQS) PROMPT('Indent comments?')

             PARM       KWD(RETBLKCMT) TYPE(*CHAR) LEN(1) RSTD(*YES) DFT(N) VALUES(Y N) +
                          PMTCTL(*PMTRQS) PROMPT('Retain blank comment markers?')

             PARM       KWD(RMVCMTEND) TYPE(*CHAR) LEN(1) RSTD(*YES) DFT(Y) VALUES(Y N) +
                          PMTCTL(*PMTRQS) PROMPT('Remove comment end markers?')

             PARM       KWD(RMVNONPRT) TYPE(*CHAR) LEN(1) RSTD(*YES) DFT(Y) VALUES(Y N) +
                          PMTCTL(*PMTRQS) PROMPT('Remove non-printable chars?')

             PARM       KWD(DIRECTIVES) TYPE(*CHAR) LEN(1) RSTD(*YES) DFT(N) VALUES(Y N) +
                          PMTCTL(*PMTRQS) PROMPT('Use /Free compiler directives?')

             PARM       KWD(CNVMOVE) TYPE(*CHAR) LEN(1) RSTD(*YES) DFT(Y) +
                          VALUES(Y N) CASE(*MONO) PMTCTL(*PMTRQS) +
                          PROMPT('Convert MOVE statements?')

             PARM       KWD(CNVKLIST) TYPE(*CHAR) LEN(1) RSTD(*YES) DFT(Y) VALUES(Y N) +
                          CASE(*MONO) PMTCTL(*PMTRQS) PROMPT('Convert Key Lists?')

             PARM       KWD(RETKLIST) TYPE(*CHAR) LEN(1) RSTD(*YES) DFT(Y) VALUES(Y N) +
                          CASE(*MONO) PMTCTL(*PMTRQS) PROMPT('Retain converted Key Lists?')

             PARM       KWD(CNVPLIST) TYPE(*CHAR) LEN(1) RSTD(*YES) DFT(Y) VALUES(Y N) +
                          CASE(*MONO) PMTCTL(*PMTRQS) PROMPT('Convert Parameter Lists?')

             PARM       KWD(RETPLIST) TYPE(*CHAR) LEN(1) RSTD(*YES) DFT(Y) VALUES(Y N) +
                          CASE(*MONO) PMTCTL(*PMTRQS) PROMPT('Retain converted Parm Lists?')

             PARM       KWD(SUPCNVMSGS) TYPE(*CHAR) LEN(1) RSTD(*YES) DFT(N) VALUES(Y N) +
                          CASE(*MONO) PMTCTL(*PMTRQS) PROMPT('Suppress conversion messages?')

             PARM       KWD(OPCODECASE) TYPE(*CHAR) LEN(6) RSTD(*YES) DFT(*MIXED) +
                          SPCVAL((*UPPER) (*LOWER) (*MIXED)) PMTCTL(*PMTRQS) PROMPT('Op-code +
                          case')

             PARM       KWD(CNVFULL) TYPE(*CHAR) LEN(1) RSTD(*YES) DFT(N) VALUES(Y N) +
                          CASE(*MONO) PROMPT('Convert to fully-free?')

             PARM       KWD(RTNLINMKR) TYPE(*CHAR) LEN(1) RSTD(*YES) DFT(N) VALUES(Y N) +
                          CASE(*MONO) PMTCTL(PMTCNVFULL) PROMPT('Retain line markers?')

             PARM       KWD(LOGCNV) TYPE(*CHAR) LEN(1) RSTD(*YES) DFT(Y) VALUES(Y N) +
                          PMTCTL(*PMTRQS) PROMPT('Log conversion?')

 PMTCNVFULL: PMTCTL     CTL(CNVFULL) COND((*EQ 'Y'))

