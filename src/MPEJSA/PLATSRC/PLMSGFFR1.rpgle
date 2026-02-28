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
      * This program accepts a unit identifier and formatted date   *
      * and time as input, and deletes the corresponding workflow    *
      * job only.                                                   *
      *                                                               *
      *  Program Modification Index                                   *
      *                                                               *
      *    Date    Mod    Who    Description                          *
      *  --------  -----  -----  -------------------------------------*
      *  07/13/20   R001  JB/PS  Log driver message errors as 'FFM'   *
      *  07/17/20   R002  JB/PS  Capture message feedback headers.    *
      *                                                               *
      *****************************************************************
     H DftActGrp(*No) ActGrp(*New) BndDir('LIBHTTP/HTTPAPI')
     H FixNbr(*Zoned) Option(*NoDebugIo:*Srcstmt) Debug(*Yes)

     Fpltintp   iF   E           k DISK    usropn
     Fplscope   iF   E           k DISK
AR002Fpldrvhdrp uF a E           k DISK
      /copy libhttp/qrpglesrc,httpapi_h

      * This program's Procedure Prototype
     Dplmsgffr1        PR
     D                             5000

      * This program's Procedure Interface
     Dplmsgffr1        PI
     DjsonString                   5000

AR001D cpylnk          PR                  ExtPgm('PLCPYLNK')
AR001D  filename                     10a

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


     D myJSON          S          65535a   varying
     D RC              S             10I 0
     d Server          S            256a
     d UsrAgent        S             64A   Inz(*blanks)
     D nextpos         S             10I 0 inz(1)
     D retdata         S          32766A
     D retlen          S             10I 0
     d ErrDta          S          32766a
     d SavDta          S                   Like(ErrDta)
     D StartPos        S              7  0 INZ(*ZEROS)
     D EndPos          S              7  0 INZ(*ZEROS)
     D testscop        S              1a
AR001D ts              s               z
AR001D filename        s             10a
AR001D driverId        s             10a
AR002D externalId      s            128a
AR002D subject         s            128a
     D RETOCC          S              7  0 INZ(*ZEROS)
     D E               S              7  0 Inz(*zeros)
     D L               S              7  0 Inz(*zeros)
     D S               S              7  0 Inz(*zeros)

        /free
           myJSON = jsonString;


        //  Once you have it in a string, you can send it to the HTTP server.
        //  Use HTTP_setCCSIDs to tell HTTPAPI to trasnlate it to UTF-8 (CCSID 1208),
        //  and then use HTTPAPI's http_post() routine to do the POST operation:
        //
        //

AR001  driverId= 'Unknown';
  |    retocc = %scan('"recipients":':jsonString);
  |    if retocc > 0;
  |      S = retocc + 15;
  |      E = %scan('"':jsonString:S);
  |      L = E - S;
  |      monitor;
  |        driverId= %trim(%subst(jsonString:S:L));
  |      on-error;
  |      endmon;
AR001  endif;

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

       //If error, Convert the data we just received to EBCDIC
       if retlen > 1;
AR001    if rc > 1;
  |        translate(retlen: retdata: 'QTCPEBC');
  |        monitor;
  |          cpylnk(filename);
  |        on-error;
AR001      endmon;
AR002    else;
  |        clear externalId;
  |        clear subject;
  |        translate(retlen: retdata: 'QTCPEBC');
  |        retocc = %scan('"external_id":':retdata);
  |        if retocc > 0;
  |          S = retocc + 15;
  |          E = %scan('"':retdata:S);
  |          L = E - S;
  |          monitor;
  |            externalId= %trim(%subst(retdata:S:L));
  |          on-error;
  |          endmon;
  |        endif;
  |        retocc = %scan('"subject":':retdata);
  |        if retocc > 0;
  |          S = retocc + 11;
  |          E = %scan('"':retdata:S);
  |          L = E - S;
  |          monitor;
  |            subject= %trim(%subst(retdata:S:L));
  |          on-error;
  |          endmon;
  |        endif;
  |        //save external_Id and subject to driver table.
  |        if subject > *blanks Or externalId > *blanks;
  |          chain driverId pldrvhdrp;
  |          if %found(pldrvhdrp);
  |            plhdrsbj = %trim(subject);
  |            plhdrxid = %trim(externalId);
  |            update rpldrvhdr;
  |          else;
  |            plhdrdrv = driverId;
  |            plhdrsbj = %trim(subject);
  |            plhdrxid = %trim(externalId);
  |            write rpldrvhdr;
  |          endif;
  |        endif;
AR002    endif;
       endif;

          StartPos  = %scan('access_token':retdata);
       if StartPos <> 0;
          StartPos = StartPos + 15;
          EndPos   = (retlen - StartPos) - 1;
                       SavDta = %trim(%subst(retdata:StartPos:EndPos));
       EndIf;
        *inlr = *on;
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
