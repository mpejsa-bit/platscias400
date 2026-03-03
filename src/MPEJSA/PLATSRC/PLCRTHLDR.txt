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
      * Process all MVT drivers and create safety hold on any       *
      * company driver not authorized in PS driver table.           *
      *                                                               *
      *  Program Modification Index                                   *
      *                                                               *
      *    Date    Mod    Who    Description                          *
      *  --------  -----  -----  ------------------------------------ *
      *****************************************************************
     Fdrivers   uf   e           k disk
     Fmessages  o    e           k disk
     Fplactdrvp if   e           k disk
     Fpldrvmsgp if   e           k disk

     D drvcode         s              6a
     D ts              s             26z
     D tsChar          ds            26
     D   month                        2a   overlay(tsChar:6)
     D   day                          2a   overlay(tsChar:9)
     D   hour                         2a   overlay(tsChar:12)
     D   minute                       2a   overlay(tsChar:15)

     C     *entry        plist
     C                   parm                    drvcode

         // process if driver message exists
         if not *inlr;
           // process an input driver, not in penalty status
           chain drvcode drivers;
           if %found(drivers) and drstat <> 'P';
             setll drcode plactdrvp;
             if not %equal(plactdrvp);
               clear rmessage;
               metype = 'D';
               mecode = drcode;
               memsg  = month+'-'+day+' '+hour+':'+minute+' '+
                        plmsgdtl;
               meinit = '@@@';
               mesna  = 'N';
               mextn  = 0;
               mescr  = 'Y';
               me_wtims = tsChar;
               me_wuser = 'PLATSCI02';
               write rmessage;
             endif;
             drstat = 'P';
             update rdrivers;
           endif;
           *inlr = *on;
         endif;

       //----------------------------------------------------------------------
       //----------------------------------------------------------------------
A002    begsr *inzsr;
A002      monitor;
A002      read pldrvmsgp;
A002      on-error;
A002        // exit hold program
            *inlr = *on;
A002      endmon;
          ts = %timestamp();
          tsChar = %char(ts);
A002    endsr;

