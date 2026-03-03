**Free
Ctl-Opt Debug
        DftActGrp( *No ) ActGrp( *Caller )
        Option( *ShowCpy: *SrcStmt: *NoDebugIO );

//--------------------------------------------------------------------------------------------------
// Program Name. . . . . : CVTRPGFREE
// Program Description . : Convert RPGILE Source Member to Free-form
// Date Created. . . . . : 30/04/2015
// Programmer. . . . . . : Ewarwoowar
//
// Please submit any issues or requests via http://cvtrpgfree.sourceforge.net
//
//--------------------------------------------------------------------------------------------------
// SYNOPSIS :
// - Reads through an RPGILE source member and reformats the contents.
//--------------------------------------------------------------------------------------------------
/Eject
//-------------------------------------------------------------------------------------------
// F I L E S
//-------------------------------------------------------------------------------------------
Dcl-F INPSRC      DISK(256)   Usage(*INPUT:*UPDATE:*OUTPUT)
                              EXTFILE(fromFileLib)
                              EXTMBR(p_FromMbr)
                              INFDS(InpAttr)
                              USROPN;

Dcl-F OUTSRC      DISK(256)   Usage(*OUTPUT)
                              EXTFILE(toFileLib)
                              EXTMBR(p_ToMbr)
                              INFDS(OutAttr)
                              USROPN;

Dcl-F CVTRPGFRP1  PRINTER     USROPN
                              OFLIND(overFlow);

//-------------------------------------------------------------------------------------------
// P R O C E D U R E   I N T E R F A C E
//-------------------------------------------------------------------------------------------

Dcl-PR CVTRPGFRER                      EXTPGM('CVTRPGFRER');
   p_ShutDown                 Char(1)  CONST;
   p_FromFile                 Char(10) CONST;
   p_FromLib                  Char(10) CONST;
   p_FromMember               Char(10) CONST;
   p_ToFile                   Char(10) CONST;
   p_ToLib                    Char(10) CONST;
   p_ToMbr                    Char(10) CONST;
   p_IndComment               Char(1)  CONST;
   p_IndIncrement           Packed(1)  CONST;
   p_RetBlnkCmt               Char(1)  CONST;
   p_RmvCmtEnd                Char(1)  CONST;
   p_RmvNonPrint              Char(1)  CONST;
   p_Directives               Char(1)  CONST;
   p_SuppressMsgs             Char(1)  CONST;
   p_SrcFromFile              Char(10) CONST;
   p_SrcFromLib               Char(10) CONST;
   p_SrcToFile                Char(10) CONST;
   p_SrcToLib                 Char(10) CONST;
   p_ConvMOVE                 Char(1)  CONST;
   p_ConvKLIST                Char(1)  CONST;
   p_RetKLIST                 Char(1)  CONST;
   p_ConvPLIST                Char(1)  CONST;
   p_RetPLIST                 Char(1)  CONST;
   p_OpCodeCase               Char(6)  CONST;
   p_FullyFree                Char(1)  Const;
   p_RetLineMaker             Char(1)  Const;
   p_LogConversion            Char(1)  Const;
End-PR;

Dcl-PI CVTRPGFRER;
   p_ShutDown                 Char(1)  CONST;
   p_FromFile                 Char(10) CONST;
   p_FromLib                  Char(10) CONST;
   p_FromMbr                  Char(10) CONST;
   p_ToFile                   Char(10) CONST;
   p_ToLib                    Char(10) CONST;
   p_ToMbr                    Char(10) CONST;
   p_IndComment               Char(1)  CONST;
   p_IndIncrement           Packed(1)  CONST;
   p_RetBlnkCmt               Char(1)  CONST;
   p_RmvCmtEnd                Char(1)  CONST;
   p_RmvNonPrint              Char(1)  CONST;
   p_Directives               Char(1)  CONST;
   p_SuppressMsgs             Char(1)  CONST;
   p_SrcFromFile              Char(10) CONST;
   p_SrcFromLib               Char(10) CONST;
   p_SrcToFile                Char(10) CONST;
   p_SrcToLib                 Char(10) CONST;
   p_ConvMOVE                 Char(1)  CONST;
   p_ConvKLIST                Char(1)  CONST;
   p_RetKLIST                 Char(1)  CONST;
   p_ConvPLIST                Char(1)  CONST;
   p_RetPLIST                 Char(1)  CONST;
   p_OpCodeCase               Char(6)  CONST;
   p_FullyFree                Char(1)  Const;
   p_RetLineMaker             Char(1)  Const;
   p_LogConversion            Char(1)  Const;
End-PI;

//-------------------------------------------------------------------------------------------
// P R O T O T Y P E   I N T E R F A C E S
//-------------------------------------------------------------------------------------------

// Remove message API.
Dcl-PR QMHRCVPM                        ExtPgm('QMHRCVPM');
   rcvvar                     Char(32767) Options(*varsize);
   rcvvarlen                   Int(10) Const;
   format                     Char(8)  Const;
   stack                      Char(10) Const;
   stackctr                    Int(10) Const;
   type                       Char(10) Const;
   msgkey                     Char(4)  Const;
   wait                        Int(10) Const;
   action                     Char(10) Const;
   errorcode                  Char(8)  Const;
End-PR;

Dcl-DS RCVM0100        Qualified;
   msgid                      Char(7)    Pos(13);
   msgkey                     Char(4)    Pos(22);
   msgdtalen                   Int(10)   Pos(45);
   msgdta                     Char(8000) Pos(49);
End-DS;

//-------------------------------------------------------------------------------------------
// N A M E D   C O N S T A N T S
//-------------------------------------------------------------------------------------------
Dcl-C LO                        'abcdefghijklmnopqrstuvwxyz';
Dcl-C UP                        'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
Dcl-C VALIDSPECS                'HFDCP';
Dcl-C VERSION                   '1.5.07';

// SQL Return Codes
Dcl-C SQL_OK                           0;
Dcl-C SQL_EOF                        100;
Dcl-C SQL_CSROPN                    -502;
Dcl-C SQL_CSRNOTOPN                 -501;
Dcl-C SQL_RCDLOCKED                 -913;
Dcl-C SQL_TIMEOUT                   -913;

//-------------------------------------------------------------------------------------------
// D A T A   S T R U C T U R E S
//-------------------------------------------------------------------------------------------

Dcl-DS PSSRDS                         PSDS;
    QPgmName                           *PROC;
    QPgmStatus                         *STATUS;
    QPrvStatus               Zoned(5:0) Pos(16);
    QLineNum                  Char(8)  Pos(21);
    QRoutine                           *ROUTINE;
    QPgmParm                           *PARMS;
    QExcpType                 Char(3)  Pos(40);
    QExcpNum                  Char(4)  Pos(43);
    QPgmLib                   Char(10) Pos(81);
    QExcpData                 Char(80) Pos(91);
    QExcpId                   Char(4)  Pos(171);
    QDate                     Char(8)  Pos(191);
    QYear                    Zoned(2:0) Pos(199);
    QLastFile                 Char(8)  Pos(201);
    QFileInfo                 Char(34) Pos(209);
    QJobName                  Char(10) Pos(244);
    QUsrName                  Char(10) Pos(254);
    QJobNbr                   Char(6)  Pos(264);
    QJobDate                 Zoned(6:0) Pos(270);
    QRunDate                 Zoned(6:0) Pos(276);
    QRunTime                 Zoned(6:0) Pos(282);
    QCrtDate                  Char(6)  Pos(288);
    QCrtTime                  Char(6)  Pos(294);
    QCplLevel                 Char(4)  Pos(300);
    QSrcFile                  Char(10) Pos(304);
    QSrcLib                   Char(10) Pos(314);
    QSrcMbr                   Char(10) Pos(324);
    QPgmQ                     Char(10) Pos(334);
    QProcMod                  Char(10) Pos(344);
    QCurUser                  Char(10) Pos(358);
    QInternalJobId            Char(16) Pos(380);
    QSystemName               Char(8)  Pos(396);
End-DS;

Dcl-DS InpAttr               Qualified;
   RecLen                      Uns(5) Pos(125);
End-DS;

Dcl-DS OutAttr               Qualified;
   RecLen                      Uns(5) Pos(125);
End-DS;

Dcl-DS InpLine                 Len(256) Qualified;
   SRCSEQ                    Zoned(6:2);
   SRCDAT                    Zoned(6:0);
   SRCDTA                     Char(240);
End-DS;

Dcl-S ptrSRCSEQ            Pointer     Inz(%addr(InpLine.SRCSEQ));
Dcl-S ptrSRCDAT            Pointer     Inz(%addr(InpLine.SRCDAT));
Dcl-S ptrSRCDTA            Pointer     Inz(%addr(InpLine.SRCDTA));

Dcl-S SRCSEQ                 Zoned(6:2) Based(ptrSRCSEQ);
Dcl-S SRCDAT                 Zoned(6:0) Based(ptrSRCDAT);
Dcl-S SRCDTA                  Char(240) Based(ptrSRCDTA);

// Fixed format line structure.
Dcl-DS SourceData                           Based(ptrSRCDTA);
   // General.
   prefix                     Char(5)  Pos(1);
   lineType                   Char(1)  Pos(6);
   directive                  Char(10) Pos(7);
   codeLine                   Char(93) Pos(8);
   fullLine                   Char(94) Pos(7);

   // C-Spec layout.
   condCtrl                   Char(2)  Pos(7);
   condNot                    Char(1)  Pos(9);
   condInd                    Char(2)  Pos(10);
   factor1                    Char(14) Pos(12);
   opCode                     Char(10) Pos(26);
   factor2                    Char(14) Pos(36);
   result                     Char(14) Pos(50);
   len                        Char(5)  Pos(64);
   dec                        Char(2)  Pos(69);
   hi                         Char(2)  Pos(71);
   lw                         Char(2)  Pos(73);
   eq                         Char(2)  Pos(75);
   comment                    Char(20) Pos(81);

   // C-spec - extended factor2.
   extFactor2                 Char(45) Pos(36);

   nonPrefix                  Char(95) Pos(6);

   procType                   Char(1)  Pos(24);
   procKeyWords               Char(37) Pos(44);

   // D-spec and P-spec layout.
   declName                   Char(15) Pos(7);
   declExt                    Char(1)  Pos(22);
   declPrefix                 Char(1)  Pos(23);
   declType                   Char(2)  Pos(24);
   declSuffix                 Char(1)  Pos(26);
   declFrom                   Char(7)  Pos(26);
   declLen                    Char(7)  Pos(33);
   declAttr                   Char(1)  Pos(40);
   declScale                  Char(3)  Pos(41);
   declKeyWords               Char(37) Pos(44);
   declOptions                Char(73) Pos(7);

   // F-spec layout.
   fileName                   Char(10) Pos(7);
   fileUsage                  Char(1)  Pos(17);
   fileDesig                  Char(1)  Pos(18);
   fileAdd                    Char(1)  Pos(20);
   fileExternal               Char(1)  Pos(22);
   fileKeyed                  Char(1)  Pos(34);
   fileDevice                 Char(7)  Pos(36);
   fileKeywords               Char(37) Pos(44);
End-DS;

// Key Lists.
Dcl-DS parmList                         Qualified DIM(511);
   lineNumber                Zoned(6:2);
   listName                   Char(14);
   listType                   Char(5);
   listPList                  Char(14);
   listProgram                Char(14);
   parameterDef                         LikeDS(parameterDefDS_T) Dim(99);
   listOutput                  Ind;
   convert                     Ind;
End-DS;

Dcl-DS parameterDefDS_T                 Qualified Template;
   parmName                   Char(14);
   parmInput                  Char(14);
   parmOutput                 Char(14);
   parmDef                    Char(93);
End-DS;

// Extracted Key Lists.
Dcl-DS keyList                          Qualified DIM(512);
   listName                   Char(14);
   keyFields                  Char(93);
End-DS;

// TAGs found.
Dcl-DS tagList                          Qualified DIM(512);
   tagName                    Char(14);
   tagType                    Char(14);
   tagUsed                     Ind;
   tagUsageCount               Uns(3);
End-DS;

// Prototype layout.
Dcl-DS DCLPR                            QUALIFIED;
   decl                       Char(7) INZ('Dcl-PR ');
   procName                   Char(16);
   type                       Char(9);
   definition                 Char(37);
   comment                    Char(23);
   fieldName                  Char(80) Pos(4);
End-DS;

// Procedure layout.
Dcl-DS DCLP                             QUALIFIED;
   decl                       Char(9) INZ('Dcl-Proc ');
   definition                 Char(61);
   comment                    Char(23);
End-DS;

// Stand-alone layout.
Dcl-DS DCLS                             QUALIFIED;
   decl                       Char(6) INZ('Dcl-S ');                            // aaa
   fieldName                  Char(17);
   type                       Char(9);
   definition                 Char(38);
   comment                    Char(23);
End-DS;

// File layout.
Dcl-DS DCLF                     QUALIFIED;
   decl                       Char(6) INZ('Dcl-F ');
   fileName                   Char(15);
   device                     Char(8);
   definition                 Char(44);
   comment                    Char(23) Pos(70);
End-DS;

// Control Option layout.
Dcl-DS DCLH                     QUALIFIED;
   decl                       Char(8) INZ('Ctl-Opt ');
   options                    Char(72);
   comment                    Char(22);
End-DS;

// Field Dictionary.
Dcl-DS variableDef_T                   Qualified Template;
   variableName               Char(14);
   sourceLine                 Char(93);
   type                       Char(10);
   length                      Uns(5);
   scale                       Uns(5);
   move                        Ind;
End-DS;
Dcl-DS variableDef                   LikeDS(variableDef_T);
Dcl-DS constantDef                   LikeDS(variableDef_T);
Dcl-DS sourceVariable                LikeDS(variableDef_T);
Dcl-DS sourceVariable2               LikeDS(variableDef_T);
Dcl-DS targetVariable                LikeDS(variableDef_T);

Dcl-DS globalDefs                    LikeDS(variableDef_T) DIM(99999);
Dcl-DS localDefs                     LikeDS(variableDef_T) DIM(99999);

//-------------------------------------------------------------------------------------------
// S T A N D - A L O N E   V A R I A B L E S
//-------------------------------------------------------------------------------------------
Dcl-S cfgCommitControl        Char(7) INZ('*NONE  ');                  // *MASTER/*SLAVE/*NONE
Dcl-S cfgCloseDown            Char(1) INZ('N');                        // Close down program?
Dcl-S initialCall             Char(1) INZ(*Blank);
Dcl-S fullyFree                Ind    Inz(*Off);

Dcl-S opCodeUP                Char(10) DIM(66) PERRCD(1) CTDATA;
Dcl-S opCodeLO                Char(10) DIM(66) ALT(opCodeUP);
Dcl-S declUP                  Char(10) DIM(12) PERRCD(1) CTDATA;
Dcl-S declLO                  Char(10) DIM(12) ALT(declUP);
Dcl-S comments                Char(92) DIM(3) CTDATA;

Dcl-S x                     Packed(5:0);
Dcl-S y                     Packed(5:0);
Dcl-S i                     Packed(5:0);
Dcl-S j                     Packed(5:0);
Dcl-S blanks                  Char(30) INZ(*Blanks);
Dcl-S maxIndent             Packed(3:0) INZ(15);
Dcl-S keyListCount             Uns(5);
Dcl-S keyListName             Char(14);
Dcl-S parmListCount            Uns(5);
Dcl-S parmListName            Char(14);
Dcl-S tagCount                 Uns(5);
Dcl-S tagName                 Char(14);
Dcl-S seqProcDefs            Zoned(6:2) Inz(0);

Dcl-S fromFileLib             Char(21);
Dcl-S toFileLib               Char(21);

Dcl-S operator                Char(10);
Dcl-S operatorEnd           Packed(3:0);
Dcl-S newOperator          VarChar(10);
Dcl-S nonConvRsn                  LIKE(codeLine);

Dcl-S inCode                   Ind INZ(*Off);
Dcl-S inArrayData              Ind INZ(*Off);
Dcl-S inComment                Ind INZ(*Off);
Dcl-S inDeclaration            Ind INZ(*Off);
Dcl-S inConstant               Ind INZ(*Off);
Dcl-S inPrototype              Ind INZ(*Off);
Dcl-S inInterface              Ind INZ(*Off);
Dcl-S inDatastructure          Ind INZ(*Off);
Dcl-S inDatastructureDecl      Ind INZ(*Off);
Dcl-S inLineCondition          Ind INZ(*Off);
Dcl-S inPadding                Ind INZ(*Off);
Dcl-S reprocessLine            Ind INZ(*Off);
Dcl-S inMainLine               Ind INZ(*Off);

Dcl-S endDS                    Ind INZ(*Off);
Dcl-S inDirective              Ind INZ(*Off);
Dcl-S inFreeFormat             Ind INZ(*On);
Dcl-S indent                   Ind INZ(*Off);
Dcl-S inSpan                   Ind INZ(*Off);
Dcl-S inLong                   Ind INZ(*Off);
Dcl-S inContinuation           Ind INZ(*Off);
Dcl-S inCase                   Ind INZ(*Off);
Dcl-S inCAB                    Ind INZ(*Off);
Dcl-S convert                  Ind INZ(*Off);
Dcl-S unindent                 Ind INZ(*Off);
Dcl-S defsMoved                Ind INZ(*Off);
Dcl-S defVariable             Char(80) Dim(9999);
Dcl-S procsOutput              Ind INZ(*Off);
Dcl-S dropLine                 Ind INZ(*Off);
Dcl-S codeStart                   LIKE(SRCSEQ) INZ(0);
Dcl-S endLine                     LIKE(SRCSEQ) INZ(0);                 // Close struct here.
Dcl-S endFound                 Ind;
Dcl-S endDeclType             Char(2);

Dcl-S savedLineType           Char(1);

Dcl-S indentLine               Ind INZ(*On);
Dcl-S increment             Packed(1:0) INZ(0);
Dcl-S indentCount           Packed(3:0) INZ(0);
Dcl-S indentSize            Packed(1:0) INZ(3);
Dcl-S indentOffset          Packed(3:0) INZ(0);
Dcl-S keywordOffset         Packed(3:0) INZ(0);
Dcl-S prevOffset            Packed(3:0) INZ(0);
Dcl-S currOffset            Packed(3:0) INZ(0);
Dcl-S lineEnd               Packed(3:0) INZ(0);
Dcl-S mainlineIndent        Packed(3:0) INZ(0);

Dcl-S savedSRCDTA                 LIKE(SRCDTA);
Dcl-S sourceLine              Char(93);
Dcl-S overflowLine            Char(92);
Dcl-S workDirective           Char(10);
Dcl-S workLineType            Char(1);
Dcl-S workDeclType            Char(2);
Dcl-S workDeclAttr            Char(1);
Dcl-S workDeclName            Char(50);
Dcl-S workDeclLine                LIKE(SRCSEQ);

Dcl-S tempDeclType            Char(2);
Dcl-S tempDeclLine                LIKE(SRCSEQ);
Dcl-S tempSavedName           Char(80);

Dcl-S workFileUsage           Char(1);
Dcl-S workFileDesig           Char(1);
Dcl-S workFileAdd             Char(1);
Dcl-S workFileKeyed           Char(1);
Dcl-S workFileDevice          Char(7);
Dcl-S checkLength           Packed(3:0);
Dcl-S workLength            Packed(7:0);
Dcl-S workCondCtrl            Char(2);

Dcl-S savedComment            Char(20);
Dcl-S savedName               Char(80);

Dcl-S padResult                Ind INZ(*Off);
Dcl-S padTarget                   LIKE(result);

Dcl-S scanString                  LIKE(factor1);
Dcl-S scanBase                    LIKE(factor2);
Dcl-S scanLength              Char(10);
Dcl-S scanStart               Char(10);
Dcl-S scanNoResult             Ind INZ(*Off);

Dcl-S substLen                Char(10);
Dcl-S substStart              Char(10);

Dcl-S setOff                   Ind INZ(*Off);
Dcl-S setOffInd1              Char(2);
Dcl-S setOffInd2              Char(2);
Dcl-S setOffInd3              Char(2);

Dcl-S setOn                    Ind INZ(*Off);
Dcl-S setOnInd1               Char(2);
Dcl-S setOnInd2               Char(2);
Dcl-S setOnInd3               Char(2);

Dcl-S xlateFrom                   LIKE(factor1);
Dcl-S xlateTo                     LIKE(factor1);
Dcl-S xlateBase                   LIKE(factor2);
Dcl-S xlateStart              Char(10);

Dcl-S caseSubRoutine          Char(10);
Dcl-S caseOperator            Char(4);

// CAT opcode work fields.
Dcl-S catFactor1                  LIKE(factor1);
Dcl-S catFactor2                  LIKE(factor2);
Dcl-S catCount              Packed(3:0) INZ(0);
Dcl-S catBlanks                   LIKE(factor2);

Dcl-S durDuration                 LIKE(factor2);
Dcl-S durCode                     LIKE(factor2);
Dcl-S durNewDate               Ind INZ(*Off);

Dcl-S inEval                   Ind INZ(*Off);
Dcl-S evalOperator                Like(opCode);
Dcl-S evalOffset            Packed(3:0);

Dcl-S inCallP                  Ind INZ(*Off);
Dcl-S callPOperator               Like(opCode);
Dcl-S callPOffset           Packed(3:0);

Dcl-S inDo                     Ind INZ(*Off);
Dcl-S doOperator                  Like(opCode);
Dcl-S doCompare               Char(2);

Dcl-S inIf                     Ind INZ(*Off);
Dcl-S ifOperator                  Like(opCode);
Dcl-S ifCompare               Char(2);

Dcl-S inWhen                   Ind INZ(*Off);
Dcl-S whenOperator                Like(opCode);
Dcl-S whenCompare             Char(2);

Dcl-S inSQL                    Ind INZ(*Off);

Dcl-S forCount              Packed(3:0) INZ(0);
Dcl-S forLevel              Packed(3:0) DIM(99);                          // Allow for 99
Dcl-S forFactor1                  LIKE(factor1);
Dcl-S forFactor2                  LIKE(factor2);

Dcl-S doCount               Packed(3:0) INZ(0);
Dcl-S doLevel               Packed(3:0) DIM(99);                          // Allow for 99

Dcl-S divFactor1                  LIKE(factor1);
Dcl-S divFactor2                  LIKE(factor2);

Dcl-S ERRCheck                 Ind INZ(*Off);
Dcl-S ERRInd                  Char(2);

// Indicator expansion work fields.
Dcl-S foundCheck               Ind INZ(*Off);
Dcl-S foundInd                Char(2);

Dcl-S equalCheck               Ind INZ(*Off);
Dcl-S equalInd                Char(2);

Dcl-S NRFCheck                 Ind INZ(*Off);
Dcl-S NRFInd                  Char(2);
Dcl-S NRFFile                     LIKE(factor2);

Dcl-S EOFCheck                 Ind INZ(*Off);
Dcl-S EOFInd                  Char(2);
Dcl-S EOFFile                     LIKE(factor2);

Dcl-S HICheck                  Ind INZ(*Off);
Dcl-S HIInd                   Char(2);
Dcl-S HiFactor1                   LIKE(factor1);
Dcl-S HiFactor2                   LIKE(factor2);

Dcl-S LWCheck                  Ind INZ(*Off);
Dcl-S LWInd                   Char(2);
Dcl-S LWFactor1                   LIKE(factor1);
Dcl-S LWFactor2                   LIKE(factor2);

Dcl-S EQCheck                  Ind INZ(*Off);
Dcl-S EQInd                   Char(2);
Dcl-S EQFactor1                   LIKE(factor1);
Dcl-S EQFactor2                   LIKE(factor2);

Dcl-S CABFactor1                  LIKE(factor1);
Dcl-S CABFactor2                  LIKE(factor2);

// CALL to CALLP work fields.
Dcl-S CALLPOutput              Ind Inz(*Off);
Dcl-S CALLPSeq               Zoned(6:2);
Dcl-S CALLPExtenders          Char(3);
Dcl-S CALLPPgm                Char(14);
Dcl-S CALLPPList              Char(14);
Dcl-S CALLPIndex               Uns(5);
Dcl-S CALLPPListIndex          Uns(5);
Dcl-S CALLPParmNum                   Uns(5);

// Report counts.
Dcl-S countSource           Packed(7:0) INZ(0);
Dcl-S countTarget           Packed(7:0) INZ(0);
Dcl-S countEligible         Packed(7:0) INZ(0);
Dcl-S countConv             Packed(7:0) INZ(0);
Dcl-S countNotConv          Packed(7:0) INZ(0);
Dcl-S countMoved            Packed(7:0) INZ(0);

Dcl-S arrayLength              Uns(3);
Dcl-S endPos                   Uns(3);
Dcl-S arrayStart           VarChar(14);
Dcl-S zz_IndArray             Char(99) Based(zz_IndArrayPtr);
Dcl-S zz_IndArrayPtr       Pointer     Inz(%addr(*IN));

/Eject
//-------------------------------------------------------------------------------------------
// Main Procedure
//-------------------------------------------------------------------------------------------

Exec SQL set option COMMIT=*NONE;

// Initialize
Exsr subInitialise;

// Perform required function
Exsr subUserFunction;

// Terminate the program.
Exsr subExitProgram;

//-------------------------------------------------------------------------------------------

/Eject
//-------------------------------------------------------------------------------------------
// USER: Perform required function.
//-------------------------------------------------------------------------------------------
BegSr subUserFunction;

   // ** Code the necessary processing here.
   // >>>>> Start of User-Point >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

   // Read through the source member.
   SetLL *Start INPSRC;
   Read INPSRC InpLine;

   DoW not %eof(INPSRC);
      countSource += 1;

      Exsr subUserReformatLine;

      Exsr subUserOutputCallP;

      Exsr subUserSetIndicators;

      // Old-style SCAN without a result field.
      If scanNoResult;
         Clear nonPrefix;

         codeLine = '// Old-style SCAN without a result!';
         Exsr subUserReformatLine;
         codeLine = 'EndIf;';
         Exsr subUserReformatLine;

         scanNoResult = *Off;
      EndIf;

      // If in a CAS statement, record the subroutine to call.
      If inCase and caseSubroutine <> *Blanks;
         codeLine = 'ExSr ' + %trim(caseSubRoutine) + ';';
         Exsr subUserReformatLine;
         caseSubRoutine = *Blanks;
      EndIf;

      // If in a CAB statement, record the branch point.
      If inCAB;
         lineType = *Blanks;
         If caseSubroutine = *Blanks;
         Else;
            If caseOperator <> *Blanks;
               codeLine = 'If ' + %trim(CABFactor1) + ' '
                        + %trim(caseOperator) + ' ' + %trim(CABFactor2) + ';';
               Exsr subUserReformatLine;
            EndIf;

            codeLine = 'LeaveSr;';
            Exsr subUserReformatLine;

            If caseOperator <> *Blanks;
               Clear nonPrefix;
               codeLine = 'EndIf;';
               Exsr subUserReformatLine;
            EndIf;
         EndIf;

         inCAB = *Off;
      EndIf;

      // Close off conditioning indicator group?
      If inLineCondition and reprocessLine = *Off;
         inLineCondition = *Off;
         Clear nonPrefix;
         codeLine = 'EndIf;';
         Exsr subUserReformatLine;
      EndIf;

      // Reprocess the current line?
      If reprocessLine;
         SRCDTA = savedSRCDTA;
         reprocessLine = *Off;
         countSource -= 1;
      Else;
         Read INPSRC InpLine;
      EndIf;
   EndDo;

   // Handle overflow.
   If overFlow;

      // Print page headings.
      Z1_PAG += 1;
      Write Z1PAGHDG;

      ZTFRFL = %trim(p_SrcFromLib) + '/' + %trim(p_SrcFromFile);
      ZTTOFL = %trim(p_SrcToLib) + '/' + %trim(p_SrcToFile);

      Write Z1TOPPAG;

      overFlow = *Off;
   EndIf;

   Z1FRMB = p_FromMbr;
   Z1TOMB = p_ToMbr;
   Z1CTSC = countSource;
   Z1CTTG = countTarget;
   Z1CTEL = countEligible;
   Z1CTCV = countConv;
   Z1CTNV = countNotConv;
   Z1CTMV = countMoved;
   If countEligible = 0;
      Z1CNVR = 0;
   Else;
      Z1CNVR = countConv * 100 / countEligible;
   EndIf;

   // Print detail format.
   Write Z1DETAIL;

   writeConversionLog();

   // <<<<< End of User-Point   <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

EndSr;
//-------------------------------------------------------------------------------------------

/Eject
//-------------------------------------------------------------------------------------------
// Perform conversion/reformatting on the current line.
//-------------------------------------------------------------------------------------------
BegSr subUserReformatLine;

   inDirective = *Off;
   inComment = *Off;
   increment = 0;

   workDirective = %xlate(LO:UP:directive);
   workLineType = %xlate(LO:UP:lineType);

   convert = *Off;
   nonConvRsn = *Blanks;

   sourceLine = codeLine;     // Start with what is already there.

   // Array data reached?
   If %subst(prefix:1:3) = '** '
   or %subst(SRCDTA:1:8) = '**CTDATA';
      inCode = *Off;
      inDeclaration = *Off;
      inArrayData = *On;
   EndIf;

   If not inArrayData;
      //----------------------------------------------------------------------------------
      // Close off Prototype/Interface/Datastructure?
      If (inPrototype or inInterface or inDatastructure)
      and SRCSEQ >= endLine;
         If not inDatastructure
         or inDatastructure and endDS;
            savedSRCDTA = SRCDTA;
            Clear SRCDTA;
            indentCount -= 1;
            indentOffset = indentCount * indentSize + 1;
            sourceLine = setOpCodeCase('End-' + endDeclType:p_OpCodeCase) + ';';
            Clear codeLine;
            %subst(codeLine:indentOffset) = %trimr(sourceLine);
            writeLine();
            SRCDTA = savedSRCDTA;
         EndIf;
         inPrototype = *Off;
         inInterface = *Off;
         inDatastructure = *Off;
         inSpan = *Off;
         inDeclaration = *Off;
         workDeclName = *Blanks;
      EndIf;

      //----------------------------------------------------------------------------------
      // Determine Line Type
      If workLineType = 'C';                  // C-Spec
         inCode = *On;
      ElseIf workLineType = 'P';              // P-Spec
         inCode = *Off;
         defsMoved = *Off;
      ElseIf workLineType = 'D';              // Declaration.
         inCode = *Off;
      ElseIf workLineType = 'H';              // Header spec.
         inCode = *Off;
      ElseIf workLineType = 'F';              // File spec.
         inCode = *Off;
      ElseIf workLineType = 'O';              // O-Spec
         inCode = *Off;
      ElseIf workLineType = 'I';              // I-Spec
         inCode = *Off;
      ElseIf %check(validSpecs:workLineType) <> 0;    // Invalid spec type.
         workLineType = *Blanks;
         lineType = *Blank;                           // Clear it!
      EndIf;

      If %trim(workDirective) = '/FREE';
         // In a free-format directive, so we must be in code too.
         If not inFreeFormat;
            inDirective = *On;
            inCode = *On;
            inFreeFormat = *On;
            lineType = ' ';
            workLineType = ' ';
            If p_Directives = 'Y';
               directive = '/Free';
            Else;
               dropLine = *On;
            EndIf;
         Else;
            dropLine = *On;   // Not needed.
         EndIf;
         inCode = *On;
      ElseIf %trim(workDirective) = '/END-FREE';
         // At the end of a directive, so we can't be in free format any more.
         //inDirective = *On;
         //directive = '/End-Free';
         //inFreeFormat = *Off;
         dropLine = *On;
      ElseIf %trim(workDirective) = '/EJECT';
         inDirective = *On;
         lineType = ' ';
         workLineType = ' ';
      ElseIf %subst(workDirective:1:5) = '/COPY';
         inDirective = *On;
         lineType = ' ';
         workLineType = ' ';
      ElseIf %subst(workDirective:1:8) = '/INCLUDE';
         inDirective = *On;
         lineType = ' ';
         workLineType = ' ';
      ElseIf %subst(workDirective:1:3) = '/IF';
         inDirective = *On;
         lineType = ' ';
         workLineType = ' ';
      ElseIf %subst(workDirective:1:6) = '/ENDIF';
         inDirective = *On;
         lineType = ' ';
         workLineType = ' ';
      ElseIf %subst(workDirective:1:7) = '/DEFINE';
         inDirective = *On;
         lineType = ' ';
         workLineType = ' ';
      ElseIf %subst(workDirective:1:6) = '/SPACE';
         inDirective = *On;
         lineType = ' ';
         workLineType = ' ';
      ElseIf %subst(workDirective:1:6) = '/TITLE';
         inDirective = *On;
         lineType = ' ';
         workLineType = ' ';
      ElseIf (%subst(workDirective:1:1) = '*'
         or %subst(workDirective:1:2) = '//')
         and (lineType = *Blank or inCode);
         removeNonPrintable(SourceData);
         // This is a comment line.
         If p_IndComment <> 'Y' or workLineType = 'C';
            // Do not indent...possibly commented-out code.
            inComment = *On;
         EndIf;
         If %subst(workDirective:1:2) = '//';
            %subst(directive:1:2) = '  ';
         Else;
            %subst(directive:1:1) = ' ';
         EndIf;
         If workLineType = 'C' or workLineType = 'D';
            lineType = ' ';
            workLineType = ' ';
         EndIf;
         // Retain blank comment markers?
         If p_RetBlnkCmt = 'N' and %len(%trim(codeLine)) = 0;
         // Leave the line blank, devoid of any marker.
         Else;
            codeLine = '//' + codeLine;
         EndIf;
         removeEndCommentMarker(p_RmvCmtEnd:codeLine);
      ElseIf %subst(workDirective:1:1) = '*';
         //            and workLineType = 'O';
         // Leave the line as it is.
         inComment = *On;
         removeNonPrintable(SourceData);
         If workLineType = 'F'
         or workLineType = 'H'
         or workLineType = 'P'
         or workLineType = 'D'
         or workLineType = 'I';
            lineType = ' ';
            workLineType = ' ';
            %subst(directive:1:1) = ' ';
            codeLine = '//' + codeLine;
         EndIf;
         removeEndCommentMarker(p_RmvCmtEnd:codeLine);
      ElseIf %len(%trim(codeLine)) = 0;
         // Just a 'spacer' line - keep it but drop the line type.
         lineType = ' ';
         workLineType = ' ';
      ElseIf %len(%trim(codeLine)) >= 2
         and %subst(%trim(codeLine):1:2) = '//'
         and (workLineType = *Blank or inCode);
         // This is a comment line.
         If p_IndComment <> 'Y' or workLineType = 'C';
            inComment = *On;
         EndIf;
         removeNonPrintable(SourceData);
         // Retain blank comment markers?
         If p_RetBlnkCmt = 'N' and %len(%trim(%subst(codeLine:3)))
                                           = 0;
            // Leave the line blank, devoid of any marker.
            codeLine = *Blanks;
         EndIf;
         removeEndCommentMarker(p_RmvCmtEnd:codeLine);
      EndIf;

      //----------------------------------------------------------------------------------
      // Start of code?  If so, pause here and move all field definitions to D-specs.
      If not procsOutput and SRCSEQ >= seqProcDefs;
         If inComment or %subst(sourceLine:1:2) = '//' or sourceLine = *Blanks;
            seqProcDefs = SRCSEQ + 0.01;
         Else;
            outputPrototypeDefs();
         EndIf;
      EndIf;

      //----------------------------------------------------------------------------------
      // Start of code?  If so, pause here and move all field definitions to D-specs.
      If (inCode or workLineType = 'I') and not defsMoved;
         If workLineType = 'P';
            Clear localDefs;
         EndIf;
         Clear defVariable;
         moveDefinitions();
      EndIf;

      //----------------------------------------------------------------------------------
      // Convert fixed-format to free-format?
      If not inComment
      and not inDirective;

         If workLineType = 'C';
            If not reprocessLine;
               countEligible += 1;
               countNotConv += 1;
            EndIf;
            operator = %xlate(LO:UP:opCode);
            savedComment = comment;

            convertC_Spec();

            If not inComment and not convert
            and not dropLine and nonConvRsn = *Blanks;
               nonConvRsn = 'Conversion not currently supported.';
            EndIf;

         ElseIf workLineType = 'P';     // Procedure start/end.
            inMainLine = *Off;
            If not reprocessLine;
               countEligible += 1;
               countNotConv += 1;
            EndIf;
            operator = *Blanks;
            savedComment = comment;

            convertP_Spec();

            If not inComment and not convert
            and not dropLine and nonConvRsn = *Blanks;
               nonConvRsn = 'Conversion not currently supported.';
            EndIf;

         ElseIf workLineType = 'D';     // Declaration.
            If not reprocessLine;
               countEligible += 1;
               countNotConv += 1;
            EndIf;
            savedComment = comment;

            convertD_Spec();

            If not inComment and not convert
            and not dropLine and nonConvRsn = *Blanks;
            //nonConvRsn = 'Conversion not currently supported.';
            EndIf;

         ElseIf workLineType = 'F';     // File.
            If not reprocessLine;
               countEligible += 1;
               countNotConv += 1;
            EndIf;
            savedComment = comment;

            convertF_Spec();

            If not inComment and not convert
            and not dropLine and nonConvRsn = *Blanks;
            //nonConvRsn = 'Conversion not currently supported.';
            EndIf;

         ElseIf workLineType = 'H';     // Header.
            If not reprocessLine;
               countEligible += 1;
               countNotConv += 1;
            EndIf;
            savedComment = comment;

            convertH_Spec();

            If not inComment and not convert
            and not dropLine and nonConvRsn = *Blanks;
            //nonConvRsn = 'Conversion not currently supported.';
            EndIf;

         ElseIf workLineType = 'O';     // Output spec
            sourceLine = fullLine;

         ElseIf workLineType = 'I';     // Input spec
            convertI_Spec();
            sourceLine = fullLine;

         ElseIf workLineType = ' ' and inCode;
            inFreeFormat = *On;
            // When in an IF we usually want subsequent lines to be pulled back to be
            // in line with the 'If', but only if those lines start with either 'and'
            // or 'or'.  Otherwise we retain the existing indentation by turning on
            // inSpan.
            If inIf and %len(%trim(codeLine)) >= 3
            and %xlate(LO:UP:%subst(%trim(codeLine):1:3)) <> 'AND'
            and %xlate(LO:UP:%subst(%trim(codeLine):1:3)) <> 'OR ';
               inSpan = *On;
            EndIf;
            If inSpan;
               currOffset = %check(' ':codeLine);  // Offset of the continuation line.
            Else;
               prevOffset = %check(' ':codeLine);  // Offset of the parent line.
            EndIf;
            sourceLine = %trim(codeLine);         // Free-format already, so trim it.
         Else;
            inFreeFormat = *On;
            sourceLine = %trimr(codeLine);        // None of the above, use the raw source
         EndIf;

         // Converted?
         If convert;
            countConv += 1;
            countNotConv -= 1;
            // Switch to free-format?
            If not inFreeFormat and not inDeclaration;
               If p_Directives = 'Y';
                  savedSRCDTA = SRCDTA;
                  Clear SRCDTA;
                  directive = '/Free';
                  writeLine();
                  SRCDTA = savedSRCDTA;
               EndIf;
               inFreeFormat = *On;
            EndIf;
         Else;
            convert = convert;
         EndIf;

         // Revert to fixed-format?
         If not convert and (lineType <> *Blanks
         or %subst(workDirective:1:5) = '/COPY' or %subst(workDirective:1:8) = '/INCLUDE');
            //                or  %subst(prefix:1:3) = '** ');        // Array data reached
            If inFreeFormat and not inDeclaration;
               If p_Directives = 'Y';
                  savedSRCDTA = SRCDTA;
                  Clear SRCDTA;
                  directive = '/End-Free';
                  writeLine();
                  SRCDTA = savedSRCDTA;
               EndIf;
               inFreeFormat = *Off;
            EndIf;
            // Record the reason for not converting?
            If nonConvRsn <> *Blanks and p_SuppressMsgs <> 'Y';
               savedSRCDTA = SRCDTA;
               Clear SRCDTA;
               codeLine = '// >>>>> Not converted: ' + nonConvRsn;
               writeLine();
               SRCDTA = savedSRCDTA;
            EndIf;
            inSpan = *Off;
         EndIf;
      Else;
         // Use source exactly as is.
         sourceLine = codeLine;
      EndIf;

      //----------------------------------------------------------------------------------
      // If we are in a code section, check if indent is affected at all.
      //         If not inDeclaration
      //         and not inDirective
      If not inDirective
      and not inComment
      and not dropLine;
         // Isolate the operator to check indentation against.
         //sourceLine = %trimr(codeLine);
         If inFreeFormat;
            If %subst(sourceLine:1:2) = '//';            // Comment - no operator.
               operator = *Blanks;
            ElseIf inSQL;                                // Embedded SQL - no operator.
               operator = *Blanks;
            Else;
               // Isolate the 'operator' (first word really).
               operator = %trim(sourceLine);
               operatorEnd = %scan(';':%trim(operator)); // Isolate the actual code.
               If operatorEnd > 0;
                  operator = %subst(operator:1:operatorEnd-1);
               EndIf;
               operatorEnd = %scan(' ':%trim(operator)); // Look for end of first 'word'.
               If operatorEnd = 0;
                  operatorEnd = %scan(';':operator);  // Only one word - is it an operator
                  If operatorEnd = 0;
                     operatorEnd = %scan('(':operator);  // Shouldn't match!
                  EndIf;
               EndIf;
               // If we have an operator, remove any attached extender code.
               If operatorEnd > 0;
                  operator = %subst(operator:1:operatorEnd - 1);
                  // Exec SQL?
                  If %xlate(LO:UP:operator) = 'EXEC';
                     If %scan('SQL':%xlate(LO:UP:%trim(sourceLine)):6)
                              > 0;
                        operator = 'Exec SQL';
                        inSQL = *On;
                     EndIf;
                  EndIf;
                  operatorEnd = %scan('(':operator);
                  If operatorEnd > 1;
                     operator = %subst(operator:1:operatorEnd - 1);
                  EndIf;
               EndIf;

               If %lookup(%xlate(LO:UP:operator):opCodeUP) > 0
               and not inDeclaration and workLineType <> 'D';
                  inCode = *On;
               Else;
                  If %lookup(%xlate(LO:UP:operator):declUP) > 0
                  or inDeclaration;
                  // Declaration!
                  Else;
                     // Not an operator!
                     operator = *Blanks;
                     x = %scan('//':sourceLine);
                     If x = 0;
                        x = %len(sourceLine);
                     Else;
                        x = x - 1;
                        If x < 1;
                           x = 1;
                        EndIf;
                     EndIf;
/if defined(*V7R3M0)
                     y = %scan('=':sourceLine:1:x);
/else
                     y = %scan('=':sourceLine:1);
                     If y >= x;
                        y = 0;
                     EndIf;
/endif
                     If y > 0;   // Looks like an assignment.
                        operator = '=';
                        inCode = *On;
                        If workLineType = *Blank;
                           sourceLine = %trim(sourceLine);
                        EndIf;
                     EndIf;
                  EndIf;
               EndIf;
            EndIf;
         Else;
            If %subst(sourceLine:1:2) = '//';            // Comment - no operator.
               operator = *Blanks;
            Else;
               operator = %xlate(LO:UP:opCode);
               If %subst(operator:1:4) <> 'EVAL'
               and operator <> *Blanks;
                  // Strip out in-line definitions.
                  len = *Blanks;
                  dec = *Blanks;
               EndIf;
            EndIf;
         EndIf;

         // Convert to upper case for check.
         operator = %xlate(LO:UP:operator);

         // Check for indentation level change.
         Exsr subUserCalcIndent;
      ElseIf inDeclaration;
      EndIf;

      //----------------------------------------------------------------------------------
      // If we need to temporarily unindent, do so to the requested increment.
      If unindent;
         indentCount += increment;
         increment = 0;
         unindent = *Off;
      EndIf;

      //----------------------------------------------------------------------------------
      // If we are in a code section and in free-format, perform reformatting.
      //If inCode and inFreeFormat and not inDirective
      If inFreeFormat
      and not inDirective
      and sourceLine <> *Blanks
      and not inComment
      and not dropLine;       //  and not inSpan
         // Derive reformatted opcode (if any)
         x = %lookup(operator:opCodeUP);
         If x > 0;
            newOperator = %trim(opCodeLO(x));
         Else;
            x = %lookup(operator:declUP);
            If x > 0;
               newOperator = %trim(declLO(x));
            Else;
               // Not a valid operator, check if this is a comment.
               x = %scan('//':%trim(sourceLine));
               If x = 1;
                  inComment = *On;
                  newOperator = '';
                  operator = *Blanks;
               Else;
                  newOperator = '';
               EndIf;
            EndIf;
         EndIf;

         // Use new opcode if it exists.
         If %len(newOperator) > 0;
            newOperator = setOpCodeCase(newOperator:p_OpCodeCase);
            If %len(%trim(sourceLine)) > %len(newOperator);
               sourceLine = %trim(%subst(%trim(sourceLine)
                                :%len(newOperator) + 1));
            Else;
               sourceLine = *Blanks;
            EndIf;
            // Insert a spcace after operator if it's not the end of the line
            // and there's no operation extender.
            If %subst(sourceLine:1:1) <> ';'
            and (%subst(sourceLine:1:1) <> '('
              or %subst(sourceLine:1:1) = '('
             and %subst(sourceLine:3:1) <> ')'
             and %subst(sourceLine:4:1) <> ')');
               sourceLine = ' ' + sourceLine;
            EndIf;
            sourceLine = newOperator + sourceLine;
         EndIf;

            // Padding required?
            If padResult;
               savedSRCDTA = SRCDTA;
               Clear codeLine;
               %subst(codeLine:indentOffset)
                     = %trim(padTarget) + ' = *Blanks;';
               writeLine();
               SRCDTA = savedSRCDTA;
               padResult = *Off;
            EndIf;

            // Determine the indentation to use.
            If indentCount > maxIndent;
               indentOffset = maxIndent * indentSize + 1;
            Else;
               indentOffset = indentCount * indentSize + 1;
            EndIf;

            // Adjust for continuation lines.
            If inCallP and (%subst(operator:1:5) <> 'CALLP');
               indentOffset += callPOffset;
            ElseIf inEval and (%subst(operator:1:4) <> 'EVAL');
               indentOffset += evalOffset;
            ElseIf inSpan;
               indentOffset = currOffset + (indentOffset - prevOffset);
            EndIf;

            // Avoid losing code off of the right hand side (comments mainly).
            If %len(%trimr(sourceLine)) + indentOffset > 93;
               indentOffset = 93 - %len(%trim(sourceLine));
            EndIf;

            // For code lines, check for overflow, and unindent accordingly if it does,
            If not inComment;
               lineEnd = %scan(';':%trimr(sourceLine));
               If lineEnd = 0;   // Code already spans to next line.
                  lineEnd = %scan('//':sourceLine);
                  If lineEnd > 0;
                     lineEnd
                       = %len(%trimr(%subst(sourceLine:1:lineEnd-1)));
                  Else;
                     lineEnd = %len(%trimr(sourceLine));
                  EndIf;
                  If not inIf and not inDo and not inWhen;
                     inSpan = *On;
                  EndIf;
               EndIf;
            EndIf;

            // Cater for code that extends into comments.
            If indentOffset + lineEnd > 74;
               Exsr subUserWrapLine;
            EndIf;

            // Ensure that we don't go back too far!
            If indentOffset < 1;
               indentOffset = 1;
            EndIf;

            savedSRCDTA = SRCDTA;
            Clear codeLine;
            If inConstant;
               // Leave line to start at leftmost column.
               codeLine = %trim(sourceLine);
               inConstant = *Off;
            ElseIf not indentLine or inSpan and not inCode;
               codeLine = %trimr(sourceLine);
               indentLine = *On;
            Else;
               %subst(codeLine:indentOffset) = %trim(sourceLine);
            EndIf;
            // Append an in-line comment?
            If (convert or setOn or setOff)
            and savedComment <> *Blanks;
               %subst(codeLine:71) = '// ' + savedComment;
               savedComment = *Blanks;
            EndIf;
            sourceLine = codeLine;
            SRCDTA = savedSRCDTA;
      EndIf;
   EndIf;

   //----------------------------------------------------------------------------------
   // Output the formatted line (and any overflows that have occurred.
   If not dropLine;
      If convert;
         Clear nonPrefix;
      ElseIf %xlate(LO:UP:lineType) = 'C';
         sourceLine = codeLine;
      EndIf;
      If inCode or inArrayData
      or lineType = *Blank or %subst(directive:1:1) = '*';
         codeLine = %trimr(sourceLine);
      Else;
         fullLine = %trimr(sourceLine);
      EndIf;
      writeLine();

      // Overflow line?
      If overFlowLine <> *Blanks;
         codeLine = overFlowLine;
         sourceLine = overflowLine;
         overflowLine = *Blanks;
         writeLine();
      EndIf;
   Else;
      dropLine = *Off;
   EndIf;

   indentCount += increment;

   // Following a WHEN or ON-ERROR or ELSE, code should be indented again.
   If indent;
      indentCount += 1;
      indent = *Off;
   // Following ENDSR, we should revert to mainline indentation.
   ElseIf operator = 'ENDSR';
      indentCount = mainlineIndent;
      inCode = *Off;
   EndIf;

   // If spanning a line, check if the current line ends the span.
   If (inSpan or inIf or inDo or inWhen or inCallP or inEval
   or inSQL or inDeclaration)
   and not inComment;
      If inDeclaration;

/if defined(*V7R3M0)
         lineEnd = %scan(';':sourceLine:1:80);
/else
         lineEnd = %scan(';':sourceLine:1);
         If lineEnd >= 80;
            lineEnd = 0;
         EndIf;
/endif

         If lineEnd > 0;
            If %len(%trim(%subst(sourceLine:lineEnd+1:80-lineEnd))) > 0;
               lineEnd = 0;   // Not really the end of the line.
            EndIf;
         EndIf;
      Else;
         lineEnd = %scan(';':%trim(sourceLine));
      EndIf;
      If lineEnd <> 0;
         inSpan = *Off;
         inIf = *Off;
         inDo = *Off;
         inWhen = *Off;
         inCallP = *Off;
         inEval = *Off;
         inSQL = *Off;
         inDeclaration = *Off;
      EndIf;
   EndIf;

EndSr;
//-------------------------------------------------------------------------------------------

/Eject
//-------------------------------------------------------------------------------------------
// Calculate indentation.
//-------------------------------------------------------------------------------------------
BegSr subUserCalcIndent;

   Select;
      When workDirective = '/EXEC SQL';
         increment = 1;
         inSQL = *On;
      When workDirective = '/END-EXEC';
         unindent = *On;
         increment = -1;
         dropLine = *On;
      When inSQL;
      // Do nothing.
      When %subst(operator:1:2) = 'IF';
         increment = 1;
         inIf = *On;
      When %subst(operator:1:2) = 'DO';
         increment = 1;
         inDo = *On;
         doCount += 1;
         doLevel(doCount) = indentCount;
      When operator = 'FOR';
         increment = 1;
         forCount += 1;
         forLevel(forCount) = indentCount;
      When operator = 'SELECT';
         increment = 2;
      When operator = 'BEGSR';
         increment = 1;
         mainlineIndent = 0;
         indentCount = mainlineIndent;
      When %subst(operator:1:5) = 'DCL-F';
         increment = 0;
         defsMoved = *Off;
      When %subst(operator:1:5) = 'DCL-C';
         increment = 0;
         defsMoved = *Off;
      When %subst(operator:1:8) = 'DCL-PROC';
         increment = 1;
         mainlineIndent = 0;
         indentCount = mainlineIndent;
         defsMoved = *Off;
      When %subst(operator:1:5) = 'DCL-S';
         increment = 0;
         defsMoved = *Off;
      When %subst(operator:1:6) = 'DCL-DS';
//         If %scan('END-DS':%xlate(lo:up:sourceLine)) = 0;
         endDS = isEndDSRequired();
         If endDS;
            increment = 1;
         EndIf;
         defsMoved = *Off;
      When %subst(operator:1:4) = 'DCL-';
         If %scan('END-PI':%xlate(lo:up:sourceLine)) = 0;
            increment = 1;
            defsMoved = *Off;
         EndIf;
      When %subst(operator:1:8) = 'END-PROC';
         indentCount = mainlineIndent;
      When %subst(operator:1:6) = 'END-DS';
         unindent = *On;
//         If endDS;
            increment = -1;
//         EndIf;
      When %subst(operator:1:4) = 'END-';
         unindent = *On;
         increment = -1;
      When operator = 'MONITOR';
         increment = 1;
      When operator = 'ENDSL';
         unindent = *On;
         increment = -2;
      When operator = 'ENDCS';
         Operator = 'ENDIF';
         unindent = *On;
         increment = -1;
      When operator = 'ENDDO';
         unindent = *On;
         increment = -1;
         doCount -= 1;
      When operator = 'ENDFOR';
         unindent = *On;
         increment = -1;
         forCount -= 1;
      When %subst(operator:1:3) = 'END';
         unindent = *On;
         increment = -1;
      When %subst(operator:1:4) = 'ELSE'; // Unindent ELSE
         unindent = *On;
         indent = *On;
         increment = -1;
      When %subst(operator:1:2) = 'OR';   // Unindent OR
         unindent = *On;
         indent = *On;
         increment = -1;
      When %subst(operator:1:3) = 'AND';  // Unindent AND
         unindent = *On;
         indent = *On;
         increment = -1;
      When operator = 'ON-ERROR';         // Unindent On-Error
         unindent = *On;
         indent = *On;
         increment = -1;
      When %subst(operator:1:4) = 'WHEN' or inWhen;
         unindent = *On;
         indent = *On;
         increment = -1;
         inWhen = *On;
      When inIF or inDo;                  // Keep conditions in line.
         unindent = *On;
         indent = *On;
         increment = -1;
      When operator = 'OTHER';             // Unindent Other
         unindent = *On;
         indent = *On;
         increment = -1;
      Other;
         increment = 0;
   EndSl;

EndSr;
//-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Set Resulting Indicators.
 //-------------------------------------------------------------------------------------------
 BegSr subUserSetIndicators;

    //-----------------------------------------------------------------------
    // Scan found.
    If foundCheck;
       Clear nonPrefix;

       codeLine = '*IN' + foundInd + ' = %found();';
       Exsr subUserReformatLine;

       foundCheck = *Off;
    EndIf;

    //-----------------------------------------------------------------------
    // Error indicator check.
    If ERRCheck;
       Clear nonPrefix;

       codeLine = '*IN' + ERRInd + ' = %error();';
       Exsr subUserReformatLine;

       ERRCheck = *Off;
    EndIf;

    //-----------------------------------------------------------------------
    // Record not found check.
    If NRFCheck;
       Clear nonPrefix;

       codeLine = '*IN' + NRFInd + ' = not %found();';
       Exsr subUserReformatLine;

       NRFCheck = *Off;
    EndIf;

    //-----------------------------------------------------------------------
    // End of File check.
    If EOFCheck;
       Clear nonPrefix;

       codeLine = '*IN' + EOFInd + ' = %eof();';
       Exsr subUserReformatLine;

       EOFCheck = *Off;
    EndIf;

    //-----------------------------------------------------------------------
    // Matching Key check.
    If equalCheck;
       Clear nonPrefix;

       codeLine = '*IN' + equalInd + ' = %equal();';
       Exsr subUserReformatLine;

       equalCheck = *Off;
    EndIf;

    //-----------------------------------------------------------------------
    // Perform SETOFF / SETON Expansion.
    If setOff;
       Clear nonPrefix;
       If setOffInd1 <> *Blanks;
          codeLine = '*IN' + setOffInd1 + ' = *Off;';
          Exsr subUserReformatLine;
       EndIf;
       If setOffInd2 <> *Blanks;
          codeLine = '*IN' + setOffInd2 + ' = *Off;';
          Exsr subUserReformatLine;
       EndIf;
       If setOffInd3 <> *Blanks;
          codeLine = '*IN' + setOffInd3 + ' = *Off;';
          Exsr subUserReformatLine;
       EndIf;
       setOff = *Off;
    EndIf;
    If setOn;
       Clear nonPrefix;
       If setOnInd1 <> *Blanks;
          codeLine = '*IN' + setOnInd1 + ' = *On;';
          Exsr subUserReformatLine;
       EndIf;
       If setOnInd2 <> *Blanks;
          codeLine = '*IN' + setOnInd2 + ' = *On;';
          Exsr subUserReformatLine;
       EndIf;
       If setOnInd3 <> *Blanks;
          codeLine = '*IN' + setOnInd3 + ' = *On;';
          Exsr subUserReformatLine;
       EndIf;
       setOn = *Off;
    EndIf;

    //-----------------------------------------------------------------------
    // Resulting indicators...

    // Turn off all specified indicators first.
    If HICheck;
       Clear nonPrefix;
       codeLine = '*IN' + HIInd + ' = *Off;';
       Exsr subUserReformatLine;
    EndIf;
    If LWCheck;
       Clear nonPrefix;
       codeLine = '*IN' + LWInd + ' = *Off;';
       Exsr subUserReformatLine;
    EndIf;
    If EQCheck;
       Clear nonPrefix;
       codeLine = '*IN' + EQInd + ' = *Off;';
       Exsr subUserReformatLine;
    EndIf;

    // And now turn on those specified accordingly.

    // HI check.
    If HICheck;
       Clear nonPrefix;

       codeLine = 'If ' + %trim(HIFactor1) + ' > '
                + %trim(HIFactor2) + ';';
       Exsr subUserReformatLine;
       codeLine = '*IN' + HIInd + ' = *On;';
       Exsr subUserReformatLine;
       codeLine = 'EndIf;';
       Exsr subUserReformatLine;

       HICheck = *Off;
    EndIf;

    // LO check.
    If LWCheck;
       Clear nonPrefix;

       codeLine = 'If ' + %trim(LWFactor1) + ' < '
                + %trim(LWFactor2) + ';';
       Exsr subUserReformatLine;
       codeLine = '*IN' + LWInd + ' = *On;';
       Exsr subUserReformatLine;
       codeLine = 'EndIf;';
       Exsr subUserReformatLine;

       LWCheck = *Off;
    EndIf;

    // EQ check.
    If EQCheck;
       Clear nonPrefix;

       codeLine = 'If ' + %trim(EQFactor1) + ' = '
                + %trim(EQFactor2) + ';';
       Exsr subUserReformatLine;
       codeLine = '*IN' + EQInd + ' = *On;';
       Exsr subUserReformatLine;
       codeLine = 'EndIf;';
       Exsr subUserReformatLine;

       EQCheck = *Off;
    EndIf;

EndSr;
//-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Output a new CALLP?
 //-------------------------------------------------------------------------------------------
 BegSr subUserOutputCallP;

   // Flagged to output a callp?
   If CALLPOutput;

      // Move input parameters?
      For CALLPParmNum = 1 to %elem(parmList);
         If parmList(CALLPPLIstIndex).parameterDef(CALLPParmNum).parmName = *Blanks;
            writeLine('');
            Leave;
         EndIf;
         If parmList(CALLPPLIstIndex).parameterDef(CALLPParmNum).parmInput <> *Blanks
         and parmList(CALLPPLIstIndex).parameterDef(CALLPParmNum).parmInput <>
             parmList(CALLPPLIstIndex).parameterDef(CALLPParmNum).parmName;
            codeLine = %trim(parmList(CALLPPLIstIndex).parameterDef(CALLPParmNum).parmName)
                  + ' = '
                  + %trim(parmList(CALLPPLIstIndex).parameterDef(CALLPParmNum).parmInput)
                  + ';';
            Exsr subUserReformatLine;
         EndIf;
      EndFor;

      // Output the actual CALLP.
      codeLine = 'CallP' + %trim(CALLPExtenders) + ' ' + %trim(%scanrpl('''':'':CALLPPgm)) + '(';
      Exsr subUserReformatLine;

      callPOffset = %len(%trim(codeLine))-1;
      inCallP = *On;

      For CALLPParmNum = 1 to %elem(parmList);
         If parmList(CALLPPLIstIndex).parameterDef(CALLPParmNum).parmName = *Blanks;
            Leave;
         EndIf;
         If CALLPParmNum > 1;
           codeLine = ':'
                    + %trim(parmList(CALLPPLIstIndex).parameterDef(CALLPParmNum).parmName);
         Else;
           codeLine = %trim(parmList(CALLPPLIstIndex).parameterDef(CALLPParmNum).parmName);
         EndIf;
         Exsr subUserReformatLine;
      EndFor;

      codeLine = ');';
      Exsr subUserReformatLine;
      inCallP = *Off;

      // Move output parameters?
      For CALLPParmNum = 1 to %elem(parmList);
         If parmList(CALLPPLIstIndex).parameterDef(CALLPParmNum).parmName = *Blanks;
            writeLine('');
            Leave;
         EndIf;
         If parmList(CALLPPLIstIndex).parameterDef(CALLPParmNum).parmOutput <> *Blanks
         and parmList(CALLPPLIstIndex).parameterDef(CALLPParmNum).parmOutput <>
             parmList(CALLPPLIstIndex).parameterDef(CALLPParmNum).parmName;
            codeLine = %trim(parmList(CALLPPLIstIndex).parameterDef(CALLPParmNum).parmOutput)
                  + ' = '
                  + %trim(parmList(CALLPPLIstIndex).parameterDef(CALLPParmNum).parmName)
                  + ';';
            Exsr subUserReformatLine;
         EndIf;
      EndFor;

      CALLPOutput = *Off;
   EndIf;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
//-------------------------------------------------------------------------------------------
// Perform line wrap.
//-------------------------------------------------------------------------------------------
BegSr subUserWrapLine;

   x = (indentOffset + lineEnd) - 74;
   x = lineEnd - x;

   // Scan backwards through the line, looking for a place to break it.
   For x = x downto 1;
      If %scan(%subst(sourceLine:x:1):' :)(') > 0;
         // Break here, and put the rest into a new line.
         Clear overflowLine;
         %subst(overflowLine:(74 - (lineEnd-x+1)))
          = %subst(sourceLine:x);

         codeLine = %subst(sourceLine:1:x-1);
         sourceLine = codeLine;
         Leave;
      EndIf;
   EndFor;

EndSr;
//-------------------------------------------------------------------------------------------

/Eject
//-------------------------------------------------------------------------------------------
// Exit the program directly.
//-------------------------------------------------------------------------------------------
BegSr subExitProgram;

   Exsr subUserExitProgram;     // Perform any user-specified exit processing.

   // If commitment control is active, a commit should have been done if everything
   // was OK, so issue a rollback here to catch and remove any uncommitted changes.
   If cfgCommitControl = '*MASTER';
      RolBk;
   EndIf;

   If cfgCloseDown = 'Y';
      *INLR = *On;                  // Close down the program.
   EndIf;

   Return;                          // Exit the program.

EndSr;
//-------------------------------------------------------------------------------------------

/Eject
//-------------------------------------------------------------------------------------------
// USER: Exit processing.
//-------------------------------------------------------------------------------------------
BegSr subUserExitProgram;

   // ** Place any program-specific exit code here.
   // >>>>> Start of User-Point >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

   If p_ShutDown <> 'Y';
      Close INPSRC;
      Close OUTSRC;
   EndIf;

   If p_ShutDown = 'Y' and initialCall <> 'Y';
      cfgCloseDown = 'Y';
      Write Z1ENDRPT;
      Close CVTRPGFRP1;
   EndIf;

   // <<<<< End of User-Point   <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

EndSr;
//-------------------------------------------------------------------------------------------

/Eject
//-------------------------------------------------------------------------------------------
// Initialisation
//-------------------------------------------------------------------------------------------
BegSr subInitialise;

   // Flag initial call.
   If initialCall = *Blank;
      initialCall = 'Y';
   Else;
      initialCall = 'N';
   EndIf;

   // Perform user-specified intialisation processing.
   Exsr subUserInitialise;

EndSr;
//-------------------------------------------------------------------------------------------

/Eject
//-------------------------------------------------------------------------------------------
// USER: Initialisation
//-------------------------------------------------------------------------------------------
BegSr subUserInitialise;

   // Set configuration/processing options:
   cfgCommitControl   = '*NONE  '; // Commitment control setting: *MASTER/*SLAVE
   cfgCloseDown       = 'N';       // Close down the program on exit?


   // >>>>> Start of User-Point >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

   // Shut down?
   If p_ShutDown = 'Y';
      Exsr subExitProgram;
   EndIf;

   // Open audit report.
   If initialCall = 'Y';
      Open CVTRPGFRP1;
      Z1_TTL = 'RPG/ILE to Free-Format Conversion Report';
      overflow = *On;
   EndIf;

   fromFileLib = %trim(p_FromLib) + '/' + %trim(p_FromFile);
   Open INPSRC;

   // Remove the "Buffer length longer than record"
   // message from the job log.

   QMHRCVPM( RCVM0100: %size(RCVM0100): 'RCVM0100'
           : '*': 0: '*DIAG': *blanks
           : 0: '*REMOVE': x'00000008');

   toFileLib = %trim(p_ToLib) + '/' + %trim(p_ToFile);
   Open OUTSRC;

   // Remove the "Buffer length longer than record"
   // message from the job log.

   QMHRCVPM( RCVM0100: %size(RCVM0100): 'RCVM0100'
           : '*': 0: '*DIAG': *blanks
           : 0: '*REMOVE': x'00000008');

   Reset countSource;
   Reset countTarget;
   Reset countEligible;
   Reset countConv;
   Reset CountNotConv;
   countMoved = 0;

   Reset maxIndent;
   Reset inCode;
   Reset inArrayData;
   Reset indentCount;

   doCount = 0;
   forCount = 0;

   indentCount = mainlineIndent;

   indentSize = p_IndIncrement;

   // Renumber the input source because we use line numbers for positioning.
   renumberSource();

   // Extract the parameter list definitions.
   extractParameterLists();

   // Extract the key list definitions.
   extractKeyLists();

   // Extract the tags in the source.
   tagCount = extractTAGs();

   If p_FullyFree = 'Y';
      fullyFree = *On;
      Clear inpLine;
      codeLine = '**FREE';
      writeLine();
   Else;
      fullyFree = *Off;
   EndIf;

   Clear inpLine;
   codeLine = '// Converted from '
            + %trim(p_SrcFromLib) + '/' + %trim(p_SrcFromFile) + '(' + %trim(p_FromMbr)
            + ') to '
            + %trim(p_SrcToLib) + '/' + %trim(p_SrcToFile) + '(' + %trim(p_ToMbr) + ').';
   writeLine();
   codeLine = '// Converted with CVTRPGFREE version ' + VERSION + ' on '
            + %char(%timestamp():*ISO) + '.';
   writeLine();
   codeLine = '// Go to https://sourceforge.net/projects/cvtrpgfree/ for support and updates.';
   writeLine();

   inMainline = *On;

   // <<<<< End of User-Point   <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

EndSr;
//-------------------------------------------------------------------------------------------
//===========================================================================================

/Eject
//==========================================================================================
// Convert C-Spec
//==========================================================================================
Dcl-Proc convertC_Spec;

// -- Procedure Interface ------------------------------------------------------------------
Dcl-PI *N;
End-PI;

// -- Data Structures ----------------------------------------------------------------------

// -- Variables ----------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------

// Control indicators
If condCtrl <> *Blanks;
   workCondCtrl = %xlate(LO:UP:condCtrl);

   If workCondCtrl <> 'AN'
   and workCondCtrl <> 'OR'
   and workCondCtrl <> 'SR'
   and workCondCtrl <> '/E'
   and workCondCtrl <> '+ ';
      nonConvRsn = 'Control indicators are not currently supported.';
      Return;
   ElseIf workCondCtrl = 'SR';
      Clear condCtrl;
      Clear workCondCtrl;
   EndIf;
Else;
   workCondCtrl = *Blanks;
EndIf;

//----------------------------------------------------------------------------------
// Conditioning indicators
If condInd <> *Blanks
and workCondCtrl <> '/E'
and workCondCtrl <> '+ ';
   If %subst(%xlate(LO:UP:opCode):1:2) = 'IF'
   or %subst(%xlate(LO:UP:opCode):1:2) = 'DO';
      nonConvRsn = 'Conditioning indicators on IF or DO are not currently supported.';
      Return;
   Else;
      Exsr subUserCvt_Conditioning;
      Return;
   EndIf;
EndIf;

Select;
   // Keep blank lines.
   When codeLine = *Blanks;
      sourceLine = *Blanks;
      convert = *On;

   //----------------------------------------------------------------------------------
   // EXEC SQL
   When workDirective = '/EXEC SQL' or inSQL;
      Exsr subUserCvt_EXEC_SQL;

   //----------------------------------------------------------------------------------
   // END-EXEC
   When workDirective = '/END-EXEC';
      convert = *On;

   //----------------------------------------------------------------------------------
   // ACQ.
   When %subst(operator:1:3) = 'ACQ';
      Exsr subUserCvt_ACQ;

   //----------------------------------------------------------------------------------
   // ADDDUR.
   When %subst(operator:1:6) = 'ADDDUR';
      Exsr subUserCvt_ADDDUR;

   //----------------------------------------------------------------------------------
   // ADD.
   When %subst(operator:1:3) = 'ADD';
      Exsr subUserCvt_ADD;

   //----------------------------------------------------------------------------------
   // ALLOC.
   When %subst(operator:1:5) = 'ALLOC';
      Exsr subUserCvt_ALLOC;

   //----------------------------------------------------------------------------------
   // BEGSR
   When operator = 'BEGSR';
      Exsr subUserCvt_BEGSR;

   //----------------------------------------------------------------------------------
   // CABxx
   When %subst(operator:1:3) = 'CAB';
      Exsr subUserCvt_CABxx;

   //----------------------------------------------------------------------------------
   // CALLB
   When %subst(operator:1:5) = 'CALLB';
      Exsr subUserCvt_CALLB;

   //----------------------------------------------------------------------------------
   // CALLP
   When %subst(operator:1:5) = 'CALLP' or inCallP;
      Exsr subUserCvt_CALLP;

   //----------------------------------------------------------------------------------
   // CALL
   When %subst(operator:1:4) = 'CALL';
      Exsr subUserCvt_CALL;

   //----------------------------------------------------------------------------------
   // CASxx
   When %subst(operator:1:3) = 'CAS';
      Exsr subUserCvt_CASxx;

   //----------------------------------------------------------------------------------
   // CAT
   When %subst(operator:1:3) = 'CAT';
      Exsr subUserCvt_CAT;

   //----------------------------------------------------------------------------------
   // CHAIN
   When %subst(operator:1:5) = 'CHAIN';
      Exsr subUserCvt_CHAIN;

   //----------------------------------------------------------------------------------
   // CHECK
   When %subst(operator:1:5) = 'CHECK';
      Exsr subUserCvt_CHECKx;

   //----------------------------------------------------------------------------------
   // CLEAR
   When %subst(operator:1:5) = 'CLEAR';
      Exsr subUserCvt_CLEAR;

   //----------------------------------------------------------------------------------
   // CLOSE
   When %subst(operator:1:5) = 'CLOSE';
      Exsr subUserCvt_CLOSE;

   //----------------------------------------------------------------------------------
   // COMMIT
   When %subst(operator:1:6) = 'COMMIT';
      Exsr subUserCvt_COMMIT;

   //----------------------------------------------------------------------------------
   // COMP
   When operator = 'COMP';
      Exsr subUserCvt_COMP;

   //----------------------------------------------------------------------------------
   // DEALLOC.
   When %subst(operator:1:7) = 'DEALLOC';
      Exsr subUserCvt_DEALLOC;

   //----------------------------------------------------------------------------------
   // DEFINE
   When operator = 'DEFINE';
      dropLine = *On;
      convert = *On;

   //----------------------------------------------------------------------------------
   // DELETE
   When %subst(operator:1:6) = 'DELETE';
      Exsr subUserCvt_DELETE;

   //----------------------------------------------------------------------------------
   // DIV (not half-adjusted)
   When operator = 'DIV';
      Exsr subUserCvt_DIV;

   //----------------------------------------------------------------------------------
   // DOxxx
   When %subst(operator:1:2) = 'DO'
   and (%subst(operator:3:3) = 'WEQ'
   or %subst(operator:3:2) = 'W '
   or %subst(operator:3:2) = 'U '
   or %subst(operator:3:3) = 'WGT'
   or %subst(operator:3:3) = 'WLT'
   or %subst(operator:3:3) = 'WNE'
   or %subst(operator:3:3) = 'WGE'
   or %subst(operator:3:3) = 'WLE'
   or %subst(operator:3:3) = 'UEQ'
   or %subst(operator:3:3) = 'UGT'
   or %subst(operator:3:3) = 'ULT'
   or %subst(operator:3:3) = 'UNE'
   or %subst(operator:3:3) = 'UGE'
   or %subst(operator:3:3) = 'ULE'
   or %subst(operator:3:3) = '   ')
   or inDo;
      Exsr subUserCvt_DO;

   //----------------------------------------------------------------------------------
   // DSPLY
   When %subst(operator:1:5) = 'DSPLY';
      Exsr subUserCvt_DSPLY;

   //----------------------------------------------------------------------------------
   // DUMP
   When %subst(operator:1:4) = 'DUMP';
      Exsr subUserCvt_DUMP;

   //----------------------------------------------------------------------------------
   // ELSE
   When operator = 'ELSE';
      Exsr subUserCvt_ELSE;

   //----------------------------------------------------------------------------------
   // ELSEIF
   When operator = 'ELSEIF';
      Exsr subUserCvt_ELSEIF;

   //----------------------------------------------------------------------------------
   // ENDxx
   When %subst(operator:1:3) = 'END';
      Exsr subUserCvt_ENDxx;

   //----------------------------------------------------------------------------------
   // EVALx
   When %subst(operator:1:4) = 'EVAL' or inEval;
      Exsr subUserCvt_EVALx;

   //----------------------------------------------------------------------------------
   // EXCEPT
   When operator = 'EXCEPT';
      Exsr subUserCvt_EXCEPT;

   //----------------------------------------------------------------------------------
   // EXFMT
   When %subst(operator:1:5) = 'EXFMT';
      Exsr subUserCvt_EXFMT;

   //----------------------------------------------------------------------------------
   // EXSR
   When operator = 'EXSR';
      Exsr subUserCvt_EXSR;

   //----------------------------------------------------------------------------------
   // EXTRCT
   When %subst(operator:1:6) = 'EXTRCT';
      Exsr subUserCvt_EXTRCT;

   //----------------------------------------------------------------------------------
   // FEOD
   When %subst(operator:1:4) = 'FEOD';
      Exsr subUserCvt_FEOD;

   //----------------------------------------------------------------------------------
   // FOR
   When operator = 'FOR';
      Exsr subUserCvt_FOR;

   //----------------------------------------------------------------------------------
   // FORCE
   When operator = 'FORCE';
      Exsr subUserCvt_FORCE;

   //----------------------------------------------------------------------------------
   // GOTO
   When %subst(operator:1:4) = 'GOTO';
      Exsr subUserCvt_GOTO;

   //----------------------------------------------------------------------------------
   // IFxx
   When %subst(operator:1:2) = 'IF' or inIf;
      Exsr subUserCvt_IF;

   //----------------------------------------------------------------------------------
   // IN
   When %subst(operator:1:2) = 'IN';
      Exsr subUserCvt_IN;

   //----------------------------------------------------------------------------------
   // ITER
   When operator = 'ITER';
      Exsr subUserCvt_ITER;

   //----------------------------------------------------------------------------------
   // KFLD
   When operator = 'KFLD';
      Exsr subUserCvt_KFLD;

   //----------------------------------------------------------------------------------
   // KLIST
   When operator = 'KLIST';
      Exsr subUserCvt_KLIST;

   //----------------------------------------------------------------------------------
   // LEAVExx;
   When %subst(operator:1:5) = 'LEAVE';
      Exsr subUserCvt_LEAVE;

   //----------------------------------------------------------------------------------
   // LOOKUP
   When operator = 'LOOKUP';
      Exsr subUserCvt_LOOKUP;

   //----------------------------------------------------------------------------------
   // MOVEA
   When %subst(operator:1:5) = 'MOVEA';
      Exsr subUserCvt_MOVEA;

   //----------------------------------------------------------------------------------
   // MOVE/MOVEL
   When operator = 'MONITOR';
      Exsr subUserCvt_MONITOR;

   //----------------------------------------------------------------------------------
   // MOVE/MOVEL
   When %subst(operator:1:4) = 'MOVE';
      Exsr subUserCvt_MOVE;

   //----------------------------------------------------------------------------------
   // MULT.
   When %subst(operator:1:4) = 'MULT';
      Exsr subUserCvt_MULT;

   //----------------------------------------------------------------------------------
   // MVR
   When operator = 'MVR';
      Exsr subUserCvt_MVR;

   //----------------------------------------------------------------------------------
   // NEXT
   When operator = 'NEXT';
      Exsr subUserCvt_NEXT;

   //----------------------------------------------------------------------------------
   // OCCUR (but not both set and get).
   When %subst(operator:1:5) = 'OCCUR';
      Exsr subUserCvt_OCCUR;

   //----------------------------------------------------------------------------------
   // ON-ERROR
   When operator = 'ON-ERROR';
      Exsr subUserCvt_ON_ERROR;

   //----------------------------------------------------------------------------------
   // OPEN
   When %subst(operator:1:4) = 'OPEN';
      Exsr subUserCvt_OPEN;

   //----------------------------------------------------------------------------------
   // OTHER
   When operator = 'OTHER';
      Exsr subUserCvt_OTHER;

   //----------------------------------------------------------------------------------
   // OUT
   When %subst(operator:1:3) = 'OUT';
      Exsr subUserCvt_OUT;

   //----------------------------------------------------------------------------------
   // PARM
   When operator = 'PARM';
      Exsr subUserCvt_PARM;

   //----------------------------------------------------------------------------------
   // PLIST
   When operator = 'PLIST';
      Exsr subUserCvt_PLIST;

   //----------------------------------------------------------------------------------
   // POST
   When %subst(operator:1:4) = 'POST';
      Exsr subUserCvt_POST;

   //----------------------------------------------------------------------------------
   // READ
   When %subst(operator:1:4) = 'READ';
      Exsr subUserCvt_READ;

   //----------------------------------------------------------------------------------
   // REL
   When %subst(operator:1:3) = 'REL';
      Exsr subUserCvt_REL;

   //----------------------------------------------------------------------------------
   // RESET
   When %subst(operator:1:5) = 'RESET';
      Exsr subUserCvt_RESET;

   //----------------------------------------------------------------------------------
   // RETURN
   When %subst(operator:1:6) = 'RETURN';
      Exsr subUserCvt_RETURN;

   //----------------------------------------------------------------------------------
   // ROLBK
   When %subst(operator:1:5) = 'ROLBK';
      Exsr subUserCvt_ROLBK;

   //----------------------------------------------------------------------------------
   // SCAN
   When operator = 'SCAN';
      Exsr subUserCvt_SCAN;

   //----------------------------------------------------------------------------------
   // SELECT
   When operator = 'SELECT';
      Exsr subUserCvt_SELECT;

   //----------------------------------------------------------------------------------
   // SETLL / SETGT
   When %subst(operator:1:5) = 'SETLL'
   or %subst(operator:1:5) = 'SETGT';
      Exsr subUserCvt_SETxx;

   //----------------------------------------------------------------------------------
   // SETOFF
   When operator = 'SETOFF';
      Exsr subUserCvt_SETOFF;

   //----------------------------------------------------------------------------------
   // SETON
   When operator = 'SETON';
      Exsr subUserCvt_SETON;

   //----------------------------------------------------------------------------------
   // SHTDN
   When operator = 'SHTDN';
      Exsr subUserCvt_SHTDN;

   //----------------------------------------------------------------------------------
   // SORTA.
   When %subst(operator:1:5) = 'SORTA';
      Exsr subUserCvt_SORTA;

   //----------------------------------------------------------------------------------
   // SUBDUR.
   When %subst(operator:1:6) = 'SUBDUR';
      Exsr subUserCvt_SUBDUR;

   //----------------------------------------------------------------------------------
   // SUBST.
   When %subst(operator:1:5) = 'SUBST';
      Exsr subUserCvt_SUBST;

   //----------------------------------------------------------------------------------
   // SUB
   When %subst(operator:1:3) = 'SUB';
      Exsr subUserCvt_SUB;

   //----------------------------------------------------------------------------------
   // TAG
   When operator = 'TAG';
      Exsr subUserCvt_TAG;

   //----------------------------------------------------------------------------------
   // TESTB
   When operator = 'TESTB';

   //----------------------------------------------------------------------------------
   // TESTN
   When operator = 'TESTN';

   //----------------------------------------------------------------------------------
   // TESTZ
   When operator = 'TESTZ';

   //----------------------------------------------------------------------------------
   // TEST
   When %subst(operator:1:4) = 'TEST';
      Exsr subUserCvt_TEST;

   //----------------------------------------------------------------------------------
   // TIME
   When operator = 'TIME';
      Exsr subUserCvt_TIME;

   //----------------------------------------------------------------------------------
   // UPDATE
   When %subst(operator:1:6) = 'UPDATE';
      Exsr subUserCvt_UPDATE;

   //----------------------------------------------------------------------------------
   // UNLOCK
   When %subst(operator:1:6) = 'UNLOCK';
      Exsr subUserCvt_UNLOCK;

   //----------------------------------------------------------------------------------
   // WHENxx
   When %subst(operator:1:4) = 'WHEN' or inWhen;
      Exsr subUserCvt_WHEN;

   //----------------------------------------------------------------------------------
   // WRITE
   When %subst(operator:1:5) = 'WRITE';
      Exsr subUserCvt_WRITE;

   //----------------------------------------------------------------------------------
   // XLATE
   When %subst(operator:1:5) = 'XLATE';
      Exsr subUserCvt_XLATE;

   //----------------------------------------------------------------------------------
   // Z-ADD (half-adjust not converted).
   When %subst(operator:1:5) = 'Z-ADD';
      Exsr subUserCvt_Z_ADD;

   //----------------------------------------------------------------------------------
   // Z-SUB (half-adjust not converted).
   When %subst(operator:1:5) = 'Z-SUB';
      Exsr subUserCvt_Z_SUB;
EndSl;

// Ensure any in-line definitions are cleared (they should have been moved to D-specs).
If not convert;
   Clear len;
   Clear dec;
EndIf;

Return;
//-------------------------------------------------------------------------------------------

/Eject
//-------------------------------------------------------------------------------------------
// Convert Conditioning Indicators.
//-------------------------------------------------------------------------------------------
BegSr subUserCvt_Conditioning;

   If condCtrl = 'AN';
      sourceLine = 'and';
   ElseIf condCtrl = 'OR';
      sourceLine = 'or';
   Else;
      sourceLine = 'If';
   EndIf;

   sourceLine = %trim(sourceLine) + ' *IN' + condInd;

   If condNot = 'N';
      sourceLine = %trim(sourceLine) + ' = *Off';
   Else;
      sourceLine = %trim(sourceLine) + ' = *On';
   EndIf;

   If operator <> *Blanks;
      sourceLine = %trim(sourceLine) + ';';
   EndIf;

   // Is this a pre-line indicator or current line?
   If operator = *Blanks;
      reprocessLine = *Off;
   Else;
      inLineCondition = *On;
      // Reprocess the current line (sans conditioning indicators).
      condCtrl = *Blanks;
      condNot  = *Blanks;
      condInd  = *Blanks;
      savedSRCDTA = SRCDTA;
      reprocessLine = *On;
   EndIf;

   convert = *On;

EndSr;
//-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert ACQ.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_ACQ;

    operator = setExtender_E(operator:lw);

    sourceLine = %trim(operator) + ' ' + %trim(factor1)
               + ' ' + %trim(factor2) + ';';

    // Set resulting indicators?
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert ADD.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_ADD;

    // Half-adjust?
    x = %scan('H':operator:4);
    If x > 0;
       sourceLine = 'Eval(H)';
    Else;
       sourceLine = *Blanks;
    EndIf;

    If factor1 = *Blanks;
       sourceLine = %trimr(sourceLine) + ' ' + %trim(result)
                  + ' = ' + %trim(result)
                  + ' + ' + %trim(factor2) +';';
    Else;
       sourceLine = %trimr(sourceLine) + ' ' + %trim(result)
                  + ' = ' + %trim(factor1)
                  + ' + ' + %trim(factor2) + ';';
    EndIf;

    sourceLine = %trim(sourceLine);

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert ADDDUR.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_ADDDUR;

    // Split out duration and code.
    x = %scan(':':factor2);
    If x = 0;
       nonConvRsn =  'No duration code specified.';
       LeaveSr;
    EndIf;

    durDuration = %trim(%subst(factor2:1:x-1));
    durCode     = %xlate(LO:UP:%trim(%subst(factor2:x+1)));

    Select;
       When durCode = '*Y' or durCode = '*YEARS';
          durCode = '%years';
       When durCode = '*M' or durCode = '*MONTHS';
          durCode = '%months';
       When durCode = '*D' or durCode = '*DAYS';
          durCode = '%days';
       When durCode = '*H' or durCode = '*HOURS';
          durCode = '%hours';
       When durCode = '*MN' or durCode = '*MINUTES';
          durCode = '%minutes';
       When durCode = '*S' or durCode = '*SECONDS';
          durCode = '%seconds';
       When durCode = '*MS' or durCode = '*MSECONDS';
          durCode = '%mseconds';
       Other;
          nonConvRsn = 'Invalid duration code specified.';
          LeaveSr;
    EndSl;

    If factor1 = *Blanks;
       sourceLine = %trim(result) + ' = ' + %trim(result);
    Else;
       sourceLine = %trim(result) + ' = ' + %trim(factor1);
    EndIf;

    sourceLine = %trimr(sourceLine) + ' + ' + %trim(durCode)
               + '(' + %trim(durDuration) + ');';

    // Set resulting indicators?
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert ALLOC.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_ALLOC;

    sourceLine = %trim(result) + ' = %alloc(' + %trim(factor2) + ');';

    // Set resulting indicators?
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert BEGSR.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_BEGSR;

    sourceLine = 'BegSr ' + %trim(factor1) + ';';

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
//-------------------------------------------------------------------------------------------
// Convert CALLB.
//-------------------------------------------------------------------------------------------
BegSr subUserCvt_CALLB;

   If %scan('D':%xlate(LO:UP:opCode)) = 0;  // No D-extender...no equivalent in freeform.
      // Hand over to CALL conversion as it's basically the same.
      Exsr subUserCvt_CALL;
   ElseIf p_ConvPList = 'Y';
      convert = *Off;
      nonConvRsn = 'Conversion of CALLB with extender D is not supported';
   EndIf;

EndSr;
//-------------------------------------------------------------------------------------------

/Eject
//-------------------------------------------------------------------------------------------
// Convert CALL.
//-------------------------------------------------------------------------------------------
BegSr subUserCvt_CALL;

   If p_ConvPList <> 'Y';
      convert = *Off;
      nonConvRsn = 'Conversion not selected on command';
      LeaveSr;
   EndIf;

   If parmListCount > 0;
      parmListName = %xlate(LO:UP:factor2);
      x = %lookup(SRCSEQ:parmList(*).lineNumber:1:parmListCount);
      If x > 0;
         If p_SuppressMsgs <> 'Y' and p_RetPList = 'Y';
            savedSRCDTA = SRCDTA;
            lineType = *Blank;
            directive = *Blanks;
            codeLine = '// >>>>> Automatically removed by conversion';
            writeLine();
            SRCDTA = savedSRCDTA;
         EndIf;

         // Comment it out.
         sourceLine = '//' + nonPrefix;
         lineType = *Blank;
         inComment = *On;
         convert = *On;

         // Set parameters for callp definition.
         CALLPOutput = *On;    // Convert to a CALLP.
         CALLPIndex = x;
         CALLPSeq = SRCSEQ;
         CALLPPgm = parmList(x).listName;

         CALLPExtenders = '';
         If lw <> *Blanks;      // Error indicator set.
            ERRCheck = *On;
            ERRInd = lw;
            CALLPExtenders = '(E)';
         Else;
            If %scan('(':operator) > 0;
               CALLPExtenders = '(E)';
            EndIf;
         EndIf;

         parmListName = parmList(x).listName;

         If parmList(x).listPList <> *Blanks;    // Uses a real parameter list.
            x = %lookup(parmList(x).listPList
                       :parmList(*).listName:1:parmListCount);
            CALLPPList = parmList(x).listName;
            CALLPPlistIndex = x;
         Else;
            CALLPPlist = *Blanks;
            CALLPPListIndex = CALLPIndex;
         EndIf;

         // Retain converted PList?
         If p_RetPList <> 'Y';
            dropLine = *On;
         EndIf;
      EndIf;
   EndIf;

EndSr;
//-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert CALLP.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_CALLP;

    // Returning for a multi-line CALLP - restore the original opcode.
    If inCallP;
       operator = callPOperator;
    EndIf;

    checkSpan();  // Does this line span more than one line?

    If not inCallP;         // First line of CALLP.

       sourceLine = %trimr(operator) + ' ' + %trim(extFactor2);
       If not inSpan;
          sourceLine = %trim(sourceLine) + ';';
       Else;
          callPOffset = %len(%trim(operator)) + 2;
          inCallP = *On;
          inSpan = *Off;
       EndIf;
    Else;                   // Second+ line of CALLP.
       sourceLine = *Blanks;
       sourceLine = %trim(extFactor2);
       If not inSpan;
          sourceLine = %trimr(sourceLine) + ';';
          //            inCallP = *Off;
       EndIf;
       inSpan = *Off;
    EndIf;

    // Multi-line CALLP?  Save the opcode.
    If inCallP;
       callPOperator = operator;
    Else;
       callPOperator = *Blanks;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
//-------------------------------------------------------------------------------------------
// Convert CABxx.
//-------------------------------------------------------------------------------------------
BegSr subUserCvt_CABxx;

   If tagCount > 0;
      If result <> *Blanks;
         tagName = %xlate(LO:UP:result);
         x = %lookup(tagName:tagList(*).tagName:1:tagCount);
         If x = 0;
            nonConvRsn =  'TAG not found.';
            LeaveSr;
         EndIf;
         If tagList(x).tagType <> 'ENDSR';
            nonConvRsn =  'associated TAG is not on ENDSR.';
            LeaveSr;
         EndIf;

         tagList(x).tagUsageCount -= 1; // Keep a track of how many we've converted.
      EndIf;
   Else;
      nonConvRsn =  'TAG not found.';
      LeaveSr;
   EndIf;

   // Extract components.
   inCAB = *On;
   caseSubRoutine = %trim(result);
   If caseSubroutine = *Blanks;
      caseOperator = *Blanks;  // Doesn't matter...no actual branch being done.
   Else;
      caseOperator = %subst(operator:4:2);
   EndIf;

   // Determine comparator.
   If caseOperator = 'EQ';
      caseOperator = '=';
   ElseIf caseOperator = 'GT';
      caseOperator = '>';
   ElseIf caseOperator = 'LT';
      caseOperator = '<';
   ElseIf caseOperator = 'GE';
      caseOperator = '>=';
   ElseIf caseOperator = 'LE';
      caseOperator = '<=';
   ElseIf caseOperator = 'NE';
      caseOperator = '<>';
   Else;
      caseOperator = *Blanks;
   EndIf;

   CABFactor1 = %trim(factor1);
   CABFactor2 = %trim(factor2);

   sourceLine = *Blanks;     // Don't output anything just yet.
   dropLine = *On;

   // Do we need to set Resulting indicators?
   If hi <> *Blanks;
      HICheck = *On;
      HIInd = hi;
      HIFactor1 = %trim(factor1);
      HIFactor2 = %trim(factor2);
   EndIf;
   If lw <> *Blanks;
      LWCheck = *On;
      LWInd = lw;
      LWFactor1 = %trim(factor1);
      LWFactor2 = %trim(factor2);
   EndIf;
   If eq <> *Blanks;
      EQCheck = *On;
      EQInd = eq;
      EQFactor1 = %trim(factor1);
      EQFactor2 = %trim(factor2);
   EndIf;

   convert = *On;

EndSr;
//-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert CASxx.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_CASxx;

    // Extract components.
    caseSubRoutine = %trim(result);
    caseOperator = %subst(operator:4:2);

    // Determine comparator.
    If caseOperator = 'EQ';
       caseOperator = '=';
    ElseIf caseOperator = 'GT';
       caseOperator = '>';
    ElseIf caseOperator = 'LT';
       caseOperator = '<';
    ElseIf caseOperator = 'GE';
       caseOperator = '>=';
    ElseIf caseOperator = 'LE';
       caseOperator = '<=';
    ElseIf caseOperator = 'NE';
       caseOperator = '<>';
    Else;
       caseOperator = 'Else';
    EndIf;

    // Build 'If' statement.
    If not inCase;
       sourceLine = 'If ' +  %trim(factor1) + ' '
                  + %trim(caseOperator) + ' ' + %trim(factor2)
                  + ';';
       inCase = *On;
    Else;
       If caseOperator = 'Else';
          sourceLine = 'Else;';
       Else;
          sourceLine = 'ElseIf ' +  %trim(factor1) + ' '
                     + %trim(caseOperator) + ' ' + %trim(factor2)
                     + ';';
       EndIf;
    EndIf;

    // Do we need to set Resulting indicators?
    If hi <> *Blanks;
       HICheck = *On;
       HIInd = hi;
       HIFactor1 = %trim(factor1);
       HIFactor2 = %trim(factor2);
    EndIf;
    If lw <> *Blanks;
       LWCheck = *On;
       LWInd = lw;
       LWFactor1 = %trim(factor1);
       LWFactor2 = %trim(factor2);
    EndIf;
    If eq <> *Blanks;
       EQCheck = *On;
       EQInd = eq;
       EQFactor1 = %trim(factor1);
       EQFactor2 = %trim(factor2);
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
//-------------------------------------------------------------------------------------------
// Convert CAT.
//-------------------------------------------------------------------------------------------
BegSr subUserCvt_CAT;

   // Pad the result?
   x = %scan('P':operator:4);
   If x > 0;
      If not inPadding;
         inPadding = *On;
         savedSRCDTA = SRCDTA;
         reprocessLine = *On;
         sourceLine = 'Clear ' + %trim(result) + ';';
         convert = *On;
         LeaveSr;
      Else;
         inPadding = *Off;
      EndIf;
   EndIf;

   // Determine first part of string.
   If factor1 = *Blanks;
      catFactor1 = %trim(result);
   Else;
      catFactor1 = %trim(factor1);
   EndIf;

   // Determine number of blanks.
   x = %scan(':':factor2);
   If x = 0;   // No trimming required;
      catBlanks = *Blanks;
      catFactor2 = %trim(factor2);
   Else;
      catBlanks = %subst(factor2:x+1);
      catFactor2 = %subst(factor2:1:x-1);
   EndIf;

   // Determine second part of String.

   // Blanks zero?
   If catBlanks <> *blanks;
      Monitor;
         catCount = %dec(catBlanks:3:0);
      On-Error;
         LeaveSr; // Uses a field to vary the number of blanks - don't convert.
      EndMon;
   EndIf;

   // If padding is not specified, check the lengths to confirm conversion possible.
   x = %scan('P':operator:4);
   If x = 0                                                 // Not padding.
   and catFactor1 <> *Blanks                                // Factor1 specified.
   and %xlate(LO:UP:catFactor1) <> %xlate(LO:UP:result);    // Factor1 not the same as result
      // Determine lengths of the fields.
      sourceVariable  = retrieveVariableDef(catFactor1);
      sourceVariable2 = retrieveVariableDef(catFactor2);
      targetVariable  = retrieveVariableDef(result);

      If sourceVariable.length + sourceVariable2.length + catCount < targetVariable.length;
         nonConvRsn =  'No padding specified, result unpredictable.';
         LeaveSr;    // Don't convert - too difficult to get right.
      EndIf;
   EndIf;

   // Drop the extender.
   operator = 'CAT';

   // Build the new line.
   If catBlanks = *Blanks;
      // No trimming.
      sourceLine = %trim(result) + ' = ' + %trim(catFactor1)
                 + ' + ' + %trim(catFactor2) + ';';
   ElseIf catCount = 0;
      // No spaces.
      sourceLine = %trim(result) + ' = %trimr(' + %trim(catFactor1)
                 + ') + %trim(' + %trim(catFactor2) + ');';
   ElseIf catCount > 25;
      LeaveSr; // Arbitrary upper limit - don't convert.
   Else;
      sourceLine = %trim(result) + ' = %trimr(' + %trim(catFactor1) + ')';
      // Literal for factor2?
      If %subst(catFactor2:1:1) = '''';
         sourceLine = %trimr(sourceLine)
                    + ' + ''' + %str(%addr(blanks):catCount) + ''' + '
                    + %trim(catFactor2) + ';';
      Else;
         sourceLine = %trimr(sourceLine)
                    + ' + ''' + %str(%addr(blanks):catCount) + ''' + '
                    + '%triml(' + %trim(catFactor2) + ');';
      EndIf;
   EndIf;

   // Set resulting indicators?
   If lw <> *Blanks;
      ERRCheck = *On;
      ERRInd = lw;
   EndIf;

   convert = *On;

EndSr;
//-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert CHAIN.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_CHAIN;

    operator = setExtender_E(operator:lw);

    sourceLine = %trim(operator) + ' ' + getKeyList(factor1) + ' '
               + %trim(factor2);

    If result <> *Blanks;
       sourceLine = %trim(sourceLine)  + ' ' + %trim(result) + ';';
    Else;
       sourceLine = %trim(sourceLine)  + ';';
    EndIf;

    // Set resulting indicators?
    If hi <> *Blanks;
       NRFCheck = *On;
       NRFInd = hi;
       NRFFile = %trim(factor2);
    EndIf;
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert CHECK.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_CHECKx;

    // Don't convert of no result specified.
    If result = *Blanks;
       nonConvRsn = 'No result field specified.';
       LeaveSr;
    EndIf;

    If %subst(operator:1:6) = 'CHECKR';
       operator = '%checkr(';
    Else;
       operator = '%check(';
    EndIf;

    // Determine starting point.
    x = %scan(':':factor2);

    // Build the new line.
    If x = 0;
       // No start specified.
       sourceLine = %trim(result) + ' = ' + %trim(operator)
                  + %trim(factor1) + ':' + %trim(factor2) + ');';
    Else;
       // Start from a specified point.
       sourceLine = %trim(result) + ' = ' + %trim(operator)
                  + %trim(factor1) + ':' + %subst(factor2:1:x-1)
                  + ':' + %trim(%subst(factor2:x+1))
                  + ');';
    EndIf;

    // Set resulting indicators?
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;
    If eq <> *Blanks;
       HICheck = *On;
       HIInd = eq;
       HIFactor1 = result;
       HIFactor2 = '0';
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert CLEAR.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_CLEAR;

    sourceLine = 'Clear ' + %trim(result) + ';';

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert CLOSE.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_CLOSE;

    operator = setExtender_E(operator:lw);

    sourceLine = %trim(operator) + ' ' + %trim(factor2) + ';';

    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert COMMIT.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_COMMIT;

    operator = setExtender_E(operator:lw);

    sourceLine = %trim(operator) + ' ' + %trim(factor1);

    sourceLine = %trim(sourceLine)  + ';';

    // Check indicators?
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert COMP.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_COMP;

    // Set resulting indicators to check.
    If hi <> *Blanks;
       HICheck = *On;
       HIInd = hi;
       HIFactor1 = factor1;
       HIFactor2 = factor2;
    EndIf;

    If lw <> *Blanks;
       LWCheck = *On;
       LWInd = lw;
       LWFactor1 = factor1;
       LWFactor2 = factor2;
    EndIf;

    If eq <> *Blanks;
       EQCheck = *On;
       EQInd = eq;
       EQFactor1 = factor1;
       EQFactor2 = factor2;
    EndIf;

    // Drop the current line.
    dropLine = *On;
    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert DEALLOC.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_DEALLOC;

    operator = setExtender_E(operator:lw);

    sourceLine = %trim(operator) + ' ' + %trim(result);

    sourceLine = %trim(sourceLine)  + ';';

    // Set resulting indicators?
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert DELETE.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_DELETE;

    operator = setExtender_E(operator:lw);

    sourceLine = %trim(operator) + ' ' + %trim(factor2);

    sourceLine = %trim(sourceLine)  + ';';

    // Check indicators?
    If hi <> *Blanks;
       NRFCheck = *On;
       NRFInd = eq;
       NRFFile = %trim(factor2);
    EndIf;
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert DIV.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_DIV;

    // Half-adjust?
    If %scan('H':operator:3) > 0;
       sourceLine = 'Eval(H) ';
    Else;
       sourceLine = *Blanks;
    EndIf;

    If factor1 = *Blanks;
       divFactor1 = result;
       divFactor2 = factor2;
    Else;
       divFactor1 = factor1;
       divFactor2 = factor2;
    EndIf;

    sourceLine = %trim( %trimr(sourceLine) + ' ' + %trim(result)
               + ' = ' + %trim(divFactor1) + ' / '
               + %trim(divFactor2) + ';');

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert DO.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_DO;

    If inDo;
       operator = doOperator;
    EndIf;

    checkSpan();  // Does this line span more than one line?

    If operator = 'DOW'     // Use Extended Factor2.
    or operator = 'DOU';    // Use Extended Factor2.
       If not inDo;         // First line of DO.
          sourceLine = %trim(operator) + ' ' + %trim(extFactor2);
          If not inSpan;
             sourceLine = %trim(sourceLine) + ';';
          Else;
             inDo = *On;
             inSpan = *Off;
          EndIf;
       Else;                   // Second line of DO.
          sourceLine = *Blanks;
          //            %subst(sourceLine:40) = %trim(extFactor2);
          sourceLine = %trim(extFactor2);
          If not inSpan;
             sourceLine = %trimr(sourceLine) + ';';
             //               inDo = *Off;
          EndIf;
          inSpan = *Off;
       EndIf;
       doCompare = '!!';    // Just a regular DO.
    Else;
       // Fixed format.
       opCode = %xlate(LO:UP:opCode);
       If not inDo;         // First line of DO.
          doCompare = %subst(opCode:4:2);
          sourceLine = %subst(opcode:1:3);
       Else;                // Second line of DO.
          If %subst(opCode:1:3) = 'AND';
             doCompare = %subst(opCode:4:2);
             sourceLine = 'And';
          ElseIf %subst(opCode:1:2) = 'OR';
             doCompare = %subst(opCode:3:2);
             sourceLine = 'Or';
          Else;
             // No longer in a DO...reprocess the line.
             inDo = *Off;
             dropLine = *On;
             reprocessLine = *On;
             sourceLine = SourceData;
             LeaveSr;
          EndIf;
       EndIf;

       If doCompare = 'EQ';
          doCompare = '=';
       ElseIf doCompare = 'GT';
          doCompare = '>';
       ElseIf doCompare = 'GE';
          doCompare = '>=';
       ElseIf doCompare = 'LT';
          doCompare = '<';
       ElseIf doCompare = 'LE';
          doCompare = '<=';
       ElseIf doCompare = 'NE';
          doCompare = '<>';
       ElseIf doCompare = '!!';
          // Do nothing.
          Else;    // Just DO - convert to FOR.
          If factor1 = *Blanks;
             forFactor1 = '1';
          Else;
             forFactor1 = factor1;
          EndIf;
          If factor2 = *Blanks;
             forFactor2 = '1';
          Else;
             forFactor2 = factor2;
          EndIf;
          factor1 = *Blanks;
          factor2 = *Blanks;
          doCompare = *Blanks;
          If result = *Blanks;
             result = 'ZZ_doCount';
          EndIf;
          sourceLine = 'For ' + %trim(result) + ' = '
                     + %trim(forFactor1) + ' To '
                     + %trim(forFactor2);
       EndIf;

       sourceLine = %trimr(sourceLine) + ' ' + %trim(factor1)
                          + ' ' + %trim(doCompare) + ' '
                          + %trim(factor2);
       If not inSpan;
          sourceLine = %trimr(sourceLine) + ';';
          inDo = *Off;
       Else;
          inDo = *On;
          inSpan = *Off;
       EndIf;
    EndIf;

    // If multi-line, retain the original opcode.
    If inDo;
       doOperator = operator;
    Else;
       doOperator = *Blanks;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert DSPLY.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_DSPLY;

    operator = setExtender_E(operator:lw);

    sourceLine = %trim(operator);

    If factor1 <> *Blanks;
       sourceLine = %trimr(sourceLine) + ' ' + %trim(factor1);
       If factor2 <> *Blanks;
          sourceLine = %trimr(sourceLine) + ' ' + %trim(factor2);
          If result <> *Blanks;
             sourceLine = %trimr(sourceLine) + ' ' + %trim(result);
          EndIf;
       EndIf;
    EndIf;

    sourceLine = %trimr(sourceLine) + ';';

    // Set resulting indicators?
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert DUMP.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_DUMP;

    If factor1 <> *Blanks;
       sourceLine = %trim(operator) + ' ' + %trim(factor1) + ';';
    Else;
       sourceLine = %trim(operator) + ';';
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert ELSE.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_ELSE;

    sourceLine = 'Else;';

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert ELSEIF.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_ELSEIF;


    Exsr subUserCvt_IF;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert ENDxx.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_ENDxx;

    // ENDSR with a TAG...can we remove it?
    If %trim(operator) = 'ENDSR';
       If %len(%trim(factor1)) > 0;
          If tagCount > 0;
             x = %lookup(%xlate(LO:UP:factor1):tagList(*).tagName:1:tagCount);
             If x = 0;
                nonConvRsn = 'Tag on ENDSR not found in tag list (this is an internal error)';
                LeaveSr;
             Else;
                If tagList(x).tagUsageCount > 0;
                   nonConvRsn = 'Cannot remove TAG on ENDSR as it is still in use';
                   LeaveSr;
                Else;
                   savedComment = factor1;
                   factor1 = *Blanks;
                   // Continue with conversion...
                EndIf;
             EndIf;
          Else;
             nonConvRsn = 'Label on ENDSR is not supported in free-form';
             LeaveSr;
          EndIf;
       EndIf;
    EndIf;

    // Do we need to convert an ENDDO to ENDFOR?
    If %trim(operator) = 'ENDDO' or %trim(operator) = 'END';
       If forCount > 0;
          If forLevel(forCount) = indentCount - 1;
             operator = 'ENDFOR' + ' ' + %trim(factor2);
             If factor2 <> *Blanks;
                savedSRCDTA = SRCDTA;
                fullLine = '* CHECK: This is a converted ENDDO -'
                         + ' Please add ''BY'' to the corresponding'
                         + ' FOR';
                writeLine();
                SRCDTA = savedSRCDTA;
             EndIf;
             //               forCount -= 1; // Remove from the stack.
          EndIf;
       EndIf;
    EndIf;

    // Convert END to ENDDO?
    If %trim(operator) = 'ENDDO' or %trim(operator) = 'END';
       If doCount > 0;
          If doLevel(doCount) = indentCount - 1;
             operator = 'ENDDO';
             //               doCount -= 1; // Remove from the stack.
          EndIf;
       EndIf;
    EndIf;

    If %trim(operator) = 'END';
       If inCase;
          operator = 'ENDCS';
       Else;
          operator = 'ENDIF';
       EndIf;
    EndIf;

    sourceLine = %trim(operator) + ';';

    convert = *On;

    If operator = 'ENDCS';
       inCase = *Off;
    EndIf;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert EVALx.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_EVALx;

    // Returning for a multi-line EVAL - restore the original opcode.
    If inEval;
       operator = evalOperator;
    EndIf;

    checkSpan();  // Does this line span more than one line?

    If not inEval;          // First line of EVAL.
       inEval = *On;
       If %scan('H':operator:5) > 0  // Half-adjust.
       or %scan('R':operator:1) > 0; // EVALR.
          sourceLine = %trimr(operator) + ' ' + %trim(extFactor2);
       Else;
          sourceLine = %trim(extFactor2);
       EndIf;
       If not inSpan;
          sourceLine = %trim(sourceLine) + ';';
       Else;
          inSpan = *Off;
       EndIf;
    Else;                   // Second+ line of EVAL.
       sourceLine = *Blanks;
       %subst(sourceLine:%len(%trim(operator)) + 2)
             = %trim(extFactor2);
       If not inSpan;
          sourceLine = %trimr(sourceLine) + ';';
       EndIf;
       inSpan = *Off;
    EndIf;

    // Multi-line EVAL?  Save the opcode.
    If inEval;
       evalOperator = operator;
    Else;
       evalOperator = *Blanks;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert EXCEPT.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_EXCEPT;

    sourceLine = %trim(operator) + ' ' + %trim(factor2) + ';';

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert Embedded SQL.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_EXEC_SQL;

    checkSpan();  // Does this line span more than one line?

    If workDirective = '/EXEC SQL';
       sourceLine = 'Exec SQL';
       inSQL = *On;
       inSpan = *Off;
    Else;
       sourceLine = %trimr(%subst(codeLine:2));
       If not inSpan;
          sourceLine = %trim(sourceLine) + ';';
       Else;
          inSQL = *On;
          inSpan = *Off;
       EndIf;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert EXFMT.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_EXFMT;

    operator = setExtender_E(operator:lw);

    sourceLine = %trim(operator) + ' ' + %trim(factor2);

    // Append datastructure?
    If result <> *Blanks;
       sourceLine = %trim(sourceLine)  + ' ' + %trim(result) + ';';
    Else;
       sourceLine = %trim(sourceLine)  + ';';
    EndIf;

    // Check indicators?
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert EXSR.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_EXSR;

    sourceLine = 'ExSr ' + %trim(factor2) + ';';

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert EXTRCT
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_EXTRCT;

    // Split out duration and code.
    x = %scan(':':factor2);
    If x = 0;
       nonConvRsn =  'No duration code specified.';
       LeaveSr;
    EndIf;

    durDuration = %trim(%subst(factor2:1:x-1));
    durCode     = %xlate(LO:UP:%trim(%subst(factor2:x+1)));

    Select;
       When durCode = '*Y' or durCode = '*YEARS';

       When durCode = '*M' or durCode = '*MONTHS';
       When durCode = '*D' or durCode = '*DAYS';
       When durCode = '*H' or durCode = '*HOURS';
       When durCode = '*MN' or durCode = '*MINUTES';
       When durCode = '*S' or durCode = '*SECONDS';
       When durCode = '*MS' or durCode = '*MSECONDS';
       Other;
          nonConvRsn = 'Invalid duration code specified.';
          LeaveSr;
    EndSl;

    sourceLine = %trim(result) + ' = %subdt(' + %trim(durDuration)
               + ':' + %trim(durCode) + ');';

    // Check indicators?
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert FEOD.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_FEOD;

    operator = setExtender_E(operator:lw);

    sourceLine = %trim(operator) + ' ' + %trim(factor2) + ';';

    // Check indicators?
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert FORCE.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_FORCE;

    sourceLine = %trim(operator) + ' ' + %trim(extFactor2) + ';';

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert FOR.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_FOR;

    sourceLine = 'For ' + %trim(extFactor2) + ';';

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
//-------------------------------------------------------------------------------------------
// Convert GOTO
//-------------------------------------------------------------------------------------------
BegSr subUserCvt_GOTO;

   If tagCount > 0;
      tagName = %xlate(LO:UP:factor2);
      x = %lookup(tagName:tagList(*).tagName:1:tagCount);
      If x > 0 and tagList(x).tagType = 'ENDSR';
            tagList(x).tagUsageCount -= 1; // Keep a track of how many we've converted.
            sourceLine = 'LeaveSr;';
            convert = *On;

      Else;
         nonConvRsn =  'TAG not found or not an ENDSR.';
         LeaveSr;
      EndIf;
   EndIf;

EndSr;
//-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert IF.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_IF;

    // Returning for a multi-line IF?  Reinstate original opcode.
    If inIf;
       operator = ifOperator;
    EndIf;

    checkSpan();  // Does this line span more than one line?

    If operator = 'IF'         // Use Extended Factor2.
    or operator = 'ELSEIF';    // Use Extended Factor2.
       If not inIf;            // First line of IF.
          sourceLine = %trim(operator) + ' ' + %trim(extFactor2);
          If not inSpan;
             sourceLine = %trim(sourceLine) + ';';
          Else;
             inIf = *On;
             inSpan = *Off;
          EndIf;
       Else;                   // Second line of IF.
          //            sourceLine = *Blanks;
          //            %subst(sourceLine:40) = %trim(extFactor2);
          sourceLine = %trim(extFactor2);
          If not inSpan;
             sourceLine = %trimr(sourceLine) + ';';
          EndIf;
          inSpan = *Off;
       EndIf;
    Else;
       // Fixed format.
       opCode = %xlate(LO:UP:opCode);
       If not inIf;         // First line of IF.
          ifCompare = %subst(opCode:3:2);
          sourceLine = 'If';
       Else;                // Second line of IF.
          If %subst(opCode:1:3) = 'AND';
             ifCompare = %subst(opCode:4:2);
             sourceLine = 'And';
          ElseIf %subst(opCode:1:2) = 'OR';
             ifCompare = %subst(opCode:3:2);
             sourceLine = 'Or';
          Else;
             // No longer in an if...reprocess the line.
             inIf = *Off;
             dropLine = *On;
             reprocessLine = *On;
             sourceLine = SourceData;
             LeaveSr;
          EndIf;
       EndIf;
       If ifCompare = 'EQ';
          ifCompare = '=';
       ElseIf ifCompare = 'GT';
          ifCompare = '>';
       ElseIf ifCompare = 'GE';
          ifCompare = '>=';
       ElseIf ifCompare = 'LT';
          ifCompare = '<';
       ElseIf ifCompare = 'LE';
          ifCompare = '<=';
       ElseIf ifCompare = 'NE';
          ifCompare = '<>';
       EndIf;
       sourceLine = %trimr(sourceLine) + ' ' + %trim(factor1)
                          + ' ' + %trim(ifCompare) + ' '
                          + %trim(factor2);
       If not inSpan;
          sourceLine = %trimr(sourceLine) + ';';
          inIf = *Off;
       Else;
          inIf = *On;
          inSpan = *Off;
       EndIf;
    EndIf;

    // Multi-line IF?  Retain original opcode.
    If inIf;
       ifOperator = operator;
    Else;
       ifOperator = *Blanks;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert IN.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_IN;

    operator = setExtender_E(operator:lw);

    If factor1 <> *Blanks;
       sourceLine = %trim(operator) + ' ' + %trim(factor1) + ' '
                  + %trim(factor2) + ';';
    Else;
       sourceLine = %trim(operator) + ' ' + %trim(factor2) + ';';
    EndIf;

    // Set resulting indicators?
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert ITER.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_ITER;

    sourceLine = %trim(operator) + ';';

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert KFLD
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_KFLD;

   If p_ConvKList <> 'Y';
      convert = *Off;
      nonConvRsn = 'Conversion not selected on command';
      LeaveSr;
   EndIf;

   If keyListCount > 0;
      x = %lookup(keyListName:keyList(*).listName:1:keyListCount);
      If x > 0;
         // Comment it out.
         sourceLine = '//' + nonPrefix;
         lineType = *Blank;
         inComment = *On;
         convert = *On;

         // Retain converted KList?
         If p_RetKList <> 'Y';
            dropLine = *On;
         EndIf;
      EndIf;
   EndIf;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
//-------------------------------------------------------------------------------------------
// Convert KLIST
//-------------------------------------------------------------------------------------------
BegSr subUserCvt_KLIST;

   If p_ConvKList <> 'Y';
      convert = *Off;
      nonConvRsn = 'Conversion not selected on command';
      LeaveSr;
   EndIf;

   If keyListCount > 0;
      keyListName = %xlate(LO:UP:factor1);
      x = %lookup(keyListName:keyList(*).listName:1:keyListCount);
      If x > 0;
         If p_SuppressMsgs <> 'Y' and p_RetKList = 'Y';
            savedSRCDTA = SRCDTA;
            lineType = *Blank;
            directive = *Blanks;
            codeLine = '// >>>>> Automatically removed by conversion';
            writeLine();
            SRCDTA = savedSRCDTA;
         EndIf;

         // Comment it out.
         sourceLine = '//' + nonPrefix;
         lineType = *Blank;
         inComment = *On;
         convert = *On;

         // Retain converted KList?
         If p_RetKList <> 'Y';
            dropLine = *On;
         EndIf;
      EndIf;
   EndIf;

EndSr;
//-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert LEAVExx.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_LEAVE;

    sourceLine = %trim(operator) + ';';

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert LOOKUP.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_LOOKUP;



 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert MONITOR.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_MONITOR;

    sourceLine = 'Monitor;';

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
//-------------------------------------------------------------------------------------------
// Convert MOVE.
//-------------------------------------------------------------------------------------------
BegSr subUserCvt_MOVE;

   // No conversion for MOVE statements.
   If p_ConvMOVE <> 'Y';
      nonConvRsn =  'CVTRPGFREE run with CNVMOVE(N).';
      LeaveSr;
   EndIf;

   nonConvRsn = *Blanks;



      // Straight move: OK to comvert THESE types of MOVE.
      If %xlate(LO:UP:%subst(factor2:1:6)) = '*BLANK'
      or %xlate(LO:UP:%subst(factor2:1:5)) = '*ZERO'
      or %xlate(LO:UP:%subst(factor2:1:4)) = '*ALL'
      or %xlate(LO:UP:factor2) = '*OFF' or %xlate(LO:UP:factor2) = '*ON'

      or (%subst(result:1:3) = '*IN' and %subst(result:4:1) <> '(');

         If %lookup(%xlate(LO:UP:%trim(result)):opCodeUP) = 0;
            sourceLine = %trim(result) + ' = ' + %trim(factor2) + ';';
         Else;
            // Result is a reserved word - don't convert.
            nonConvRsn = 'Result field name is a reserved word.';
         EndIf;
      Else;
         // Straight move - check variable definitions.
         sourceVariable = retrieveVariableDef(factor2);
         targetVariable = retrieveVariableDef(result);

         // Are both fields known to the utility...
         If targetVariable.variableName <> *Blanks
         and sourceVariable.variableName <> *Blanks;

            // Pad the result?
            If not inPadding
            and %scan('P':operator:5) > 0
            and targetVariable.length > sourceVariable.length
            and targetVariable.type <> 'CHAR';
               inPadding = *On;
               savedSRCDTA = SRCDTA;
               reprocessLine = *On;
               sourceLine = 'Clear ' + %trim(result) + ';';
            Else;
               inPadding = *Off;

               Select;
                  When sourceVariable.type = 'CHAR';
                     Exsr subUserCvt_MOVE_Alpha;

                  When sourceVariable.type = 'NUMERIC'
                    or sourceVariable.type = 'PACKED'
                    or sourceVariable.type = 'ZONED';
                     Exsr subUserCvt_MOVE_Numeric;

                  When sourceVariable.type = 'DATE';
                     Exsr subUserCvt_MOVE_Date;

                  When sourceVariable.type = 'TIME';
                     Exsr subUserCvt_MOVE_Time;



                     // Same type and length...
                  When targetVariable.type = sourceVariable.type
                   and targetVariable.length = sourceVariable.length;
                     sourceLine = %trim(result) + ' = ' + %trim(factor2) + ';';

                  Other;
                     // Fields are not compatible for a straight move - don't convert.
                     nonConvRsn = 'conversion from ' + %trim(sourceVariable.type) + ' to '
                                + targetVariable.type + ' is not currently supported.';

               EndSl;
            EndIf;
         Else;
            // Straight move is too dangerous - don't convert.
            nonConvRsn = 'Straight move between unknown fields is dangerous.';
         EndIf;
      EndIf;



   If nonConvRsn = *Blanks;
      convert = *On;
   EndIf;

EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
//-------------------------------------------------------------------------------------------
// Convert MOVE of an Alpha field.
//-------------------------------------------------------------------------------------------
BegSr subUserCvt_MOVE_Alpha;

   Select;
      When targetVariable.type = 'CHAR'
       and %subst(operator:5:1) = 'L';
         If (targetVariable.length <= sourceVariable.length
             or %scan('P':operator) > 0);
            sourceLine = %trim(result) + ' = ' + %trim(factor2) + ';';

         Else;
            sourceLine = '%subst(' + %trim(result)
                       + ':1:' + %char(sourceVariable.length)
                       + ') = ' + %trim(factor2) + ';';
         EndIf;
         LeaveSr;

      When targetVariable.type = 'CHAR'
       and %subst(operator:5:1) <> 'L';
         If targetVariable.length = sourceVariable.length;
            sourceLine = %trim(result) + ' = ' + %trim(factor2) + ';';

         ElseIf targetVariable.length < sourceVariable.length
         or %scan('P':operator) > 0;
            sourceLine = 'EvalR ' + %trim(result) + ' = ' + %trim(factor2) + ';';

         ElseIf targetVariable.length > sourceVariable.length;
            sourceLine = '%subst(' + %trim(result)
                       + ':' + %char(targetVariable.length - sourceVariable.length + 1)
                       + ') = ' + %trim(factor2) + ';';
         EndIf;
         LeaveSr;

      When (targetVariable.type = 'PACKED'
         or targetVariable.type = 'ZONED'
         or targetVariable.type = 'NUMERIC');
         If targetVariable.length <= sourceVariable.length;
            sourceLine = %trim(result)
                       + ' = %dec(' + %trim(factor2)
                       + ':' + %char(targetVariable.length)
                       + ':' + %char(targetVariable.scale)
                       + ');';
         ElseIf targetVariable.length > sourceVariable.length
         and %scan('P':operator) > 0;
            sourceLine = %trim(result)
                       + ' = %dec(' + %trim(factor2)
                       + ':' + %char(targetVariable.length)
                       + ':' + %char(targetVariable.scale)
                       + ');';
         Else;
            nonConvRsn = 'Numeric result larger than alpha source - too complex to convert.';

         EndIf;
         LeaveSr;

      When targetVariable.type = 'TIME'
       and factor1 <> *Blanks;
         sourceLine = %trim(result)  + ' = %time(' + %trim(factor2) + ':' + %trim(factor1) + ');';
         LeaveSr;

      When targetVariable.type = 'DATE'
       and factor1 <> *Blanks;
         sourceLine = %trim(result)  + ' = %date(' + %trim(factor2) + ':' + %trim(factor1) + ');';
         LeaveSr;

      Other;
         // Fields are not compatible for a straight move - don't convert.
         nonConvRsn = 'conversion from ' + %trim(sourceVariable.type) + ' to '
                    + targetVariable.type + ' is not currently supported.';
         LeaveSr;

   EndSl;

EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
//-------------------------------------------------------------------------------------------
// Convert MOVE of a Numeric field.
//-------------------------------------------------------------------------------------------
BegSr subUserCvt_MOVE_Numeric;

   Select;
      When targetVariable.type = 'PACKED'
        or targetVariable.type = 'ZONED'
        or targetVariable.type = 'NUMERIC';
         sourceLine = %trim(result) + ' = ' + %trim(factor2) + ';';
         LeaveSr;

      When targetVariable.type = 'CHAR'
       and targetVariable.length = sourceVariable.length;
         sourceLine = %trim(result) + ' = %editc(' + %trim(factor2) + ':''X'');';
         LeaveSr;

      When targetVariable.type = 'CHAR'
       and targetVariable.length < sourceVariable.length
       and %subst(operator:5:1) = 'L';
         sourceLine = %trim(result) + ' = %editc(' + %trim(factor2) + ':''X'');';
         LeaveSr;

      When targetVariable.type = 'CHAR'
       and targetVariable.length < sourceVariable.length
       and %subst(operator:5:1) <> 'L';
         sourceLine = 'EvalR ' + %trim(result) + ' = %editc(' + %trim(factor2) + ':''X'');';
         LeaveSr;

      When targetVariable.type = 'CHAR'
       and targetVariable.length > sourceVariable.length
       and %subst(operator:5:1) = 'L';
         sourceLine = '%subst(' + %trim(result) + ':1:' + %char(sourceVariable.length) + ')'
                    + ' = %editc(' + %trim(factor2) + ':''X'');';
         LeaveSr;

      When targetVariable.type = 'CHAR'
       and targetVariable.length > sourceVariable.length
       and %subst(operator:5:1) <> 'L';
         sourceLine = '%subst(' + %trim(result)
                    + ':' + %char(targetVariable.length - sourceVariable.length + 1) + ')'
                    + ' = %editc(' + %trim(factor2) + ':''X'');';
         LeaveSr;

      When targetVariable.type = 'TIME'
       and factor1 <> *Blanks;
         sourceLine = %trim(result)  + ' = %time(' + %trim(factor2) + ':' + %trim(factor1) + ');';
         LeaveSr;

      When targetVariable.type = 'DATE'
       and factor1 <> *Blanks;
         sourceLine = %trim(result)  + ' = %date(' + %trim(factor2) + ':' + %trim(factor1) + ');';
         LeaveSr;

      When targetVariable.type = 'DATE'
       and factor1 = *Blanks
       and sourceVariable.variableName = '*DATE';
         sourceLine = %trim(result)  + ' = %date(' + %trim(factor2) + ');';
         LeaveSr;

      Other;
         // Fields are not compatible for a straight move - don't convert.
         nonConvRsn = 'conversion from ' + %trim(sourceVariable.type) + ' to '
                    + targetVariable.type + ' is not currently supported.';
         LeaveSr;

   EndSl;

EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
//-------------------------------------------------------------------------------------------
// Convert MOVE of a Date field.
//-------------------------------------------------------------------------------------------
BegSr subUserCvt_MOVE_Date;

   Select;
      When targetVariable.type = 'DATE';
         sourceLine = %trim(result) + ' = ' + %trim(factor2) + ';';
         LeaveSr;

      When (targetVariable.type = 'PACKED'
        or targetVariable.type = 'ZONED'
        or targetVariable.type = 'NUMERIC')
       and factor1 <> *Blanks;
         sourceLine = %trim(result)  + ' = %dec(' + %trim(factor2) + ':' + %trim(factor1) + ');';
         LeaveSr;

      When (targetVariable.type = 'PACKED'
        or targetVariable.type = 'ZONED'
        or targetVariable.type = 'NUMERIC')
       and factor1 = *Blanks
       and targetVariable.length = 8;
         sourceLine = %trim(result)  + ' = %dec(' + %trim(factor2) + ');';
         LeaveSr;

      When targetVariable.type = 'CHAR'
       and factor1 <> *Blanks;
         sourceLine = %trim(result) + ' = %char(' + %trim(factor2) + ':' + %trim(factor1) + ');';
         LeaveSr;

      Other;
         // Fields are not compatible for a straight move - don't convert.
         nonConvRsn = 'conversion from ' + %trim(sourceVariable.type) + ' to '
                    + targetVariable.type + ' is not currently supported.';
         LeaveSr;

   EndSl;

EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
//-------------------------------------------------------------------------------------------
// Convert MOVE of a Time field.
//-------------------------------------------------------------------------------------------
BegSr subUserCvt_MOVE_Time;

   Select;
      When targetVariable.type = 'TIME';
         sourceLine = %trim(result) + ' = ' + %trim(factor2) + ';';
         LeaveSr;

      When (targetVariable.type = 'PACKED'
        or targetVariable.type = 'ZONED'
        or targetVariable.type = 'NUMERIC')
       and factor1 <> *Blanks;
         sourceLine = %trim(result)  + ' = %dec(' + %trim(factor2) + ':' + %trim(factor1) + ');';
         LeaveSr;

      When targetVariable.type = 'CHAR'
       and factor1 <> *Blanks;
         sourceLine = %trim(result) + ' = %char(' + %trim(factor2) + ':' + %trim(factor1) + ');';
         LeaveSr;

      Other;
         // Fields are not compatible for a straight move - don't convert.
         nonConvRsn = 'conversion from ' + %trim(sourceVariable.type) + ' to '
                    + targetVariable.type + ' is not currently supported.';
         LeaveSr;

   EndSl;

EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
//-------------------------------------------------------------------------------------------
// Convert MOVE of a Timestamp field.
//-------------------------------------------------------------------------------------------
BegSr subUserCvt_MOVE_Timestamp;

   nonConvRsn = 'conversion from ' + %trim(sourceVariable.type) + ' to '
              + targetVariable.type + ' is not currently supported.';
   LeaveSr;

EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
//-------------------------------------------------------------------------------------------
// Convert MOVEA.
//-------------------------------------------------------------------------------------------
BegSr subUserCvt_MOVEA;

   // MOVEA supported only for indicators like so:
   // C                   MOVEA     '00000000'    *IN(50)
   If  (%scan('''0':factor2) > 0 or %scan('''1':factor2) > 0)
   and %subst(result:1:4) = '*IN(';
      arrayLength = %len(%trim(factor2)) - 2;
      endPos = %scan(')':result);
      arrayStart = %subst(result:5:endpos-5);

      sourceLine = '%subst(zz_IndArray:' + arrayStart + ':'
                 + %char(arrayLength) + ') = ' + %trim(factor2) + ';';

      convert = *On;
      LeaveSr;

   else;

     nonConvRsn = 'Data type Conversion necesssary';
     LeaveSr;

  EndIf;

EndSr;
//-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert MULT.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_MULT;

    // Half-adjust?
    x = %scan('H':operator:4);
    If x > 0;
       sourceLine = 'Eval(H)';
    Else;
       sourceLine = *Blanks;
    EndIf;

    If factor1 = *Blanks;
       sourceLine = %trimr(sourceLine) + ' ' + %trim(result)
                  + ' = ' + %trim(result)
                  + ' * ' + %trim(factor2) +';';
    Else;
       sourceLine = %trimr(sourceLine) + ' ' + %trim(result)
                  + ' = ' + %trim(factor1)
                  + ' * ' + %trim(factor2) + ';';
    EndIf;

    sourceLine = %trim(sourceLine);

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert MVR.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_MVR;

    sourceLine = %trim(result) + ' = %rem(' + %trim(divFactor1)
               + ':' + %trim(divFactor2) + ');';

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert NEXT.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_NEXT;

    operator = setExtender_E(operator:lw);

    sourceLine = %trim(operator) + ' ' + %trim(factor1) + ' '
               + %trim(factor2) + ';';


    // Check indicators?
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert OCCUR.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_OCCUR;

    If factor1 = *Blanks;      // Get occurrence.
       sourceLine = %trim(result) + ' = ' + '%occur('
                  + %trim(factor2) + ');';
    ElseIf result = *Blanks;   // Set occurrent.
       sourceLine = '%occur(' + %trim(factor2) + ') = '
                  + %trim(factor1) + ';';
    Else;
       nonConvRsn = 'Cannot determine of OCCUR is used to set or '
                  + 'get the occurrence.';
       LeaveSr;
    EndIf;

    // Check resulting indicators?
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert ON-ERROR.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_ON_ERROR;

    If extFactor2 = *Blanks;
       sourceLine = %trim(operator) + ';';
    Else;
       sourceLine = %trim(operator) + ' ' + %trim(extFactor2) + ';';
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert OPEN.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_OPEN;

    If lw <> *Blanks;      // Error indicator set.
       x = %scan('(':operator);
       If x > 0;
         operator = %subst(operator:1:x) + 'E' + %subst(operator:x+1);
       Else;
          operator = %trim(operator) + '(E)';
       EndIf;
    EndIf;

    sourceLine = %trim(operator) + ' ' + %trim(factor2) + ';';

    // Check resulting indicators?
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert OTHER.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_OTHER;

    sourceLine = 'Other;';

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert OUT.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_OUT;

    operator = setExtender_E(operator:lw);

    If factor1 = *Blanks;
       sourceLine = %trim(operator) + ' ' + %trim(factor2) + ';';
    Else;
       sourceLine = %trim(operator) + ' ' + %trim(factor1) + ' '
                  + %trim(factor2) + ';';
    EndIf;

    // Set resulting indicators?
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert PARM
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_PARM;

   If p_ConvPList <> 'Y';
      convert = *Off;
      nonConvRsn = 'Conversion not selected on command';
      LeaveSr;
   EndIf;

   If parmListCount > 0;
      x = %lookup(parmListName:parmList(*).listName:1:parmListCount);
      If x > 0 and parmList(x).convert;
         // Comment it out.
         sourceLine = '//' + nonPrefix;
         lineType = *Blank;
         inComment = *On;
         convert = *On;

         // Retain converted PList?
         If p_RetPList <> 'Y';
            dropLine = *On;
         EndIf;
      EndIf;
   EndIf;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
//-------------------------------------------------------------------------------------------
// Convert PLIST
//-------------------------------------------------------------------------------------------
BegSr subUserCvt_PLIST;

   If p_ConvPList <> 'Y';
      convert = *Off;
      nonConvRsn = 'Conversion not selected on command';
      LeaveSr;
   EndIf;

   If parmListCount > 0;
      parmListName = %xlate(LO:UP:factor1);
      x = %lookup(parmListName:parmList(*).listName:1:parmListCount);
      If x > 0 and parmList(x).convert;
         If p_SuppressMsgs <> 'Y' and p_RetPList = 'Y';
            savedSRCDTA = SRCDTA;
            lineType = *Blank;
            directive = *Blanks;
            codeLine = '// >>>>> Automatically removed by conversion';
            writeLine();
            SRCDTA = savedSRCDTA;
         EndIf;

         // Comment it out.
         sourceLine = '//' + nonPrefix;
         lineType = *Blank;
         inComment = *On;
         convert = *On;

         // Retain converted PList?
         If p_RetPList <> 'Y';
            dropLine = *On;
         EndIf;
      EndIf;
   EndIf;

EndSr;
//-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert POST.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_POST;

    If factor2 = *Blanks;
       nonConvRsn =  'No filename specified in Factor2.';
       LeaveSr;
    EndIf;

    If result <> *Blanks;
       nonConvRsn =  'INFDS specified in result.';
       LeaveSr;
    EndIf;

    If lw <> *Blanks;      // Error indicator set.
       x = %scan('(':operator);
       If x > 0;
         operator = %subst(operator:1:x) + 'E' + %subst(operator:x+1);
       Else;
          operator = %trim(operator) + '(E)';
       EndIf;
    EndIf;

    If factor1 = *Blanks;
       sourceLine = %trim(operator) + ' ' + %trim(factor2) + ';';
    Else;
       sourceLine = %trim(operator) + ' ' + %trim(factor1) + ' '
                  + %trim(factor2) + ';';
    EndIf;

    // Set resulting indicators?
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert READ.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_READ;

    If lw <> *Blanks;      // Error indicator set.
       x = %scan('(':operator);
       If x > 0;
         operator = %subst(operator:1:x) + 'E' + %subst(operator:x+1);
       Else;
          operator = %trim(operator) + '(E)';
       EndIf;
    EndIf;

    If factor1 <> *Blanks;
       sourceLine = %trim(operator) + ' ' + getKeyList(factor1) + ' '
                  + %trim(factor2);
    Else;
       sourceLine = %trim(operator) + ' ' + %trim(factor2);
    EndIf;

    // Append datastructure?
    If result <> *Blanks;
       sourceLine = %trim(sourceLine)  + ' ' + %trim(result) + ';';
    Else;
       sourceLine = %trim(sourceLine)  + ';';
    EndIf;

    // Check indicators?
    If eq <> *Blanks;
       EOFCheck = *On;
       EOFInd = eq;
       EOFFile = %trim(factor2);
    EndIf;
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
//-------------------------------------------------------------------------------------------
// Convert REALLOC.
//-------------------------------------------------------------------------------------------
BegSr subUserCvt_REALLOC;

   sourceLine = %trim(result) + ' = %realloc(' + %trim(factor2)
              + ');';

   // Set resulting indicators?
   If lw <> *Blanks;
      ERRCheck = *On;
      ERRInd = lw;
   EndIf;

   convert = *On;

EndSr;
//-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert REL.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_REL;

    operator = setExtender_E(operator:lw);

    sourceLine = %trim(operator) + ' ' + %trim(factor1)
               + ' ' + %trim(factor2) + ';';

    // Check resulting indicators?
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert RESET.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_RESET;

    operator = setExtender_E(operator:lw);

    sourceLine = %trim(operator);

    If factor1 <> *Blanks;
       sourceLine = %trimr(sourceLine) + ' ' + %trim(factor1);
    EndIf;

    If factor2 <> *Blanks;
       sourceLine = %trimr(sourceLine) + ' ' + %trim(factor2);
    EndIf;

    sourceLine = %trimr(sourceLine) + ' ' + %trim(result) + ';';

    // Check indicators?
    If hi <> *Blanks;
       NRFCheck = *On;
       NRFInd = eq;
       NRFFile = %trim(factor2);
    EndIf;
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert RETURN;
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_RETURN;

    sourceLine = 'Return ' + %trim(%subst(operator:7))
               + ' ' + %trim(extFactor2) + ';';

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert ROLBK.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_ROLBK;

    operator = setExtender_E(operator:lw);

    sourceLine = %trim(operator) + ' ' + %trim(factor1);

    sourceLine = %trim(sourceLine)  + ';';

    // Check indicators?
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert SCAN.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_SCAN;

    // Determine length of comparator.
    x = %scan(':':factor1);
    If x = 0;   // No length specified.
       scanLength = *Blanks;               // Scan length
       scanString = %trim(factor1);        // Scan string
    Else;
       scanLength = %subst(factor1:x+1);   // Scan length
       scanString = %subst(factor1:1:x-1); // Scan string
    EndIf;

    // Determine starting point.
    x = %scan(':':factor2);
    If x = 0;   // No start specified.
       scanStart = '1';                    // Start position
       scanBase = %trim(factor2);          // Base string
    Else;
       scanStart = %subst(factor2:x+1);    // Start position
       scanBase = %subst(factor2:1:x-1);   // Base string
    EndIf;

    // Build the new line.
    If scanLength = *Blanks;
       // No length specified.
       sourceLine = '%scan(' + %trim(scanString)
                  + ':' + %trim(scanBase) + ':' + %trim(scanStart)
                  + ')';
    Else;
       // Use a subset of the scan string.
       sourceLine = '%scan(%subst('
                  + %trim(scanString) + ':1:' + %trim(scanLength)
                  + '):' + %trim(scanBase) + ':' + %trim(scanStart)
                  + ')';
    EndIf;

    // Result specified?
    If result = *Blanks;
       scanNoResult = *On;
       sourceLine = 'If ' + %trimr(sourceLine) + ' = 0;';
    Else;
       scanNoResult = *Off;
       sourceLine = %trim(result) + ' = ' + %trimr(sourceLine) + ';';
    EndIf;

    // Set resulting indicators?
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;
    If eq <> *Blanks;
       foundCheck = *On;
       foundInd = eq;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert SELECT
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_SELECT;

    sourceLine = 'Select;';

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert SETOFF
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_SETOFF;

    setOff = *On;
    setOffInd1 = hi;
    setOffInd2 = lw;
    setOffInd3 = eq;

    dropLine = *On;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert SETON
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_SETON;

    setOn = *On;
    setOnInd1 = hi;
    setOnInd2 = lw;
    setOnInd3 = eq;

    dropLine = *On;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert SETxx.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_SETxx;

    If lw <> *Blanks;      // Error indicator set.
       x = %scan('(':operator);
       If x > 0;
         operator = %subst(operator:1:x) + 'E' + %subst(operator:x+1);
       Else;
          operator = %trim(operator) + '(E)';
       EndIf;
    EndIf;

    sourceLine = %trim(operator) + ' ' + getKeyList(factor1) + ' '
               + %trim(factor2);
    If result <> *Blanks;
       sourceLine = %trim(sourceLine)  + ' ' + %trim(result) + ';';
    Else;
       sourceLine = %trim(sourceLine)  + ';';
    EndIf;

    // Check resulting indicators.
    If hi <> *Blanks;
       NRFCheck = *On;
       NRFInd = hi;
       NRFFile = %trim(factor2);
    EndIf;
    If eq <> *Blanks;
       equalCheck = *On;
       equalInd = eq;
    EndIf;
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert SHTDN
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_SHTDN;

    sourceLine = '*IN' + hi + ' = %shtdn();';

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert SORTA.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_SORTA;

    sourceLine = %trim(operator) + ' ' + %trim(extFactor2);

    sourceLine = %trim(sourceLine)  + ';';

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
//-------------------------------------------------------------------------------------------
// Convert SQRT.
//-------------------------------------------------------------------------------------------
BegSr subUserCvt_SQRT;

   // Not valid in free-format!
   Return;

   sourceLine = %trim(result) + ' = %sqrt(' + %trim(factor2) + ');';

   convert = *On;

EndSr;
//-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert SUB.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_SUB;

    // Half-adjust?
    x = %scan('H':operator:4);
    If x > 0;
       operator = 'SUB';
       sourceLine = 'Eval(H)';
    Else;
       sourceLine = *Blanks;
    EndIf;

    If factor1 = *Blanks;
       sourceLine = %trimr(sourceLine) + ' ' + %trim(result)
                  + ' = ' + %trim(result)
                  + ' - ' + %trim(factor2) +';';
    Else;
       sourceLine = %trimr(sourceLine) + ' ' + %trim(result)
                  + ' = ' + %trim(factor1)
                  + ' - ' + %trim(factor2) + ';';
    EndIf;

    sourceLine = %trim(sourceLine);

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert SUBDUR.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_SUBDUR;

    // Split out duration and code.
    x = %scan(':':factor2);
    If x = 0;
       x = %scan(':':result);
       If x = 0;
          nonConvRsn =  'No duration code specified.';
          LeaveSr;
       Else;
          durNewDate = *Off;
       EndIf;
    Else;
       durNewDate = *On;
    EndIf;

    If durNewDate;
       durDuration = %trim(%subst(factor2:1:x-1));
       durCode     = %xlate(LO:UP:%trim(%subst(factor2:x+1)));

       Select;
          When durCode = '*Y' or durCode = '*YEARS';
             durCode = '%years';
          When durCode = '*M' or durCode = '*MONTHS';
             durCode = '%months';
          When durCode = '*D' or durCode = '*DAYS';
             durCode = '%days';
          When durCode = '*H' or durCode = '*HOURS';
             durCode = '%hours';
          When durCode = '*MN' or durCode = '*MINUTES';
             durCode = '%minutes';
          When durCode = '*S' or durCode = '*SECONDS';
             durCode = '%seconds';
          When durCode = '*MS' or durCode = '*MSECONDS';
             durCode = '%mseconds';
          Other;
             nonConvRsn = 'Invalid duration code specified.';
             LeaveSr;
       EndSl;

       If factor1 = *Blanks;
          sourceLine = %trim(result) + ' = ' + %trim(result);
       Else;
          sourceLine = %trim(result) + ' = ' + %trim(factor1);
       EndIf;

       sourceLine = %trimr(sourceLine) + ' - ' + %trim(durCode)
                  + '(' + %trim(durDuration) + ');';
    Else;
       durDuration = %trim(%subst(result:1:x-1));
       durCode     = %xlate(LO:UP:%trim(%subst(result:x+1)));

       Select;
          When durCode = '*Y' or durCode = '*YEARS';
          When durCode = '*M' or durCode = '*MONTHS';
          When durCode = '*D' or durCode = '*DAYS';
          When durCode = '*H' or durCode = '*HOURS';
          When durCode = '*MN' or durCode = '*MINUTES';
          When durCode = '*S' or durCode = '*SECONDS';
          When durCode = '*MS' or durCode = '*MSECONDS';
          Other;
             nonConvRsn = 'Invalid duration code specified.';
             LeaveSr;
       EndSl;

       sourceLine = %trim(durDuration) + ' = %diff(' + %trim(factor1)
                  + ':' + %trim(factor2) + ':' + %trim(durCode) + ');';
    EndIf;

    // Set resulting indicators?
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert SUBST.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_SUBST;

    // Pad the result?
    x = %scan('P':operator:4);
    If x = 0                                              // Not padding.
    and factor1 <> *Blanks                                // Factor1 specified.
    and %xlate(LO:UP:factor1) <> %xlate(LO:UP:result);    // Factor1 not the same as result
       nonConvRsn = 'No padding specified, and factor1 and result '
                  + 'are not the same.';
       LeaveSr;    // Don't convert - too difficult to get right.
    EndIf;

    substLen = %trim(factor1);

    x = %scan(':':factor2);
    If x = 0;
       substStart = '1';
       x = %len(%trim(factor2)) + 1;
    Else;
       substStart = %subst(factor2:x+1);
    EndIf;

    sourceLine = %trim(result) + ' = %subst('
               + %subst(factor2:1:x-1) + ':'
               + %trim(substStart)
               + ':' + %trim(substLen) + ');';

    // Set resulting indicators?
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
//-------------------------------------------------------------------------------------------
// Convert TAG
//-------------------------------------------------------------------------------------------
BegSr subUserCvt_TAG;

   If tagCount > 0;
      tagName = %xlate(LO:UP:factor1);
      x = %lookup(tagName:tagList(*).tagName:1:tagCount);
      If x > 0;
         If tagList(x).tagUsageCount = 0;
            If p_SuppressMsgs <> 'Y';
               savedSRCDTA = SRCDTA;
               lineType = *Blank;
               directive = *Blanks;
               codeLine = '// >>>>> Automatically removed by conversion';
               writeLine();
               SRCDTA = savedSRCDTA;
            EndIf;

            // Comment it out.
            sourceLine = '//' + nonPrefix;
            lineType = *Blank;
            inComment = *On;
            convert = *On;
         Else;
            nonConvRsn = 'TAG is currently referenced.';
            convert = *Off;
            LeaveSr;
         EndIf;
      EndIf;
   EndIf;

EndSr;
//-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert TEST.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_TEST;

    operator = setExtender_E(operator:lw);

    sourceLine = %trim(operator) + ' ' + %trim(factor1) + ' '
               + %trim(result) + ';';

    // Set resulting indicators?
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert TIME.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_TIME;

    sourceLine = %trim(result) + ' = %dec(%time());';

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert UNLOCK.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_UNLOCK;

    operator = setExtender_E(operator:lw);

    sourceLine = %trim(operator) + ' ' + %trim(factor2) + ';';

    // Check indicators?
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert UPDATE.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_UPDATE;

    operator = setExtender_E(operator:lw);

    sourceLine = %trim(operator) + ' ' + %trim(factor2);

    // Append datastructure?
    If result <> *Blanks;
       sourceLine = %trim(sourceLine)  + ' ' + %trim(result) + ';';
    Else;
       sourceLine = %trim(sourceLine)  + ';';
    EndIf;

    // Check indicators?
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert WHEN.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_WHEN;

    // Returning for a multi-line IF?  Reinstate original opcode.
    If inWhen;
       operator = whenOperator;
    EndIf;

    checkSpan();  // Does this line span more than one line?

    If operator = 'WHEN';     // Use Extended Factor2.
       If not inWhen;            // First line of IF.
          sourceLine = %trim(operator) + ' ' + %trim(extFactor2);
          If not inSpan;
             sourceLine = %trim(sourceLine) + ';';
          Else;
             inWhen = *On;
             inSpan = *Off;
          EndIf;
       Else;                   // Second line of WHEN.
          sourceLine = %trim(extFactor2);
          If not inSpan;
             sourceLine = %trimr(sourceLine) + ';';
          EndIf;
          inSpan = *Off;
       EndIf;
    Else;
       // Fixed format.
       opCode = %xlate(LO:UP:opCode);
       If not inWhen;         // First line of WHEN.
          whenCompare = %subst(opCode:5:2);
          sourceLine = 'When';
       Else;                // Second line of WHEN.
          If %subst(opCode:1:3) = 'AND';
             whenCompare = %subst(opCode:4:2);
             sourceLine = 'And';
          Else;
             whenCompare = %subst(opCode:3:2);
             sourceLine = 'Or';
          EndIf;
       EndIf;
       If whenCompare = 'EQ';
          whenCompare = '=';
       ElseIf whenCompare = 'GT';
          whenCompare = '>';
       ElseIf whenCompare = 'GE';
          whenCompare = '>=';
       ElseIf whenCompare = 'LT';
          whenCompare = '<';
       ElseIf whenCompare = 'LE';
          whenCompare = '<=';
       ElseIf whenCompare = 'NE';
          whenCompare = '<>';
       EndIf;
       sourceLine = %trimr(sourceLine) + ' ' + %trim(factor1)
                          + ' ' + %trim(whenCompare) + ' '
                          + %trim(factor2);
       If not inSpan;
          sourceLine = %trimr(sourceLine) + ';';
          inWhen = *Off;
       Else;
          inWhen = *On;
          inSpan = *Off;
       EndIf;
    EndIf;

    // Multi-line IF?  Retain original opcode.
    If inWhen;
       whenOperator = operator;
    Else;
       whenOperator = *Blanks;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert WRITE.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_WRITE;

    operator = setExtender_E(operator:lw);

    sourceLine = %trim(operator) + ' ' + %trim(factor2);

    // Append datastructure?
    If result <> *Blanks;
       sourceLine = %trim(sourceLine)  + ' ' + %trim(result) + ';';
    Else;
       sourceLine = %trim(sourceLine)  + ';';
    EndIf;

    // Check indicators?
    If eq <> *Blanks;
       EOFCheck = *On;
       EOFInd = eq;
       EOFFile = %trim(factor2);
    EndIf;
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
//-------------------------------------------------------------------------------------------
// Convert XFOOT.
//-------------------------------------------------------------------------------------------
BegSr subUserCvt_XFOOT;

   // Not valid in free-format!
   Return;

   If %scan('H':operator) = 0;
      sourceLine = %trim(result) + ' = %xfoot(' + %trim(factor2)
                 + ');';
   Else;
      // Half-adjust.
      sourceLine = 'Eval(H) ' + %trim(result) + ' = %xfoot('
                 + %trim(factor2) + ');';
   EndIf;

   convert = *On;

EndSr;
//-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert XLATE.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_XLATE;



    // Derive from and to.
    x = %scan(':':factor1);
    If x = 0;
       LeaveSr;    // Invalid specification - there MUST be a from and to - don't convert.
    Else;
       xlateFrom = %subst(factor1:1:x-1);
       xlateTo = %subst(factor1:x+1);
    EndIf;

    // Check for start position.
    x = %scan(':':factor2);
    If x = 0;
       xlateStart = *Blanks;
       xlateBase = factor2;
    Else;
       xlateStart = %subst(factor2:x+1);
       xlateBase = %subst(factor2:1:x-1);
    EndIf;

    // Build new line.
    sourceLine = %trim(result) + ' = %xlate('
               + %trim(xlateFrom) + ':' + %trim(xlateTo) + ':'
               + %trim(xlateBase);
    If xlateStart <> *Blanks;
       sourceLine = %trimr(sourceLine) + ':' + %trim(xlateStart);
    EndIf;
    sourceLine = %trimr(sourceLine) + ');';

    // Set resulting indicators?
    If lw <> *Blanks;
       ERRCheck = *On;
       ERRInd = lw;
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert Z-ADD.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_Z_ADD;

    sourceLine = %trim(result) + ' = ' + %trim(factor2) + ';';

    // Half-adjust required?
    If %len(%trim(operator)) > 5;
       sourceLine = 'Eval(H) ' + %trim(sourceLine);
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

/Eject
 //-------------------------------------------------------------------------------------------
 // Convert Z-SUB.
 //-------------------------------------------------------------------------------------------
 BegSr subUserCvt_Z_SUB;


    sourceLine = %trim(result) + ' = ' + %trim(factor2) + ' * -1;';

    // Half-adjust required?
    If %len(%trim(operator)) > 5;
       sourceLine = 'Eval(H) ' + %trim(sourceLine);
    EndIf;

    convert = *On;

 EndSr;
 //-------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// Convert D-Spec
//==========================================================================================
Dcl-Proc convertD_Spec;

// -- Procedure Interface ------------------------------------------------------------------
// -- Data Structures ----------------------------------------------------------------------
// -- Variables ----------------------------------------------------------------------------
Dcl-C DSKEYWORDS '*PROC *STATUS *OPCODE *ROUTINE *PARMS *FILE *RECORD *SIZE *INP *OUT *MODE';

//////Dcl-S inDatastructureDecl           Ind;
Dcl-S fieldName                    Char(80);

//-------------------------------------------------------------------------------------------

    // Keep blank lines.
    If codeLine = *Blanks;
       sourceLine = *Blanks;
       convert = *On;
       Return;
    EndIf;

    sourceLine = fullLine;

    workDeclAttr = %xlate(LO:UP:declAttr);

    checkSpan();  // Does this line span more than one line?


    If not inDeclaration or declName = *Blanks;
       If not inDeclaration;

          GetDeclarationType(workDeclType:savedName:workDeclLine);
       EndIf;

       //-------------------------------------------------------------------------
       // Stand-alone Field Definition.
       //-------------------------------------------------------------------------
       If workDeclType = 'S';      // Stand-alone field.
          Exsr subStandAlone;

          //-------------------------------------------------------------------------
          // Constant Definition.
          //-------------------------------------------------------------------------
       ElseIf workDeclType = 'C';
          Exsr subConstant;

          //-------------------------------------------------------------------------
          // Prototype/Interface/Datastructure Definition.
          //-------------------------------------------------------------------------
       ElseIf workDeclType = 'PR'
           or inPrototype
           or workDeclType = 'PI'
           or inInterface
           or workDeclType = 'DS'
           or inDatastructure;
           Exsr subBlockDefinition;

          //-------------------------------------------------------------------------
          // Unsupported.
          //-------------------------------------------------------------------------
       Else;
          inDeclaration = *Off;
          convert = *Off;
          Return;
       EndIf;

       //-------------------------------------------------------------------------
       // Second+ line of declaration.
       //-------------------------------------------------------------------------
    Else;
       Clear DCLS;
       DCLS.definition = %trim(declKeyWords);
       If not inSpan;
          DCLS.definition = %trim(DCLS.definition) + ';';
          inDeclaration = *Off;
       EndIf;
       sourceLine = DCLS;
       inSpan = *Off;
    EndIf;

    convert = *On;

   Return;

//------------------------------------------------------------------------------------------
// Stand-alone field definition.
//------------------------------------------------------------------------------------------
BegSr subStandAlone;

   inDeclaration = *On;

   Clear DCLS;

   // FROMFILE is not allowed.
   If %scan('FROMFILE':%xlate(LO:UP:declKeywords)) > 0;
      inDeclaration = *Off;
      nonConvRsn = 'FROMFILE not allowed in Free-Form';
      convert = *Off;
      LeaveSr;
   EndIf;

   If savedName <> *Blanks;
      DCLS.decl = 'Dcl-S ';
      %subst(DCLS:7) = savedName;

      // Store name?
      storeVariable(savedName);
   EndIf;

   If %len(%trim(savedName)) <= 17;   // Long name - must be the only thing on this line.

      // Type.
      If workDeclAttr = *Blanks
      and DCLS.type = *Blanks;
         If declLen = *Blanks;
            // No definition (probably in keywords - e.g. LIKE()).
         ElseIf declScale = *Blanks;
            workDeclAttr = 'A';
         Else;
            If inDatastructure;
               workDeclAttr = 'S';
            Else;
               workDeclAttr = 'P';
            EndIf;
         EndIf;
      EndIf;

      If workDeclAttr = *Blanks;
         // No definition (probably in keywords - e.g. LIKE()).
      ElseIf workDeclAttr = 'A';
         x = %scan('VARYING':%xlate(LO:UP:declKeywords));
         If x > 0;
            DCLS.type = '  VarChar';
            declKeywords = %subst(declKeywords:x+7);
         Else;
            DCLS.type = '     Char';
         EndIf;
      ElseIf workDeclAttr = 'P';
         DCLS.type = '   Packed';
      ElseIf workDeclAttr = 'D';
         DCLS.type = '     Date';
         x = %scan('DATFMT':%xlate(LO:UP:declKeywords));
         If x > 0;
            x = %scan('(':declKeywords:x);
            y = %scan(')':declKeywords:x);
            DCLS.definition = '('
                      + %subst(declKeywords:x+1:y-x-1)
                      + ')';
            declKeywords = %subst(declKeywords:y+1);
         EndIf;
         workLength = 8;
      ElseIf workDeclAttr = 'T';
         DCLS.type = '     Time';
         x = %scan('TIMFMT':%xlate(LO:UP:declKeywords));
         If x > 0;
            x = %scan('(':declKeywords:x);
            y = %scan(')':declKeywords:x);
            DCLS.definition = '('
                      + %subst(declKeywords:x+1:y-x-1)
                      + ')';
            declKeywords = %subst(declKeywords:y+1);
         EndIf;
         workLength = 6;
      ElseIf workDeclAttr = 'Z';
         DCLS.type = 'TimeStamp';
         workLength = 26;
      ElseIf workDeclAttr = 'I';
         DCLS.type = '      Int';
      ElseIf workDeclAttr = 'U';
         DCLS.type = '      Uns';
      ElseIf workDeclAttr = 'S';
         DCLS.type = '    Zoned';
      ElseIf workDeclAttr = 'F';
         DCLS.type = '    Float';
      ElseIf workDeclAttr = 'N';
         DCLS.type = '      Ind';
         workLength = 1;
      ElseIf workDeclAttr = '*';
         DCLS.type = '  Pointer';
         workLength = 15;
      ElseIf workDeclAttr = 'B';
         DCLS.type = '   BinDec';
         workLength = workLength * 2;
      ElseIf workDeclAttr = 'G';
         x = %scan('VARYING':%xlate(LO:UP:declKeywords));
         If x > 0;
            DCLS.type = ' VarGraph';
            declKeywords = %subst(declKeywords:x+7);
         Else;
            DCLS.type = '    Graph';
         EndIf;
      Else;
         inDeclaration = *Off;
         convert = *Off;
         LeaveSr;
      EndIf;

      // Attributes.
      If workDeclAttr <> '*'
      and workDeclAttr <> 'N'
      and workDeclAttr <> 'D'
      and workDeclAttr <> 'T'
      and workDeclAttr <> 'Z'
      and workDeclAttr <> *Blank
      and DCLS.type <> *Blanks;
         DCLS.definition = '(' + %trim(declLen);
         workLength = %dec(%trim(declLen):7:0);
         If declScale <> *Blanks;
            DCLS.definition = %trimr(DCLS.definition)
                            + ':' + %trim(declScale);
         EndIf;
         DCLS.definition = %trimr(DCLS.definition) + ')';
      EndIf;

      // Keywords.
      If declKeyWords <> *Blanks;
         // Expand DTAARA?
         x = %scan('DTAARA(':%xlate(LO:UP:declKeywords));
         If x > 0;
            i = %scan(')':declKeywords:x+1);
            If i > 0;
               If %scan('*VAR':%subst(declKeywords:x+7:i-x-7)) > 0;

/if defined(*V7R3M0)
                  j = %scan(':':declKeywords:x+7:i-x-7);
/else
                  j = %scan(':':declKeywords:x+7);
                  If j >= i-x-7;
                     j = 0;
                  EndIf;
/endif

                  declKeywords = %subst(declKeywords:1:x+6)
                     + %trim(%subst(declKeywords:j+1:i-j-1))
                     + %subst(declKeywords:i);
               Else;
                  If %scan('''':%subst(declKeywords:x+7:i-x-7)) = 0;
                     declKeywords = %subst(declKeywords:1:x+6)
                        + ''''
                        + %xlate(LO:UP:%trim(%subst(declKeywords:x+7:i-x-7)))
                        + ''''
                        + %subst(declKeywords:i);
                  EndIf;
               EndIf;
            EndIf;
         EndIf;

         // Try to put the keywords into the new line.
         If DCLS.definition = *Blanks and DCLS.type = *Blanks;         // Expand DTAARA?

            DCLS.definition = %trim(declKeyWords);
         Else;
            // How big is it?
            x = %len(%trim(%trim(DCLS.definition) + ' ' + %trim(declKeyWords)));
            If x > 38;
               x = %len(%trim(%trim(DCLS.type)
                                    + %trim(DCLS.definition) + ' '
                                    + %trim(declKeyWords)));

                  %subst(DCLS:71-x) = %trim(%trim(DCLS.type)
                                    + %trim(DCLS.definition) + ' '
                                    + %trim(declKeyWords));
            Else;
               DCLS.definition = %trimr(DCLS.definition) + ' '
                               + %trim(declKeyWords);
            EndIf;
         EndIf;
      EndIf;

      If comment <> *Blanks;
         If %subst(%trim(comment):1:2) = '//';
            DCLS.comment = '   ' + comment;
         Else;
            DCLS.comment = '// ' + comment;
         EndIf;
      EndIf;

      storeVariableDef(savedName:DCLS.type:%char(workLength):declScale:DCLS);
   EndIf;

   If not inSpan;
      DCLS.definition = %trimr(DCLS.definition) + ';';
      // Continuation of constant must start at left margin.
      If inContinuation;
         DCLS = DCLS.definition;
      EndIf;
      inDeclaration = *Off;
   Else;
      // Continuation of constant must start at left margin.
      If inContinuation;
         DCLS = DCLS.definition;
      EndIf;
      inSpan = *Off;
   EndIf;

   If %subst(DCLS:%len(%trim(DCLS)):1) = '-';
      inContinuation = *On;
   Else;
      inContinuation = *Off;
   EndIf;

   // Converted line...
   sourceLine = DCLS;
   If not inSpan;
      savedName = *Blanks;
   EndIf;

EndSr;
//------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------
// Constant definition.
//------------------------------------------------------------------------------------------
BegSr subConstant;

   inDeclaration = *On;

   Clear DCLS;

   If savedName <> *Blanks;
      DCLS.decl = 'Dcl-C ';
      %subst(DCLS:7) = %xlate(LO:UP:savedName);

      // Store name?
      storeVariable(savedName);
      Clear constantDef;
      constantDef.variableName = %xlate(LO:UP:savedName);
   EndIf;

   If %len(%trim(savedName)) <= 17 and not inLong;   // Long name - must be the only thing on this l


      // Keywords.
      If declKeyWords <> *Blanks;
         If DCLS.definition = *Blanks;
            DCLS.definition = %trimr(declKeyWords);
         Else;
            DCLS.definition = %trimr(DCLS.definition) + ' '
                            + %trim(declKeyWords);
         EndIf;
      EndIf;

      // Strip off CONST keyword...
      x = %scan('CONST(':%xlate(LO:UP:DCLS.definition));
      If x > 0;
         DCLS.definition = %subst(DCLS.definition:x+6);
      EndIf;

/if defined(*V7R3M0)
      x = %scanr(')':DCLS.definition);
/else
      x = 0;
      For i = %len(DCLS.definition) downto 1;
         If %subst(DCLS.definition:i:1) = ')';
            x = i;
            Leave;
         EndIf;
      EndFor;
/endif
      If x > 0
      and x = %len(%trimr(DCLS.definition));
         DCLS.definition = %subst(DCLS.definition:1:x-1);
      EndIf;

      If constantDef.type = *Blank;
         If %subst(DCLS.definition:1:1) = '''';
            constantDef.type = 'CHAR';
         Else;
            constantDef.type = 'NUMERIC';
         EndIf;
      EndIf;


      // Build the definition of the constant as we go.
      constantDef.length += %len(%trim(DCLS.definition));
      // Starts with a quote - reduce length.
      If %subst(%trim(DCLS.definition):1:1) = '''';
         constantDef.length -= 1;
      EndIf;
      // Ends with a quote - reduce length.
      If %subst(%trim(DCLS.definition):%len(%trim(DCLS.definition)):1) = '''';
         constantDef.length -= 1;
      EndIf;
      // Ends with a dash - reduce length.
      If %subst(%trim(DCLS.definition):%len(%trim(DCLS.definition)):1) = '-';
         constantDef.length -= 1;
      EndIf;

   Else;
      inLong = *Off;
   EndIf;

   If comment <> *Blanks;
      If %subst(%trim(comment):1:2) = '//';
         DCLS.comment = '   ' + comment;
      Else;
         DCLS.comment = '// ' + comment;
      EndIf;
   EndIf;

   If not inSpan;
      DCLS.definition = %trimr(DCLS.definition) + ';';
      // Continuation of constant must start at left margin.
      If DCLS.decl = *Blanks;
         DCLS = DCLS.definition;
         inConstant = *On;
      EndIf;
      inDeclaration = *Off;
      // Store the definition.
      storeVariableDef(constantDef.variableName
                      :constantDef.type
                      :%char(constantDef.length)
                      :%char(constantDef.scale)
                      :'');
   Else;
      // Continuation of constant must start at left margin.
      If DCLS.decl = *Blanks;
         DCLS = DCLS.definition;
         inConstant = *On;
      EndIf;
      inSpan = *Off;
   EndIf;

   // Converted line...
   sourceLine = DCLS;
   If not inSpan;
      savedName = *Blanks;
   EndIf;

EndSr;
//------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------
// Prototype/Interface/Datastructure definition.
//------------------------------------------------------------------------------------------
BegSr subBlockDefinition;

   Clear DCLPR;

   // Determine where to end the structure.
   If not inPrototype
   and not inInterface
   and not inDatastructure;
      inDatastructureDecl = *Off;
      If workDeclType = 'PR';
         inPrototype = *On;
      ElseIf workDeclType = 'PI';
         inInterface = *On;
      ElseIf workDeclType = 'DS';
         inDatastructure = *On;
      EndIf;
      DCLPR.decl = 'Dcl-' + workDeclType;
      If savedName = *Blanks;
         savedName = '*N';
      EndIf;
      %subst(DCLPR:8) = savedName;
      endDeclType = workDeclType;
      workDeclName = savedName;
      getDeclarationEndLine();

//////      If inDatastructure;
//////         // Scan for whether or not an End-DS is required...
//////         endDS = isEndDSRequired();
//////      Else;
//////         endDS = *Off;
//////      EndIf;
   Else;
      DCLPR.fieldName = savedName;
   EndIf;

   If not inDeclaration;
      If DCLPR.fieldName = *Blanks;
         DCLPR.fieldName = '*N';
      EndIf;
      inDeclaration = *On;
   EndIf;

   // Store name?
   If inDatastructure
   and DCLPR.fieldName <> *Blanks;
      If %subst(DCLPR.fieldName:1:1) = '-';
         fieldName = %xlate(LO:UP:%subst(DCLPR.fieldName:5));
      Else;
         fieldName = %xlate(LO:UP:DCLPR.fieldName);
      EndIf;

      storeVariable(fieldName);
   EndIf;

   If %len(%trim(savedName)) <= 17;   // Long name - must be the only thing on this line.

      // Type.
      If workDeclAttr = *Blanks
      and DCLPR.type = *Blanks;
         If declLen = *Blanks or %xlate(LO:UP:declLen) = 'E';
            // No definition (probably in keywords - e.g. LIKE()).
         ElseIf declScale = *Blanks;
            workDeclAttr = 'A';
         Else;
            If inDatastructure;
               workDeclAttr = 'S';
            Else;
               workDeclAttr = 'P';
            EndIf;
         EndIf;
      EndIf;

      If workDeclAttr = *Blanks;
         // No definition (probably in keywords - e.g. LIKE()).
      ElseIf workDeclAttr = 'A';
         If DCLPR.decl = 'Dcl-DS';
            If declLen <> *Blanks;
               DCLPR.type = '      Len';
            EndIf;
         Else;
            x = %scan('VARYING':%xlate(LO:UP:declKeywords));
            If x > 0;
               DCLPR.type = '  VarChar';
               declKeywords = %subst(declKeywords:x+7);
            Else;
               DCLPR.type = '     Char';
            EndIf;
         EndIf;
      ElseIf workDeclAttr = 'P';
         DCLPR.type = '   Packed';
      ElseIf workDeclAttr = 'D';
         DCLPR.type = '     Date';
         x = %scan('DATFMT':%xlate(LO:UP:declKeywords));
         If x > 0;
            x = %scan('(':declKeywords:x);
            y = %scan(')':declKeywords:x);
            DCLS.definition = '('
                      + %subst(declKeywords:x+1:y-x-1)
                      + ')';
            declKeywords = %subst(declKeywords:y+1);
         EndIf;
         workLength = 8;
      ElseIf workDeclAttr = 'T';
         DCLPR.type = '     Time';
         x = %scan('TIMFMT':%xlate(LO:UP:declKeywords));
         If x > 0;
            x = %scan('(':declKeywords:x);
            y = %scan(')':declKeywords:x);
            DCLS.definition = '('
                      + %subst(declKeywords:x+1:y-x-1)
                      + ')';
            declKeywords = %subst(declKeywords:y+1);
         EndIf;
         workLength = 6;
      ElseIf workDeclAttr = 'Z';
         DCLPR.type = 'TimeStamp';
         workLength = 26;
      ElseIf workDeclAttr = 'I';
         DCLPR.type = '      Int';
      ElseIf workDeclAttr = 'U';
         DCLPR.type = '      Uns';
      ElseIf workDeclAttr = 'S';
         DCLPR.type = '    Zoned';
      ElseIf workDeclAttr = 'F';
         DCLPR.type = '    Float';
      ElseIf workDeclAttr = 'N';
         DCLPR.type = '      Ind';
         workLength = 1;
      ElseIf workDeclAttr = '*';
         DCLPR.type = '  Pointer';
         x = %scan('PROCPTR':%xlate(LO:UP:declKeywords));
         If x > 0;
            DCLPR.definition = '(*PROC)';
            declKeywords = %subst(declKeywords:x+7);
         EndIf;
         workLength = 15;
      ElseIf workDeclAttr = 'B';
         DCLPR.type = '   BinDec';
      ElseIf workDeclAttr = 'G';
         x = %scan('VARYING':%xlate(LO:UP:declKeywords));
         If x > 0;
            DCLPR.type = ' VarGraph';
            declKeywords = %subst(declKeywords:x+7);
         Else;
            DCLPR.type = '    Graph';
         EndIf;
      Else;
         inDeclaration = *Off;
         convert = *Off;
         LeaveSr;
      EndIf;

      // Attributes.
      If workDeclAttr <> '*'
      and workDeclAttr <> 'N'
      and workDeclAttr <> 'D'
      and workDeclAttr <> 'T'
      and workDeclAttr <> 'Z'
      and workDeclAttr <> *Blank
      and DCLPR.type <> *Blanks;
         DCLPR.definition = '(';
         If inDatastructure and declFrom <> *Blanks;
            workLength = %dec(%trim(declLen):7:0)
                       - %dec(%trim(declFrom):7:0) + 1;
            If workDeclAttr = 'B';
               workLength = workLength * 2;
            ElseIf workDeclAttr = 'P';
               workLength = (workLength * 2) - 1;
            EndIf;
            adjustArrayLength(workLength);
            DCLPR.definition = %trim(DCLPR.definition)
                             + %char(workLength);
         Else;
            DCLPR.definition = %trim(DCLPR.definition)
                             + %trim(declLen);
            workLength = %dec(%trim(declLen):7:0);
         EndIf;

         If declScale <> *Blanks;
            DCLPR.definition = %trimr(DCLPR.definition)
                            + ':' + %trim(declScale);
         EndIf;
         DCLPR.definition = %trimr(DCLPR.definition) + ')';
      EndIf;

      // From specified?
      If inDatastructure;
         If declFrom <> *Blanks
         and %scan('...':declOptions) = 0;
            If %scan(%xlate(LO:UP:%trim(declFrom)):DSKEYWORDS) > 0;
               declKeywords = %xlate(LO:UP:declFrom) + %xlate(LO:UP:declLen)
                            + ' ' + declKeywords;
            Else;
               declKeywords = 'Pos(' + %trim(declFrom) + ') ' + declKeywords;
            EndIf;
         Else;
            // Overlay specified using the base datastructure name?
            // This is not permitted in free-form, so convert it to 'POS'.
            x = %scan('OVERLAY(':%xlate(LO:UP:declKeywords));
            If x > 0;
               i = %scan(':':declKeywords:x);
               If i > 0;
                  If %trim(%xlate(lo:up
                          :%subst(declKeywords:x+8:i-x-8))) =
                     %xlate(LO:UP:workDeclName);
                     j = %scan(')':declKeywords:i);
                     If j > 0;
                        If x = 1;
                           declKeywords
                            = 'Pos('
                            + %trim(%subst(declKeywords:i+1:j-i-1))
                            + %subst(declKeywords:j);
                        Else;
                           declKeywords
                             = %trim(%subst(declKeywords:1:x-1))
                             + ' Pos('
                             + %trim(%subst(declKeywords:i+1:j-i-1))
                             + %subst(declKeywords:j);
                        EndIf;
                     EndIf;
                  EndIf;
               EndIf;
            EndIf;
         EndIf;


      EndIf;

      // Datastructure type?
      If declPrefix = 'S';       // Program Status
         declKeywords = 'PSDS ' + declKeywords;
         If savedName = DCLPR.procName;
            %subst(savedName:16:1) = *Blank;
         EndIf;
         %subst(DCLPR.procName:16:1) = *Blank;

      ElseIf declPrefix = 'U';   // Dataarea
         // If not already defined as a data area, do it now.
         If %scan('DTAARA':%xlate(LO:UP:declKeywords)) = 0;
            If declName = *Blanks;
               declKeywords = 'DTAARA(*AUTO) ' + declKeywords;
            Else;
               declKeywords = 'DTAARA ' + declKeywords;
            EndIf;
         EndIf;
         %subst(DCLPR.procName:16:1) = *Blank;
      EndIf;

      // Keywords.
      If declKeyWords <> *Blanks;
         // Expand EXTNAME?
         x = %scan('EXTNAME(':%xlate(LO:UP:declKeywords));
         If x > 0;
            x += 8;   // Point to start of definition.
            // Are there any parameters?...
            i = %scan(':':declKeywords:x+1);
            If i = 0; // ...No - find the end;
               i = %scan(')':declKeywords:x+1);
            EndIf;

            DoW i > 0;
               If %scan('''':%subst(declKeywords:x:i-x)) = 0;
                  declKeywords = %subst(declKeywords:1:x-1)
                     + ''''
                     + %xlate(LO:UP:%trim(%subst(declKeywords:x:i-x)))
                     + ''''
                     + %subst(declKeywords:i);
                  x = i + 3;   // Nudge the search point to cater for inserted quotes.
               EndIf;
               i = %scan(':':declKeywords:x+1);
            EndDo;
         EndIf;
         // Expand DTAARA?
         x = %scan('DTAARA(':%xlate(LO:UP:declKeywords));
         If x > 0;
            i = %scan(')':declKeywords:x+1);
            If i > 0;
               If %scan('*AUTO':%subst(declKeywords:x+7:i-x-7)) > 0;
                  // Leave it as it is.
               ElseIf %scan('*VAR':%subst(declKeywords:x+7:i-x-7)) > 0;
/if defined(*V7R3M0)
                  j = %scan(':':declKeywords:x+7:i-x-7);
/else
                  j = %scan(':':declKeywords:x+7);
                  If j >= i-x-7;
                     j = 0;
                  EndIf;
/endif
                  declKeywords = %subst(declKeywords:1:x+6)
                     + %trim(%subst(declKeywords:j+1:i-j-1))
                     + %subst(declKeywords:i);
               Else;
                  If %scan('''':%subst(declKeywords:x+7:i-x-7)) = 0;
                     declKeywords = %subst(declKeywords:1:x+6)
                        + ''''
                        + %xlate(LO:UP:%trim(%subst(declKeywords:x+7:i-x-7)))
                        + ''''
                        + %subst(declKeywords:i);
                  EndIf;
               EndIf;
            EndIf;
         EndIf;
         If DCLPR.definition = *Blanks and DCLPR.type = *Blanks;
            DCLPR.definition = %trim(declKeyWords);
         Else;
            DCLPR.definition = %trimr(DCLPR.definition) + ' '
                            + %trim(declKeyWords);
         EndIf;
      EndIf;

      storeVariableDef(savedName:DCLPR.type:%char(workLength):declScale:DCLPR);
   EndIf;

   If comment <> *Blanks;
      If %subst(%trim(comment):1:2) = '//';
         DCLPR.comment = '   ' + comment;
      Else;
         DCLPR.comment = '// ' + comment;
      EndIf;
   EndIf;

   If not inSpan;
      If DCLPR.definition = *Blanks and DCLPR.type = *Blanks;
         DCLPR.procName = %trimr(DCLPR.procName) + ';';
      Else;
         DCLPR.definition = %trimr(DCLPR.definition) + ';';
//////         indentLine = *Off;
         keywordOffset = 37;
      EndIf;
      inDeclaration = *Off;
      inDatastructureDecl = *Off;
   Else;
      inSpan = *Off;
   EndIf;

   // Converted line...
   sourceLine = DCLPR;
   If not inSpan;
      savedName = *Blanks;
   EndIf;

EndSr;
//------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// Convert F-Spec to free-format.
//==========================================================================================
Dcl-Proc convertF_Spec;

// -- Procedure Interface ------------------------------------------------------------------
Dcl-PI *N;
End-PI;

// -- Data Structures ----------------------------------------------------------------------
// -- Variables ----------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------

    // Keep blank lines.
    If codeLine = *Blanks;
       sourceLine = *Blanks;
       convert = *On;
       Return;
    EndIf;

    sourceLine = fullLine;
    indentLine = *Off;

    workFileUsage  = %xlate(LO:UP:fileUsage);
    workFileDesig  = %xlate(LO:UP:fileDesig);
    workFileAdd    = %xlate(LO:UP:fileAdd);
    workFileDevice = %xlate(LO:UP:fileDevice);
    workFileKeyed  = %xlate(LO:UP:fileKeyed);

    checkSpan();  // Does this line span more than one line?

    If not inDeclaration;

       // Validate whether this can be converted.
       If workFileUsage = 'I'
       and (workFileDesig = 'P'
       or workFileDesig = 'S'
       or workFileUsage = 'T')

       or workFileUsage = 'O'
       and workFileAdd = 'A'

       or workFileUsage = 'U'
       and (workFileDesig = 'P'
       or workFileDesig = 'S')

       or workFileUsage = 'C'
       and workFileDesig = 'T';

          // Not supported in free-form.
          inDeclaration = *Off;
          convert = *Off;
          nonConvRsn = 'File usage not supported in free-form';
          Return;
       EndIf;

       savedName = %trim(fileName);

       If %xlate(LO:UP:fileExternal) = 'E';       // Externally-described file.
          inDeclaration = *On;

          Clear DCLF;
          DCLF.decl = 'Dcl-F ';
          %subst(DCLF:7) = %xlate(LO:UP:savedName);

          // Set device type.
          If workFileDevice <> 'DISK';
             DCLF.device = workFileDevice;
          EndIf;

          // Set usage.
          If workFileUsage = 'I';
             If workFileAdd = ' ';
                If workFileDevice <> 'DISK'
                and workFileDevice <> 'SEQ'
                and workFileDevice <> 'SPECIAL';
                   DCLF.definition = '*INPUT';
                EndIf;
             Else;
                DCLF.definition = '*INPUT:*OUTPUT';
             EndIf;
          ElseIf workFileUsage = 'U';
             If workFileAdd = ' ';
                DCLF.definition = '*UPDATE:*DELETE';
             Else;
                DCLF.definition = '*UPDATE:*DELETE:*OUTPUT';
             EndIf;
          ElseIf workFileUsage = 'O';
             If workFileDevice <> 'PRINTER';
                DCLF.definition = '*OUTPUT';
             EndIf;
          ElseIf workFileUsage = 'C';
             If workFileDevice <> 'WORKSTN';
                DCLF.definition = '*INPUT:*OUTPUT';
             EndIf;
          EndIf;

          // Pad out usage.
          If DCLF.definition <> *Blanks;
             DCLF.definition = 'Usage(' + %trim(DCLF.definition) + ')';
          EndIf;

          // Keyed file?
          If workFileKeyed = 'K';
             DCLF.definition = %trim(%trim(DCLF.definition)
                                     + ' ' + 'Keyed');
          EndIf;

          If comment <> *Blanks;
             If %subst(%trim(comment):1:2) = '//';
                DCLF.comment = '   ' + comment;
             Else;
                DCLF.comment = '// ' + comment;
             EndIf;
          EndIf;

          // Keywords.
          If fileKeyWords <> *Blanks;
             // Do we have room to insert the keywords here?
             checkLength = %len(%trim(%trim(DCLF.definition)
                                     + ' ' + %trim(fileKeyWords))) + 1;

             If comment <> *Blanks;
                checkLength += 3;
             EndIf;

             If checkLength > %len(DCLF.definition);
                // Not enoungh room for the keywords, so output the current line.
                savedSRCDTA = SRCDTA;
                lineType = *Blank;
                directive = *Blanks;
                codeLine = DCLF;
                writeLine();
                SRCDTA = savedSRCDTA;
                // ...and move the keywords to their own line.
                Clear DCLF;
                DCLF.definition = fileKeywords;
                savedComment = *Blanks;
             Else;
                DCLF.definition = %trim(%trim(DCLF.definition)
                                        + ' ' + %trim(fileKeyWords));
             EndIf;
          EndIf;

          If not inSpan;
             DCLF.definition = %trimr(DCLF.definition) + ';';
             inDeclaration = *Off;
          Else;
             inSpan = *Off;
          EndIf;

          // Converted line...
          sourceLine = DCLF;

          // Store field definitions?
          If workFileDevice = 'DISK';
             retrieveFileColumns(fileName);
          ElseIf workFileDevice = 'WORKSTN' or workFileDevice = 'PRINTER';
             retrieveDSPFFields(fileName);
          EndIf;
       Else;
          inDeclaration = *Off;
          convert = *Off;
          nonConvRsn = 'File not externally-described';
          Return;
       EndIf;

    Else;                   // Second+ line of declaration
       Clear DCLF;
       DCLF.definition = %trim(fileKeyWords);
       If not inSpan;
          DCLF.definition = %trim(DCLF.definition) + ';';
          inDeclaration = *Off;
       EndIf;
       sourceLine = DCLF;
       inSpan = *Off;
    EndIf;

    convert = *On;

   Return;

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// Convert H-Spec
//==========================================================================================
Dcl-Proc convertH_Spec;

// -- Procedure Interface ------------------------------------------------------------------
Dcl-PI *N;
End-PI;

// -- Data Structures ----------------------------------------------------------------------
// -- Variables ----------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------

    // Keep blank lines.
    If codeLine = *Blanks;
       sourceLine = *Blanks;
       convert = *On;
       Return;
    EndIf;

    sourceLine = codeLine;
    indentLine = *Off;

    checkSpan();  // Does this line span more than one line?

    If not inDeclaration;
       inDeclaration = *On;

       Clear DCLH;
       DCLH.decl = 'Ctl-Opt ';
       DCLH.options = %trim(declOptions);

       If comment <> *Blanks;
          If %subst(%trim(comment):1:2) = '//';
             DCLH.comment = '   ' + comment;
          Else;
             DCLH.comment = '// ' + comment;
          EndIf;
       EndIf;

       If not inSpan;
          DCLH.options = %trimr(DCLH.options) + ';';
          inDeclaration = *Off;
       Else;
          inSpan = *Off;
       EndIf;

       // Converted line...
       sourceLine = DCLH;

    Else;                   // Second+ line of declaration
       Clear DCLH;
       DCLH.options = %trim(declOptions);
       If not inSpan;
          DCLH.options = %trim(DCLH.options) + ';';
          inDeclaration = *Off;
       EndIf;
       sourceLine = DCLH;
       inSpan = *Off;
    EndIf;

    convert = *On;

   Return;

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// Convert I-Spec - no conversion possible, but add any defined fields to the
//                  variable disctionary to aid MOVEs, etc.
//==========================================================================================
Dcl-Proc convertI_Spec;

// -- Procedure Interface ------------------------------------------------------------------
Dcl-PI *N;
End-PI;

// -- Data Structures ----------------------------------------------------------------------
Dcl-DS formatJ                                   Qualified;
   lineType                        Char(1)       Pos(6);
   formatJBlanks                   Char(24)      Pos(7);
   from                            Char(5)       Pos(37);
   to                              Char(5)       Pos(42);
   dc                              Char(2)       Pos(47);
   field                           Char(14)      Pos(49);
End-DS;

Dcl-DS formatJX                                  Qualified;
   lineType                        Char(1)       Pos(6);
   extField                        Char(10)      Pos(21);
   field                           Char(14)      Pos(49);
End-DS;

Dcl-DS field                                     LikeDS(variableDef_T);
Dcl-DS extField                                  LikeDS(variableDef_T);

// -- Variables ----------------------------------------------------------------------------
Dcl-S from                          Uns(10);
Dcl-S to                            Uns(10);
Dcl-S dc                            Uns(10);
Dcl-S length                        Uns(10);
Dcl-S type                         Char(10);

//------------------------------------------------------------------------------------------

   // Extract source line.
   formatJ  = sourceData;
   formatJX = sourceData;


   // Valid Format J...
   If formatJ.formatJBlanks = *Blanks;
      // ...get definitions.
      from = %dec(formatJ.from:5:0);
      to   = %dec(formatJ.to  :5:0);
      If formatJ.dc = *Blanks;
         dc = 0;
         type = 'CHAR';
      Else;
         dc = %dec(formatJ.dc:2:0);
         type = 'NUMERIC';
      EndIf;
      length = to - from + 1;

      // Add to dictionary.
      storeVariableDef(formatJ.field:type:%char(length):%char(dc):'');

   // Valid format JX...
   ElseIf formatJX.extField <> *Blanks;
      // ...get external field definition.
      extField = retrieveVariableDef(formatJX.extField);

      // If external field found in dictionary, add mapped field to dictionary.
      If extField.variableName <> *Blanks;
         field = extField;
         field.variableName = formatJX.field;    // Assign new field name.
         storeVariableDef(field.variableName:field.type:%char(field.length):%char(field.scale):'');
      EndIf;

   EndIf;

   Return;

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// Convert P-Spec
//==========================================================================================
Dcl-Proc convertP_Spec;

// -- Procedure Interface ------------------------------------------------------------------
Dcl-PI *N;
End-PI;

// -- Data Structures ----------------------------------------------------------------------
// -- Variables ----------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------

   // Keep blank lines.
   If codeLine = *Blanks;
      sourceLine = *Blanks;
      convert = *On;
      Return;
   EndIf;

   sourceLine = fullLine;

   checkSpan();  // Does this line span more than one line?

   If not inDeclaration;   // First line of procedure start/end.

      GetDeclarationType(workDeclType:savedName:workDeclLine);

      If workDeclType = 'B'       // Begin.
      or workDeclType = 'E'       // End.
      or declName <> *Blanks;
         inDeclaration = *On;

         Clear DCLP;

         If workDeclType = 'B';
            DCLP.decl = 'Dcl-Proc ';
         Else;
            DCLP.decl = 'End-Proc ';
         EndIf;
         DCLP.definition = savedName;

         If procKeyWords <> *Blanks;
            DCLP.definition = %trimr(DCLP.definition)
                            + ' ' + %trim(procKeyWords);
         EndIf;

         If comment <> *Blanks;
            If %subst(%trim(comment):1:2) = '//';
               DCLP.comment = '   ' + comment;
            Else;
               DCLP.comment = '// ' + comment;
            EndIf;
         EndIf;

         If not inSpan;
            DCLP.definition = %trimr(DCLP.definition) + ';';
            inDeclaration = *Off;
         Else;
            inSpan = *Off;
         EndIf;

         // Converted line...
         sourceLine = DCLP;
         savedName = *Blanks;

      Else;
         inDeclaration = *Off;
         convert = *Off;
         Return;
      EndIf;

   Else;                   // Second+ line of procedure start/end.
      Clear DCLP;
      DCLP.definition = %trim(declKeyWords);
      If not inSpan;
         DCLP.definition = %trimr(DCLP.definition) + ';';
      EndIf;
      sourceLine = DCLP;
      inSpan = *Off;
   EndIf;

   convert = *On;

   Return;

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// Get the line number at which the current structure ends.
//==========================================================================================
Dcl-Proc getDeclarationEndLine;

// -- Procedure Interface ------------------------------------------------------------------
Dcl-PI *N;
End-PI;

// -- Data Structures ----------------------------------------------------------------------
// -- Variables ----------------------------------------------------------------------------
Dcl-S wkDirective               Char(10);

//-------------------------------------------------------------------------------------------

    savedSRCDTA = SRCDTA;
    endLine = 0;
    endFound = *Off;

    // Read ahead to find the start of the next declaration.
    Read INPSRC InpLine;
    x = 1;
    DoW not %eof();
       If lineType <> *Blanks;
          If %xlate(LO:UP:lineType) = workLineType;
             If codeLine = *Blanks;
                // Ignore empty lines.
             ElseIf %subst(directive:1:1) = '/';
                // Ignore directives.
             ElseIf %subst(directive:2:1) = '*'
                 or %len(%trim(codeLine)) >= 2
                and %subst(%trim(codeLine):1:2) = '//';
                // Ignore comment.
             ElseIf inSpan
                and declName = *Blanks
                and SRCSEQ = workDeclLine;
                // Ignore the curent declaration.
             ElseIf declType = *Blanks
                and (declLen <> *Blanks or declKeywords <> *Blanks or declAttr <> *Blanks);
                // Ignore sub-field definition.
             ElseIf declType = *Blanks
                and declName <> *Blanks
                and %scan('...':declOptions) = 0;
                // Ignore sub-field definition.
             ElseIf %scan('...':declOptions) > 0;
                // We have a continuation line, but is it a sub-field or a new
                // delcaration?
                GetDeclarationType(tempDeclType
                                  :tempSavedName
                                  :tempDeclLine);
                If tempDeclType <> *Blanks;
                   // We've hit the next declaration or code.
                   Leave;
                EndIf;
             Else;
                // We've hit the next declaration or code.
                Leave;
             EndIf;
          Else;
             // We've found a different line type.
             Leave;
          EndIf;
       Else;
          If %len(%trim(codeLine)) >= 4;
             If %xlate(LO:UP:%subst(codeLine:1:4)) = 'DCL-';
                // We've found a different line type.
                Leave;
             EndIf;
          EndIf;
       EndIf;

       Read INPSRC InpLine;
       x += 1;     // Keep a track of how many lines we have read.
    EndDo;

    // End of file breaks the logic!  We need to reposition to the last record before
    // continuing.
    If %eof(INPSRC);
       SetGT *HIVAL INPSRC;
       SRCSEQ += 0.01;
    EndIf;

    // We are now at the start of the next declaration.
    endLine = SRCSEQ;
    endFound = *Off;

    // Return to the previous point.
    For i = 1 to x;
       ReadP INPSRC InpLine;

       // Move the end point ignoring blank lines or comments.
       If not endFound;
          wkDirective = %xlate(LO:UP:directive);
          If codeLine = *Blanks;
             endLine = SRCSEQ;
          ElseIf (lineType = *Blanks
             or %subst(wkDirective:1:1) = '*'
             or %subst(wkDirective:1:2) = '//'
             or (%len(%trim(codeLine)) > 1
             and %subst(%trim(codeLine):1:2) = '//'))
          and %subst(wkDirective:1:6) <> '/ENDIF';
             endLine = SRCSEQ;
          ElseIf (%subst(wkDirective:1:5) = '/COPY' or %subst(wkDirective:1:8) = '/INCLUDE')
             and (inPrototype or inInterface or inDataStructure);
             endLine = SRCSEQ;
          Else;
             endFound = *On;
          EndIf;
       EndIf;
    EndFor;

    SRCDTA = savedSRCDTA;

   Return;

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// Returns whether or not an End-DS is required for the current data structure
// definition.
//==========================================================================================
Dcl-Proc isEndDSRequired;

// -- Procedure Interface ------------------------------------------------------------------
Dcl-PI *N                    Ind;
End-PI;

// -- Data Structures ----------------------------------------------------------------------
// -- Variables ----------------------------------------------------------------------------
Dcl-S isRequired             Ind      Inz(*On);
Dcl-S x                      Int(10);
Dcl-S i                      Int(10);

//-------------------------------------------------------------------------------------------

   savedSRCDTA = SRCDTA;
   endFound = *Off;

   // Read ahead to find the start of the next declaration.

   DoU SRCSEQ >= endLine;
      If %scan('LIKEDS(':%xlate(LO:UP:SRCDTA)) > 0;
         isRequired = *Off;
         Leave;
      ElseIf %scan('LIKEREC(':%xlate(LO:UP:SRCDTA)) > 0;
         isRequired = *Off;
         Leave;
//      ElseIf %scan('END-DS':%xlate(LO:UP:declKeywords)) > 0;
      ElseIf %scan('END-DS':%xlate(LO:UP:SRCDTA)) > 0;
         isRequired = *Off;
         Leave;
      EndIf;

      Read INPSRC InpLine;
      x += 1;     // Keep a track of how many lines we have read.
   EndDo;

    // End of file breaks the logic!  We need to reposition to the last record before
    // continuing.
    If %eof(INPSRC);
       SetGT *HIVAL INPSRC;
       SRCSEQ += 0.01;
    EndIf;


    // Return to the previous point.
    For i = 1 to x;
       ReadP INPSRC InpLine;
    EndFor;

    SRCDTA = savedSRCDTA;

   Return isRequired;

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// Get the type of declaration encountered - it may not be on the current line!
//==========================================================================================
Dcl-Proc getDeclarationType;

// -- Procedure Interface ------------------------------------------------------------------
Dcl-PI GetDeclarationType;
   p_DeclType               Char( 2 );
   p_SavedName              Char( 80 );
   p_DeclLine                        Like(SRCSEQ);
End-PI;

// -- Data Structures ----------------------------------------------------------------------

// -- Variables ----------------------------------------------------------------------------
Dcl-S savedLineType        Char(  1 );
Dcl-S x                  Packed( 3:0 );
Dcl-S savedSRCDTA          Char( 100 );

//-------------------------------------------------------------------------------------------

   // Start with what we've got.
   If ((declExt = ' ' and declPrefix  = ' ')
   or declPrefix = 'S' or declPrefix = 'U')
   and declSuffix = ' ';
      p_DeclType = %xlate(LO:UP:declType);
      p_SavedName = %trim(declName);
   Else;
      p_DeclType = *Blank;
      p_SavedName = %trim(%subst(fullLine:1:74));
   EndIf;

   x = %scan(' ':p_SavedName);
   If x > 1;
      p_SavedName = %subst(p_SavedName:1:x-1);
   EndIf;

   // If we already have the declaration type, then stop.
   If p_DeclType = 'S'
   or p_DeclType = 'DS'
   or p_DeclType = 'C'
   or p_DeclType = 'B'
   or p_DeclType = 'E'
   or p_DeclType = 'PR'
   or p_DeclType = 'PI'

   or p_DeclType = *Blanks and declType = *Blanks
   and (inPrototype or inDataStructure);
      p_DeclLine = SRCSEQ;
      p_SavedName = %trimr(p_SavedName:'. ');
      Return;
   EndIf;

   savedSRCDTA = SRCDTA;
   savedLineType = %xlate(LO:UP:lineType);      // Save current line type for comparison.
   p_DeclLine = 0;

   // Trim any ellipsis from the name as this is not valid in free-form.
   x = %scan('...':p_SavedName);
   If x > 0;
      p_SavedName = %trimr(p_SavedName:'. ');
      inSpan = *On;
      inLong = *On;
   ElseIf declFrom <> *Blanks
       or declLen <> *Blanks
       or declOptions <> *BLanks;
      // It's not a declaration - it's a subfield.
      p_DeclType = %xlate(LO:UP:declType);
      p_DeclLine = SRCSEQ;
      Return;
   EndIf;

   // Read ahead to find the next line with a declaration type.
   x = 0;
   Read INPSRC InpLine;
   DoW not %eof();
      x += 1;     // Keep a track of how many lines we have read.

      lineType = %xlate(LO:UP:lineType);

      If lineType <> savedLineType;
         // End of this declaration.
         Leave;
      EndIf;

      If declType <> *Blanks;
         // We have found the declaration.
         p_DeclType = %xlate(LO:UP:declType);
         p_DeclLine = SRCSEQ;
         Leave;
      ElseIf declFrom <> *Blanks
          or declLen <> *Blanks
          or declOptions <> *BLanks;
         // It's not a declaration - it's a subfield.
         p_DeclType = %xlate(LO:UP:declType);
         p_DeclLine = SRCSEQ;
         Leave;
      EndIf;

      Read INPSRC InpLine;
   EndDo;

   // End of file breaks the logic!  We need to reposition to the last record before
   // continuing.
   If %eof(INPSRC);
      SetGT *HIVAL INPSRC;
      ReadP INPSRC InpLine;
   EndIf;

   // Return to the previous point.
   For i = 1 to x;
      ReadP INPSRC InpLine;
   EndFor;

   SRCDTA = savedSRCDTA;

   Return;

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// Move in-line definitions to the end of the declarations.
//==========================================================================================
Dcl-Proc moveDefinitions;

   // -- Procedure Interface ------------------------------------------------------------------

   // -- Data Structures ----------------------------------------------------------------------
   Dcl-DS movedDefs                       LikeDS(variableDef_T) DIM(9999);
   Dcl-DS checkDef                        LikeDS(variableDef_T);

   // -- Variables ----------------------------------------------------------------------------
   Dcl-S x                             Uns(5);
   Dcl-S l                             Uns(5);
   Dcl-S p                             Uns(5);
   Dcl-S y                             Uns(5);
   Dcl-S moved                         Ind;
   Dcl-S moveDef                       Ind;
   Dcl-S useINArray                    Ind;

   //-------------------------------------------------------------------------------------------

   codeStart = SRCSEQ;   // Save the start of the source.
   savedSRCDTA = SRCDTA;

   Clear movedDefs;
   Reset DCLS;
   moved = *Off;
   useINArray = *Off;

   // Read through the source and create a D-spec for every field definition found.
   DoW not %eof(INPSRC);
      // Stop if we hit either the start or end of a procedure (to preserve local
      // definitions of variables).
      If lineType = 'P'
      or %xlate(LO:UP:%subst(%trim(codeLine) + '        ':1:8))
                                                   = 'DCL-PROC'
      or %xlate(LO:UP:%subst(%trim(codeLine) + '        ':1:8))
                                                   = 'END-PROC';
         Leave;
      EndIf;

      If %xlate(LO:UP:lineType) = 'C'
      and %subst(directive:1:1) = ' ';
         opCode = %xlate(LO:UP:opCode);
         // C-Spec with a size definition.
         If opCode <> *Blanks
         and %subst(opCode:1:4) <> 'EVAL'
         and opCode <> 'IF'
         and opCode <> 'ELSEIF'
         and opCode <> 'WHEN'
         and opCode <> 'DOW'
         and opCode <> 'DOU'
         and opCode <> 'DSPLY'
         and opCode <> 'SORTA'
         and opCode <> 'SORTA(D)'
         and %subst(opCode:1:5) <> 'CALLP'
         and (len <> *Blanks or opCode = 'DEFINE' or opCode = 'DO' and result = *Blanks)
         or  opCode = 'MOVEA'
         and %subst(result:1:3) = '*IN'
         and (%scan('''1':factor2) > 0 or %scan('''0':factor2) > 0);
            moveDef = *Off;
            // Special case: DO with a count variable.
            If opCode = 'DO' and result = *Blanks;
               result = 'ZZ_doCount';
               len = '9';
               dec = '0';
            EndIf;
            // Special case: MOVEA referencing the indicator array.
            If opCode = 'MOVEA'
            and %subst(result:1:3) = '*IN'
            and (%scan('''1':factor2) > 0 or %scan('''0':factor2) > 0);
               useINArray = *On;
            EndIf;

            // Trim off modifiers.
            x = %scan(':':result);
            If x > 0;
               result = %subst(result:1:x-1);
            EndIf;

            // Only do if not already moved.
            If %lookup(%xlate(LO:UP:result):defVariable) = 0
            and %lookup(%xlate(LO:UP:result):movedDefs(*).variableName) = 0;
               Reset DCLS;
               DCLS.decl = setOpCodeCase(DCLS.decl:p_OpCodeCase);
               // In-line definition.
               If len <> *Blanks
               and %scan('+':len) = 0 and %scan('-':len) = 0;
                  moveDef = *On;
                  DCLS.fieldName = result;
                  If dec = *Blanks;
                     DCLS.type = '     Char';
                  Else;
                     DCLS.type = '   Packed';
                  EndIf;
                  DCLS.definition = '(' + %trim(len);
                  If dec <> *Blanks;
                     DCLS.definition = %trimr(DCLS.definition)
                                     + ':' + %trim(dec);
                  EndIf;
                  DCLS.definition = %trimr(DCLS.definition) + ')';
               EndIf;

               // *LIKE Definition
               If %xlate(LO:UP:opCode) = 'DEFINE';
                  moveDef = *On;
                  DCLS.fieldName = result;
                  If %xlate(LO:UP:factor1) = '*LIKE';
                     %subst(DCLS.definition:8)
                                 = 'LIKE(' + %trimr(factor2);
                     // Length adjustment?
                     If %scan('+':len) > 0 or %scan('-':len) > 0;
                        len = %scanrpl(' ':'':len);
                        DCLS.definition = %trimr(DCLS.definition)
                                        + ':' + %trim(len);
                     EndIf;
                     DCLS.definition = %trimr(DCLS.definition) + ')';
                  Else;
                     If %xlate(LO:UP:%trim(factor2)) = '*LDA';
                        DCLS.definition = %trimr(DCLS.definition)
                              + ' DTAARA(' + %trimr(factor2) + ')';
                     ElseIf factor2 = *Blanks;
                        DCLS.definition = %trimr(DCLS.definition)
                          + ' DTAARA';
                     Else;
                        DCLS.definition = %trimr(DCLS.definition)
                          + ' DTAARA(''' + %trimr(factor2) + ''')';
                     EndIf;
                  EndIf;
               EndIf;

               If moveDef;
                  // Put any additional keywords needed here!
                  DCLS.definition = %trimr(DCLS.definition) + ';';
                  If comment <> *Blanks;
                     DCLS.comment = '// ' + comment;
                  EndIf;

                  checkDef = retrieveVariableDef(result);

                  If checkDef.variableName = *Blanks;     // Not already stored.

                     // Store the moved definition.
                     storeVariableDef(result:DCLS.type:len:dec:DCLS);

                     x = %lookup(' ':movedDefs(*).variableName);
                     movedDefs(x).variableName = %xlate(LO:UP:result);
                     movedDefs(x).sourceLine = DCLS;
                     movedDefs(x).type = %trim(DCLS.type);
                     If len <> *Blanks;
                        Monitor;
                           movedDefs(x).length = %dec(len:3:0);
                        On-Error;
                           movedDefs(x).length = 0;
                        EndMon;
                     EndIf;

                     // Already defined on *ENTRY parameter list?
                     movedDefs(x).move = *On;
                     For l = 1 to parmListCount;
                        If parmList(l).listName = *Blanks;
                           Leave;
                        ElseIf parmList(l).listName = '*ENTRY';
                           For p = 1 to %elem(parmList.parameterDef);
                              If %xlate(LO:UP:parmList(l).parameterDef(p).parmName)
                                       = movedDefs(x).variableName;
                                 movedDefs(x).move = *Off;
                                 Leave;
                              EndIf;
                           EndFor;
                        EndIf;
                        If movedDefs(x).move = *Off;
                           Leave;
                        EndIf;
                     EndFor;
                  EndIf;

                  moved = *On;
               EndIf;
            EndIf;
         EndIf;
      EndIf;

      Read INPSRC InpLine;
   EndDo;

   // Provide variables to perform conversion of indicator array moves.
   If useINArray;
      Reset DCLS;

      result = 'zz_indArray';
      DCLS.fieldName = 'zz_indArray';
      DCLS.type = '     Char';
      DCLS.definition = '(99) Based(zz_IndArrayPtr);';

      // Store the moved definition.
      x = %lookup(' ':movedDefs(*).variableName);
      movedDefs(x).variableName = %xlate(LO:UP:result);
      movedDefs(x).sourceLine = DCLS;
      movedDefs(x).move = *On;

      result = 'zz_indArrayPtr';
      DCLS.fieldName = 'zz_indArrayPtr';
      DCLS.type = '  Pointer';
      DCLS.definition = '     Inz(%addr(*IN));';

      // Store the moved definition.
      x = %lookup(' ':movedDefs(*).variableName);
      movedDefs(x).variableName = %xlate(LO:UP:result);
      movedDefs(x).sourceLine = DCLS;
      movedDefs(x).move = *On;
      moved = *On;
   EndIf;

   // Anything to output?
   If moved;
      SortA movedDefs(*).variableName;
      For x = 1 to %elem(movedDefs);
         If movedDefs(x).variableName <> *Blanks;
            If not defsMoved;
               // Log start of moved field block;
               SRCDTA = *Blanks;
               codeLine = comments(1);
               writeLine();
               codeLine = comments(2);
               writeLine();
               codeLine = comments(1);
               writeLine();
               defsMoved = *On;
            EndIf;

            If movedDefs(x).move = *On;
               lineType = ' ';
               codeLine = movedDefs(x).sourceLine;
               countMoved += 1;

               writeLine();
            EndIf;
         EndIf;
      EndFor;

      If defsMoved;
         // Log end of moved field block;
         SRCDTA = *Blanks;
         codeLine = comments(1);
         writeLine();
         codeLine = comments(3);
         writeLine();
         codeLine = comments(1);
         writeLine();
      EndIf;
   EndIf;

   // Reposition source file pointer to the start of the source again.
   SetLL *Start INPSRC;
   Read INPSRC InpLine;
   DoW SRCSEQ <> codeStart;
      Read INPSRC InpLine;
   EndDo;

   defsMoved = *On;
   SRCDTA = savedSRCDTA;

   Return;

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// If factor1 a key list, expand it to contain the key fields.
//==========================================================================================
Dcl-Proc getKeyList;

   // -- Procedure Interface ------------------------------------------------------------------
   Dcl-PI *N                  VarChar(93);
      factor1                    Char(14);
   End-PI;

   // -- Data Structures ----------------------------------------------------------------------
   // -- Variables ----------------------------------------------------------------------------
   Dcl-S keyFields         VarChar(93);
   Dcl-S listName             Char(14);
   Dcl-S x                     Uns(3);
   //-------------------------------------------------------------------------------------------

   keyFields = %trim(factor1);

   // Do we have any key lists, and if so, is factor1 the name of one?
   If keyListCount > 0
   and factor1 <> *Blanks;
      listName = %xlate(LO:UP:%trim(factor1));

      x = %lookup(listName:keyList(*).listName:1:keyListCount);

      If x > 0;
         keyFields = '(' + %trim(keyList(x).keyFields) + ')';
      EndIf;
   EndIf;

   // Return the list of key fields (or just factor1 of none exist).
   Return keyFields;

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// Extract key lists for use in conversions.
//==========================================================================================
Dcl-Proc extractKeyLists;

   // -- Procedure Interface ------------------------------------------------------------------
   // -- Data Structures ----------------------------------------------------------------------

   // -- Variables ----------------------------------------------------------------------------
   Dcl-S x                             Uns(5);
   Dcl-S inKeyList                     Ind;

   //-------------------------------------------------------------------------------------------

   Clear keyList;
   inKeyList = *Off;
   x = 0;
   keyListCount = 0;

   // Conversion of key lists requested?
   If p_ConvKLIST <> 'Y';
      Return;
   EndIf;

   SetLL *Start INPSRC;
   Read INPSRC InpLine;

   // Read through the source and create a record of every key List found.
   DoW not %eof(INPSRC);

      If inKeyList;
         // End of key list?
         If lineType = 'C'
         and %xlate(LO:UP:opCode) <> 'KFLD'
         and %subst(directive:1:1) <> '*'
         and opCode <> *Blanks;
            inKeyList = *Off;
            // Avoid an empty key list.
            If keyList(x).keyFields = *Blanks;
               keyList(x).listName = *Blanks;
               x -= 1;
            EndIf;

         // New key field.
         ElseIf lineType = 'C'
         and %xlate(LO:UP:opCode) = 'KFLD'
         and %subst(directive:1:1) <> '*';
            If factor2 = *Blanks;
               If keyList(x).keyFields = *Blanks;
                  keyList(x).keyFields = %xlate(LO:UP:result);
               Else;
                  keyList(x).keyFields = %trim(keyList(x).keyFields) + ':' + %xlate(LO:UP:result);
               EndIf;
            Else;
               // Key field conditioning indicator detected - abort the extraction of this key list.
               inKeyList = *Off;
               keyList(x).listName = *Blanks;
               keyList(x).keyFields = *Blanks;
               x -= 1;
            EndIf;
         EndIf;
      EndIf;

      If not inKeyList;
         // New key list - store the name.
         If lineType = 'C' and %xlate(LO:UP:opCode) = 'KLIST'
         and %subst(directive:1:1) <> '*';
            inKeyList = *On;
            x += 1;
            keyList(x).listName  = %xlate(LO:UP:factor1);
            keyList(x).keyFields = *Blanks;
         EndIf;
      EndIf;

      Read INPSRC InpLine;
   EndDo;

   keyListCount = x;

   Return;

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// Extract parameter list for use in conversions.
//==========================================================================================
Dcl-Proc extractParameterLists;

   // -- Procedure Interface ------------------------------------------------------------------
   // -- Data Structures ----------------------------------------------------------------------

   // -- Variables ----------------------------------------------------------------------------
   Dcl-S x                             Uns(5);
   Dcl-S f                             Uns(5);
   Dcl-S p                             Uns(5);
   Dcl-S inParmList                     Ind;
   Dcl-S inArrayData                    Ind;

   //-------------------------------------------------------------------------------------------

   Clear parmList;
   inParmList = *Off;
   inArrayData = *Off;
   x = 0;
   p = 0;
   parmListCount = 0;

   // Conversion of parameter lists requested?
   If p_ConvPLIST <> 'Y';
      Return;
   EndIf;

   SetLL *Start INPSRC;
   Read INPSRC InpLine;

   // Read through the source and create a record of every parameter List found.
   DoW not %eof(INPSRC);

      If %subst(SRCDTA:1:2) = '**';
         inArrayData = *On;
      EndIf;

      // Save position of output prototypes?
      If not inArrayData
         and (lineType = 'H' or lineType = 'F');
         seqProcDefs = SRCSEQ + 0.01;
      EndIf;

      If inParmList;
         // End of parameter list?
         If lineType = 'C'
         and %xlate(LO:UP:opCode) <> 'PARM'
         and %subst(directive:1:1) <> '*'
         and opCode <> *Blanks;
            inParmList = *Off;

         // New parameter.
         ElseIf lineType = 'C'
         and %xlate(LO:UP:opCode) = 'PARM'
         and %subst(directive:1:1) <> '*';
            p += 1;
            Clear DCLS;
            DCLS.fieldName = result;
            // In-line definition.
            If len <> *Blanks
            and %scan('+':len) = 0 and %scan('-':len) = 0;
               If dec = *Blanks;
                  DCLS.type = '     Char';
               Else;
                  DCLS.type = '   Packed';
               EndIf;
               DCLS.definition = '(' + %trim(len);
               If dec <> *Blanks;
                  DCLS.definition = %trimr(DCLS.definition)
                                  + ':' + %trim(dec);
               EndIf;
               DCLS.definition = %trimr(DCLS.definition) + ')';
            Else;
               DCLS.definition = 'Like(' + %trimr(DCLS.fieldName) + ')';
            EndIf;

            DCLS = %trimr(DCLS) + ';';
            If comment <> *Blanks;
               DCLS.comment = '// ' + comment;
            EndIf;

            parmList(x).parameterDef(p).parmName = result;
            parmList(x).parameterDef(p).parmInput = factor2;
            parmList(x).parameterDef(p).parmOutput = factor1;
            parmList(x).parameterDef(p).parmDef = DCLS;

            // For *ENTRY with mapped parameters, flag that we have already output it so that it
            // doesn't get converted - this is temporary until I get time to code the mappings
            // correctly.
            If parmList(x).listName = '*ENTRY'
            and (factor1 <> *Blanks or factor2 <> *Blanks);
               parmList(x).convert = *Off;
            EndIf;
         EndIf;
      EndIf;

      If not inParmList;
         // New parameter list - store the name.
         If lineType = 'C'
         and (%xlate(LO:UP:opCode) = 'PLIST'
           or %xlate(LO:UP:opCode) = 'CALL'
           or %xlate(LO:UP:opCode) = 'CALLB'
           or %xlate(LO:UP:%subst(opCode:1:5)) = 'CALL('
           or %xlate(LO:UP:%subst(opCode:1:6)) = 'CALLB(')
         and %subst(directive:1:1) <> '*';
            inParmList = *On;
            x += 1;
            parmList(x).lineNumber = SRCSEQ;
            If %xlate(LO:UP:opCode) = 'PLIST';
               parmList(x).listName  = %xlate(LO:UP:factor1);
               parmList(x).listType = 'PLIST';
            Else;
               parmList(x).listName  = %xlate(LO:UP:factor2);
               parmList(x).listProgram = %xlate(LO:UP:factor2);
               If %subst(parmList(x).listName:1:1) <> '''';     // Variable program call.
                  parmList(x).listName = %trim(parmList(x).listName) + '_';
               EndIf;
               parmList(x).listType = 'PGM';
               If result <> *Blanks;   // Program call uses a real parameter list.
                  parmList(x).listPList = %xlate(LO:UP:result);
               EndIf;
            EndIf;
            parmList(x).convert = *On;
            p = 0;
            Clear parmList(x).parameterDef;
         EndIf;
      EndIf;

      Read INPSRC InpLine;
   EndDo;

   parmListCount = x;

   Return;

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// Extract a list of TAGs and whether or not they are used.
//==========================================================================================
Dcl-Proc extractTAGs;

   // -- Procedure Interface ------------------------------------------------------------------
Dcl-PI *N                              Uns(5) End-PI;

   // -- Data Structures ----------------------------------------------------------------------

   // -- Variables ----------------------------------------------------------------------------
   Dcl-S tagCount                        Uns(5);
   Dcl-S tagName                        Char(14);
   Dcl-S wkFactor1                      Char(14);
   Dcl-S wkFactor2                      Char(14);
   Dcl-S wkOpCode                       Char(14);
   Dcl-S thisTag                         Uns(5);

   //-------------------------------------------------------------------------------------------

   Clear tagList;
   tagCount = 0;

   SetLL *Start INPSRC;
   Read INPSRC InpLine;

   // Read through the source and create list of every tag found.
   DoW not %eof(INPSRC);

      // New key list - store the name.
      If lineType = 'C'
      and %subst(directive:1:1) <> '*';

         wkOpCode = %xlate(LO:UP:opCode);
         wkFactor1 = %xlate(LO:UP:factor1);

         Select;
            When wkOpCode = 'TAG';
               tagName = wkFactor1;
               Exsr subUserAddToArray;

               tagList(thisTag).tagType = 'TAG';

            When wkOpCode = 'ENDSR' and factor1 <> *Blanks;
               tagName = wkFactor1;
               Exsr subUserAddToArray;

               tagList(thisTag).tagType = 'ENDSR';

            When wkOpCode = 'GOTO';
               tagName = %xlate(LO:UP:factor2);
               Exsr subUserAddToArray;

               tagList(thisTag).tagUsed = *On;
               tagList(thisTag).tagUsageCount += 1;

            When wkOpCode = 'GOTO' or %subst(wkOpCode:1:3) = 'CAB';
               tagName = %xlate(LO:UP:result);
               Exsr subUserAddToArray;

               tagList(thisTag).tagUsed = *On;
               tagList(thisTag).tagUsageCount += 1;

         EndSl;
      EndIf;

      Read INPSRC InpLine;
   EndDo;


   Return tagCount;
//-------------------------------------------------------------------------------------------

/Eject
//-------------------------------------------------------------------------------------------
// Add to array.
//-------------------------------------------------------------------------------------------
BegSr subUserAddToArray;

   // Get the index for this TAG.
   thisTag = %lookup(tagName:tagList(*).tagName:1:tagCount);

   // If not already in the array, add it.
   If thisTag = 0;
      tagCount += 1;
      thisTag = tagCount;
      tagList(thisTag).tagName = tagName;
   EndIf;

EndSr;
//-------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// Remove non-printable characters from the line.
//==========================================================================================
Dcl-Proc removeNonPrintable;

   // -- Procedure Interface ------------------------------------------------------------------
   Dcl-PI *N;
      codeLine                     Char(93);
      limit                         Uns(3)  Const Options(*NoPass);
   End-PI;

   // -- Data Structures ----------------------------------------------------------------------
   //
   Dcl-C PRINTABLE                 ' abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-
-=¬!"£$%^&*()_+\¦|,<.>/?[{]};:@#~''';

   // -- Variables ----------------------------------------------------------------------------
   Dcl-S length                    Uns(3);
   Dcl-S x                         Uns(3);
   Dcl-S comment               VarChar(93);
   Dcl-S wkLimit                   Uns(3);

   //-------------------------------------------------------------------------------------------

   // Only if requested.
   If p_RmvNonPrint <> 'Y';
      Return;
   EndIf;

   If %parms >= %parmnum(limit);
      wkLimit = limit;
   Else;
      wkLimit = %len(codeLine);
   EndIf;

   comment = %trimr(codeLine);
   length = %len(%trimr(comment));

   x = %check(PRINTABLE:comment);

   DoW x > 0 and x <= wkLimit;
      %subst(comment:x:1) = ' ';

      x = %check(PRINTABLE:comment:x);
   EndDo;

   codeLine = %trimr(comment);

   Return;

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// Remove end-of-comment markers.
//==========================================================================================
Dcl-Proc removeEndCommentMarker;

   // -- Procedure Interface ------------------------------------------------------------------
   Dcl-PI *N;
      removeMarkers                Char(1) Const;
      codeLine                     Char(93);
   End-PI;

   // -- Data Structures ----------------------------------------------------------------------

   // -- Variables ----------------------------------------------------------------------------
   Dcl-S length                    Uns(3);
   Dcl-S comment               VarChar(93);

   //-------------------------------------------------------------------------------------------

   // Only if requested.
   If removeMarkers <> 'Y';
      Return;
   EndIf;

   comment = %trimr(codeLine);
   length = %len(%trimr(comment));

   If length >= 4;
      If %subst(comment:length-1:2) = ' *';
         codeLine = %subst(comment:1:length-2);
      ElseIf %subst(codeLine:length-2:3) = ' //';
         codeLine = %subst(comment:1:length-3);
      EndIf;
   EndIf;

   Return;

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// Write out any prototype definitions.
//==========================================================================================
Dcl-Proc outputPrototypeDefs;

   // -- Procedure Interface ------------------------------------------------------------------
   // -- Data Structures ----------------------------------------------------------------------

   // -- Variables ----------------------------------------------------------------------------
   Dcl-S x                         Uns(5);
   Dcl-S y                         Uns(5);
   Dcl-S p                         Uns(5);
   Dcl-S protTitle                 Ind;
   Dcl-S protName                 Char(14);
   //-------------------------------------------------------------------------------------------

   // Only do this once.
   procsOutput = *On;

   // No prototypes to output.
   If parmListCount =0;
      Return;
   EndIf;

   // *ENTRY list first.
   For x = 1 to parmListCount;
      If parmList(x).listName = '*ENTRY'
      and parmList(x).convert;
         savedSRCDTA = SRCDTA;
         Clear SRCDTA;

         writeLine('');
         writeLine('       // Procedure Interface');
         writeLine('       Dcl-PI ' + %trim(p_FromMbr) + ';');
         For p = 1 to %elem(parmList.parameterDef);
            If parmList(x).parameterDef(p).parmDef = *Blanks;
               Leave;
            EndIf;
            writeLine('    ' + parmList(x).parameterDef(p).parmDef);
            If parmList(x).parameterDef(p).parmDef <> *Blanks;

               // Store names?
               storeVariable(parmList(x).parameterDef(p).parmName);

            EndIf;
         EndFor;
         writeLine('       End-PI;');

         SRCDTA = savedSRCDTA;
      EndIf;
   EndFor;

   // Prototypes next.
   For x = 1 to parmListCount;
      If parmList(x).listType = 'PGM' and not parmList(x).listOutput;
         protName = parmList(x).listName;
         savedSRCDTA = SRCDTA;
         Clear SRCDTA;

         writeLine('');
         If not protTitle;
            writeLine('       // Prototypes');
            protTitle = *On;
         EndIf;

         Reset DCLPR;
         DCLPR.procName = %scanrpl('''':'':parmList(x).listName);
         DCLPR.definition = 'ExtPgm(' + %trim(parmList(x).listProgram) + ');';
         writeLine('       ' + DCLPR);
         parmList(x).listOutput =*On;

         If parmList(x).listPList <> *Blanks;
            y = %lookup(parmList(x).listPList:parmList(*).listName);
         Else;
            y = x;
         EndIf;
         For p = 1 to %elem(parmList.parameterDef);
            If parmList(y).parameterDef(p).parmDef = *Blanks;
               Leave;
            EndIf;
            writeLine('    ' + parmList(y).parameterDef(p).parmDef);
         EndFor;
         writeLine('       End-PR;');

         // Flag any duplicates as output so we don't try to output them again.
         For y = 1 to parmListCount;
            If parmList(y).listType = 'PGM'
            and parmList(y).listName = protName
            and parmList(y).listOutput = *Off;
               parmList(y).listOutput = *On;
            EndIf;
         EndFor;

         SRCDTA = savedSRCDTA;
      EndIf;
   EndFor;

   writeLine('');

   Return;

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// Write out a line to the output member.
//==========================================================================================
Dcl-Proc writeLine;

   // -- Procedure Interface ------------------------------------------------------------------
Dcl-PI *N;
   outputSource          Char(240) Const   Options(*NoPass);
End-PI;

   // -- Data Structures ----------------------------------------------------------------------
Dcl-DS OutLine            Len(256) Qualified;
   SRCSEQ               Zoned(6:2);
   SRCDAT               Zoned(6:0);
   SRCDTA                Char(240);
End-DS;

   // -- Variables ----------------------------------------------------------------------------
Dcl-S lineMarker         Char(5);

   //-------------------------------------------------------------------------------------------

   countTarget += 1;

   If %parms() = 0;
      OutLine = InpLine;
   Else;
      OutLine.SRCSEQ = SRCSEQ;
      OutLine.SRCDAT = SRCDAT;
      OutLine.SRCDTA = outputSource;
   EndIf;

   // Using fully-free?  Shift to left margin.
   If fullyFree;
      lineMarker = %subst(OutLine.SRCDTA:1:5);
      If %subst(OutLine.SRCDTA:7:1) <> *Blank;
         OutLine.SRCDTA = %subst(OutLine.SRCDTA:7);
      Else;
         OutLine.SRCDTA = %subst(OutLine.SRCDTA:8);
      EndIf;

      If lineMarker <> *Blanks and p_RetLineMaker = 'Y';
         %subst(OutLine.SRCDTA:94) = '//' + lineMarker;
      EndIf;
   EndIf;

   Write OUTSRC OutLine;

   Return;

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// Check if the current line spans more than one line.
//==========================================================================================
Dcl-Proc checkSpan;

   // -- Procedure Interface ------------------------------------------------------------------
   // -- Data Structures ----------------------------------------------------------------------
   // -- Variables ----------------------------------------------------------------------------
   Dcl-S nameEnd                    Uns(5);
   Dcl-S ellipsis                   Uns(5);
   Dcl-S nameLen                    Uns(5);

   //-------------------------------------------------------------------------------------------

   inSpan = *Off;
   inLong = *Off;
   savedSRCDTA = SRCDTA;
   savedLineType = %xlate(LO:UP:lineType);      // Save current line type for comparison.
   x = 0;

   // Is the current line a continuation line?
   If savedLineType = 'D';
      If declName <> *Blanks;
         nameLen = %len(%trim(declOptions));
         nameEnd = %scan(' ':%trim(declOptions));
         ellipsis = %scan('...':%trim(declOptions));
         If nameEnd = 0 and ellipsis > 0 and ellipsis = nameLen - 2;
            // Yes - so we must be in a span.
            inSpan = *On;
            inLong = *On;
         EndIf;
      EndIf;
   EndIf;

   If not inSpan;

      Read INPSRC inpLine;

      DoW not %eof();

         x += 1;     // Keep a track of how many lines we have read.

         lineType = %xlate(LO:UP:lineType);

         If lineType <> *Blank
         and lineType <> savedLineType;
            // Not a spanned line.
            Leave;

         ElseIf lineType <> *Blank
            and fullLine = *Blanks;
            // Comment line, so ignore.

         ElseIf lineType = 'D'
         and %subst(directive:1:1) <> '*';                       // D-spec and no comment
            If declName = *Blanks
            and declType = *Blanks
            and (declLen = *Blanks and declAttr = *Blanks)
            and declKeyWords <> *Blanks;
               inSpan = *On;
            EndIf;
            Leave;

         ElseIf lineType = 'P'
         and %subst(directive:1:1) <> '*';                       // P-spec and no comment
            If declName = *Blanks
            and (procType <> *Blanks or procKeyWords <> *Blanks);
               inSpan = *On;
            EndIf;
            Leave;

         ElseIf lineType = 'H'
         and %subst(directive:1:1) = *Blank;                     // H-spec and no comment
            inSpan = *On;
            Leave;

         ElseIf lineType = 'C'
         and (%subst(directive:1:1) = *Blank                       // C-spec and no comment
               or condCtrl = 'SR');
            opCode = %xlate(LO:UP:opCode);
            If condInd <> *Blanks;                                 // Conditioning indicators
               // Not a spanned line.
               Leave;
            ElseIf %subst(operator:1:4) = 'EVAL';
               If opCode = *Blanks and extFactor2 <> *Blanks;     // EVAL continues.
                  inSpan = *On;
               EndIf;
               Leave;
            ElseIf %subst(operator:1:5) = 'CALLP';
               If opCode = *Blanks;                               // CALLP continues.
                  inSpan = *On;
               EndIf;
               Leave;
            ElseIf operator = 'IF'                                // IF Continues.
                or operator = 'ELSEIF';                           // ELSEIF Continues.
               If opCode = *Blanks;
                  inSpan = *On;
               EndIf;
               Leave;
            ElseIf %subst(operator:1:2) = 'IF';                   // IF Continues.
               If %subst(opCode:1:2) = 'OR'
               or %subst(opCode:1:3) = 'AND'
               or opCode = *Blanks;
                  inSpan = *On;
               EndIf;
               Leave;
            ElseIf %subst(operator:1:2) = 'DO';                   // DO Continues.
               If %subst(opCode:1:2) = 'OR'
               or %subst(opCode:1:3) = 'AND'
               or opCode = *Blanks;
                  inSpan = *On;
               EndIf;
               Leave;
            ElseIf %subst(operator:1:4) = 'WHEN';                 // WHEN Continues.
               If %subst(opCode:1:2) = 'OR'
               or %subst(opCode:1:3) = 'AND'
               or opCode = *Blanks;
                  inSpan = *On;
               EndIf;
               Leave;
            EndIf;

         ElseIf lineType = 'C'
         and %subst(directive:1:1) = '+';                        // Embedded SQL
            inSpan = *On;
            Leave;

         ElseIf lineType = 'F'
         and %subst(directive:1:1) <> '*';                       // F-spec and no comment
            If fileName = *Blanks and fileKeyWords <> *Blanks;
               inSpan = *On;
            EndIf;
            Leave;

         ElseIf %subst(directive:1:1) = '/';          // Directive, so line must end here.
            Leave;
         EndIf;

         Read INPSRC InpLine;
      EndDo;
   EndIf;

   // End of file breaks the logic!  We need to reposition to the last record before
   // continuing.
   If %eof(INPSRC);
      SetGT *HIVAL INPSRC;
      ReadP INPSRC InpLine;
   EndIf;

   // Return to the previous point.
   For i = 1 to x;
      ReadP INPSRC InpLine;
   EndFor;

   SRCDTA = savedSRCDTA;

   Return;

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// Check for an array definition and adjust the length according to the number of elements.
//==========================================================================================
Dcl-Proc adjustArrayLength;

   // -- Procedure Interface ------------------------------------------------------------------
   Dcl-PI AdjustArrayLength;
      p_Length               Packed( 7:0 );
   End-PI;

   // -- Data Structures ----------------------------------------------------------------------

   // -- Variables ----------------------------------------------------------------------------
   Dcl-S x                     Uns(5);
   Dcl-S i                     Uns(5);
   Dcl-S j                     Uns(5);
   Dcl-S elements              Uns(10);
   Dcl-S savedSRCDTA          Char(100);

   //-------------------------------------------------------------------------------------------

   savedSRCDTA = SRCDTA;
   x = 0;

   // Read ahead to find the next line with a declaration type.
   DoW not %eof();
      // Array definition on the current line?
      i = %scan('DIM(':%xlate(LO:UP:declKeywords));

      If i > 0;
         j = %scan(')':declKeywords:i+4);
         elements = %dec(%subst(declKeywords:i + 4:j - i - 4):7:0);
         // Adjust the length of the variable.
         If %rem(p_Length:elements) = 0;
            p_Length = %div(p_Length:elements);
         EndIf;
         Leave;
      EndIf;

      Read INPSRC InpLine;
      If not %eof(INPSRC);
         x += 1;     // Keep a track of how many lines we have read.

         lineType = %xlate(LO:UP:lineType);

         If lineType <> *Blank
         and lineType <> 'D';
            // Not part of this definition - stop looking for array definition.
            Leave;

         ElseIf lineType = 'D'
         and %subst(directive:1:1) <> '*';                       // D-spec and no comment
            If declName <> *Blanks;
               // A new declaration - stop looking for array definition.
               Leave;
            EndIf;
         ElseIf %scan('DCL-':%xlate(LO:UP:%trim(codeLine))) > 0;
            // A new declaration - stop looking for array definition.
            Leave;
         EndIf;
      EndIf;
   EndDo;

   // End of file breaks the logic!  We need to reposition to the last record before
   // continuing.
   If %eof(INPSRC);
      SetGT *HIVAL INPSRC;
      ReadP INPSRC InpLine;
   EndIf;

   // Return to the previous point.
   For i = 1 to x;
      ReadP INPSRC InpLine;
   EndFor;

   SRCDTA = savedSRCDTA;

   Return;

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// Store a variable name.
//==========================================================================================
Dcl-Proc storeVariable;

   // -- Procedure Interface ------------------------------------------------------------------
   Dcl-PI *N;
      variableName               Char(80) Const;
   End-PI;

   // -- Data Structures ----------------------------------------------------------------------
   // -- Variables ----------------------------------------------------------------------------
   Dcl-S x                        Uns(5);
   Dcl-S name                    Char(80);

   //-------------------------------------------------------------------------------------------

   If variableName = *Blanks;
      Return;
   EndIf;

   name = %xlate(LO:UP:variableName);

   x = %lookup(name:defVariable);
   If x > 0;
      Return;
   EndIf;

   x = %lookup(' ':defVariable);
   defVariable(x) = name;

   Return;

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// Retrieve a file column definition and store for MOVEs.
//==========================================================================================
Dcl-Proc retrieveFileColumns;

   // -- Procedure Interface ------------------------------------------------------------------
   Dcl-PI *N;
      tableName                  Char(10) Const;
   End-PI;

   // -- Data Structures ----------------------------------------------------------------------
   // -- Variables ----------------------------------------------------------------------------
   Dcl-S schemaName              Char(10);
   Dcl-S columnName              Char(10);
   Dcl-S dataType                Char(8);
   Dcl-S length                   Uns(10);
   Dcl-S lengthChar              Char(7);
   Dcl-S decimals                 Uns(3);
   Dcl-S decimalsChar            Char(3);

   Dcl-S baseSchema              Char(10);

   Dcl-S nullInd                  Int(5);

   //-------------------------------------------------------------------------------------------

/if defined(*V7R2M0)

   Exec SQL declare RTVFILECOLS cursor for
             select SCHEMA_NAME, COLUMN_NAME, DATA_TYPE, LENGTH, NUMERIC_SCALE
               from qsys2.library_list_info
               join qsys2.syscolumns on SYSTEM_TABLE_SCHEMA = SCHEMA_NAME
              where SYSTEM_TABLE_NAME = :tableName;

   Exec SQL open RTVFILECOLS;
   If SQLCOD = SQL_CSROPN;
      Exec SQL close RTVFILECOLS;
      Exec SQL open  RTVFILECOLS;
   ElseIf SQLCOD <> SQL_OK;
      savedSRCDTA = SRCDTA;
      lineType = *Blank;
      directive = *Blanks;
      codeLine = '// >>>>> File not found - conversion could be impaired.';
      writeLine();
      SRCDTA = savedSRCDTA;
   EndIf;

   Exec SQL fetch next from RTVFILECOLS into :schemaName, :columnName,
                                             :dataType,   :length, :decimals :nullInd;

   baseSchema = schemaName;    // Save first library name.

   DoW SQLCOD = SQL_OK;
      // Only process the file found in the first library.
      If schemaName <> baseSchema;
         Leave;
      EndIf;

      lengthChar = %char(length);
      decimalsChar = %char(decimals);

      // Store the definition.
      storeVariableDef(columnName:dataType:lengthChar:decimalsChar:'');

      Exec SQL fetch next from RTVFILECOLS into :schemaName, :columnName,
                                                :dataType,   :length, :decimals :nullInd;
   EndDo;

   Exec SQL close RTVFILECOLS;

/endif

   Return;

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// Retrieve a display file's field definition and store for MOVEs.
//==========================================================================================
Dcl-Proc retrieveDSPFFields;

   // -- Procedure Interface ------------------------------------------------------------------
   Dcl-PI *N;
      DSPFName                   Char(10) Const;
   End-PI;

   // -- Data Structures ----------------------------------------------------------------------
   Dcl-DS variable                        LikeDS(variableDef_T);

   Dcl-C DSPFFD  'DSPFFD FILE(&FILE) OUTPUT(*OUTFILE) OUTFILE(QTEMP/CVTFREEFFD)';

   // -- Variables ----------------------------------------------------------------------------
   Dcl-S x                        Uns(5);
   Dcl-S columnName              Char(10);
   Dcl-S dataType                Char(8);
   Dcl-S length                   Uns(10);
   Dcl-S lengthChar              Char(7);
   Dcl-S decimals                 Uns(3);
   Dcl-S decimalsChar            Char(3);

   Dcl-S command              VarChar(1024);

   //-------------------------------------------------------------------------------------------

   command = %scanrpl('&FILE':%trim(DSPFName):DSPFFD);
   Exec SQL call QCMDEXC(:command);

   Exec SQL declare RTVDSPFFLDS cursor for
             select distinct WHFLDI, WHFLDT, WHFLDB, WHFLDP
               from QTEMP.CVTFREEFFD
           order by WHFLDI;

   Exec SQL open RTVDSPFFLDS;
   If SQLCOD = SQL_CSROPN;
      Exec SQL close RTVDSPFFLDS;
      Exec SQL open  RTVDSPFFLDS;
   ElseIf SQLCOD <> SQL_OK;
      savedSRCDTA = SRCDTA;
      lineType = *Blank;
      directive = *Blanks;
      codeLine = '// >>>>> File not found - conversion could be impaired.';
      writeLine();
      SRCDTA = savedSRCDTA;
   EndIf;

   Exec SQL fetch next from RTVDSPFFLDS into :columnName, :dataType, :length, :decimals;

   DoW SQLCOD = SQL_OK;

      Select;
         When dataType = 'A';
            dataType = 'CHAR';
         When dataType = 'S';
            dataType = 'ZONED';
         When dataType = 'P';
            dataType = 'PACKED';
         Other;
      EndSl;

      lengthChar = %char(length);
      decimalsChar = %char(decimals);

      // Store the definition.
      storeVariableDef(columnName:dataType:lengthChar:decimalsChar:'');

      Exec SQL fetch next from RTVDSPFFLDS into :columnName, :dataType, :length, :decimals;
   EndDo;

   Exec SQL close RTVDSPFFLDS;

   Return;

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// Store a variable definition.
//==========================================================================================
Dcl-Proc storeVariableDef;

   // -- Procedure Interface ------------------------------------------------------------------
   Dcl-PI *N;
      name                       Char(14) Const;
      type                       Char(10) Const;
      length                     Char(7)  Const;
      decimals                   Char(3)  Const;
      sourceLine                 Char(93) Const;
      move                        Ind     Const Options(*NoPass);
   End-PI;

   // -- Data Structures ----------------------------------------------------------------------
   Dcl-DS variables                       LikeDS(variableDef_T) Dim(99999)
                                          Based(arrayPtr);
   Dcl-DS likeVar                         LikeDS(variableDef_T);

   // -- Variables ----------------------------------------------------------------------------
   Dcl-S x                        Uns(5);
   Dcl-S y                        Uns(5);
   Dcl-S arrayPtr             Pointer;
   Dcl-S result                  Char(10);
   Dcl-S varName                 Char(14);

   //-------------------------------------------------------------------------------------------

   If name = *Blanks;
      Return;
   EndIf;

   If inMainline;
      arrayPtr = %addr(globalDefs);
   Else;
      arrayPtr = %addr(localDefs);
   EndIf;

   // Already stored?
   varName = %xlate(LO:UP:name);
   x = %lookup(varName:variables(*).variableName);
   If x > 0;
      If variables(x).type = *Blanks;     // Previous definition was incomplete.
         variables(x).sourceLine = sourceLine;
         variables(x).type = %xlate(LO:UP:%trim(type));
         If length <> *Blanks;
            Monitor;
               variables(x).length = %dec(length:3:0);
            On-Error;
               variables(x).length = 0;
            EndMon;
         EndIf;
         If decimals <> *Blanks;
            Monitor;
               variables(x).scale = %dec(decimals:3:0);
            On-Error;
               variables(x).scale = 0;
            EndMon;
         EndIf;
      EndIf;

   // LIKE defined?  Attempt to pull definition from dictionary.
   ElseIf type = *Blanks;
      x = %scan('LIKE(':%xlate(LO:UP:sourceLine));
      If x > 0;
         y = %scan(')':sourceLine:x);
         If y > 0;
            likeVar.variableName = %subst(sourceLine:x+5:y-x-5);
            likeVar = retrieveVariableDef(likeVar.variableName);
            likeVar.variableName = varName;

            x = %lookup(' ':variables(*).variableName);

            If x > 0;
               variables(x) = likeVar;
            EndIf;
         EndIf;
      EndIf;

   Else;
      x = %lookup(' ':variables(*).variableName);

      If x > 0;
         variables(x).variableName = varName;
         variables(x).sourceLine = sourceLine;
         variables(x).type = %xlate(LO:UP:%trim(type));
         If length <> *Blanks;
            Monitor;
               variables(x).length = %dec(length:3:0);
            On-Error;
               variables(x).length = 0;
            EndMon;
         EndIf;
         If decimals <> *Blanks;
            Monitor;
               variables(x).scale = %dec(decimals:3:0);
            On-Error;
               variables(x).scale = 0;
            EndMon;
         EndIf;
      Else;
         dsply varName '' result;
      EndIf;
   EndIf;

   Return;

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// Retrieve a variable definition.
//==========================================================================================
Dcl-Proc retrieveVariableDef;

   // -- Procedure Interface ------------------------------------------------------------------
   Dcl-PI *N                              LikeDS(variableDef_T);
      name                       Char(14) Const;
   End-PI;

   // -- Data Structures ----------------------------------------------------------------------
   // -- Variables ----------------------------------------------------------------------------
   Dcl-S i                        Uns(5);
   Dcl-S x                        Uns(5);
   Dcl-S varName                 Char(14);
   Dcl-DS variable                        LikeDS(variableDef_T);

   //-------------------------------------------------------------------------------------------

   Clear variable;


   If name <> *Blanks;

      varName = %xlate(LO:UP:name);

      // Literal?
      If %subst(name:1:1) = '''';
/if defined(*V7R3M0)
         x = %scanr('''':name);
/else
         x = 0;
         For i = %len(name) downto 1;
            If %subst(name:i:1) = '''';
               x = i;
               Leave;
            EndIf;
         EndFor;
/endif
         If x > 0;

            variable.variableName = %scanrpl('''''':'''':name);
            variable.type = 'CHAR';
            Monitor;
               If variable.variableName <> *Blanks;
                  variable.length = %len(%trim(variable.variableName)) - 2;
               Else;
                  variable.length = x-2;
                  variable.variableName = name;
               EndIf;
            On-Error;
               variable.length = 0;
            EndMon;
         EndIf;

      ElseIf varName = '*DATE' or varName = 'UDATE';
         variable.variableName = varName;
         variable.type = 'NUMERIC';
         variable.length = 6;

      Else;
         // Array name.
         x = %scan('(':name);
         If x > 0;
            varName = %subst(varName:1:x-1);
         EndIf;

         // Try the local cache first.
         x = %lookup(varName:localDefs(*).variableName);
         If x > 0;
            variable = localDefs(x);

         Else;
            // Try the global cache.
            x = %lookup(varName:globalDefs(*).variableName);
            If x > 0;
               variable = globalDefs(x);
            EndIf;
         EndIf;
      EndIf;

   EndIf;

   Return variable;

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// Renumber the input source lines: existing numbers cannot be trusted!
//==========================================================================================
Dcl-Proc renumberSource;

   // -- Procedure Interface ------------------------------------------------------------------
   Dcl-PI *N;
   End-PI;

   // -- Data Structures ----------------------------------------------------------------------
   // -- Variables ----------------------------------------------------------------------------
   Dcl-S seqNumber              Zoned(6:2);

   //-------------------------------------------------------------------------------------------

   seqNumber = 0;

   SetLL *Start INPSRC;
   Read INPSRC inpLine;

   DoW not %eof(INPSRC);
      seqNumber += 0.01;
      inpLine.SRCSEQ = seqNumber;
      removeNonPrintable(inpLine.SRCDTA:7);
      Update INPSRC inpLine;
      Read INPSRC inpLine;
   EndDo;

      seqNumber += 0.01;
      inpLine.SRCSEQ = seqNumber;
      inpLine.SRCDTA = *Blanks;
      Write INPSRC inpLine;

   Return;

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// Set the case of the opcode or declaration.
//==========================================================================================
Dcl-Proc setOpCodeCase;

   // -- Procedure Interface ------------------------------------------------------------------
   Dcl-PI *N               VarChar(10);
      p_OpCode             VarChar(10) Const;
      p_Case                  Char(6)  Const;
   End-PI;

   // -- Data Structures ----------------------------------------------------------------------
   // -- Variables ----------------------------------------------------------------------------
   Dcl-S opCode            VarChar(10);

   //-------------------------------------------------------------------------------------------

   opCode = p_OpCode;

   Select;
      When p_Case = '*UPPER';
         opCode = %xlate(LO:UP:opCode);

      When p_Case = '*LOWER';
         opCode = %xlate(up:lo:opCode);

      Other;
         // Leave as is, as it should already be 'mixed'.
   EndSl;

   Return opCode;

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// Set the operation extender E if required.
//==========================================================================================
Dcl-Proc setExtender_E;

   // -- Procedure Interface ------------------------------------------------------------------
   Dcl-PI *N                  Char(10);
      p_Operator              Char(10) Const;
      p_LW_Ind                Char(2)  Const;
   End-PI;

   // -- Data Structures ----------------------------------------------------------------------
   // -- Variables ----------------------------------------------------------------------------
   Dcl-S opCode               Char(10);
   Dcl-S x                     Uns(10);

   //-------------------------------------------------------------------------------------------

   opCode = p_Operator;

   If p_LW_Ind <> *Blanks;      // Error indicator set.
      x = %scan('(':opCode);
      If x > 0;
        opCode = %subst(opCode:1:x) + 'E' + %subst(opCode:x+1);
      Else;
         opCode = %trim(opCode) + '(E)';
      EndIf;
   EndIf;

   Return opCode;

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// Create an entry on the conversion log table.
//==========================================================================================
Dcl-Proc writeConversionLog;

   // -- Procedure Interface ------------------------------------------------------------------
   // -- Data Structures ----------------------------------------------------------------------
   // -- Variables ----------------------------------------------------------------------------
   Dcl-S exists                Ind     Static;
   Dcl-S count                 Uns(10);
   Dcl-S conversionRate     Packed(5:2);
   Dcl-S wkVersion            Char(6);

   //-------------------------------------------------------------------------------------------

   // Ignore if logging not requested.
   If p_LogConversion <> 'Y';
      Return;
   EndIf;

   // Create the log table?
   If not exists;
      Exec SQL select count(*)
                 into :count
                 from QGPL.CVTRPGLOG;

      If count = 0;
         createConversionLog();
      EndIf;

      exists = *On;
   EndIf;

   wkVersion = VERSION;
   If countEligible > 0;
      conversionRate = countConv * 100 / countEligible;
   Else;
      conversionRate = 0;
   EndIf;

   Exec SQL insert into QGPL.CVTRPGLOG
                 values (
                         :p_SrcFromLib,
                         :p_SrcFromFile,
                         :p_FromMbr,
                         :p_SrcToLib,
                         :p_SrcToFile,
                         :p_ToMbr,
                         :countSource,
                         :countTarget,
                         :countEligible,
                         :countConv,
                         :countNotConv,
                         :countMoved,
                         :conversionRate,
                         :wkVersion,
                         current_timestamp,
                         :QCurUser
                        ) with NC;


   Return;

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================

/Eject
//==========================================================================================
// Create the conversion log table.
//==========================================================================================
Dcl-Proc createConversionLog;

   // -- Procedure Interface ------------------------------------------------------------------
   // -- Data Structures ----------------------------------------------------------------------
   // -- Variables ----------------------------------------------------------------------------
   //-------------------------------------------------------------------------------------------

   Exec SQL create or replace table QGPL.CVTRPGLOG (
            CVFRMLIB CHAR(10) NOT NULL,
            CVFRMFIL CHAR(10) NOT NULL,
            CVFRMMBR CHAR(10) NOT NULL,
            CVTOLIB  CHAR(10) NOT NULL,
            CVTOFIL  CHAR(10) NOT NULL,
            CVTOMBR  CHAR(10) NOT NULL,
            CVCNTSRC DECIMAL(6) NOT NULL,
            CVCNTTRG DECIMAL(6) NOT NULL,
            CVCNTELG DECIMAL(6) NOT NULL,
            CVCNTCNV DECIMAL(6) NOT NULL,
            CVCNTNOT DECIMAL(6) NOT NULL,
            CVCNTMOV DECIMAL(6) NOT NULL,
            CVCNVRAT DECIMAL(5, 2) NOT NULL,
            CVCNVVER CHAR(6) NOT NULL,
            CVCNVTIM TIMESTAMP NOT NULL,
            CVCNVUSR CHAR(10) NOT NULL
            ) RCDFMT CVTLOGR;

   Exec SQL LABEL ON TABLE QGPL.CVTRPGLOG
            IS 'CVTRPGFREE Conversion Log';

// Column text and labels.
   Exec SQL LABEL ON COLUMN QGPL.CVTRPGLOG (
            CVFRMLIB IS 'From                Library' ,
            CVFRMFIL IS 'From                File' ,
            CVFRMMBR IS 'From                Member' ,
            CVTOLIB  IS 'To                  Library' ,
            CVTOFIL  IS 'To                  File' ,
            CVTOMBR  IS 'To                  Member' ,
            CVCNTSRC IS 'Source              Lines' ,
            CVCNTTRG IS 'Target              Lines' ,
            CVCNTELG IS 'Eligible            To Convert' ,
            CVCNTCNV IS '                    Converted' ,
            CVCNTNOT IS 'Not                 Converted' ,
            CVCNTMOV IS 'Moved               Definitions' ,
            CVCNVRAT IS 'Conversion          Rate' ,
            CVCNVVER IS 'CVTRPGFREE          Version' ,
            CVCNVTIM IS 'Conversion          Timestamp' ,
            CVCNVUSR IS 'Conversion          User'
            );


   Exec SQL LABEL ON COLUMN QGPL.CVTRPGLOG (
            CVFRMLIB TEXT IS 'From library' ,
            CVFRMFIL TEXT IS 'From file' ,
            CVFRMMBR TEXT IS 'From member' ,
            CVTOLIB  TEXT IS 'To library' ,
            CVTOFIL  TEXT IS 'To file' ,
            CVTOMBR  TEXT IS 'To member' ,
            CVCNTSRC TEXT IS 'Input lines' ,
            CVCNTTRG TEXT IS 'Output lines' ,
            CVCNTELG TEXT IS 'Eligible for conversion' ,
            CVCNTCNV TEXT IS 'Lines converted' ,
            CVCNTNOT TEXT IS 'Lines not converted' ,
            CVCNTMOV TEXT IS 'Definitions moved' ,
            CVCNVRAT TEXT IS 'Conversion rate' ,
            CVCNVVER TEXT IS 'CVTRPGFREE version' ,
            CVCNVTIM TEXT IS 'Conversion time' ,
            CVCNVUSR TEXT IS 'Conversion user'
            );


   Return;

//------------------------------------------------------------------------------------------
End-Proc;
//==========================================================================================
**CTDATA opCodeUP
ACQ       Acq
BEGSR     BegSr
CALLP     CallP
CHAIN     Chain
CLEAR     Clear
CLOSE     Close
COMMIT    Commit
DEALLOC   DeAlloc
DELETE    Delete
DOU       DoU
DOW       DoW
DSPLY     Dsply
DUMP      Dump
ELSE      Else
ELSEIF    ElseIf
ENDDO     EndDo
ENDFOR    EndFor
ENDIF     EndIf
ENDMON    EndMon
ENDSL     EndSl
ENDSR     EndSr
EVAL      Eval
EVALR     EvalR
EVAL-CORR Eval-Corr
EXCEPT    Except
EXFMT     Exfmt
EXSR      Exsr
EXEC SQL  Exec SQL
FEOD      FEOD
FOR       For
FORCE     Force
IF        If
IN        In
ITER      Iter
LEAVE     Leave
LEAVESR   LeaveSr
MONITOR   Monitor
NEXT      Next
ON-ERROR  On-Error
OPEN      Open
OTHER     Other
OUT       Out
POST      Post
READ      Read
READC     ReadC
READE     ReadE
READP     ReadP
READPE    ReadPE
REL       Rel
RESET     Reset
RETURN    Return
ROLBK     RolBk
SELECT    Select
SETGT     SetGT
SETLL     SetLL
SORTA     SortA
TEST      Test
UNLOCK    Unlock
UPDATE    Update
WHEN      When
WRITE     Write
XML-INTO  XML-Into
XML-SAX   XML-SAX
ENDCS     ----------
AND       and
OR        or
**CTDATA declUP
DCL-F     Dcl-F
DCL-S     Dcl-S
DCL-C     Dcl-C
DCL-PR    Dcl-PR
DCL-PI    Dcl-PI
DCL-PROC  Dcl-Proc
DCL-DS    Dcl-DS
END-DS    End-DS
END-PR    End-PR
END-PI    End-PI
END-PROC  End-Proc
CTL-OPT   Ctl-Opt
**CTDATA comments
//===========================================================================================
// Start of moved field definitions.
// End of moved field definitions.
