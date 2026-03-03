     H DftActGrp(*No) ActGrp(*New) BndDir('LIBHTTP/HTTPAPI')
     H FixNbr(*Zoned) Option(*NoDebugIo:*Srcstmt) Debug(*Yes)
     H BNDDIR('YAJL') DECEDIT('0.')
     H alwnull(*USRCTL)

     Fplscope   iF   E           k DISK
      /include yajl_h
      /copy libhttp/qrpglesrc,httpapi_h

      * This program's Procedure Prototype
     Dpltwfcanr        PR
     d                               28a

      * This program's Procedure Interface
     Dpltwfcanr        PI
     djobid                          28a

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
     d Server          S            256a
     d UsrAgent        S             64A   Inz(*blanks)
     D nextpos         S             10I 0 inz(1)
     D retdata         S          32766A
     D retlen          S             10I 0
     d ErrDta          S          32766a
     d SavDta          S                   Like(ErrDta)
     D StartPos        S              7  0 INZ(*ZEROS)
     D EndPos          S              7  0 INZ(*ZEROS)
     d* jobID           S             28A   Inz(*blanks)



        //  Once you have it in a string, you can send it to the HTTP server.
        //  Use HTTP_setCCSIDs to tell HTTPAPI to trasnlate it to UTF-8 (CCSID 1208),
        //  and then use HTTPAPI's http_post() routine to do the POST operation:

        HTTP_debug(*off);
        //HTTP_SetCCSIDs(1208:1208);
        http_setCCSIDs( 1208: 0 );
        HTTP_SetFileCCSID(1208);

        // Also need code here to set up 'additional headers'
          http_xproc( HTTP_POINT_ADDL_HEADER
                      : %paddr(add_headers) );

       // jobid = unord# +'-'+ undisp + '/?id_type=external';
        Server = %trim('https://mvt.pltsci.com/api/jobs/'+jobid);

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
