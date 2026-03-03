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
      * update the statu of sent(outbound) messages to a driver     *
      *
      *  Program Modification Index
      *
      *    Date    Mod    Who    Description
      *  --------  -----  -----  ------------------------------------
      *
      *****************************************************************
     Fplmcmsghl1uF   e           k disk
     Fplmcmsghl2uF   e           k disk    rename(rmcmsgh:l2)
     Fpltintp   iF   e           k disk

      * Prototype to call DLYJOB
     dDLYJOB           pr                  extpgm('QCMDEXC')                    execute command
     d                             3000a   const options(*varsize)
     d                               15p 5 const

      * Constants/Variables to Delay the Job
     d dlycmd          s             50a   inz(*blanks)                         delay job cmd
     d dlycmd11        c                   const('DLYJOB (')                    delay job cmd
     d dlycmd12        c                   const(')')                           delay job cmd
      *
     d longjul         s              7  0


      /free
        dou *inlr = *on;
        exsr main;
        exsr delayjob;
        enddo;
        *inlr = *on;

        //------------------------------------------------
        //------------------------------------------------
        //------------------------------------------------
        begsr delayjob;

          monitor;
          open pltintp;
          read pltintp;
          on-error;
          read pltintp;
          close pltintp;
          endmon;

          // "DLYJOB(" + variable from file + ")"
          dlycmd = %trim(dlycmd11) + %trim(pltdftdly5) + dlycmd12;
          // Issue the DLYJOB command
          Callp DLYJOB(dlycmd:%size(dlycmd));
        endsr;

        //------------------------------------------------
        //------------------------------------------------
        //------------------------------------------------
        begsr main;
        longjul = %Dec(%date():*longjul);
        setll (longjul:'O') plmcmsghl1;
        reade (longjul:'O') plmcmsghl1;
        dow  %eof(plmcmsghl1) = *off;

        mhstat = '000';
        update rmcmsgh;
        reade (longjul:'O') plmcmsghl1;
        enddo;

        setll (longjul:'O') plmcmsghl2;
        reade (longjul:'O') plmcmsghl2;
        dow  %eof(plmcmsghl2) = *off;

        mhstat = '000';
        update l2;
        reade (longjul:'O') plmcmsghl2;
        enddo;
        endsr;
        //------------------------------------------------
        //------------------------------------------------
