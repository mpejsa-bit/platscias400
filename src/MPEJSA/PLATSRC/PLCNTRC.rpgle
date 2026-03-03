     H OPTION(*SRCSTMT : *NODEBUGIO)
      *---------------------------------------------------------------*
      *                                                               *
      *    @ Copyright Platform Science                             *
      *                9255 towne center                            *
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
      *
      *  Program Modification Index
      *
      *    Date    Mod    Who    Description
      *  --------  -----  -----  ------------------------------------
      *  11/22/19  001    JB/PS  Remove author check (@@@) on empties.
      *****************************************************************
      //
     FCONTACT   IF   E             DISK
     F                                     RECNO(CON)
     Fplactordp uF   E           k DISK
     Fpldltordp o    E           k DISK
     Fpltintp   iF   E           k DISK    usropn

       //procedure prototypes
     D cancelJob       PR                  ExtPgm('PLTWFCANR')
     D  unit                          6a

      // Prototype to call DLYJOB
     dDLYJOB           pr                  extpgm('QCMDEXC')                    execute command
     d                             3000a   const options(*varsize)
     d                               15p 5 const

      // Constants/Variables to Delay the Job
     d dlycmd          s             50a   inz(*blanks)                         delay job cmd
     d dlycmd11        c                   const('DLYJOB (')                    delay job cmd
     d dlycmd12        c                   const(')')                           delay job cmd
      //----------------------------------------------------------
      //
      //----------------------------------------------------------
     D                 DS
     D  CNREST                 1     77
     D  XDCMNT                23     67
     D  voided                23     28
     D  vord#                 38     44
     D  vdisp#                46     47
     D  vord#1                36     42
     D  vdisp#1               44     45
      //
      //
     D PLCTTRC         DS
     D  REC#                   1     12  0
      //
     D  CON            s             12  0
     D  HLDRC          s             12  0
     d jobID           S             32A   Inz(*blanks)
      //
      //****************************************************************
      // MAIN PROCESSING
      //****************************************************************
      //
     C     *DTAARA       DEFINE                  PLCTTRC
      //
            CON =    CON ;
            IN PLCTTRC;
            HLDRC = rec#;

          SETGT HLDRC RCONTACT;
           *IN90 = NOT %FOUND;
           IF *IN90 = *ON;
          READP RCONTACT;
          *IN90 = %EOF;
            HLDRC = CON;
          ENDIF;
       //
          DOU *INLR = *ON
          AND *INLR = *OFF;

            READ RCONTACT;
             *IN90 = %EOF;
             IF *IN90 = *ON;
            SETGT HLDRC RCONTACT;
            IN *LOCK PLCTTRC;
            rec# = HLDRC;
            OUT PLCTTRC;
            exsr delayjob;

            ELSE;

            HLDRC = CON;

            IF CNCODE = 'L';
             //* insert program call here
            ENDIF;

            IF CNCODE = 'T';
             //*
             exsr cancelWFJob;
            ENDIF;

            IF CNCODE = 'V';
             //*
           if voided = 'VOIDED';
           cnord# = vord#;
           cndisp = vdisp#;
           else;
           cnord# = vord#1;
           cndisp = vdisp#1;
           endif;
           exsr cancelWFJob;
            ENDIF;

            IF CNCODE = 'E';
D001       //if CNINIT <> '@@@';
             //* insert program call here
           exsr cancelWFJob;
D001       //endif;
            ENDIF;


            IN *LOCK PLCTTRC;
            REC# = HLDRC;
            OUT PLCTTRC;
            ENDIF;
         //
          ENDDO;
       //
          *inlr = *on;
       RETURN;
       //
       //-------------------------------------------------------------
       //- call program to cancel WF job       -----------------------
       //-------------------------------------------------------------
         begsr cancelWFJob;
         chain (cnord#:cndisp) plactordp;
         if %found(plactordp) = *on;
         delete plactordr;
         write  pldltordr;
         jobid = cnord# +'-'+ cndisp +'/?id_type=external';
         canceljob(jobid);
         endif;
         endsr;
        //------------------------------------------------
        //------------------------------------------------
      /END-FREE
        begsr delayjob;
          monitor;
          open pltintp;
          read pltintp;
          on-error;
          read pltintp;
          close pltintp;
          endmon;

          // "DLYJOB(" + variable from file + ")"
          dlycmd = %trim(dlycmd11) + %trim(pltdftdly1) + dlycmd12;

          // Issue the DLYJOB command
          Callp DLYJOB(dlycmd:%size(dlycmd));
        endsr;

      /end-free
