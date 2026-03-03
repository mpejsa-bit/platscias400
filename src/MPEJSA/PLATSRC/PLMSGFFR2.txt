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
      *  04/24/20   R001  JB/PS  Construct to create message based    *
      *                          MC interface message parameters.     *
      *                                                               *
      *****************************************************************
     H DftActGrp(*No) ActGrp(*New) BndDir('LIBHTTP/HTTPAPI')
     H FixNbr(*Zoned) Option(*NoDebugIo:*Srcstmt) Debug(*Yes)
     H BNDDIR('YAJL') DECEDIT('0.')
     H alwnull(*USRCTL)

AR001Fmcmsgd    if   e           k disk
     Funits     if   e           k disk
     Funitsdr1  if   e           k disk    rename(runitmas:unitsdl1)
     Funitsdr2  if   e           k disk    rename(runitmas:unitsdl2)
AR001FplRetryQl5uf a e           k disk
     Fpltintp   iF   E           k DISK    usropn
     Fplscope   iF   E           k DISK
      /copy libhttp/qrpglesrc,httpapi_h

      /include yajl_h
      * This program's Procedure Prototype
     Dplmsgffr2        PR
CR001D                                6a
CR001D                                7s 0
CR001D                                6s 0

      * This program's Procedure Interface
     Dplmsgffr2        PI
CR001Dmhunit                          6a
CR001Dmhdate                          7s 0
CR001Dmhtime                          6s 0

     D incoming        PR            10I 0
     D                               10I 0 value
     D                             8192A   options(*varsize)
     D                               10I 0 value
       //?procedure prototypes
     D translate       PR                  ExtPgm('QDCXLATE')
     D   length                       5P 0 const
     D   myJson                   32766A   options(*varsize)
     D   table                       10A   const

     D pltauthr        PR                  ExtPgm('PLTAUTHR')
     D   scope                       30
     D   token                     1224

     D cpylnk          PR                  ExtPgm('PLCPYLNK')
     D  filename                     10a

AR001 // Prototype to call DLYJOB
  |  dDLYJOB           pr                  extpgm('QCMDEXC')                    execute command
  |  d                             3000a   const options(*varsize)
  |  d                               15p 5 const
  |
  |   // Constants/Variables to Delay the Job
  |  d dlycmd          s             50a   inz(*blanks)                         delay job cmd
  |  d dlycmd11        c                   const('DLYJOB (')                    delay job cmd
AR001d dlycmd12        c                   const(')')                           delay job cmd

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

AR001d driver          s             10a
  |  d deepLink        s             50a
  |  d message         s           5000a
  |  d message1        s             40a
  |  d message2        s             40a
  |  d message3        s             40a
  |  d message4        s             40a
  |  d message5        s             40a
  |  d messageA        s             40a   dim(50)
  |  d m               s              1  0
AR001d x               s              3  0
     d UTCFormat       s             25a
     d UTCend          s              6a   inz('-07:00')
     d colon           s              1a   inz(':')
     d T               s              1a   inz('T')
     d TS              s               z
     d timestamp       s             26  0
     d timestampChar   s             26a
     d jsonString      s           5000a   inz(' ')
     d driverID1       s             10a   inz(' ')
     d driverID2       s             10a   inz(' ')
     d errMsg          s            500a   varying
     d len             s             10i 0
AR001d driverID        s             10a   inz(*blanks)
AR001d ffMessage       s           5000a   inz(*blanks)
     d myJSON          s          65535a   varying
     d RC              s             10i 0
     d Server          s            256a
     d filename        s             10a
     d UsrAgent        s             64a   Inz(*blanks)
     d nextpos         s             10i 0 inz(1)
     d retdata         s          32766a
     d retlen          s             10i 0
     d ErrDta          s          32766a
     d SavDta          s                   Like(ErrDta)
     d StartPos        s              7  0 INZ(*ZEROS)
     d EndPos          s              7  0 INZ(*ZEROS)
     d testscop        s              1a
     d smhunit         s              6a
     d smhdate         s              7  0
     d smhtime         s              6  0
      /free

TEMP     mhunit = ' TBAG1';
TEMP     mhdate = 2020120;
TEMP     mhtime = 192346;
         smhunit = mhunit;
         smhdate = mhdate;
         smhtime = mhtime;

         chain mhunit units;
         if %found(units);
           driverId = undr1;

AR001    exsr getmsgbody;
  |        clear m;
  |        dow message = *blanks And m < 3;
  |          dlycmd = %trim(dlycmd11) + %trim('1') + dlycmd12;
  |          // Delay 1 second to allow detail writes.
  |          callp DLYJOB(dlycmd:%size(dlycmd));
  |          exsr getmsgbody;
  |          m +=1;
  |        enddo;
  |
  |      ffMessage = message;
AR001    deepLink = *blanks;

         driver1 = %trim(undr1);
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

         yajl_genOpen(*OFF);  // use *ON for easier to read JSON
                              //    *OFF for more compact JSON
         yajl_beginObj();
           yajl_addChar('message':%trim(FFmessage));
           if DeepLink <> *blanks;
             yajl_addChar('deeplink_id':%trim(DeepLink));
             yajl_addChar('deeplink_type':'macro');
           endif;

           yajl_beginArray('recipients');
             yajl_addChar(%trim(driverId));
             if driverId1 <> *blank;
               yajl_addChar(%trim(driverId1));
             endif;
             if driverId2 <> *blank;
               yajl_addChar(%trim(driverId2));
             endif;
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

         myJSON = jsonString;

        //  Once you have it in a string, you can send it to the HTTP server.
        //  Use HTTP_setCCSIDs to tell HTTPAPI to trasnlate it to UTF-8 (CCSID 1208),
        //  and then use HTTPAPI's http_post() routine to do the POST operation:

        http_setCCSIDs( 1208: 0 );
        HTTP_debug(*off);
        //HTTP_SetCCSIDs(1208:1208);
        HTTP_SetFileCCSID(1208);

        // Also need code here to set up 'additional headers'
          http_xproc( HTTP_POINT_ADDL_HEADER
                      : %paddr(add_headers) );
          monitor;
          open pltintp;
          read pltintp;
          on-error;
          read pltintp;
          close pltintp;
          endmon;

        Server = %trim(%trim(pltinturl) + %trim(pltitmsgep));

AR001      //write to workflow retry queue on request.
  |        setll (smhunit:smhdate:smhtime) plRetryQl5;
  |        if not %equal(plRetryQl5);
  |          clear rplRetryQ;
  |          plqtype = 'FFMSG';
  |          plcrffu = smhunit;
  |          plcrffd = smhdate;
  |          plcrfft = smhtime;
  |          plqsend = %char(%timestamp(ts):*ISO);
  |          write rplRetryQ;
AR037      endif;

       //?Send web service request to platform science
       rc=http_url_post_raw(%trim(Server)
                      : %addr( myJSON : *data )
                      : %len( myJSON )
                      : 1
                      : %paddr('INCOMING')
                      : HTTP_TIMEOUT
                      : HTTP_USERAGENT
                      : 'application/json' );

       //On error, call api to generate hard error.
       if rc = -1;
     C                   CALL      'PLERRORC'                                   Text format
       endif;

       //?If no error, Convert the data we just received to EBCDIC
       if retlen > 1;
             //Translate(retlen: retdata: 'QTCPEBC');
               filename = %trim(unord#) + 'MSG';
               monitor;
                 cpylnk(filename);
                 on-error;
               endmon;
AR001  else;
  |      //remove from workflow retry queue on success request.
  |      chain (smhunit:smhdate:smhtime) plRetryQl5;
  |      if %found(plRetryQl5);
  |        delete rplRetryQ;
AR001    endif;
       endif;

         StartPos  = %scan('access_token':retdata);
         if StartPos <> 0;
          StartPos = StartPos + 15;
          EndPos   = (retlen - StartPos) - 1;
                       SavDta = %trim(%subst(retdata:StartPos:EndPos));
         EndIf;
       EndIf;

       *inlr = *on;

       //-------------------------------------------------------------
       //- get message body -----------------------
       //-------------------------------------------------------------
AR001    begsr getmsgbody;
  |        clear message;
  |        clear messageA;
  |        x = 0;
  |        setll (mhunit:mhdate:mhtime:'O') mcmsgd;
  |        reade (mhunit:mhdate:mhtime:'O') mcmsgd;
  |        dow %eof(mcmsgd) = *off;
  |          x = x + 1;
  |          messageA(x) = %trim(mdmsgs);
  |          reade (mhunit:mhdate:mhtime:'O') mcmsgd;
  |        enddo;
  |
  |  C                   movea     messageA      message
AR001    endsr;

       //----------------------------------------------------------------------
       //----------------------------------------------------------------------
     P add_headers     B
     D                 PI
     D   headers                  32767a   varying
     D CRLF            C                   x'0d25'
     D token           s           1224
     D scope           s             30
        //Content-Type:application/json
        //api-version:2.0
        //Authorization:Bearer <token>
        /free
          // code to calculate 'token' should go here.
           scope = '"messaging"';
           chain(n) scope plscope;
           if %found(plscope) = *on;
           token = plttoken;
           else;
           pltauthr(scope: token);
           endif;

          //headers = 'Content-Type: application/json' + CRLF
            headers = 'api-version: 2.0' + CRLF
                    + 'Authorization: Bearer ' + token + CRLF;
        /end-free
     P                 E
       //
       //Incoming   - receives the raw data returned in the web service request
       //
       //This procedure is called from within the 'black box' of the 'http_url_
       //Notice the pointer address of the 5th input parameter on the call of '
       //This procedure must be available to the 'black box', but not included
       //therefore it is found here.
       //
       //----------------------------------------------------------------------
     P incoming        B

       //?procedure parameters
     D incoming        PI            10I 0
     D   descriptor                  10I 0 value
     D   myJson                    8192A   options(*varsize)
     D   datalen                     10I 0 value


       //?Make sure we don't overflow the string:
      /FREE
          retlen = (nextpos + datalen) - 1;
          if retlen > %size(retdata);
                  datalen=datalen-(%size(retdata)-retlen);
          endif;

         //  If there is nothing to write, return THAT...
          if datalen < 1;
                  return 0;
          endif;

         //  Here we add any data sent to the end of our 'retdata' string:
          %subst(retdata: nextpos) =
            %subst(myJson:1:datalen);
          nextpos = nextpos + datalen;

         //  We always return the amount of data that we wrote.   Note
         //   that if http-api sees that we didn't write as much data as
         //   it sent us, it'll abort the process with an error message.
          return datalen;
      /END-FREE
     P                 E
