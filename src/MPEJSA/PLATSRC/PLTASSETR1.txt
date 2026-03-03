     H DftActGrp(*No) ActGrp(*New) BndDir('LIBHTTP/HTTPAPI')
     H FixNbr(*Zoned) Option(*NoDebugIo:*Srcstmt) Debug(*Yes)
     H BNDDIR('YAJL') DECEDIT('0.')
     H alwnull(*USRCTL)

     Funits     iF   E           k DISK

      /include yajl_h
      /copy libhttp/qrpglesrc,httpapi_h

      * This program's Procedure Prototype
     Dpltassetr1       PR
     d                                6a

      * This program's Procedure Interface
     Dpltassetr1       PI
     dtruck#                          6a

       //?procedure prototypes

     D incoming        PR            10I 0
     D                               10I 0 value
     D                             8192A   options(*varsize)
     D                               10I 0 value
     D translate       PR                  ExtPgm('QDCXLATE')
     D   length                       5P 0 const
     D   myJson                   32766A   options(*varsize)
     D   table                       10A   const
     D pltauthrp       PR                  ExtPgm('PLTAUTHR')
     D   scope                       30
     D   token                     1224


     D jsonString      s          65535a
     D myJSON          S          65535a   varying
     D RC              S             10I 0
     D errMsg          s            500a   varying
     D response        S           1000a   varying
     d Server          S            256a
     d UsrAgent        S             64A   Inz(*blanks)
     D nextpos         S             10I 0 inz(1)
     D retdata         S          32766A
     D retlen          S             10I 0
     d ErrDta          S          32766a
     d SavDta          S                   Like(ErrDta)
     D StartPos        S              7  0 INZ(*ZEROS)
     D EndPos          S              7  0 INZ(*ZEROS)

        chain truck# units;
        if %found(units) = *off;
        if unser <> *blanks;
        if undel <> 'D';
        exsr buildjson;
           myJSON = jsonString;
        exsr sendit;
        endif;
        endif;
        endif;

        *inlr = *on;



       begsr sendit;
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

       // Server = %trim('https://mvt.platformscience.com/api/admin/assets');
        Server = %trim('https://mvt.pltsci.com/api/admin/assets');
       //?Send web service request to PlatForm Science
       rc=http_url_post_raw(%trim(Server)
                      : %addr( myJSON : *data )
                      : %len( myJSON )
                      : 1
                      : %paddr('INCOMING')
                      : HTTP_TIMEOUT
                      : HTTP_USERAGENT
                      : 'application/json' );

       //?If no error, Convert the data we just received to EBCDIC
       if retlen > 1;
               Translate(retlen: retdata: 'QTCPEBC');
       endif;

       endsr;


       //--------------------------------------------------------------------
       //in here we are building a json for adding the assets-------------
       //--------------------------------------------------------------------
        begsr buildJson;
         yajl_genOpen(*ON);  // use *ON for easier to read JSON
                              //    *OFF for more compact JSON

         yajl_beginArray();
         yajl_beginObj();
           yajl_addChar('type':'power_unit');
           yajl_addChar('external_id':%trim(ununit));
           yajl_addChar('hardware_id':%trim(unser));
           if unmake = 'INTERNATIONA';
           yajl_addChar('make':%trim('INTERNATIONAL'));
           else;
           yajl_addChar('make':%trim(unmake));
           endif;
           yajl_addChar('model':' ');

           yajl_addChar('year':%trim(unyear));

                yajl_beginObj('license_plate');
                 yajl_addChar('number':%trim(unplat));
                 yajl_addChar('jurisdiction':%trim(unplst));
                yajl_endObj();

          yajl_endObj();
          yajl_endArray();



       jsonString = yajl_copyBufStr();
            yajl_saveBuf('/tmp/example.json': errMsg);

          yajl_genClose();
        endsr;
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
           scope = '"admin"';

           pltauthrp(scope: token);

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

          return datalen;
      /END-FREE
     P                 E
