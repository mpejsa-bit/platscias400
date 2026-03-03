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
      * This program accepts a preplanned order and an optional     *
      * driver code as input, and deletes the corresponding         *
      * preplanned order only.                                      *
      *
      *  Program Modification Index
      *
      *    Date    Mod    Who    Description
      *  --------  -----  -----  ------------------------------------
      *  12/06/19   R001  JB/PS  Add optional passed parameter for
      *                          driver code, with new url to execute
      *                          as driverIdPreplan.
      *  04/03/20   R002  JB/PS  Send preplan to team drivers.        *
      *****************************************************************
     H DftActGrp(*No) ActGrp(*New) BndDir('LIBHTTP/HTTPAPI')
     H FixNbr(*Zoned) Option(*NoDebugIo:*Srcstmt) Debug(*Yes)
     H BNDDIR('YAJL') DECEDIT('0.')
     H alwnull(*USRCTL)

     Fplscope   iF   E           k DISK
AR002Fpltintp   if   E           k DISK    usropn
AR002Funitsdr1  if   e           k disk
AR002Funitsdr2  if   e           k disk    rename(runitmas:dr2)
      /include yajl_h
      /copy libhttp/qrpglesrc,httpapi_h

      * This program's Procedure Prototype
     Dpltppcanr        PR
     d                                7a
AR001d                                6a   options(*nopass)

      * This program's Procedure Interface
     Dpltppcanr        PI
     d preplan                        7a
AR001d drvCode                        6a   options(*nopass)

       //?procedure prototypes
     D translate       PR                  ExtPgm('QDCXLATE')
     D   length                       5P 0 const
     D   myJson                   32766A   options(*varsize)
     D   table                       10A   const
     D pltauthr        PR                  ExtPgm('PLTAUTHR')
     D   scope                       30
     D   token                     1224


     D jsonString      s          65535a
     D myJSON          S          65535a   varying
     D RC              S             10I 0
     D response        S           1000a   varying
CR002d Server          S            256a   Inz(*blanks)
     d UsrAgent        S             64A   Inz(*blanks)
     D nextpos         S             10I 0 inz(1)
     D retdata         S          32766A
     D retlen          S             10I 0
     d ErrDta          S          32766a
     d SavDta          S                   Like(ErrDta)
     D StartPos        S              7  0 INZ(*ZEROS)
     D EndPos          S              7  0 INZ(*ZEROS)
AR002dpltfuelflg       s              1a
     d* jobID           S             28A   Inz(*blanks)

        //  Once you have it in a string, you can send it to the HTTP server.
        //  Use HTTP_setCCSIDs to tell HTTPAPI to trasnlate it to UTF-8 (CCSID 1208),
        //  and then use HTTPAPI's http_post() routine to do the POST operation:
        HTTP_debug(*on);
        //HTTP_SetCCSIDs(1208:1208);
        http_setCCSIDs( 1208: 0 );
        HTTP_SetFileCCSID(1208);

        // Also need code here to set up 'additional headers'
          http_xproc( HTTP_POINT_ADDL_HEADER
                      : %paddr(add_headers) );

AR002   clear undr2;
  |     if pltteamflg = '1' And %parms() = 2;
  |       chain drvCode unitsdr1;
  |       if not %found(unitsdr1);
  |         chain drvCode unitsdr2;
  |       endif;
AR002   endif;

AR002   //Execute Team Drivers only if interface enabled.
AR002   if pltteamflg = '1' and undr2 > *blanks;
AR002   Server = %trim('https://mvt.pltsci.com/api/preplan/'
AR002                  +preplan+'/team/'+preplan+'_'+%trim(ununit));

AR002   elseif %parms() = 2;
DR001   //if %parms() = 2;
AR001     Server = %trim('https://mvt.pltsci.com/api/drivers/'+
AR001                     %trim(drvCode)+'/preplan/'+preplan);
AR001   else;
          Server = %trim('https://mvt.pltsci.com/api/preplan/'+preplan);
AR001   endif;

        monitor;
        response = http_string('DELETE': server);
        on-error;
        retlen = 0;
        endmon;

       //?If no error, Convert the data we just received to EBCDIC
       if retlen > 1;
               Translate(retlen: retdata: 'QTCPEBC');
       endif;

        *inlr = *on;

        //---------------------------------------------------------------------
        //     *inzsr;
        //---------------------------------------------------------------------
AR002   begsr *inzsr;
  |       monitor;
  |       open pltintp;
  |       read pltintp;
  |       on-error;
  |       // disable driver team interface
  |       pltteamflg = '0';
  |       // disable fuel stops interface
  |       pltfuelflg = '0';
  |       close pltintp;
  |       endmon;
AR002   endsr;

       //----------------------------------------------------------------------
       //----------------------------------------------------------------------
     P add_headers     B
     D                 PI
     D   headers                  32767a   varying
     D CRLF            C                   x'0d25'
     D token           s           1224
     D scope           s             30
        /free
          // code to calculate 'token' should go here.
           scope = '"workflow"';

           chain(n) scope plscope;
           if %found(plscope) = *on;
           token = plttoken;
           else;
           pltauthr(scope: token);
           endif;

            headers = 'api-version: 2.0' + CRLF
                    + 'Authorization: Bearer ' + token + CRLF;
        /end-free
     P                 E
