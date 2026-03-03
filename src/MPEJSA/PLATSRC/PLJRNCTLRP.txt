     H OPTION (*NODEBUGIO)
     FPLJRNCTLP if   e           k disk
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
      /free

         chain(n) Process PLJRNCTLP;
         Journal     =   PLJJRNL    ;
         JournalLib  =   PLJLIBL    ;
         File        =   PLJFILE    ;
         FileLib     =   PLJFLIBL   ;
         ExitPgm     =   PLJEXITPGM ;
         ExitLib     =   PLJEXITLIB ;
         Delay       =   PLJJRNDLY  ;

        //
        return;
      /end-free
