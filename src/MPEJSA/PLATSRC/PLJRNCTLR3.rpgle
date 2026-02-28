     H OPTION (*NODEBUGIO)
     FPLJRNCTL3 if   e           k disk
      *----------------------------------------------------------
      * Entry point
      *----------------------------------------------------------
     C     *entry        plist
     C                   parm                    Process          10
     C                   parm                    Journal          10
     C                   parm                    JournalLib       10
     C                   parm                    File             10
     C                   parm                    FileLib          10
     C                   parm                    ExitPgm          10
     C                   parm                    ExitLib          10
     C                   parm                    Delay             4 0
     C                   parm                    LastDate          8 0
     C                   parm                    LastTime          6 0
     C                   parm                    LastSeqn         15 0
      /free

         chain(n) Process PLJRNCTL3;
         Journal     =   PLJJRNL    ;
         JournalLib  =   PLJLIBL    ;
         File        =   PLJFILE    ;
         FileLib     =   PLJFLIBL   ;
         ExitPgm     =   PLJEXITPGM ;
         ExitLib     =   PLJEXITLIB ;
         Delay       =   PLJJRNDLY  ;
         LastDate    =   PLJLSTDT   ;
         LastTime    =   PLJLSTTM   ;
         LastSeqn    =   PLJLSEQ    ;

        //
        return;
      /end-free
