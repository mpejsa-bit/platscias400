     H OPTION (*NODEBUGIO:*Srcstmt) DFTACTGRP(*NO)
     H BNDDIR('YAJL') DECEDIT('0.') FixNbr(*Zoned)
     H alwnull(*USRCTL)
      *---------------------------------------------------------------*
      *                                                               *
      *    @ Copyright Platform Science                             *
      *                9255 towne center                            *
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
      *  Program Description                                          *
      * this program reads a DB of inbound messages from a driver   *
      * via the AMQP process.                                       *
      * Once processed the records are marked as such.              *
      *                                                               *
      *  Program Modification Index                                   *
      *                                                               *
      *    Date    Mod    Who    Description                          *
      *  --------  -----  -----  ------------------------------------ *
      *  01/03/22         VR/PS  ------Initial Version-----           *
      *****************************************************************
      * PS files
     FPSOBFFMSL4uF   e           k disk
      *

        dcl-s dlytime uns(10);
        dcl-ds inputDs LikeRec(PSOBFFMSGR: *Input);

        dcl-pr SendData2DQ ExtPgm('QSNDDTAQ');
          *n char(10) Const;           //DQ Name
          *n char(10) Const;           //DQ Lib Name
          *n packed(5:0) Const;        //Data Length
          *n likeDS(inputDS) Const;    //Data
        end-pr;

        dcl-pr sleep int(10) extproc('sleep') ;
         *n uns(10) value;
        end-pr;

        //------------------------------------------------
        // Main
        //------------------------------------------------

        dou *inlr = *on;
          exsr srProcess;
          Sleep(1);
        enddo;

        *inlr = *on;

        //------------------------------------------------
        // Main Process subrountine
        //------------------------------------------------
        Begsr srProcess;

          Clear inputDS;

          setll *loval PSOBFFMSL4;
          read PSOBFFMSL4 inputDS;
          dow not %eof(PSOBFFMSL4);

            SendData2DQ('PSOBLODQ1': 'PLATSCI': %size(inputDS): inputDS);

            PSSNDT = %Timestamp();
            PSSNDQ = 'Y';
            Update PSOBFFMSGR;

            Read PSOBFFMSL4;

          enddo;

        Endsr;
