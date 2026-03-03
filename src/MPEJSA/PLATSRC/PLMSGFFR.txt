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
      *  Program Description                                          *
      * This program accepts a unit identifier, date an time as     *
      * input, and then creates corrsponding freeform message.       *
      *                                                               *
      *  Program Modification Index                                   *
      *                                                               *
      *    Date    Mod    Who    Description                          *
      *  --------  -----  -----  -------------------------------------*
      *  07/17/20   R001  JB/PS  Retrieve driver message headers      *
      *                                                               *
      *****************************************************************
     H DFTACTGRP(*NO) ACTGRP(*CALLER) OPTION(*SRCSTMT)
     H BNDDIR('YAJL') DECEDIT('0.')

     Funitsdr1  if   e           k disk
     Funitsdr2  if   e           k disk    rename(runitmas:l2)
AR001Fpldrvhdrp if   e           k disk
      /include yajl_h
      * This program's Procedure Prototype
     Dplmsgffr         PR
     D                               10a
     D                             5000
     D                               50

      * This program's Procedure Interface
     Dplmsgffr         PI
     DdriverID                       10a
     DFFmessage                    5000
     DDeepLink                       50

     D plmsgffr1       PR                  ExtPgm('PLMSGFFR1')
     D jsonString                  5000

     D timeUTC         DS
     D ccyy                           4A
     D dash1                          1A
     D mm                             2A
     D dash2                          1A
     D dd                             2A
     D dash3                          1A
     D hh                             2a
     D period1                        1A
     D min                            2a
     D period2                        1A
     D sec                            2a


     D driver1         DS
     D iccdrv                  1      6A
     D UTCFormat       s             25a
     D UTCend          s              6a   inz('-07:00')
     D colon           s              1a   inz(':')
     D T               s              1a   inz('T')
     D TS              s               z
     D timestamp       s             26  0
     D timestampChar   s             26a
     D jsonString      s           5000a   inz(' ')
     D driverID1       s             10a   inz(' ')
     D driverID2       s             10a   inz(' ')
     D errMsg          s            500a   varying
     D len             s             10I 0
      /free

         driver1 = %trim(DriverId);
         chain(n) driver1 unitsdr1;
         if %found(unitsdr1) = *on;
         if undr2 <> *blanks;
         driverId1 = undr2;
         endif;
         else;

         chain(n) driver1 unitsdr2;
         if %found(unitsdr2) = *on;
         if undr2 <> *blanks;
         driverId1 = undr2;
         endif;
         endif;

         endif;

AR001    if driverID1 <> *blanks;
  |        driverId2 = driverId1;
  |        clear driverId1;
  |        exsr formatJson;
  |        plmsgffr1(jsonString);
  |        driverId = driverId2;
  |        exsr formatJson;
  |        plmsgffr1(jsonString);
AR001    else;
           exsr formatJson;
           plmsgffr1(jsonString);
AR001    endif;

       *inlr = *on;

        //-----------------------------------------------
        //      formatJson
        //-----------------------------------------------
AR001   begsr formatJson;

         yajl_genOpen(*OFF);  // use *ON for easier to read JSON
                              //    *OFF for more compact JSON

         yajl_beginObj();
AR001      yajl_addChar('conversation');
           yajl_beginObj();
AR001    //retrieve external_Id and subject for driver header.
  |      chain driverId pldrvhdrp;
  |      if %found(pldrvhdrp);
  |        yajl_addChar('subject':%trim(plhdrsbj));
  |        yajl_addBool('read_only':'0');
  |        yajl_addBool('is_group_chat':'0');
  |        yajl_addChar('external_id':%trim(plhdrxid));
AR001    endif;
         yajl_endObj();
         yajl_addChar('message':%trim(FFmessage));
         if DeepLink <> *blanks;
DR001    //yajl_addChar('deeplink_id':%trim(DeepLink));
DR001    //yajl_addChar('deeplink_type':'macro');
         endif;

          yajl_beginArray('recipients');
          yajl_addChar(%trim(driverId));

          if driverId1 <> *blank;
          yajl_addChar(%trim(driverId1));
          endif;

DR001     //if driverId2 <> *blank;
DR001     //yajl_addChar(%trim(driverId2));
DR001     //endif;

          yajl_endArray();
         yajl_beginObj();
         TS = %timestamp();
         timestampChar = %char(%timestamp(TS):*ISO);
         timeUTC = timestampChar;
         period1 = colon;
         period2 = colon;
         dash3   = T;
         UTCformat = timeUTC + UTCend;
         yajl_addChar('timestamp': UTCFormat);
          yajl_endObj();
          jsonString = yajl_copyBufStr();
          yajl_genClose();
AR010   endsr;

