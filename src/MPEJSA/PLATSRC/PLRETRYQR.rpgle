     H OPTION (*NODEBUGIO)
      *---------------------------------------------------------------*
      *                                                               *
      *    @ Copyright Platform Science                             *
      *                9255 towne center                           *
      *                San Diego , CA 92121                         *
      *                                                               *
      * This software is licensed material of Platform Science and  *
      * may only be used consistent with the license granted.  No   *
      * part of this material may be reproduced, tranferred, or     *
      * copied for any purpose without the express written permis-  *
      * sion of Platform Science.      Copyright 2019.              *
      *                                                               *
      *                                                               *
      *---------------------------------------------------------------*
      *  Program Description
      *
      *  Program Modification Index
      *
      *    Date    Mod    Who    Description
      *  --------  -----  -----  ------------------------------------
      *
      *****************************************************************
     Funits     if   e           k disk
     FplRetryql1uf   e           k disk    rename(rplRetryQ:rRetryQl1)
     FplRetryql7if   e           k disk

       //procedure prototypes
     d createJob       pr                  extPgm('PLTWFJOBR')
     d  passunit                           like(plcrwju)
     d  passdate                           like(plcrwjd)
     d  passtime                           like(plcrwjt)

     d cancelJob       pr                  extPgm('PLTWFCANR')
     d  passjob                            like(plcnwji)

     d completeJob     pr                  extPgm('PLTWFCMPR')
     d  passjob#                           like(plcmwji)
     d  passrsn                            like(plcmwjr)

     d createPln       pr                  extPgm('PLTPPJOBR')
     d  passunt2                           like(plcrwpu)
     d  passdat2                           like(plcrwpd)
     d  passtim2                           like(plcrwpt)

     d cancelPln       pr                  extPgm('PLTPPCANR')
     d  passordr                           like(plcnwpo)
     d  passdrvr                           like(plcnwpd) options(*nopass)

     d sendFFMsg       pr                  extPgm('PLMSGFFR2')
     d  passunt3                           like(plcrffu)
     d  passdat3                           like(plcrffd)
     d  passtim3                           like(plcrfft)

     d  passunit       s              6a
     d  passdate       s              7s 0
     d  passtime       s              6s 0
     d  tsChar         s             26a
     d  ts             s               z

      /free
        ts = %timestamp();
        tsChar = %char(%timestamp(ts):*ISO);

        setll *loval plRetryQl7;
        dou %eof(plRetryQl7);
          read plRetryQl7;
          if not %eof(plRetryQl7);
            if plqsend > tsChar;
              iter;
            endif;
            select;
            when plqType = 'WFJOB';
              exsr createWFJob;
            when plqType = 'WFCAN';
              cancelJob(plcnwji);
            when plqType = 'WFCMP';
              completeJob(plcmwji:plcmwjr);
            when plqType = 'PPJOB';
              createPln(plcrwpu:plcrwpd:plcrwpt);
            when plqType = 'PPCAN' And plcnwpd > *blanks;
              cancelPln(plcnwpo:plcnwpd);
            when plqType = 'PPCAN';
              cancelPln(plcnwpo);
            when plqType = 'FFMSG';
              sendFFMsg(plcrffu:plcrffd:plcrfft);
            endsl;
          endif;
        enddo;

        *inlr = *on;
        return;

       //-------------------------------------------------------------*
       //- call program to create WF job                              *
       //-------------------------------------------------------------*
         begsr createWFJob;

           chain plcrwju units;
           if %found(units) And unStat = 'D';
             createJob(plcrwju:plcrwjd:plcrwjt);
           //remove from workflow retry queue on success request.
           else;
             chain (plcrwju:plcrwjd:plcrwjt) plRetryQl1;
             if %found(plRetryQl1);
               delete rRetryQl1;
             endif;
           endif;
         endsr;

      /end-free
