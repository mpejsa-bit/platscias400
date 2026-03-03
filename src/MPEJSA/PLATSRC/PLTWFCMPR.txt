     h DftActGrp(*No) ActGrp(*New) BndDir('LIBHTTP/HTTPAPI')
     h FixNbr(*Zoned) Option(*NoDebugIo:*Srcstmt) Debug(*Yes)
     h BNDDIR('YAJL') DECEDIT('0.')
     h alwnull(*USRCTL)

     fpltintp   if   e           k disk    usropn
     fplscope   if   e           k disk
      /include yajl_h
      /copy libhttp/qrpglesrc,httpapi_h

      * This program's Procedure Prototype
     dpltwfcmpr        PR
     d                               10a
     d                               30a

      * This program's Procedure Interface
     dpltwfcmpr        PI
     djobId                          10a
     djobRsn                         30a

       //?procedure prototypes
     d translate       PR                  ExtPgm('QDCXLATE')
     d   length                       5P 0 const
     d   myJson                   32766A   options(*varsize)
     d   table                       10A   const

     d pltauthr        PR                  ExtPgm('PLTAUTHR')
     d   scope                       30
     d   token                     1224

     d rtvtimz         PR                  ExtPgm('RTVTIMZ')
     d   offset                       2a

     d cpylnk          PR                  ExtPgm('PLCPYLNK')
     d  filename                     10a

     d timeUTC         DS
     d ccyy                           4A
     d dash1                          1A   inz('-')
     d mm                             2A
     d dash2                          1A   inz('-')
     d dd                             2A
     d dash3                          1A   inz('-')
     d hh                             2a
     d period1                        1A   inz('.')
     d min                            2a
     d period2                        1A   inz('.')
     d sec                            2a

     d UTCendSys       DS
     d UTCendN                        1a   inz('-')
     d UTCendHH                       2a   inz('06')
     d UTCendNColon                   1a   inz(':')
     d UTCendNM                       2a   inz('00')

     d offset          S              2a
     d custTZ          S              2a
     d jsonString      s          65535a
     d myJSON          S          65535a   varying
     d filename        s             10a
     d RC              S             10I 0
     D sendStr         s               a   len(16000000) varying
     D respStr         s               a   len(16000000) varying
     d Server          S            256a
     d UsrAgent        S             64A   Inz(*blanks)
     d nextpos         S             10I 0 inz(1)
     d retdata         S          32766A
     d retlen          S             10I 0
     d ErrDta          S          32766a
     d SavDta          S                   Like(ErrDta)
     d StartPos        S              7  0 INZ(*ZEROS)
     d EndPos          S              7  0 INZ(*ZEROS)
     d UTCFormat       s             25a
     d UTCend          s              6a   inz('-08:00')
     d colon           s              1a   inz(':')
     d T               s              1a   inz('T')
     d TS              s               z
     d timestamp       s             26  0
     d timestampChar   s             26a
TEMP d pltfuelflg      s              1a


        TS = %timestamp();
        timestampChar = %char(%timestamp(TS):*ISO);
        timeUTC = timestampChar;
        period1 = colon;
        period2 = colon;
        dash3   = T;
        UTCformat = timeUTC + UTCendSys;

          yajl_genOpen(*ON);  // use *ON for easier to read JSON
                              // use *OFF for more compact JSON
            yajl_beginObj();
              yajl_addChar('status':'tms_completed');
              yajl_addChar('completed_at':UTCFormat);
              yajl_addChar('id_type':'external');

              if jobRsn > *blanks;
                yajl_beginArray('meta');
                  yajl_addChar(%trim(jobRsn));
                yajl_endArray();
              endif;
            yajl_endObj();

          jsonString = yajl_copyBufStr();

        //  Once you have it in a string, you can send it to the HTTP server.
        //  Use HTTP_setCCSIDs to tell HTTPAPI to trasnlate it to UTF-8 (CCSID 1208),
        //  and then use HTTPAPI's http_post() routine to do the POST operation:

        HTTP_debug(*on);
        http_setCCSIDs( 1208: 0 );
        HTTP_SetFileCCSID(1208);

        // Also need code here to set up 'additional headers'
        http_xproc( HTTP_POINT_ADDL_HEADER
                    : %paddr(add_headers) );

        // jobid = unord# +'-'+ undisp + '/?id_type=external';
        server = %trim('https://mvt.pltsci.com/api/jobs/'
                       +%trim(jobId)+'/status');

        myJSON = jsonString;

             //this is an update/do a put not a post
             sendStr = %trim(myJson);
             rc=http_req( 'PATCH'
                        : %trim(Server)
                        : *omit
                        : respStr
                        : *omit
                        : sendStr
                        : 'application/json' );

             //On error, call api to generate hard error.
             if rc = -1;
     C                   CALL      'PLERRORC'
             endif;

             //if no error, Convert the data to EBCDIC
             if rc <> 1;
               //Translate(retlen: retdata: 'QTCPEBC');
               filename = %trim(%subst(jobId:1:7)) + 'WFU';
               monitor;
                 cpylnk(filename);
                 on-error;
               endmon;
             endif;
          yajl_genClose();

       *inlr = *on;

        //---------------------------------------------------------------------
        //     *inzsr;
        //---------------------------------------------------------------------
        begsr *inzsr;
          monitor;
          open pltintp;
          read pltintp;
          on-error;
          // disable driver team interface
          pltteamflg = '0';
          // disable fuel stops interface
          pltfuelflg = '0';
          close pltintp;
          endmon;

          rtvtimz(offset);
          UTCEndHH = offset;
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
       //----------------------------------------------------------------------
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
     P                 E
      /END-FREE
