     H Option(*SrcStmt:*NoDebugIO)
     H Debug(*Yes)
      *
     DdsDateStruc      DS                  Qualified
     D Date                           8S 0
     D Time                           6S 0
     D MilliSec                       6S 0
      *
     DInputStruc       DS                  LikeDS(dsDateStruc) Inz
     DOutputStruc      DS                  LikeDS(dsDateStruc) Inz
      *
     DdsErrCode        DS                  Qualified
     D BytesProvided                 10I 0 Inz(%Size(dsErrCode.MsgData))
     D BytesAvail                    10I 0
     D ExceptionID                    7
     D Reserved                       1
     D MsgData                      128
      *
     DCvtDateTimeFmt   PR                  ExtPgm('QWCCVTDT')
     D InputFormat                   10    Const
     D InputTS                             Const LikeDS(dsDateStruc)
     D OutputFormat                  10    Const
     D OutputTS                            LikeDS(dsDateStruc)
     D dsErrCode                           LikeDS(dsErrCode)
     D InputTZ                       10    Const
     D OutputTZ                      10    Const
     D TimeZoneInfo                        LikeDs(dsTimeZone)
     D TimeZoneInfoL                 10I 0 Const
     D PrecisionInd                   1    Const
      *
     DdsTimeZone       DS                  Qualified
     D BytesReturned                 10I 0
     D BytesAvailable                10I 0
     D TimeZoneName                  10
     D Reserved1                      1
     D DaylightSaving                 1
     D CurOffset                     10I 0
     D CurFullName                   50
     D CurAbbrName                   10
     D MsgFile                        7
     D MsgFileLib                    10
      *
     D TS_Char         S             26    Inz
     D InputTS         S               Z   Inz
     D MiSec6          S              6S 0 Inz(000001)
     D parmInputTZ     S             10    Inz
     D parmOutputTZ    S             10    Inz
      *
     D Date8           S              8A
     D Time6           S              6A
     D IccTZ           S              2
     D State           S              2
     D Offset          S             10
     D ZoneAbb         S             30
     D InDteFmt        S             10
     D TmpDte          S             10
      *
     D GenericTS       DS            30
     D  Year                   1      4
     D  Cst01                  5      5
     D  Month                  6      7
     D  Cst02                  8      8
     D  Day                    9     10
     D  Cst03                 11     11
     D  HH                    12     13
     D  Cst04                 14     14
     D  MM                    15     16
     D  Cst05                 17     17
     D  SS                    18     19
      *------------------------ Main -------------------------------------*
     C
     C     *Entry        Plist
     C                   Parm                    Date8
     C                   Parm                    InDteFmt
     C                   Parm                    Time6
     C                   Parm                    IccTZ
     C                   Parm                    State
     C                   Parm                    Offset
     C                   Parm                    ZoneAbb
     C
      *
      /Free
           Clear dsDateStruc;
           Clear InputStruc;
           Clear OutputStruc;
           Clear dsErrCode;
           Clear dsTimeZone;
           Clear dsTimeZone;
           Clear GenericTS;
           Clear TmpDte;

           parmInputTZ = '*SYS';

           Select;
             When IccTZ = '08';
               parmOutputTZ = 'QN0330NST2';
               ZoneAbb = 'US/St_Johns';
             When IccTZ = '07';
               parmOutputTZ = 'QN0500EST3';
               ZoneAbb = 'US/New_York';
             When IccTZ = '06';
               parmOutputTZ = 'QN0600CST2';
               ZoneAbb = 'US/Chicago';
             When IccTZ = '05';
               If State = 'AZ';
                 parmOutputTZ = 'QN0700MST4';
                 ZoneAbb = 'US/Phoenix';
               Else;
                 parmOutputTZ = 'QN0700MST3';
                 ZoneAbb = 'US/Denver';
               EndIf;
             When IccTZ = '04';
               parmOutputTZ = 'QN0800PST2';
               ZoneAbb = 'US/Los_Angeles';
             When IccTZ = '03';
               parmOutputTZ = 'QN0900AST2';
               ZoneAbb = 'US/Anchorage';
             When IccTZ = '02';
               parmOutputTZ = 'QN0900AST2';
               ZoneAbb = 'US/Anchorage';
           EndSl;

           Select;
             When InDteFmt = '*LONGJUL';
               TmpDte = %Char(%Date(%Dec(Date8:8:0):*LongJul):*ISO);
             When InDteFmt = '*JUL';
               TmpDte = %Char(%Date(%Dec(Date8:8:0):*Jul):*ISO);
             When InDteFmt = '*ISO';
               TmpDte = %Char(%Date(%Dec(Date8:8:0):*ISO):*ISO);
           EndSl;

           TS_Char =  %Trim(TmpDte)+'-'+
                      %Char(%Time(%Dec(Time6:6:0):*ISO):*ISO)+'.'+
                      %EditC(MiSec6:'X');

           InputTS = %TimeStamp(TS_Char);

           InputStruc.Date=%Int(%Char(%Date(InputTS):*ISO0));
           InputStruc.Time=%Int(%Char(%Time(InputTS):*ISO0));
           InputStruc.MilliSec=%SubDt(InputTS:*MS);

           CvtDateTimeFmt('*YYMD':
                           InputStruc:
                           '*YYMD':
                           OutputStruc:
                           dsErrCode:
                           parmInputTZ:
                           parmOutputTZ:
                           dsTimeZone:
                           %Size(dsTimeZone):
                           (InputStruc.MilliSec>0));

            Offset = %Char(%Dec(dsTimeZone.CurOffset/60:3:0));

            *inlr = *on;
            Return ;
      /End-free
